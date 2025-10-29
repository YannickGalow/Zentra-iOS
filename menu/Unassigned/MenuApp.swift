import SwiftUI
import LocalAuthentication
import Foundation

@main
struct MenuApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("rememberLogin") var rememberLogin = false

    @StateObject var themeEngine = ThemeEngine()
    @StateObject var discordWebhookManager = DiscordWebhookManager() // <--- Hinzugefügt

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
                    ZStack {
                        if isLoggedIn {
                            switch selectedPage {
                            case "settings":
                                SettingsView(selectedPage: $selectedPage)
                                    .environmentObject(themeEngine)
                                    .environmentObject(discordWebhookManager) // <--- Hinzugefügt
                                    .transition(.move(edge: .trailing))
                            default:
                                MainView(selectedPage: $selectedPage)
                                    .environmentObject(discordWebhookManager) // <--- Hinzugefügt
                                    .transition(.opacity)
                            }
                        } else {
                            LoginView(onLogin: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isLoggedIn = true
                                    selectedPage = nil
                                }
                            })
                            .transition(.opacity)
                        }
                    }
                    .environmentObject(themeEngine)
                    .environmentObject(discordWebhookManager) // <--- Hinzugefügt
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
            .onAppear {
                BuildCounter.incrementIfNeeded()

                authenticateIfNeeded()

                if !didSendFirstLaunchActivation {
                    Task {
                        await discordWebhookManager.sendProductActivationEmbed()
                        UserDefaults.standard.set(true, forKey: "didSendFirstLaunchActivation")
                        didSendFirstLaunchActivation = true
                    }
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
}

