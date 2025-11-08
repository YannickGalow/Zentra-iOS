import SwiftUI

struct Sidebar: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("authToken") var authToken: String = ""
    @AppStorage("trustUnknownLinks") var trustUnknownLinks: Bool = false

    @Binding var selectedPage: String?
    
    var onCollapse: (() -> Void)? = nil

    @State private var showSettings = false
    @State private var showLoginView = false
    @State private var showCustomLogoutDialog = false
    @State private var showLinkConfirmation = false
    @State private var pendingLinkURL: URL? = nil
    @State private var pendingLinkAppURL: URL? = nil
    @State private var pendingLinkName: String = ""
    @State private var logoTapCount: Int = 0
    @State private var lastTapTime: Date = Date()
    @State private var showDeveloperOptionsToast: Bool = false
    @State private var developerOptionsToastMessage: String = ""

    @EnvironmentObject var tcf: TCF
    @EnvironmentObject var webhookManager: DiscordWebhookManager

    private var displayName: String {
        if isLoggedIn {
            if currentUsername.isEmpty {
                return "User"
            } else {
                let first = currentUsername.prefix(1).uppercased()
                let rest = currentUsername.dropFirst()
                return first + rest
            }
        } else {
            return "Guest"
        }
    }

    private var loginStatus: String {
        isLoggedIn ? "Logged in" : "Not logged in"
    }

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    tcf.colors.background,
                    tcf.colors.background.opacity(0.98),
                    tcf.colors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Profile Hero Section
                    VStack(spacing: 20) {
                        // Avatar with glass effect
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            tcf.colors.accent.opacity(0.3),
                                            tcf.colors.accent.opacity(0.1),
                                            .clear
                                        ],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            tcf.colors.accent.opacity(0.5),
                                            tcf.colors.accent.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: isLoggedIn ? "person.crop.circle.fill" : "person.crop.circle")
                        .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(tcf.colors.accent)
                                .shadow(color: tcf.colors.accent.opacity(0.6), radius: 12, x: 0, y: 6)
                        }
                        .padding(.top, 30)
                        .contentShape(Circle())
                        .onTapGesture {
                            // Only count taps when logged in
                            if isLoggedIn {
                                handleLogoTap()
                            }
                        }
                        
                        VStack(spacing: 6) {
                        Text(displayName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(tcf.colors.text)
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(tcf.colors.accent)
                                    .frame(width: 6, height: 6)
                                
                                Text(loginStatus)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(tcf.colors.text.opacity(0.6))
                            }
                        }
                        
                        // Auth Button
                        Button(action: {
                            if isLoggedIn {
                                showCustomLogoutDialog = true
                            } else {
                                showLoginView = true
                            }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: isLoggedIn ? "rectangle.portrait.and.arrow.right" : "person.badge.key")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text(isLoggedIn ? "Sign Out" : "Login")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(isLoggedIn ? tcf.colors.error : tcf.colors.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.6)
                                    
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: isLoggedIn ? [
                                                    tcf.colors.error.opacity(0.15),
                                                    tcf.colors.error.opacity(0.08)
                                                ] : [
                                                    tcf.colors.accent.opacity(0.15),
                                                    tcf.colors.accent.opacity(0.08)
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
                                            colors: isLoggedIn ? [
                                                tcf.colors.error.opacity(0.4),
                                                tcf.colors.error.opacity(0.2)
                                            ] : [
                                                tcf.colors.accent.opacity(0.4),
                                                tcf.colors.accent.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                    
                    // Navigation Section
                    VStack(spacing: 0) {
                        HStack {
                            Text("Navigation")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(tcf.colors.text.opacity(0.5))
                                .textCase(.uppercase)
                                .tracking(1)
                    Spacer()
                }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 16)
                        
                        VStack(spacing: 8) {
                            SidebarNavButton(
                                icon: "house.fill",
                                label: "Dashboard",
                                isSelected: selectedPage == "start"
                            ) {
                                conditionalWithAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedPage = "start"
                            onCollapse?()
                        }
                    }
                            
                            SidebarNavButton(
                                icon: "chart.bar.xaxis",
                                label: "Bazaar Tracker",
                                isSelected: false,
                                action: {
                                    // Functionality disabled
                                },
                                isDisabled: true
                            )
                            
                            SidebarNavButton(
                                icon: "eurosign.circle.fill",
                                label: "Bazaar Profit",
                                isSelected: false,
                                action: {
                                    // Functionality disabled
                                },
                                isDisabled: true
                            )
                            
                            SidebarNavButton(
                                icon: "gearshape.fill",
                                label: "Settings",
                                isSelected: false,
                                action: {
                                    if isLoggedIn {
                                        showSettings = true
                                    }
                                },
                                isDisabled: !isLoggedIn
                            )
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    }
                    
                    // Contact Section
                    VStack(spacing: 0) {
                        HStack {
                            Text("Connect")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(tcf.colors.text.opacity(0.5))
                                .textCase(.uppercase)
                                .tracking(1)
                            Spacer()
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 16)
                        
                        HStack(spacing: 12) {
                            SidebarSocialButton(
                                icon: "camera.fill",
                                label: "Instagram"
                            ) {
                                handleLink("Instagram", url: Links.instagramWebURL, appURL: Links.instagramAppURL)
                            }
                            
                            SidebarSocialButton(
                                icon: "play.rectangle.fill",
                                label: "YouTube"
                            ) {
                                handleLink("YouTube", url: Links.youtubeWebURL, appURL: Links.youtubeAppURL)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    }
                }
                .padding(.top, 20)
            }
            
            // Developer Options Toast Notification
            if showDeveloperOptionsToast {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(developerOptionsToastMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .opacity(0.9)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(tcf.colors.accent.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showDeveloperOptionsToast)
            }
        }
        .frame(minWidth: 300)
        .sheet(isPresented: Binding(
            get: { showSettings },
            set: { newValue in
                let animationsEnabled = UserDefaults.standard.bool(forKey: "animationsEnabled")
                if animationsEnabled {
                    showSettings = newValue
                } else {
                    withAnimation(nil) {
                        showSettings = newValue
                    }
                }
            }
        )) {
            SettingsView(selectedPage: $selectedPage)
                .environmentObject(tcf)
        }
        .sheet(isPresented: Binding(
            get: { showLoginView },
            set: { newValue in
                let animationsEnabled = UserDefaults.standard.bool(forKey: "animationsEnabled")
                if animationsEnabled {
                    showLoginView = newValue
                } else {
                    withAnimation(nil) {
                        showLoginView = newValue
                    }
                }
            }
        )) {
            LoginView(onLogin: {
                conditionalWithAnimation {
                    isLoggedIn = true
                    let animationsEnabled = UserDefaults.standard.bool(forKey: "animationsEnabled")
                    if animationsEnabled {
                        showLoginView = false
                    } else {
                        withAnimation(nil) {
                            showLoginView = false
                        }
                    }
                    Task { await webhookManager.logLogin(username: currentUsername) }
                }
            })
            .environmentObject(tcf)
        }
        .alert("Do you really want to sign out?", isPresented: $showCustomLogoutDialog) {
            Button(role: .cancel) {
                // Cancel
            } label: {
                Text("Cancel")
            }
            Button(role: .destructive) {
                Task {
                    await performLogout()
                }
            } label: {
                Text("Sign Out")
            }
        } message: {
            Text("When you sign out, all your settings will be reset to default values. This includes themes, Discord webhooks, privacy settings, and other preferences. You will need to configure them again after logging back in.")
        }
        .alert("Open \(pendingLinkName)?", isPresented: $showLinkConfirmation) {
            Button("Cancel", role: .cancel) {
                pendingLinkURL = nil
                pendingLinkAppURL = nil
            }
            Button("Open") {
                if let url = pendingLinkURL, let appURL = pendingLinkAppURL {
                    openLink(url: url, appURL: appURL)
                }
                pendingLinkURL = nil
                pendingLinkAppURL = nil
            }
        }
    }

    private func handleLink(_ linkName: String, url: URL, appURL: URL) {
        if trustUnknownLinks {
            openLink(url: url, appURL: appURL)
        } else {
            pendingLinkName = linkName
            pendingLinkURL = url
            pendingLinkAppURL = appURL
            showLinkConfirmation = true
        }
    }
    
    private func performLogout() async {
        let usernameToLog = currentUsername
        let tokenToLogout = authToken
        
        // Logout from server if token exists
        if !tokenToLogout.isEmpty {
            do {
                try await ServerManager.shared.logout(token: tokenToLogout)
            } catch {
                // Server logout failed, but continue with local logout
                print("⚠️ Server logout failed: \(error)")
            }
        }
        
        // Reset all settings to default
        await MainActor.run {
            conditionalWithAnimation {
                // Reset authentication
                isLoggedIn = false
                currentUsername = ""
                authToken = ""
                
                // Reset privacy settings
                trustUnknownLinks = false
                
                // Reset theme to light (white theme)
                tcf.selectedThemeId = "light"
                
                // Reset all other settings
                UserDefaults.standard.set(false, forKey: "rememberLogin")
                UserDefaults.standard.set(false, forKey: "useBiometrics")
                UserDefaults.standard.set("", forKey: "discordWebhookURL")
                UserDefaults.standard.set(false, forKey: "logLoginLogout")
                UserDefaults.standard.set(false, forKey: "logThemeChanges")
                UserDefaults.standard.set(false, forKey: "logSettingsChanges")
                UserDefaults.standard.set(true, forKey: "animationsEnabled")
                UserDefaults.standard.set(false, forKey: "showCustomDiscordMessage")
                UserDefaults.standard.set(false, forKey: "developerOptionsEnabled")
                
                // Clear keychain
                KeychainHelper.shared.delete(service: "com.example.LoginApp", account: usernameToLog)
                
                selectedPage = "start"
                
                // Log logout to Discord
                Task { await webhookManager.logLogout(username: usernameToLog) }
            }
        }
    }
    
    private func openLink(url: URL, appURL: URL) {
        UIApplication.shared.open(appURL, options: [:]) { success in
            if !success {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func handleLogoTap() {
        // Only process taps when logged in
        guard isLoggedIn else { return }
        
        let now = Date()
        let timeSinceLastTap = now.timeIntervalSince(lastTapTime)
        
        // Reset counter if more than 2 seconds passed since last tap
        if timeSinceLastTap > 2.0 {
            logoTapCount = 1
        } else {
            logoTapCount += 1
        }
        
        lastTapTime = now
        
        // If 5 taps detected, toggle developer options
        if logoTapCount >= 5 {
            let currentValue = UserDefaults.standard.bool(forKey: "developerOptionsEnabled")
            let newValue = !currentValue
            UserDefaults.standard.set(newValue, forKey: "developerOptionsEnabled")
            logoTapCount = 0
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Show temporary toast notification
            developerOptionsToastMessage = newValue ? "Developer Options Enabled" : "Developer Options Disabled"
            withAnimation {
                showDeveloperOptionsToast = true
            }
            
            // Hide toast after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showDeveloperOptionsToast = false
                }
            }
        } else {
            // Light haptic feedback for each tap
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}

// Modern Navigation Button
private struct SidebarNavButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    var isDisabled: Bool = false
    
    @EnvironmentObject var tcf: TCF
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [
                                    tcf.colors.accent.opacity(0.3),
                                    tcf.colors.accent.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isDisabled ? tcf.colors.text.opacity(0.3) : (isSelected ? tcf.colors.accent : tcf.colors.text.opacity(0.7)))
                }
                
                Text(label)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isDisabled ? tcf.colors.text.opacity(0.3) : (isSelected ? tcf.colors.text : tcf.colors.text.opacity(0.8)))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .opacity(isDisabled ? 0.1 : (isSelected ? 0.5 : 0.3))
                    
                    if isSelected && !isDisabled {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        tcf.colors.accent.opacity(0.12),
                                        tcf.colors.accent.opacity(0.06)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isDisabled ?
                        LinearGradient(
                            colors: [
                                tcf.colors.text.opacity(0.1),
                                tcf.colors.text.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        (isSelected ?
                        LinearGradient(
                            colors: [
                                tcf.colors.accent.opacity(0.5),
                                tcf.colors.accent.opacity(0.2)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [
                                .white.opacity(0.15),
                                .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(
                color: isDisabled ? .clear : (isSelected ? tcf.colors.accent.opacity(0.15) : .black.opacity(0.05)),
                radius: isDisabled ? 0 : (isSelected ? 8 : 4),
                x: 0,
                y: isDisabled ? 0 : (isSelected ? 4 : 2)
            )
        }
        .buttonStyle(SidebarNavButtonStyle(isPressed: $isPressed))
        .allowsHitTesting(!isDisabled)
    }
}

private struct SidebarNavButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .conditionalAnimation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// Social Media Button
private struct SidebarSocialButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    @EnvironmentObject var tcf: TCF
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(tcf.colors.accent)
                    .frame(width: 50, height: 50)
                    .background(
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .opacity(0.5)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            tcf.colors.accent.opacity(0.15),
                                            tcf.colors.accent.opacity(0.08)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        tcf.colors.accent.opacity(0.4),
                                        tcf.colors.accent.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: tcf.colors.accent.opacity(0.2), radius: 8, x: 0, y: 4)
                
            Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(tcf.colors.text.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.2),
                                .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(SidebarSocialButtonStyle(isPressed: $isPressed))
    }
}

private struct SidebarSocialButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .conditionalAnimation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
        }
    }
}
