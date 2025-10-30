// LoginView.swift
import SwiftUI

struct LoginView: View {
    var onLogin: (() -> Void)? = nil

    @State private var username = ""
    @State private var password = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("rememberLogin") var rememberLogin: Bool = false
    @AppStorage("useBiometrics") var useBiometrics: Bool = false
    @AppStorage("currentUsername") var currentUsername: String = ""

    @State private var showPassword = false
    @State private var showError = false

    @State private var showSavePasswordPrompt = false

    @EnvironmentObject var themeEngine: ThemeEngine

    private let keychainService = "com.example.LoginApp"

    var body: some View {
        ZStack {
            // Simple static background
            themeEngine.colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 40)

                    VStack(spacing: 8) {
                        Text("Debugger Version")
                            .font(.title2)
                            .foregroundColor(themeEngine.colors.text.opacity(0.8))
                        Text("Login")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(themeEngine.colors.text)
                    }
                    .padding(.bottom, 8)

                    VStack(spacing: 16) {
                        TextField("Username", text: $username)
                            .textContentType(.username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .frame(height: 50)
                            .padding(.horizontal, 16)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.5)
                                    
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    themeEngine.colors.accent.opacity(0.25),
                                                    themeEngine.colors.accent.opacity(0.1),
                                                    themeEngine.colors.accent.opacity(0.15)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.2),
                                                    .white.opacity(0.05)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                            )
                            .foregroundColor(.white.opacity(0.95))
                            .accentColor(themeEngine.colors.accent)
                            .submitLabel(.next)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.5),
                                                themeEngine.colors.accent.opacity(0.6),
                                                .white.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: themeEngine.colors.accent.opacity(0.3), radius: 10, x: 0, y: 5)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

                        HStack(spacing: 12) {
                            Group {
                                if showPassword {
                                    TextField("Password", text: $password)
                                        .textContentType(.password)
                                        .foregroundColor(.white.opacity(0.95))
                                } else {
                                    SecureField("Password", text: $password)
                                        .textContentType(.password)
                                        .foregroundColor(.white.opacity(0.95))
                                }
                            }
                            .submitLabel(.done)
                            .onSubmit { performLogin() }
                            .frame(maxWidth: .infinity)
                            .accentColor(themeEngine.colors.accent)

                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(themeEngine.colors.accent)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.4)
                                    )
                            }
                            .frame(width: 36, height: 36)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.5)
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                themeEngine.colors.accent.opacity(0.25),
                                                themeEngine.colors.accent.opacity(0.1),
                                                themeEngine.colors.accent.opacity(0.15)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.2),
                                                .white.opacity(0.05)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.5),
                                            themeEngine.colors.accent.opacity(0.6),
                                            .white.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: themeEngine.colors.accent.opacity(0.3), radius: 10, x: 0, y: 5)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }

                    VStack(spacing: 12) {
                        Toggle("Remember login", isOn: $rememberLogin)
                            .toggleStyle(SwitchToggleStyle(tint: themeEngine.colors.accent))
                            .foregroundColor(themeEngine.colors.text)
                            .font(.subheadline)

                        Toggle("Enable Face ID / Passcode", isOn: $useBiometrics)
                            .toggleStyle(SwitchToggleStyle(tint: themeEngine.colors.accent))
                            .foregroundColor(themeEngine.colors.text)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                    .padding(.top, 4)

                    if showError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(themeEngine.colors.error)
                            Text("Wrong username or password")
                                .foregroundColor(themeEngine.colors.error)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(themeEngine.colors.error.opacity(0.15))
                        )
                        .padding(.top, 8)
                    }

                    HStack(spacing: 12) {
                        // Login Button
                        Button(action: { performLogin() }) {
                            Text("Login")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .buttonStyle(LoginButtonStyle(
                            backgroundColor: themeEngine.colors.accent,
                            foregroundColor: .white
                        ))

                        // Debug Button - Quick Admin Login
                        Button(action: { debugLogin() }) {
                            Image(systemName: "wrench.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(LoginButtonStyle(
                            backgroundColor: themeEngine.colors.accent.opacity(0.75),
                            foregroundColor: .white
                        ))
                    }
                    .padding(.top, 8)

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .alert(isPresented: $showSavePasswordPrompt) {
                    Alert(
                        title: Text("Save Password?"),
                        message: Text("Do you want to save the password for \(username)?"),
                        primaryButton: .default(Text("Save"), action: {
                            KeychainHelper.shared.save(password, service: keychainService, account: username)
                            onLogin?()
                        }),
                        secondaryButton: .cancel(Text("Cancel"), action: { onLogin?() })
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

    func debugLogin() {
        withAnimation {
            username = "admin"
            password = "1234"
            showError = false
            currentUsername = "admin"
            KeychainHelper.shared.delete(service: keychainService, account: "admin")
            onLogin?()
        }
    }
}

// Custom Button Style for Login Buttons
private struct LoginButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    backgroundColor.opacity(0.9),
                                    backgroundColor.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .opacity(0.2)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.4),
                                .white.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: backgroundColor.opacity(0.4), radius: configuration.isPressed ? 6 : 12, x: 0, y: configuration.isPressed ? 3 : 6)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

