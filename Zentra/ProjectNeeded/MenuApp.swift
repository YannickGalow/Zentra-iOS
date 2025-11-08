import SwiftUI
import LocalAuthentication
import Foundation
import UserNotifications
import UIKit
import ActivityKit
import Darwin

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
    @AppStorage("deviceUUID") private var deviceUUID: String = ""

    init() {
        // Load UUID from Keychain on app start (survives app reinstall)
        let keychainService = "com.zentra.deviceUUID"
        let keychainAccount = "deviceUUID"
        
        // If UserDefaults is empty, try to load from Keychain
        if deviceUUID.isEmpty {
            if let keychainUUID = KeychainHelper.shared.read(service: keychainService, account: keychainAccount), !keychainUUID.isEmpty {
                // Restore UUID from Keychain to UserDefaults
                UserDefaults.standard.set(keychainUUID, forKey: "deviceUUID")
                print("✅ Device UUID beim App-Start aus Keychain wiederhergestellt: \(keychainUUID)")
            }
        } else {
            // Ensure UUID is also saved in Keychain (migration for existing installations)
            KeychainHelper.shared.save(deviceUUID, service: keychainService, account: keychainAccount)
        }
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
                    // Generate or retrieve device UUID FIRST - check Keychain first (persists after reinstall)
                    let keychainService = "com.zentra.deviceUUID"
                    let keychainAccount = "deviceUUID"
                    
                    // Try to get UUID from Keychain first (survives app reinstall)
                    if let keychainUUID = KeychainHelper.shared.read(service: keychainService, account: keychainAccount), !keychainUUID.isEmpty {
                        deviceUUID = keychainUUID
                        print("✅ Device UUID aus Keychain geladen: \(deviceUUID)")
                    } else if deviceUUID.isEmpty {
                        // Generate new UUID if not found in Keychain or UserDefaults
                        deviceUUID = UUID().uuidString
                        print("✅ Neue Device UUID generiert: \(deviceUUID)")
                    }
                    
                    // IMPORTANT: Save UUID to Keychain (persists after app reinstall) AND UserDefaults (for quick access)
                    // Keychain has priority - it survives app deletion/reinstall
                    KeychainHelper.shared.save(deviceUUID, service: keychainService, account: keychainAccount)
                    UserDefaults.standard.set(deviceUUID, forKey: "deviceUUID")
                    UserDefaults.standard.synchronize()  // Force immediate save
                    
                    // Collect device information
                    let deviceName = UIDevice.current.name
                    // Get actual device model (e.g., "iPhone15,2" instead of just "iPhone")
                    var systemInfo = utsname()
                    uname(&systemInfo)
                    let modelCode = withUnsafePointer(to: &systemInfo.machine) {
                        $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                            String(validatingUTF8: $0)
                        }
                    }
                    let deviceModel = modelCode ?? UIDevice.current.model
                    let iosVersion = UIDevice.current.systemVersion
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                    
                    UserDefaults.standard.set(deviceName, forKey: "deviceName")
                    print("✅ Geräteinformationen erfasst:")
                    print("   - UUID: \(deviceUUID)")
                    print("   - Name: \(deviceName)")
                    print("   - Model: \(deviceModel)")
                    print("   - iOS: \(iosVersion)")
                    
                    // Send activation via server (non-blocking - UUID is already saved)
                    Task {
                        do {
                            print("🔄 Sende Aktivierung an Server...")
                            let response = try await ServerManager.shared.sendDeviceActivation(
                                deviceUUID: deviceUUID,
                                deviceName: deviceName,
                                deviceModel: deviceModel,
                                iosVersion: iosVersion,
                                appVersion: appVersion,
                                buildNumber: buildNumber
                            )
                            
                            // Mark as sent even if Discord failed - UUID is valid
                            await MainActor.run {
                                UserDefaults.standard.set(true, forKey: "didSendFirstLaunchActivation")
                                didSendFirstLaunchActivation = true
                            }
                            
                            if response.success {
                                print("✅ Aktivierung erfolgreich über Server gesendet - UUID: \(deviceUUID)")
                            } else {
                                print("⚠️ Server empfangen, aber Discord-Fehler: \(response.message)")
                                print("✅ UUID wurde trotzdem gespeichert: \(deviceUUID)")
                            }
                        } catch {
                            print("❌ Fehler bei Aktivierung: \(error.localizedDescription)")
                            print("❌ Fehler-Details: \(error)")
                            print("✅ UUID wurde trotzdem gespeichert: \(deviceUUID)")
                            // Mark as sent anyway - UUID is saved and that's what matters
                            await MainActor.run {
                                UserDefaults.standard.set(true, forKey: "didSendFirstLaunchActivation")
                                didSendFirstLaunchActivation = true
                            }
                        }
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

