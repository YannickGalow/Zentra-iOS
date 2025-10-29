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
    @StateObject var languageManager = LanguageManager()
    
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("currentUsername") var currentUsername: String = ""
    
    @AppStorage("didShowLanguageSetup") var didShowLanguageSetup = false
    @AppStorage("selectedLanguage") var selectedLanguage = AppLanguage.system.rawValue

    @UIApplicationDelegateAdaptor(PushNotificationDelegate.self) var pushDelegate
    
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("rememberLogin") var rememberLogin = false

    @StateObject var themeEngine = ThemeEngine()
    @StateObject var discordWebhookManager = DiscordWebhookManager()

    @State private var selectedPage: String? = nil
    @State private var isUnlocked = false
    @State private var didSendFirstLaunchActivation = UserDefaults.standard.bool(forKey: "didSendFirstLaunchActivation")

    init() {
        if !rememberLogin {
            isLoggedIn = false
        }
    }
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isUnlocked {
                    if !didShowLanguageSetup {
                        LanguageSetupView()
                            .environmentObject(themeEngine)
                            .environmentObject(languageManager)
                    } else {
                        ZStack {
                            if isLoggedIn {
                                VStack {
                                    switch selectedPage {
                                    case "settings":
                                        SettingsView(selectedPage: $selectedPage)
                                            .environmentObject(themeEngine)
                                            .environmentObject(discordWebhookManager)
                                            .environmentObject(languageManager)
                                            .transition(.move(edge: .trailing))
                                    default:
                                        MainView(selectedPage: $selectedPage)
                                            .environmentObject(discordWebhookManager)
                                            .environmentObject(languageManager)
                                            .transition(.opacity)
                                    }
                                }
                            } else {
                                LoginView(onLogin: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isLoggedIn = true
                                        selectedPage = nil
                                    }
                                })
                                .environmentObject(languageManager)
                                .transition(.opacity)
                            }
                        }
                        .environmentObject(themeEngine)
                        .environmentObject(discordWebhookManager)
                        .environmentObject(languageManager)
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
            .environmentObject(themeEngine)
            .environmentObject(discordWebhookManager)
            .environmentObject(languageManager)
            .onAppear {
                authenticateIfNeeded()

                if !didSendFirstLaunchActivation {
                    Task {
                        await discordWebhookManager.sendProductActivationEmbed()
                        UserDefaults.standard.set(true, forKey: "didSendFirstLaunchActivation")
                        didSendFirstLaunchActivation = true
                    }
                }
                
                UNUserNotificationCenter.current().delegate = pushDelegate
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    print("Push-Berechtigung: \(granted), Fehler: \(String(describing: error))")
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
                    break
                default:
                    break
                }
            }
            .environmentObject(languageManager)
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
}
