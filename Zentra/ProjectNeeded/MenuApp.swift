import SwiftUI
import LocalAuthentication
import Foundation
import UserNotifications
import UIKit
import ActivityKit

class PushNotificationDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        print("✅ Device Token: \(token)")
        // TODO: Device Token an Server übermitteln
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Fehler bei Push-Registrierung: \(error.localizedDescription)")
    }
    // Empfangen von Pushes, wenn App im Vordergrund ist
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge]) // Push im Vordergrund zeigen
    }
    // Handling von Taps auf Pushes
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Push empfangen/Tap: \(response.notification.request.content.userInfo)")
        completionHandler()
    }
    
}

@main
struct MenuApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("rememberLogin") var rememberLogin: Bool = false

    @UIApplicationDelegateAdaptor(PushNotificationDelegate.self) var pushDelegate
    
    @StateObject var tcf = TCF()
    @StateObject var discordWebhookManager = DiscordWebhookManager()

    @State private var selectedPage: String? = nil
    @State private var isUnlocked = false
    @State private var didSendFirstLaunchActivation = UserDefaults.standard.bool(forKey: "didSendFirstLaunchActivation")
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup: Bool = false
    @AppStorage("authToken") private var authToken: String = ""

    init() {
        // Don't reset login status on app start
        // Login status should persist if token exists
        // Only reset if explicitly logged out
    }
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isUnlocked {
                    if hasCompletedSetup {
                        VStack {
                            MainView(selectedPage: $selectedPage)
                                .environmentObject(discordWebhookManager)
                                .transition(.identity)
                        }
                        .environmentObject(tcf)
                        .environmentObject(discordWebhookManager)
                    } else {
                        SetupView(hasCompletedSetup: $hasCompletedSetup)
                            .environmentObject(tcf)
                            .transition(.opacity)
                    }
                } else {
                    Color.black.opacity(0.9)
                        .ignoresSafeArea()
                        .overlay(
                            VStack(spacing: 20) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)

                                Text("Authentifizierung erforderlich...")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        )
                }
            }
            .environmentObject(tcf)
            .environmentObject(discordWebhookManager)
            .onAppear {
                authenticateIfNeeded()

                if !didSendFirstLaunchActivation {
                    // Erfasse Gerätenamen beim ersten Start
                    let deviceName = UIDevice.current.name
                    UserDefaults.standard.set(deviceName, forKey: "deviceName")
                    print("✅ Gerätename erfasst: \(deviceName)")
                    
                    Task {
                        await discordWebhookManager.sendProductActivationEmbed(deviceName: deviceName)
                        UserDefaults.standard.set(true, forKey: "didSendFirstLaunchActivation")
                        didSendFirstLaunchActivation = true
                    }
                }
                
                UNUserNotificationCenter.current().delegate = pushDelegate
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    print("Push permission: \(granted), Error: \(String(describing: error))")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .background:
                    break
                case .active:
                    // Only validate token if user is logged in and has a token
                    // Don't validate on every app start to avoid unnecessary logouts
                    if isLoggedIn && !authToken.isEmpty {
                        // Validate in background, but don't block UI
                        Task.detached(priority: .background) {
                            await validateTokenAndLogoutIfNeeded()
                        }
                    }
                    break
                default:
                    break
                }
            }
        }
    }

    func authenticateIfNeeded() {
        let useBiometrics = UserDefaults.standard.bool(forKey: "useBiometrics")
        if !useBiometrics {
            isUnlocked = true
            return
        }

        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "App entsperren"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        print("✅ Authentifizierung erfolgreich")
                        isUnlocked = true
                    } else {
                        print("❌ Authentifizierung fehlgeschlagen: \(authError?.localizedDescription ?? "")")
                        // App bleibt gesperrt oder wird geschlossen
                        exit(0)
                    }
                }
            }
        } else {
            print("⚠️ Face ID / Code nicht verfügbar: \(error?.localizedDescription ?? "")")
            isUnlocked = true
        }
    }
    
    /// Validate authentication token and logout if invalid
    /// Only logs out if server explicitly returns 401 (unauthorized)
    /// Keeps user logged in if server is offline or unreachable
    func validateTokenAndLogoutIfNeeded() async {
        guard !authToken.isEmpty else {
            // No token, but don't logout - might be intentional
            return
        }
        
        do {
            let verification = try await ServerManager.shared.verifyToken(authToken)
            
            await MainActor.run {
                if !verification.valid {
                    // Server explicitly says token is invalid (401), logout
                    print("⚠️ Token ungültig (401) - automatischer Logout")
                    isLoggedIn = false
                    currentUsername = ""
                    authToken = ""
                    UserDefaults.standard.set(false, forKey: "rememberLogin")
                } else {
                    print("✅ Token gültig")
                }
            }
        } catch let error as ServerError {
            // Only logout on explicit authentication errors (401)
            switch error {
            case .authenticationError, .httpError(401):
                // Server explicitly says token is invalid, logout
                print("⚠️ Token ungültig (401) - automatischer Logout")
                await MainActor.run {
                    isLoggedIn = false
                    currentUsername = ""
                    authToken = ""
                    UserDefaults.standard.set(false, forKey: "rememberLogin")
                }
            case .httpError(let code):
                // Other HTTP errors (404, 500, etc.) - keep user logged in
                print("⚠️ Token-Validierung fehlgeschlagen (HTTP \(code)) - Login bleibt bestehen")
            default:
                // Server offline or other errors - keep user logged in (token might still be valid)
                print("⚠️ Token-Validierung fehlgeschlagen (Server offline?) - Login bleibt bestehen")
            }
        } catch {
            // Network errors, timeouts, etc. - keep user logged in (server might be temporarily offline)
            print("⚠️ Token-Validierung fehlgeschlagen (Netzwerkfehler?) - Login bleibt bestehen")
        }
    }
}

