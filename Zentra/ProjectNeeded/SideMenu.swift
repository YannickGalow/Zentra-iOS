import SwiftUI

struct Sidebar: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("currentUsername") var currentUsername: String = ""
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

    @EnvironmentObject var themeEngine: ThemeEngine
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
                    themeEngine.colors.background,
                    themeEngine.colors.background.opacity(0.98),
                    themeEngine.colors.background
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
                                            themeEngine.colors.accent.opacity(0.3),
                                            themeEngine.colors.accent.opacity(0.1),
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
                                            themeEngine.colors.accent.opacity(0.5),
                                            themeEngine.colors.accent.opacity(0.2)
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
                                .foregroundColor(themeEngine.colors.accent)
                                .shadow(color: themeEngine.colors.accent.opacity(0.6), radius: 12, x: 0, y: 6)
                        }
                        .padding(.top, 30)
                        
                        VStack(spacing: 6) {
                            Text(displayName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(themeEngine.colors.text)
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(themeEngine.colors.accent)
                                    .frame(width: 6, height: 6)
                                
                                Text(loginStatus)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeEngine.colors.text.opacity(0.6))
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
                            .foregroundColor(isLoggedIn ? themeEngine.colors.error : themeEngine.colors.accent)
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
                                                    themeEngine.colors.error.opacity(0.15),
                                                    themeEngine.colors.error.opacity(0.08)
                                                ] : [
                                                    themeEngine.colors.accent.opacity(0.15),
                                                    themeEngine.colors.accent.opacity(0.08)
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
                                                themeEngine.colors.error.opacity(0.4),
                                                themeEngine.colors.error.opacity(0.2)
                                            ] : [
                                                themeEngine.colors.accent.opacity(0.4),
                                                themeEngine.colors.accent.opacity(0.2)
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
                                .foregroundColor(themeEngine.colors.text.opacity(0.5))
                                .textCase(.uppercase)
                                .tracking(1)
                            Spacer()
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 16)
                        
                        VStack(spacing: 8) {
                            SidebarNavButton(
                                icon: "house.fill",
                                label: "Home",
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
                                isSelected: selectedPage == "bazaar"
                            ) {
                                conditionalWithAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    selectedPage = "bazaar"
                                    onCollapse?()
                                }
                            }
                            
                            SidebarNavButton(
                                icon: "eurosign.circle.fill",
                                label: "Bazaar Profit",
                                isSelected: selectedPage == "bazaarProfit"
                            ) {
                                conditionalWithAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    selectedPage = "bazaarProfit"
                                    onCollapse?()
                                }
                            }
                            
                            SidebarNavButton(
                                icon: "gearshape.fill",
                                label: "Settings",
                                isSelected: false
                            ) {
                                showSettings = true
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    }
                    
                    // Contact Section
                    VStack(spacing: 0) {
                        HStack {
                            Text("Connect")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(themeEngine.colors.text.opacity(0.5))
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
                .environmentObject(themeEngine)
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
            .environmentObject(themeEngine)
        }
        .alert("Do you really want to sign out?", isPresented: $showCustomLogoutDialog) {
            Button(role: .cancel) {
                // Cancel
            } label: {
                Text("Cancel")
            }
            Button(role: .destructive) {
                conditionalWithAnimation {
                    let usernameToLog = currentUsername
                    isLoggedIn = false
                    currentUsername = ""
                    selectedPage = "start"
                    Task { await webhookManager.logLogout(username: usernameToLog) }
                }
            } label: {
                Text("Sign Out")
            }
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
    
    private func openLink(url: URL, appURL: URL) {
        UIApplication.shared.open(appURL, options: [:]) { success in
            if !success {
                UIApplication.shared.open(url)
            }
        }
    }
}

// Modern Navigation Button
private struct SidebarNavButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeEngine: ThemeEngine
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
                                    themeEngine.colors.accent.opacity(0.3),
                                    themeEngine.colors.accent.opacity(0.2)
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
                        .foregroundColor(isSelected ? themeEngine.colors.accent : themeEngine.colors.text.opacity(0.7))
                }
                
                Text(label)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? themeEngine.colors.text : themeEngine.colors.text.opacity(0.8))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .opacity(isSelected ? 0.5 : 0.3)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        themeEngine.colors.accent.opacity(0.12),
                                        themeEngine.colors.accent.opacity(0.06)
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
                        isSelected ?
                        LinearGradient(
                            colors: [
                                themeEngine.colors.accent.opacity(0.5),
                                themeEngine.colors.accent.opacity(0.2)
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
                        ),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(
                color: isSelected ? themeEngine.colors.accent.opacity(0.15) : .black.opacity(0.05),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(SidebarNavButtonStyle(isPressed: $isPressed))
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
    
    @EnvironmentObject var themeEngine: ThemeEngine
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(themeEngine.colors.accent)
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
                                            themeEngine.colors.accent.opacity(0.15),
                                            themeEngine.colors.accent.opacity(0.08)
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
                                        themeEngine.colors.accent.opacity(0.4),
                                        themeEngine.colors.accent.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: themeEngine.colors.accent.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeEngine.colors.text.opacity(0.7))
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
