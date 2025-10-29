// LoginView.swift

import SwiftUI

struct LoginView: View {
    var onLogin: (() -> Void)? = nil

    @State private var username = ""
    @State private var password = ""
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("rememberLogin") var rememberLogin = false
    @AppStorage("useBiometrics") var useBiometrics = false
    @AppStorage("currentUsername") var currentUsername: String = ""

    @State private var showPassword = false
    @State private var showError = false

    @State private var showSavePasswordPrompt = false

    @EnvironmentObject var themeEngine: ThemeEngine

    private let keychainService = "com.example.LoginApp"

    var body: some View {
        ZStack {
            themeEngine.colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    Spacer().frame(height: 60)

                    Text("Login")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(themeEngine.colors.text)

                    VStack(spacing: 15) {
                        TextField("Benutzername", text: $username)
                            .textContentType(.username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(themeEngine.colors.accent.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(themeEngine.colors.text)
                            .submitLabel(.next)

                        HStack {
                            Group {
                                if showPassword {
                                    TextField("Passwort", text: $password)
                                        .textContentType(.password)
                                        .foregroundColor(themeEngine.colors.text)
                                } else {
                                    SecureField("Passwort", text: $password)
                                        .textContentType(.password)
                                        .foregroundColor(themeEngine.colors.text)
                                }
                            }
                            .submitLabel(.done)
                            .onSubmit { performLogin() }

                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(themeEngine.colors.text)
                            }
                        }
                        .padding()
                        .background(themeEngine.colors.accent.opacity(0.1))
                        .cornerRadius(10)
                    }

                    Toggle("Login merken", isOn: $rememberLogin)
                        .toggleStyle(SwitchToggleStyle(tint: themeEngine.colors.accent))
                        .foregroundColor(themeEngine.colors.text)

                    // Face ID-Option direkt hier
                    Toggle("Face ID / Code-Schutz aktivieren", isOn: $useBiometrics)
                        .toggleStyle(SwitchToggleStyle(tint: themeEngine.colors.accent))
                        .foregroundColor(themeEngine.colors.text)

                    if showError {
                        Text("Falscher Benutzername oder Passwort")
                            .foregroundColor(themeEngine.colors.error)
                            .font(.footnote)
                    }

                    Button(action: { performLogin() }) {
                        Text("Einloggen")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeEngine.colors.accent)
                            .foregroundColor(themeEngine.colors.background)
                            .cornerRadius(10)
                    }

                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)
                .alert(isPresented: $showSavePasswordPrompt) {
                    Alert(
                        title: Text("Passwort speichern?"),
                        message: Text("Möchten Sie das Passwort für \(username) speichern?"),
                        primaryButton: .default(Text("Speichern"), action: {
                            KeychainHelper.shared.save(password, service: keychainService, account: username)
                            onLogin?()
                        }),
                        secondaryButton: .cancel({
                            onLogin?()
                        })
                    )
                }
            }
        }
    }

    func performLogin() {
        withAnimation {
            if (username == "admin" && password == "1234") || (username == "user" && password == "1234") {
                showError = false
                currentUsername = username
                if rememberLogin {
                    showSavePasswordPrompt = true
                } else {
                    KeychainHelper.shared.delete(service: keychainService, account: username)
                    onLogin?()
                }
            } else {
                showError = true
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { showError = false }
                }
            }
        }
    }
}
