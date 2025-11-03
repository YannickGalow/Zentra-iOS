import SwiftUI
import UIKit
import UniformTypeIdentifiers
import UserNotifications

struct SettingsView: View {
    @AppStorage("rememberLogin") var rememberLogin: Bool = false
    @AppStorage("trustUnknownLinks") var trustUnknownLinks: Bool = false
    @AppStorage("useBiometrics") var useBiometrics: Bool = false
    @AppStorage("discordWebhookURL") var discordWebhookURL: String = ""
    @AppStorage("logLoginLogout") var logLoginLogout: Bool = false
    @AppStorage("logThemeChanges") var logThemeChanges: Bool = false
    @AppStorage("logSettingsChanges") var logSettingsChanges: Bool = false
    @AppStorage("animationsEnabled") var animationsEnabled: Bool = true
    @AppStorage("showCustomDiscordMessage") var showCustomDiscordMessage: Bool = false
    @State private var selectedLanguage: String = AppLanguage.system.rawValue
    @Binding var selectedPage: String?
    @State private var showDeleteConfirmation: Bool = false
    @State private var themeToDelete: ThemeModel?
    @State private var showingImporter: Bool = false
    @State private var isChangingTheme: Bool = false
    @State private var customDiscordMessage: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeEngine: ThemeEngine
    @EnvironmentObject var webhookManager: DiscordWebhookManager
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Text("Settings")
                            .font(.largeTitle.bold())
                            .foregroundColor(themeEngine.colors.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)

                        anmeldungCard

                        privatsphaereCard

                        discordLoggingCard

                        designCard
                    
                    appSettingsCard

                    Button("Send Test Notification") {
                        triggerTestNotification()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: themeEngine.colors.accent, foregroundColor: .white))
                    .padding(.top, 24)
                    
                    Spacer(minLength: 20)
                    
                    Text("© 2025 Yannick Galow")
                        .font(.footnote)
                        .foregroundColor(themeEngine.colors.text.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 60)
                .opacity(isChangingTheme ? (animationsEnabled ? 0.3 : 0.5) : 1.0)
                .blur(radius: isChangingTheme ? (animationsEnabled ? 3 : 0) : 0)
            }
            .background(themeEngine.colors.background.ignoresSafeArea())
            
            // Loading animation during theme change
            if isChangingTheme {
                ThemeLoadingView()
                    .environmentObject(themeEngine)
                    .transition(animationsEnabled ? .opacity : .identity)
            }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        let animationsEnabled = UserDefaults.standard.bool(forKey: "animationsEnabled")
                        selectedPage = "start"
                        if animationsEnabled {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            withAnimation(nil) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .foregroundColor(themeEngine.colors.accent)
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Really delete theme?"),
                    message: Text("The theme \"\(themeToDelete?.name ?? "")\" will be removed. This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let theme = themeToDelete {
                            deleteTheme(theme)
                            if logThemeChanges {
                                Task {
                                    await webhookManager.logThemeChange(themeName: theme.name)
                                }
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }

    private var anmeldungCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header with accent bar
            HStack(spacing: 12) {
                Rectangle()
                    .fill(themeEngine.colors.accent)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                Text("Login")
                    .font(.title3.bold())
                    .foregroundColor(themeEngine.colors.accent)
            }
            SettingsToggleRow(label: "Remember login", isOn: $rememberLogin) { newValue in
                self.handleRememberLoginChanged(newValue)
            }
        }
        .padding(20)
        .liquidGlassCard()
    }

    private var privatsphaereCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(themeEngine.colors.accent)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                Text("Privacy")
                    .font(.title3.bold())
                    .foregroundColor(themeEngine.colors.accent)
            }

            VStack(spacing: 20) {
                SettingsToggleRow(label: "Trust links from unknown sources", isOn: $trustUnknownLinks) { newValue in
                    self.handleTrustUnknownLinksChanged(newValue)
                }

                SettingsToggleRow(label: "Enable Face ID / Passcode protection", isOn: $useBiometrics) { newValue in
                    self.handleUseBiometricsChanged(newValue)
                }
            }
        }
        .padding(20)
        .liquidGlassCard()
    }

    private var discordLoggingCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(themeEngine.colors.accent)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                Text("Discord Integration Settings")
                    .font(.title3.bold())
                    .foregroundColor(themeEngine.colors.accent)
            }

            ZStack {
                TextField("Paste webhook URL", text: $discordWebhookURL)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .padding()
                    .liquidGlassBackground(cornerRadius: 12)
                    .foregroundColor(themeEngine.colors.text)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeEngine.colors.accent.opacity(0.5), lineWidth: 1)
                    )
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture(count: 1) {
                        #if canImport(UIKit)
                        if let string = UIPasteboard.general.string, let url = URL(string: string), url.scheme?.hasPrefix("http") == true {
                            discordWebhookURL = string
                        }
                        #endif
                    }
                    .onTapGesture(count: 2) {
                        discordWebhookURL = ""
                    }
            }

            // Only show settings when valid webhook URL is entered
            if let webhookURL = URL(string: discordWebhookURL),
               webhookURL.absoluteString.contains("discord.com/api/webhooks/") {

                // Toggle to enable/disable custom message feature
                SettingsToggleRow(label: "Enable quick messages text field", isOn: $showCustomDiscordMessage)

                // Custom message text field (only shown when enabled)
                if showCustomDiscordMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Message")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(themeEngine.colors.text.opacity(0.8))
                        
                        TextField("Enter your message...", text: $customDiscordMessage, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.6)
                            )
                            .foregroundColor(themeEngine.colors.text)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeEngine.colors.accent.opacity(0.5), lineWidth: 1)
                            )
                            .lineLimit(3...6)
                    }

                    Button("Send custom message") {
                        guard !customDiscordMessage.isEmpty else { return }
                        Task {
                            await webhookManager.logCustomMessage(text: customDiscordMessage)
                            customDiscordMessage = ""
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: themeEngine.colors.accent, foregroundColor: themeEngine.colors.background))
                    .disabled(customDiscordMessage.isEmpty)
                    .opacity(customDiscordMessage.isEmpty ? 0.6 : 1.0)
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    SettingsToggleRow(label: "Post login/logout", isOn: $logLoginLogout)
                    SettingsToggleRow(label: "Post theme changes", isOn: $logThemeChanges)
                    SettingsToggleRow(label: "Post settings changes", isOn: $logSettingsChanges)
                }
                
                // Send test post button at the bottom
                Button("Send test post") {
                    Task {
                        await webhookManager.logTestPost()
                    }
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: themeEngine.colors.accent.opacity(0.7), foregroundColor: themeEngine.colors.background))
            }
        }
        .padding(20)
        .liquidGlassCard()
    }

    private var designCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            let availableThemes = themeEngine.availableThemes
            let textColor = themeEngine.colors.text

            HStack(spacing: 12) {
                Rectangle()
                    .fill(themeEngine.colors.accent)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                Text("Design")
                    .font(.title3.bold())
                    .foregroundColor(themeEngine.colors.accent)
            }

            ForEach(availableThemes) { theme in
                HStack {
                    Button {
                        Task {
                            await changeTheme(to: theme.id)
                        }
                    } label: {
                        HStack {
                            Text(theme.name)
                                .foregroundColor(textColor)
                            Spacer()
                            if themeEngine.selectedThemeId == theme.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(themeEngine.colors.accent)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Built-in Themes (default, light, dark) können nicht gelöscht werden
                    let builtInThemeIds = ["default", "light", "dark"]
                    if !builtInThemeIds.contains(theme.id) {
                        Button {
                            themeToDelete = theme
                            showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(16)
                .liquidGlassBackground(cornerRadius: 12)
            }

            Button("Upload theme") {
                showingImporter = true
            }
            .buttonStyle(PrimaryButtonStyle(backgroundColor: themeEngine.colors.accent, foregroundColor: themeEngine.colors.background))
        }
        .padding(20)
        .liquidGlassCard()
    }
    
    private var appSettingsCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(themeEngine.colors.accent)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                Text("Performance Settings")
                    .font(.title3.bold())
                    .foregroundColor(themeEngine.colors.accent)
            }
            
            SettingsToggleRow(label: "Enable Animations", isOn: $animationsEnabled)
        }
        .padding(20)
        .liquidGlassCard()
    }

    private func deleteTheme(_ theme: ThemeModel) {
        // Built-in Themes können nicht gelöscht werden
        let builtInThemeIds = ["default", "light", "dark"]
        if builtInThemeIds.contains(theme.id) {
            print("⚠️ Built-in Theme kann nicht gelöscht werden:", theme.name)
            return
        }
        
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let themeFile = docsURL.appendingPathComponent("themes").appendingPathComponent("\(theme.id).json")

        do {
            try fileManager.removeItem(at: themeFile)
            print("✅ Theme gelöscht:", theme.name)
            themeEngine.loadThemes()
        } catch {
            print("❌ Fehler beim Löschen des Themes:", error)
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let selectedFile = urls.first {
                let accessGranted = selectedFile.startAccessingSecurityScopedResource()
                defer {
                    if accessGranted {
                        selectedFile.stopAccessingSecurityScopedResource()
                    }
                }

                do {
                    let fileManager = FileManager.default
                    let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let themesDir = docsURL.appendingPathComponent("themes")

                    if !fileManager.fileExists(atPath: themesDir.path) {
                        try fileManager.createDirectory(at: themesDir, withIntermediateDirectories: true)
                    }

                    let destinationURL = themesDir.appendingPathComponent(selectedFile.lastPathComponent)
                    if fileManager.fileExists(atPath: destinationURL.path) {
                        try fileManager.removeItem(at: destinationURL)
                    }

                    themeEngine.loadThemes()
                    if let lastTheme = themeEngine.availableThemes.last {
                        themeEngine.selectedThemeId = lastTheme.id
                        print("✅ Theme aktiviert:", lastTheme.name)
                        if logThemeChanges {
                            Task {
                                await webhookManager.logThemeChange(themeName: lastTheme.name)
                            }
                        }
                    }

                } catch {
                    print("❌ Error copying: \(error)")
                }
            }
        case .failure(let error):
            print("❌ Import error: \(error)")
        }
    }
    
    private func changeTheme(to themeId: String) async {
        // Prevent multiple theme changes simultaneously
        guard !isChangingTheme else { return }
        
        // Only show loading animation if animations are enabled
        if animationsEnabled {
            // Start loading animation
            await MainActor.run {
                conditionalWithAnimation(.easeInOut(duration: 0.2)) {
                    isChangingTheme = true
                }
            }
            
            // Kurze Verzögerung für die Animation
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4 Sekunden
        }
        
        // Theme anwenden
        await MainActor.run {
            conditionalWithAnimation(.easeInOut(duration: 0.4)) {
                themeEngine.selectedThemeId = themeId
                themeEngine.objectWillChange.send() // Force UI update
            }
        }
        
        // Theme vollständig laden lassen und UI aktualisieren
        if animationsEnabled {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 Sekunden
        } else {
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 Sekunden
        }
        
        // Discord Logging (falls aktiviert)
        if logThemeChanges,
           let theme = themeEngine.availableThemes.first(where: { $0.id == themeId }) {
            await webhookManager.logThemeChange(themeName: theme.name)
        }
        
        // Hide loading animation (only if it was shown)
        if animationsEnabled {
            await MainActor.run {
                conditionalWithAnimation(.easeInOut(duration: 0.3)) {
                    isChangingTheme = false
                }
            }
        }
    }
    
    private func handleThemeChange(selectedId: String) {
        // Theme wird automatisch durch @AppStorage selectedThemeId aktualisiert
        themeEngine.selectedThemeId = selectedId
        themeEngine.objectWillChange.send() // Force UI update
        if logThemeChanges,
           let theme = themeEngine.availableThemes.first(where: { $0.id == selectedId }) {
            Task {
                await webhookManager.logThemeChange(themeName: theme.name)
            }
        }
    }
    
    // New handlers for toggles with webhookManager usage
    
    private func handleRememberLoginChanged(_ newValue: Bool) {
        if self.logSettingsChanges {
            Task {
                await self.webhookManager.logSettingsChange(setting: "Login merken", newValue: newValue ? "Aktiviert" : "Deaktiviert")
            }
        }
    }
    
    private func handleTrustUnknownLinksChanged(_ newValue: Bool) {
        if self.logSettingsChanges {
            Task {
                await self.webhookManager.logSettingsChange(setting: "Links von unbekannten vertrauen", newValue: newValue ? "Aktiviert" : "Deaktiviert")
            }
        }
    }
    
    private func handleUseBiometricsChanged(_ newValue: Bool) {
        if self.logSettingsChanges {
            Task {
                await self.webhookManager.logSettingsChange(setting: "Face ID / Code-Schutz", newValue: newValue ? "Aktiviert" : "Deaktiviert")
            }
        }
    }

}

// MARK: - Theme Loading View
struct ThemeLoadingView: View {
    @EnvironmentObject var themeEngine: ThemeEngine
    @AppStorage("animationsEnabled") var animationsEnabled: Bool = true
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Background with blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Liquid Glass Card with loading animation
            VStack(spacing: 24) {
                // Rotating spinner
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    themeEngine.colors.accent.opacity(0.3),
                                    themeEngine.colors.accent.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    themeEngine.colors.accent,
                                    themeEngine.colors.accent.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(rotationAngle))
                }
                .scaleEffect(scale)
                
                Text("Applying theme...")
                    .font(.headline)
                    .foregroundColor(themeEngine.colors.text)
            }
            .padding(40)
            .liquidGlassCard()
            .shadow(color: themeEngine.colors.accent.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .onAppear {
            if animationsEnabled {
                // Rotation Animation
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
                
                // Scale Animation
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.0
                }
            } else {
                // Set values immediately without animation
                rotationAngle = 360
                scale = 1.0
            }
        }
    }
}

extension SettingsView {
    private func triggerTestNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // Ask for the first time
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("❌ Error requesting permission: \(error)")
                        return
                    }
                    if granted {
                        self.sendTestNotification()
                    } else {
                        print("❌ User has denied notifications.")
                    }
                }
            case .authorized, .provisional:
                self.sendTestNotification()
            case .denied:
                print("❌ Notifications have been disabled. Please enable them in system settings.")
            default:
                break
            }
        }
    }
    
    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Zentra Notification"
        content.body = "This is a test notification."
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error sending test notification: \(error)")
            } else {
                print("✅ Test notification sent.")
            }
        }
    }
}

private struct SettingsToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    var onChanged: ((Bool) -> Void)? = nil
    @EnvironmentObject var themeEngine: ThemeEngine

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(themeEngine.colors.text)
            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { newValue in
                    isOn = newValue
                    onChanged?(newValue)
                }
            ))
            .labelsHidden()
            .tint(themeEngine.colors.accent)
        }
        .padding(16)
        .liquidGlassBackground(cornerRadius: 12)
    }
}

