import SwiftUI

struct SideMenu: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("trustUnknownLinks") var trustUnknownLinks: Bool = false

    @Binding var selectedPage: String?
    
    // Closure called to collapse the menu, e.g. after page selection
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
                // Only capitalize the first letter, leave the rest untouched
                let first = currentUsername.prefix(1).uppercased()
                let rest = currentUsername.dropFirst()
                return first + rest
            }
        } else {
            return "Not logged in"
        }
    }

    private var loginStatus: String? {
        isLoggedIn ? "Logged in" : nil
    }

    var body: some View {
        VStack(spacing: 24) {
            // 📛 Profilbereich
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 10) {
                    Rectangle()
                        .fill(themeEngine.colors.accent)
                        .frame(width: 4, height: 24)
                        .cornerRadius(2)

                    Text("Profile")
                        .font(.title3.bold())
                        .foregroundColor(themeEngine.colors.accent)
                }
                .padding(.bottom, 4)

                // Profil content
                HStack(spacing: 12) {
                    Image(systemName: isLoggedIn ? "person.crop.circle.fill" : "person.crop.circle.badge.exclam")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(themeEngine.colors.accent)
                        .shadow(radius: 4)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(displayName)
                            .font(.headline)
                            .foregroundColor(themeEngine.colors.text)

                        if let status = loginStatus {
                            Text(status)
                                .font(.subheadline)
                                .foregroundColor(themeEngine.colors.text.opacity(0.7))
                        }
                    }
                    Spacer()
                }
                
                // Login or Sign Out Button
                if isLoggedIn {
                    SideMenuButtonView(label: "Sign Out",
                                       icon: "rectangle.portrait.and.arrow.right",
                                       style: .primary,
                                       isDestructive: true) {
                        showCustomLogoutDialog = true
                    }
                    .frame(maxWidth: .infinity)
                    .environmentObject(themeEngine)
                } else {
                    SideMenuButtonView(label: "Login",
                                       icon: "person.badge.key.fill",
                                       style: .primary) {
                        showLoginView = true
                    }
                    .frame(maxWidth: .infinity)
                    .environmentObject(themeEngine)
                }
            }
            .padding(20)
            .liquidGlassCard()

            // Navigation Card
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 10) {
                    Rectangle()
                        .fill(themeEngine.colors.accent)
                        .frame(width: 4, height: 24)
                        .cornerRadius(2)

                    Text("Navigation")
                        .font(.title3.bold())
                        .foregroundColor(themeEngine.colors.accent)
                }
                .padding(.bottom, 4)

                VStack(spacing: 12) {
                    SideMenuButtonView(label: "Home", icon: "house", style: .primary) {
                        withAnimation {
                            selectedPage = "start"
                            onCollapse?()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .environmentObject(themeEngine)

                    SideMenuButtonView(label: "Bazaar Tracker", icon: "chart.bar.xaxis", style: .primary) {
                        withAnimation {
                            selectedPage = "bazaar"
                            onCollapse?()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .environmentObject(themeEngine)
                    
                    SideMenuButtonView(label: "Bazaar Profit", icon: "eurosign.circle", style: .primary) {
                        withAnimation {
                            selectedPage = "bazaarProfit"
                            onCollapse?()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .environmentObject(themeEngine)
                    
                    SideMenuButtonView(label: "Settings", icon: "gearshape", style: .primary) {
                        showSettings = true
                    }
                    .frame(maxWidth: .infinity)
                    .environmentObject(themeEngine)
                }
            }
            .padding(20)
            .liquidGlassCard()

            Spacer(minLength: 26)

            // 🔗 Social Links (Contact) moved to bottom
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 10) {
                    Rectangle()
                        .fill(themeEngine.colors.accent)
                        .frame(width: 4, height: 24)
                        .cornerRadius(2)

                    Text("Contact")
                        .font(.title3.bold())
                        .foregroundColor(themeEngine.colors.accent)
                }
                .padding(.bottom, 4)

                VStack(spacing: 12) {
                    SideMenuButtonView(label: "Instagram", icon: "camera", style: .primary) {
                        handleLink("Instagram", url: Links.instagramWebURL, appURL: Links.instagramAppURL)
                    }
                    .frame(maxWidth: .infinity)
                    .environmentObject(themeEngine)

                    SideMenuButtonView(label: "YouTube", icon: "play.rectangle", style: .primary) {
                        handleLink("YouTube", url: Links.youtubeWebURL, appURL: Links.youtubeAppURL)
                    }
                    .frame(maxWidth: .infinity)
                    .environmentObject(themeEngine)
                }
            }
            .padding(20)
            .liquidGlassCard()
        }
        .padding(.horizontal, 28)
        .frame(minWidth: 260) // Menü wird etwas breiter für vollständige Button-Beschriftung
        .safeAreaPadding(.top, 24) // Use safeAreaPadding for iOS 26+ compatibility
        .background(themeEngine.colors.background)
        .sheet(isPresented: $showSettings) {
            SettingsView(selectedPage: $selectedPage)
                .environmentObject(themeEngine)
                .font(.body)
        }
        .sheet(isPresented: $showLoginView) {
            LoginView(onLogin: {
                withAnimation {
                    isLoggedIn = true
                    showLoginView = false
                    Task { await webhookManager.logLogin(username: currentUsername) }
                }
            })
            .environmentObject(themeEngine)
            .font(.body)
        }
        .alert("Do you really want to sign out?", isPresented: $showCustomLogoutDialog) {
            Button(role: .cancel) {
                // Cancel - do nothing
            } label: {
                Text("Cancel")
            }
            Button(role: .destructive) {
                withAnimation {
                    // Save username for webhook before clearing it
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
            // Wenn trustUnknownLinks aktiviert ist, öffne direkt
            openLink(url: url, appURL: appURL)
        } else {
            // Wenn trustUnknownLinks deaktiviert ist, zeige Bestätigungsdialog
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

private struct SideMenuPrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
                    .opacity(configuration.isPressed ? 0.7 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

private struct SideMenuButtonView: View {
    enum ButtonStyle {
        case standard
        case primary
    }

    let label: String
    let icon: String
    var style: ButtonStyle = .standard
    var color: Color? = nil
    var isDestructive: Bool = false
    let action: () -> Void
    @EnvironmentObject var themeEngine: ThemeEngine

    var body: some View {
        buildButton()
    }

    @ViewBuilder
    private func buildButton() -> some View {
        let buttonContent = HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(foregroundColor)
            Text(label)
                .foregroundColor(foregroundColor)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
        .padding(.vertical, 8)
        .background(background)
        .cornerRadius(10)

        if style == .primary {
            Button(action: action) {
                buttonContent
            }
            .buttonStyle(
                SideMenuPrimaryButtonStyle(
                    backgroundColor: isDestructive ? themeEngine.colors.error : themeEngine.colors.accent,
                    foregroundColor: isDestructive ? themeEngine.colors.background : themeEngine.colors.text
                )
            )
            .environmentObject(themeEngine)
        } else {
            Button(action: action) {
                buttonContent
            }
            .buttonStyle(PlainButtonStyle())
            .environmentObject(themeEngine)
        }
    }

    private var foregroundColor: Color {
        if let clr = color {
            return clr
        }
        if isDestructive {
            return themeEngine.colors.background
        }
        switch style {
        case .primary:
            return themeEngine.colors.text
        case .standard:
            return themeEngine.colors.accent
        }
    }

    private var background: Color {
        if isDestructive {
            return themeEngine.colors.error.opacity(0.9)
        }
        switch style {
        case .primary:
            return themeEngine.colors.accent
        case .standard:
            return Color.clear
        }
    }
}
