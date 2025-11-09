// RegisterView.swift
import SwiftUI
import UIKit
import Darwin

struct RegisterView: View {
    var onRegister: (() -> Void)? = nil
    @Binding var showLoginView: Bool

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("authToken") var authToken: String = ""
    @AppStorage("deviceUUID") var deviceUUID: String = ""

    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var errorCode: String? = nil
    @State private var isLoading = false
    @State private var limitReached = false
    @State private var accountCount = 0
    @State private var remainingRegistrations = 3
    @State private var isCheckingLimit = true
    @State private var hasCheckedLimit = false

    @EnvironmentObject var tcf: TCF
    
    private let serverManager = ServerManager.shared

    var body: some View {
        ZStack {
            // Simple static background
            tcf.colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 40)

                    if isCheckingLimit {
                        // Loading state
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: tcf.colors.accent))
                            Text("Checking registration limit...")
                                .font(.subheadline)
                                .foregroundColor(tcf.colors.text.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else if limitReached {
                        // Limit reached - show support message
                        VStack(spacing: 32) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                tcf.colors.error.opacity(0.4),
                                                tcf.colors.error.opacity(0.2),
                                                tcf.colors.error.opacity(0.1),
                                                .clear
                                            ],
                                            center: .center,
                                            startRadius: 15,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 140, height: 140)
                                
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                tcf.colors.error.opacity(0.3),
                                                tcf.colors.error.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 55, weight: .medium))
                                    .foregroundColor(tcf.colors.error)
                            }
                            
                            VStack(spacing: 16) {
                                Text("Registrierung nicht möglich")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(tcf.colors.text)
                                
                                VStack(spacing: 12) {
                                    Text("Aus Sicherheitsgründen (Exploit-Schutz) ist dieses Gerät von weiteren Registrierungen ausgeschlossen.")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(tcf.colors.text.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)
                                        .padding(.horizontal, 8)
                                    
                                    VStack(spacing: 8) {
                                        HStack(spacing: 4) {
                                            Text("Erstellte Accounts:")
                                                .foregroundColor(tcf.colors.text.opacity(0.7))
                                            Text("\(accountCount)/3")
                                                .foregroundColor(tcf.colors.text)
                                                .fontWeight(.semibold)
                                        }
                                        .font(.subheadline)
                                        
                                        HStack(spacing: 4) {
                                            Text("Verbleibend:")
                                                .foregroundColor(tcf.colors.text.opacity(0.7))
                                            Text("\(remainingRegistrations)")
                                                .foregroundColor(tcf.colors.text)
                                                .fontWeight(.semibold)
                                        }
                                        .font(.subheadline)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            
                            VStack(spacing: 16) {
                                Text("Weitere Accounts benötigt?")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(tcf.colors.text)
                                
                                Text("Bitte kontaktiere den Support für weitere Informationen und Unterstützung.")
                                    .font(.system(size: 15))
                                    .foregroundColor(tcf.colors.text.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                                
                                // Support buttons
                                HStack(spacing: 20) {
                                    Button(action: {
                                        if let url = URL(string: "mailto:support@zentra.app") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "envelope.fill")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text("Email")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                    }
                                    .buttonStyle(PrimaryButtonStyle(backgroundColor: tcf.colors.accent, foregroundColor: .white))
                                }
                            }
                            .padding(.top, 8)
                            
                            // Back to login button
                            Button(action: {
                                showLoginView = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Back to Login")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(tcf.colors.text.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                            .buttonStyle(PrimaryButtonStyle(backgroundColor: tcf.colors.accent.opacity(0.2), foregroundColor: tcf.colors.text))
                        }
                        .padding(36)
                        .liquidGlassCard()
                    } else {
                        // Normal registration form
                        VStack(spacing: 8) {
                            Text("Create Account")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(tcf.colors.text)
                            Text("Register to access all features")
                                .font(.subheadline)
                                .foregroundColor(tcf.colors.text.opacity(0.7))
                        }
                        .padding(.bottom, 8)

                    VStack(spacing: 16) {
                        // Username Field
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

                        // Email Field
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
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

                        // Password Field
                        HStack {
                            if showPassword {
                                TextField("Password", text: $password)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Password", text: $password)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(tcf.colors.text.opacity(0.6))
                            }
                        }
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

                        // Confirm Password Field
                        HStack {
                            if showConfirmPassword {
                                TextField("Confirm Password", text: $confirmPassword)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Confirm Password", text: $confirmPassword)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            Button(action: { showConfirmPassword.toggle() }) {
                                Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(tcf.colors.text.opacity(0.6))
                            }
                        }
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
                                    HStack(spacing: 4) {
                                        Text("Fehlercode:")
                                            .foregroundColor(tcf.colors.error.opacity(0.8))
                                        Text(code)
                                            .foregroundColor(tcf.colors.error)
                                            .font(.system(.subheadline, design: .monospaced))
                                            .fontWeight(.semibold)
                                    }
                                    .font(.caption)
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

                    // Register Button
                    Button(action: {
                        print("🔵 Register Button pressed")
                        print("   - isLoading: \(isLoading)")
                        print("   - isFormValid: \(isFormValid)")
                        print("   - username: \(username)")
                        print("   - email: \(email)")
                        print("   - password length: \(password.count)")
                        Task {
                            await performRegister()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Register")
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
                    .disabled(isLoading || !isFormValid)
                    .opacity((isLoading || !isFormValid) ? 0.6 : 1.0)

                    // Login Link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(tcf.colors.text.opacity(0.7))
                        Button(action: { showLoginView = true }) {
                            Text("Login")
                                .foregroundColor(tcf.colors.accent)
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                    }
                    
                    Spacer().frame(height: 40)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .task {
                if !hasCheckedLimit {
                    await checkRegistrationLimit()
                    hasCheckedLimit = true
                }
            }
            .onAppear {
                // Also check on appear in case task didn't run
                if !hasCheckedLimit {
                    Task {
                        await checkRegistrationLimit()
                        hasCheckedLimit = true
                    }
                }
            }
        }
        }
    }
    
    // MARK: - Helper Functions
    
    private var isFormValid: Bool {
        !username.isEmpty && 
        username.count >= 3 &&
        !email.isEmpty && 
        isValidEmail(email) && 
        !password.isEmpty && 
        password.count >= 6 && 
        password == confirmPassword
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func performRegister() async {
        print("🟢 performRegister() called")
        await MainActor.run {
            isLoading = true
            showError = false
            errorCode = nil
        }
        print("🟢 isLoading set to true")

        // Validate form
        guard !username.isEmpty && username.count >= 3 else {
            await MainActor.run {
                showError = true
                errorMessage = "Username must be at least 3 characters"
                isLoading = false
            }
            return
        }

        guard isValidEmail(email) else {
            await MainActor.run {
                showError = true
                errorMessage = "Please enter a valid email address"
                isLoading = false
            }
            return
        }

        guard password.count >= 6 else {
            await MainActor.run {
                showError = true
                errorMessage = "Password must be at least 6 characters"
                isLoading = false
            }
            return
        }

        guard password == confirmPassword else {
            await MainActor.run {
                showError = true
                errorMessage = "Passwords do not match"
                isLoading = false
            }
            return
        }

        // Retrieve device UUID - should already exist from checkRegistrationLimit()
        let keychainService = "com.zentra.deviceUUID"
        let keychainAccount = "deviceUUID"
        
        var finalUUID = deviceUUID
        
        // Always check Keychain first (most reliable, persists after reinstall)
        if let keychainUUID = KeychainHelper.shared.read(service: keychainService, account: keychainAccount), !keychainUUID.isEmpty {
            finalUUID = keychainUUID
            print("✅ Device UUID aus Keychain geladen (RegisterView performRegister): \(finalUUID)")
        } else if finalUUID.isEmpty {
            // Fallback: check UserDefaults
            if let defaultsUUID = UserDefaults.standard.string(forKey: "deviceUUID"), !defaultsUUID.isEmpty {
                finalUUID = defaultsUUID
                print("✅ Device UUID aus UserDefaults geladen (RegisterView performRegister): \(finalUUID)")
            } else {
                // Last resort: generate new UUID (should rarely happen if checkRegistrationLimit was called)
                finalUUID = UUID().uuidString
                print("⚠️ Neue Device UUID generiert (RegisterView performRegister): \(finalUUID)")
            }
        }
        
        // Ensure UUID is saved to both Keychain and UserDefaults
        await MainActor.run {
            deviceUUID = finalUUID
            KeychainHelper.shared.save(finalUUID, service: keychainService, account: keychainAccount)
            UserDefaults.standard.set(finalUUID, forKey: "deviceUUID")
            UserDefaults.standard.synchronize()
        }

        // Collect device information
        let deviceName = UIDevice.current.name
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

        do {
            print("🟢 Calling serverManager.register()...")
            print("   - Server URL: \(ServerManager.shared.serverURL)")
            print("   - Username: \(username)")
            print("   - Email: \(email)")
            print("   - Device UUID: \(finalUUID)")
            
            let response = try await serverManager.register(
                username: username,
                email: email,
                password: password,
                deviceUUID: finalUUID,
                deviceName: deviceName,
                deviceModel: deviceModel,
                iosVersion: iosVersion,
                appVersion: appVersion,
                buildNumber: buildNumber
            )

            print("🟢 Server response received:")
            print("   - success: \(response.success)")
            print("   - message: \(response.message ?? "nil")")
            print("   - token: \(response.token != nil ? "present" : "nil")")

            if response.success, let token = response.token {
                print("✅ Registration successful!")
                await MainActor.run {
                    self.authToken = token
                    self.currentUsername = username
                    self.isLoggedIn = true
                    self.showError = false
                    self.isLoading = false
                    onRegister?()
                }
            } else {
                print("❌ Registration failed: \(response.message ?? "Unknown error")")
                await MainActor.run {
                    showError = true
                    errorMessage = response.message ?? "Registration failed"
                    isLoading = false
                }
            }
        } catch {
            print("❌ Registration error: \(error)")
            print("   - Error type: \(type(of: error))")
            await MainActor.run {
                showError = true
                if let serverError = error as? ServerError {
                    errorMessage = serverError.localizedDescription
                    let httpStatusCode = extractHTTPStatusCode(from: serverError)
                    errorCode = generateErrorCode(errorType: "REG_ERROR", email: email, httpStatusCode: httpStatusCode)
                } else {
                    errorMessage = "Connection error. Please check if the server is running."
                    errorCode = generateErrorCode(errorType: "CONNECTION_ERROR", email: email, httpStatusCode: nil)
                }
                isLoading = false
            }
        }
    }

    private func generateErrorCode(errorType: String, email: String, httpStatusCode: Int?) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let emailHash = abs(email.hashValue) % 10000
        let errorTypeHash = abs(errorType.hashValue) % 1000

        if let statusCode = httpStatusCode {
            return String(format: "DBG-%05d-%04d-HTTP%d", timestamp % 100000, (emailHash + errorTypeHash) % 10000, statusCode)
        } else {
            return String(format: "DBG-%05d-%04d", timestamp % 100000, (emailHash + errorTypeHash) % 10000)
        }
    }

    private func extractHTTPStatusCode(from error: ServerError) -> Int? {
        switch error {
        case .httpError(let code):
            return code
        default:
            return nil
        }
    }
    
    private func checkRegistrationLimit() async {
        await MainActor.run {
            isCheckingLimit = true
        }
        
        // Get UUID from Keychain or UserDefaults
        let keychainService = "com.zentra.deviceUUID"
        let keychainAccount = "deviceUUID"
        
        var uuidToCheck = deviceUUID
        
        // Always check Keychain first (most reliable)
        if let keychainUUID = KeychainHelper.shared.read(service: keychainService, account: keychainAccount), !keychainUUID.isEmpty {
            uuidToCheck = keychainUUID
            print("✅ [RegisterView] UUID aus Keychain geladen: \(uuidToCheck)")
        } else if uuidToCheck.isEmpty {
            if let defaultsUUID = UserDefaults.standard.string(forKey: "deviceUUID"), !defaultsUUID.isEmpty {
                uuidToCheck = defaultsUUID
                print("✅ [RegisterView] UUID aus UserDefaults geladen: \(uuidToCheck)")
            }
        }
        
        // If no UUID found, generate and save one BEFORE checking limit
        if uuidToCheck.isEmpty {
            uuidToCheck = UUID().uuidString
            print("✅ [RegisterView] Neue UUID generiert für Limit-Prüfung: \(uuidToCheck)")
            
            // IMPORTANT: Save UUID to Keychain (persists after app reinstall) AND UserDefaults (for quick access)
            KeychainHelper.shared.save(uuidToCheck, service: keychainService, account: keychainAccount)
            UserDefaults.standard.set(uuidToCheck, forKey: "deviceUUID")
            UserDefaults.standard.synchronize()
            
            // Update the @AppStorage variable
            await MainActor.run {
                deviceUUID = uuidToCheck
            }
        }
        
        print("🔄 [RegisterView] Prüfe Registrierungslimit für UUID: \(uuidToCheck)")
        
        do {
            let response = try await serverManager.checkRegistrationLimit(deviceUUID: uuidToCheck)
            
            print("✅ [RegisterView] Limit-Prüfung erfolgreich:")
            print("   - Limit erreicht: \(response.limit_reached)")
            print("   - Account Count: \(response.account_count)/3")
            print("   - Verbleibend: \(response.remaining_registrations)")
            
            await MainActor.run {
                isCheckingLimit = false
                limitReached = response.limit_reached
                accountCount = response.account_count
                remainingRegistrations = response.remaining_registrations
            }
        } catch {
            print("❌ [RegisterView] Fehler bei Limit-Prüfung: \(error.localizedDescription)")
            // On error, allow registration attempt (server will reject if limit reached)
            await MainActor.run {
                isCheckingLimit = false
                limitReached = false
            }
        }
    }
}

// Custom Button Style for Register Buttons (same as Login)
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
    }
}

