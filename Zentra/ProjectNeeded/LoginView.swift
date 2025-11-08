// LoginView.swift
import SwiftUI

struct LoginView: View {
    var onLogin: (() -> Void)? = nil

    @State private var username = ""
    @State private var password = ""
    @State private var showRegisterView = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("rememberLogin") var rememberLogin: Bool = false
    @AppStorage("useBiometrics") var useBiometrics: Bool = false
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("authToken") var authToken: String = ""  // Store authentication token

    @State private var showPassword = false
    @State private var showError = false
    @State private var errorMessage = "Wrong username or password"
    @State private var errorCode: String? = nil
    @State private var isLoading = false

    @State private var showSavePasswordPrompt = false
    @State private var registrationLimitReached = false
    @State private var isCheckingLimit = false

    @EnvironmentObject var tcf: TCF

    private let serverManager = ServerManager.shared
    private let keychainService = "com.example.LoginApp"
    @AppStorage("deviceUUID") private var deviceUUID: String = ""

    var body: some View {
        ZStack {
            // Simple static background
            tcf.colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 40)

                    VStack(spacing: 8) {
                        Text("Debugger Version")
                            .font(.title2)
                            .foregroundColor(tcf.colors.text.opacity(0.8))
                        Text("Login")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(tcf.colors.text)
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
                                                    tcf.colors.accent.opacity(0.25),
                                                    tcf.colors.accent.opacity(0.1),
                                                    tcf.colors.accent.opacity(0.15)
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
                            .accentColor(tcf.colors.accent)
                            .submitLabel(.next)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.5),
                                                tcf.colors.accent.opacity(0.6),
                                                .white.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: tcf.colors.accent.opacity(0.3), radius: 10, x: 0, y: 5)
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
                            .onSubmit { Task { await performLogin() } }
                            .frame(maxWidth: .infinity)
                            .accentColor(tcf.colors.accent)

                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(tcf.colors.accent)
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
                                                tcf.colors.accent.opacity(0.25),
                                                tcf.colors.accent.opacity(0.1),
                                                tcf.colors.accent.opacity(0.15)
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
                                            tcf.colors.accent.opacity(0.6),
                                            .white.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: tcf.colors.accent.opacity(0.3), radius: 10, x: 0, y: 5)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }

                    VStack(spacing: 12) {
                        Toggle("Remember login", isOn: $rememberLogin)
                            .toggleStyle(SwitchToggleStyle(tint: tcf.colors.accent))
                            .foregroundColor(tcf.colors.text)
                            .font(.subheadline)

                        Toggle("Enable Face ID / Passcode", isOn: $useBiometrics)
                            .toggleStyle(SwitchToggleStyle(tint: tcf.colors.accent))
                            .foregroundColor(tcf.colors.text)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                    .padding(.top, 4)

                    if showError {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(tcf.colors.error)
                                Text(errorMessage)
                                    .foregroundColor(tcf.colors.error)
                            }
                            .font(.subheadline)
                            
                            if let code = errorCode {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 4) {
                                        Text("Fehlercode:")
                                            .foregroundColor(tcf.colors.error.opacity(0.8))
                                        Text(code)
                                            .foregroundColor(tcf.colors.error)
                                            .font(.system(.subheadline, design: .monospaced))
                                            .fontWeight(.semibold)
                                    }
                                    .font(.caption)
                                    
                                    // Extract and display HTTP status code if available
                                    if code.contains("HTTP"), let httpCode = extractHTTPCodeFromErrorCode(code) {
                                        HStack(spacing: 4) {
                                            Text("HTTP Status:")
                                                .foregroundColor(tcf.colors.error.opacity(0.8))
                                            Text("\(httpCode)")
                                                .foregroundColor(tcf.colors.error)
                                                .font(.system(.caption, design: .monospaced))
                                                .fontWeight(.semibold)
                                        }
                                        .font(.caption2)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(tcf.colors.error.opacity(0.15))
                        )
                        .padding(.top, 8)
                    }
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: tcf.colors.accent))
                            Text("Authenticating...")
                                .foregroundColor(tcf.colors.text.opacity(0.7))
                        }
                        .font(.subheadline)
                        .padding(.top, 8)
                    }

                    HStack(spacing: 12) {
                        // Login Button
                        Button(action: { Task { await performLogin() } }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Login")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                        .buttonStyle(LoginButtonStyle(
                            backgroundColor: tcf.colors.accent,
                            foregroundColor: .white
                        ))
                        .disabled(isLoading)

                    }
                    .padding(.top, 8)

                    // Register Link (only show if limit not reached)
                    if !registrationLimitReached {
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(tcf.colors.text.opacity(0.7))
                            Button(action: { showRegisterView = true }) {
                                Text("Register")
                                    .foregroundColor(tcf.colors.accent)
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.subheadline)
                        .padding(.top, 8)
                    } else {
                        VStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(tcf.colors.error.opacity(0.8))
                                Text("Registrierung nicht möglich")
                                    .foregroundColor(tcf.colors.text.opacity(0.8))
                                    .fontWeight(.semibold)
                            }
                            .font(.caption)
                            
                            Text("Aus Sicherheitsgründen (Exploit-Schutz) ist dieses Gerät von weiteren Registrierungen ausgeschlossen.")
                                .font(.caption2)
                                .foregroundColor(tcf.colors.text.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                            
                            Text("Bitte kontaktiere den Support für weitere Informationen.")
                                .font(.caption2)
                                .foregroundColor(tcf.colors.text.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(tcf.colors.error.opacity(0.15))
                        )
                        .padding(.top, 8)
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .sheet(isPresented: $showRegisterView) {
                RegisterView(onRegister: {
                    showRegisterView = false
                    onLogin?()
                }, showLoginView: $showRegisterView)
                    .environmentObject(tcf)
            }
            .task {
                await checkRegistrationLimit()
            }
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
    
    func performLogin() async {
        await MainActor.run {
            isLoading = true
            showError = false
            errorCode = nil
        }
        
        do {
            // Authenticate with server
            let authResponse = try await serverManager.login(username: username, password: password)
            
            await MainActor.run {
                if authResponse.success, let token = authResponse.token, let username = authResponse.username {
                    // Login successful
                    self.authToken = token
                    self.currentUsername = username
                    self.isLoggedIn = true
                    self.showError = false
                    self.isLoading = false
                    
                if rememberLogin {
                        // Save password to keychain
                        KeychainHelper.shared.save(password, service: keychainService, account: username)
                    showSavePasswordPrompt = true
                } else {
                        // Don't save password
                    KeychainHelper.shared.delete(service: keychainService, account: username)
                    onLogin?()
                }
            } else {
                    // Login failed (shouldn't happen with proper server, but handle gracefully)
                    showError = true
                    errorMessage = authResponse.message
                    errorCode = generateErrorCode(errorType: "AUTH_FAILED", username: username, httpStatusCode: 401)
                    isLoading = false
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        conditionalWithAnimation { showError = false }
                    }
                }
            }
        } catch {
            await MainActor.run {
                showError = true
                if let serverError = error as? ServerError {
                    errorMessage = serverError.localizedDescription
                    let httpStatusCode = extractHTTPStatusCode(from: serverError)
                    errorCode = generateErrorCode(errorType: "SERVER_ERROR", username: username, httpStatusCode: httpStatusCode)
                } else {
                    errorMessage = "Connection error. Please check if the server is running."
                    errorCode = generateErrorCode(errorType: "CONNECTION_ERROR", username: username, httpStatusCode: nil)
                }
                isLoading = false
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    conditionalWithAnimation { showError = false }
                }
            }
        }
    }

    /// Extract HTTP status code from ServerError
    private func extractHTTPStatusCode(from error: ServerError) -> Int? {
        switch error {
        case .httpError(let code):
            return code
        case .authenticationError:
            return 401
        case .invalidURL:
            return nil
        case .invalidResponse:
            return nil
        case .decodingError:
            return nil
        }
    }
    
    /// Extract HTTP status code from error code string
    private func extractHTTPCodeFromErrorCode(_ errorCode: String) -> Int? {
        // Extract HTTP code from format: DBG-XXXXX-XXXX-HTTPXXX
        if let httpRange = errorCode.range(of: "HTTP") {
            let httpCodeString = String(errorCode[httpRange.upperBound...])
            return Int(httpCodeString)
        }
        return nil
    }
    
    /// Generate a unique error code for debugging purposes
    private func generateErrorCode(errorType: String, username: String, httpStatusCode: Int?) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let usernameHash = abs(username.hashValue) % 10000
        let errorTypeHash = abs(errorType.hashValue) % 1000
        
        // Format: DBG-XXXXX-XXXX-HTTPXXX (Debugger-Version-ErrorCode-HTTPStatusCode)
        // Example: DBG-12345-6789-HTTP404
        if let statusCode = httpStatusCode {
            return String(format: "DBG-%05d-%04d-HTTP%d", timestamp % 100000, (usernameHash + errorTypeHash) % 10000, statusCode)
        } else {
            // No HTTP status code available (connection error, etc.)
            return String(format: "DBG-%05d-%04d", timestamp % 100000, (usernameHash + errorTypeHash) % 10000)
        }
    }
    
    private func checkRegistrationLimit() async {
        // Get UUID from Keychain or UserDefaults
        let keychainService = "com.zentra.deviceUUID"
        let keychainAccount = "deviceUUID"
        
        var uuidToCheck = deviceUUID
        
        if uuidToCheck.isEmpty {
            if let keychainUUID = KeychainHelper.shared.read(service: keychainService, account: keychainAccount), !keychainUUID.isEmpty {
                uuidToCheck = keychainUUID
            } else if let defaultsUUID = UserDefaults.standard.string(forKey: "deviceUUID"), !defaultsUUID.isEmpty {
                uuidToCheck = defaultsUUID
            }
        }
        
        guard !uuidToCheck.isEmpty else {
            // No UUID yet, allow registration (will be generated)
            await MainActor.run {
                registrationLimitReached = false
            }
            return
        }
        
        do {
            let response = try await serverManager.checkRegistrationLimit(deviceUUID: uuidToCheck)
            
            await MainActor.run {
                registrationLimitReached = response.limit_reached
            }
        } catch {
            // On error, allow registration attempt (server will reject if limit reached)
            await MainActor.run {
                registrationLimitReached = false
            }
        }
    }
}

// Custom Button Style for Login Buttons
private struct LoginButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        let animationsEnabled = UserDefaults.standard.bool(forKey: "animationsEnabled")
        
        return configuration.label
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
            .transaction { transaction in
                if !animationsEnabled {
                    transaction.animation = nil
                }
            }
            .conditionalAnimation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
    
}
