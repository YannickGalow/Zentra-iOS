import SwiftUI
import UIKit
import UniformTypeIdentifiers
import UserNotifications
import Darwin

struct SettingsView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
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
    @State private var themeToDelete: TCFThemeModel? = nil
    @State private var showingImporter: Bool = false
    @State private var isChangingTheme: Bool = false
    @State private var customDiscordMessage: String = ""
    @State private var showPasswordPrompt: Bool = false
    @State private var themePassword: String = ""
    @State private var pendingThemeURL: URL? = nil
    @State private var showDeveloperInfo: Bool = false
    @State private var showLoginRequiredAlert: Bool = false
    @State private var showUUIDCopiedToast: Bool = false
    @AppStorage("deviceUUID") private var deviceUUID: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tcf: TCF
    @EnvironmentObject var webhookManager: DiscordWebhookManager
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Text("Settings")
                            .font(.largeTitle.bold())
                            .foregroundColor(tcf.colors.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                        
                        if !isLoggedIn {
                            VStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(tcf.colors.text.opacity(0.5))
                                
                                Text("Login Required")
                                    .font(.headline)
                                    .foregroundColor(tcf.colors.text.opacity(0.7))
                                
                                Text("Please log in to access settings.")
                                    .font(.subheadline)
                                    .foregroundColor(tcf.colors.text.opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .liquidGlassCard()
                        }

                        anmeldungCard

                        privatsphaereCard

                        discordLoggingCard

                        designCard
                        
                        supportCard
                    
                    if UserDefaults.standard.bool(forKey: "developerOptionsEnabled") {
                        developerOptionsCard
                    }
                    
                    Spacer(minLength: 20)
                    
                    Text("© 2025 Yannick Galow")
                        .font(.footnote)
                        .foregroundColor(tcf.colors.text.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 60)
                .opacity(isChangingTheme ? (animationsEnabled ? 0.3 : 0.5) : (isLoggedIn ? 1.0 : 0.5))
                .blur(radius: isChangingTheme ? (animationsEnabled ? 3 : 0) : (isLoggedIn ? 0 : 2))
                .disabled(!isLoggedIn)
            }
            .background(tcf.colors.background.ignoresSafeArea())
            
            // Loading animation during theme change
            if isChangingTheme {
                ThemeLoadingView()
                    .environmentObject(tcf)
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
                    .foregroundColor(tcf.colors.accent)
                }
            }
            .alert("Login Required", isPresented: $showLoginRequiredAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please log in to access settings.")
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
                            themeToDelete = nil
                        }
                    },
                    secondaryButton: .cancel(Text("Cancel")) {
                        themeToDelete = nil
                    }
                )
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [UTType(filenameExtension: "gtheme") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .sheet(isPresented: $showPasswordPrompt) {
            ThemePasswordView(
                password: $themePassword,
                onConfirm: {
                    if let url = pendingThemeURL {
                        importThemeWithPassword(url: url, password: themePassword)
                        themePassword = ""
                        pendingThemeURL = nil
                        showPasswordPrompt = false
                    }
                },
                onCancel: {
                    themePassword = ""
                    pendingThemeURL = nil
                    showPasswordPrompt = false
                }
            )
            .environmentObject(tcf)
        }
            .sheet(isPresented: $showDeveloperInfo) {
            DeveloperInfoView()
                .environmentObject(tcf)
        }
        .alert("Login Required", isPresented: $showLoginRequiredAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please log in to change settings.")
        }
    }
    
    // MARK: - Helper Functions
    
    private func checkLoginRequired() -> Bool {
        if !isLoggedIn {
            showLoginRequiredAlert = true
            return false
        }
        return true
    }

    private var anmeldungCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header with accent bar
            HStack(spacing: 12) {
                Rectangle()
                    .fill(tcf.colors.accent)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                Text("Login")
                    .font(.title3.bold())
                    .foregroundColor(tcf.colors.accent)
            }
            SettingsToggleRow(
                label: "Remember login",
                isOn: $rememberLogin,
                isDisabled: !isLoggedIn
            ) { newValue in
                guard checkLoginRequired() else { return }
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
                    .fill(tcf.colors.accent)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                Text("Privacy")
                    .font(.title3.bold())
                    .foregroundColor(tcf.colors.accent)
            }

            VStack(spacing: 20) {
                SettingsToggleRow(
                    label: "Trust links from unknown sources",
                    isOn: $trustUnknownLinks,
                    isDisabled: !isLoggedIn
                ) { newValue in
                    guard checkLoginRequired() else { return }
                    self.handleTrustUnknownLinksChanged(newValue)
                }

                SettingsToggleRow(
                    label: "Enable Face ID / Passcode protection",
                    isOn: $useBiometrics,
                    isDisabled: !isLoggedIn
                ) { newValue in
                    guard checkLoginRequired() else { return }
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
                    .fill(tcf.colors.accent)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                Text("Discord Integration Settings")
                    .font(.title3.bold())
                    .foregroundColor(tcf.colors.accent)
            }

            ZStack {
                TextField("Paste webhook URL", text: $discordWebhookURL)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .padding()
                    .liquidGlassBackground(cornerRadius: 12)
                    .foregroundColor(isLoggedIn ? tcf.colors.text : tcf.colors.text.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(tcf.colors.accent.opacity(0.5), lineWidth: 1)
                    )
                    .disabled(!isLoggedIn)
                if isLoggedIn {
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
                } else {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showLoginRequiredAlert = true
                        }
                }
            }
            .opacity(isLoggedIn ? 1.0 : 0.6)

            // Only show settings when valid webhook URL is entered
            if let webhookURL = URL(string: discordWebhookURL),
               webhookURL.absoluteString.contains("discord.com/api/webhooks/") {

                // Toggle to enable/disable custom message feature
                SettingsToggleRow(
                    label: "Enable quick messages text field",
                    isOn: $showCustomDiscordMessage,
                    isDisabled: !isLoggedIn
                ) { newValue in
                    guard checkLoginRequired() else { return }
                }

                // Custom message text field (only shown when enabled)
                if showCustomDiscordMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom Message")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(tcf.colors.text.opacity(0.8))
                        
                        TextField("Enter your message...", text: $customDiscordMessage, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.6)
                            )
                            .foregroundColor(isLoggedIn ? tcf.colors.text : tcf.colors.text.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(tcf.colors.accent.opacity(0.5), lineWidth: 1)
                            )
                            .lineLimit(3...6)
                            .disabled(!isLoggedIn)
                            .opacity(isLoggedIn ? 1.0 : 0.6)
                    }

                    Button("Send custom message") {
                        guard checkLoginRequired() else { return }
                        guard !customDiscordMessage.isEmpty else { return }
                        Task {
                            await webhookManager.logCustomMessage(text: customDiscordMessage)
                            customDiscordMessage = ""
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: tcf.colors.accent, foregroundColor: tcf.colors.background))
                    .disabled(customDiscordMessage.isEmpty)
                    .opacity(customDiscordMessage.isEmpty ? 0.6 : 1.0)
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    SettingsToggleRow(
                        label: "Post login/logout",
                        isOn: $logLoginLogout,
                        isDisabled: !isLoggedIn
                    ) { newValue in
                        guard checkLoginRequired() else { return }
                    }
                    SettingsToggleRow(
                        label: "Post theme changes",
                        isOn: $logThemeChanges,
                        isDisabled: !isLoggedIn
                    ) { newValue in
                        guard checkLoginRequired() else { return }
                    }
                    SettingsToggleRow(
                        label: "Post settings changes",
                        isOn: $logSettingsChanges,
                        isDisabled: !isLoggedIn
                    ) { newValue in
                        guard checkLoginRequired() else { return }
                    }
                }
                
                // Send test post button at the bottom
                Button("Send test post") {
                    guard checkLoginRequired() else { return }
                    Task {
                        await webhookManager.logTestPost()
                    }
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: tcf.colors.accent.opacity(0.7), foregroundColor: tcf.colors.background))
            }
        }
        .padding(20)
        .liquidGlassCard()
    }

    private var designCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            let textColor = tcf.colors.text

            HStack(spacing: 12) {
                Rectangle()
                    .fill(tcf.colors.accent)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                Text("Design")
                    .font(.title3.bold())
                    .foregroundColor(tcf.colors.accent)
            }

            ForEach(tcf.availableThemes) { theme in
                HStack {
                    Button {
                        guard checkLoginRequired() else { return }
                        Task {
                            await changeTheme(to: theme.id)
                        }
                    } label: {
                        HStack {
                            Text(theme.name)
                                .foregroundColor(isLoggedIn ? textColor : textColor.opacity(0.5))
                            Spacer()
                            if tcf.selectedThemeId == theme.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(tcf.colors.accent)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!isLoggedIn)
                    .opacity(isLoggedIn ? 1.0 : 0.6)
                    
                    // Built-in Themes (default, light, dark) können nicht gelöscht werden
                    let builtInThemeIds = ["default", "light", "dark"]
                    if !builtInThemeIds.contains(theme.id) && isLoggedIn {
                        Button {
                            guard checkLoginRequired() else { return }
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
                guard checkLoginRequired() else { return }
                showingImporter = true
            }
            .buttonStyle(PrimaryButtonStyle(backgroundColor: tcf.colors.accent, foregroundColor: tcf.colors.background))
            .disabled(!isLoggedIn)
            .opacity(isLoggedIn ? 1.0 : 0.6)
        }
        .padding(20)
        .liquidGlassCard()
    }
    
    private var supportCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(tcf.colors.accent)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                Text("Support")
                    .font(.title3.bold())
                    .foregroundColor(tcf.colors.accent)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Device UUID")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(tcf.colors.text.opacity(0.7))
                
                Text(getDeviceUUID())
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(tcf.colors.text)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                            .opacity(0.5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(tcf.colors.accent.opacity(0.3), lineWidth: 1)
                    )
                
                Button(action: {
                    copyUUIDToClipboard()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Copy UUID to Clipboard")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: tcf.colors.accent, foregroundColor: .white))
                .disabled(getDeviceUUID() == "Not set")
                .opacity(getDeviceUUID() == "Not set" ? 0.6 : 1.0)
            }
        }
        .padding(20)
        .liquidGlassCard()
        .overlay(
            // Toast overlay
            VStack {
                Spacer()
                if showUUIDCopiedToast {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("UUID copied to clipboard")
                            .foregroundColor(.white)
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 100)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showUUIDCopiedToast)
        )
    }
    
    private func getDeviceUUID() -> String {
        // Try multiple sources for UUID
        if !deviceUUID.isEmpty {
            return deviceUUID
        }
        
        // Try UserDefaults directly
        if let uuid = UserDefaults.standard.string(forKey: "deviceUUID"), !uuid.isEmpty {
            return uuid
        }
        
        return "Not set"
    }
    
    private func copyUUIDToClipboard() {
        let uuid = getDeviceUUID()
        guard uuid != "Not set" else { return }
        
        // Copy to clipboard
        UIPasteboard.general.string = uuid
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Show toast
        withAnimation {
            showUUIDCopiedToast = true
        }
        
        // Hide toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showUUIDCopiedToast = false
            }
        }
    }
    
    private var developerOptionsCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(tcf.colors.accent)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                Text("Developer Options")
                    .font(.title3.bold())
                    .foregroundColor(tcf.colors.accent)
            }
            
            // Performance Settings
            SettingsToggleRow(
                label: "Enable Animations",
                isOn: $animationsEnabled,
                isDisabled: !isLoggedIn
            ) { newValue in
                guard checkLoginRequired() else { return }
            }
            
            // Developer Information Button
            Button("Show Developer Information") {
                showDeveloperInfo = true
            }
            .buttonStyle(PrimaryButtonStyle(backgroundColor: tcf.colors.accent, foregroundColor: .black))
            .disabled(!isLoggedIn)
            .opacity(isLoggedIn ? 1.0 : 0.6)
            
            // Send Test Notification Button
            Button("Send Test Notification") {
                triggerTestNotification()
            }
            .buttonStyle(PrimaryButtonStyle(backgroundColor: tcf.colors.accent, foregroundColor: .black))
            .disabled(!isLoggedIn)
            .opacity(isLoggedIn ? 1.0 : 0.6)
        }
        .padding(20)
        .liquidGlassCard()
    }

    private func deleteTheme(_ theme: TCFThemeModel) {
        // Built-in Themes cannot be deleted
        let builtInThemeIds = ["default", "light", "dark"]
        if builtInThemeIds.contains(theme.id) {
            print("⚠️ TCF: Built-in theme cannot be deleted: \(theme.name)")
            return
        }
        
        tcf.deleteTheme(theme)
        
        // Switch to default if deleted theme was active
        if tcf.selectedThemeId == theme.id {
            tcf.selectedThemeId = "default"
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

                // Validate file extension - only .gtheme files are allowed
                guard selectedFile.pathExtension.lowercased() == "gtheme" else {
                    print("❌ TCF: Invalid file extension. Only .gtheme files are supported. File has extension: \(selectedFile.pathExtension)")
                    // Show corruption error - file was renamed or has wrong extension
                    return
                }

                do {
                    // Check if theme is encrypted
                    let data = try Data(contentsOf: selectedFile)
                    
                    // Validate file content structure
                    if !ThemeEncryptionManager.shared.isEncrypted(data) {
                        // Try to decode as JSON to validate structure
                        do {
                            _ = try JSONDecoder().decode(TCFThemeModel.self, from: data)
                        } catch {
                            print("❌ TCF: File appears corrupted or invalid. Error: \(error)")
                            // Show corruption error
                            return
                        }
                    }
                    
                    if ThemeEncryptionManager.shared.isEncrypted(data) {
                        // Request password
                        pendingThemeURL = selectedFile
                        showPasswordPrompt = true
                        return
                    }
                    
                    // Import and adapt theme automatically
                    let importedTheme = try tcf.importAndAdaptTheme(from: selectedFile)
                    
                    // Activate the imported theme
                    tcf.selectedThemeId = importedTheme.id
                    print("✅ TCF: Theme imported and adapted: \(importedTheme.name)")
                    
                    if logThemeChanges {
                        Task {
                            await webhookManager.logThemeChange(themeName: importedTheme.name)
                        }
                    }
                } catch {
                    print("❌ TCF Import error: \(error)")
                    // Show corruption error for non-.gtheme files or invalid content
                    if error is DecodingError {
                        print("❌ TCF: File appears corrupted or invalid format.")
                    }
                }
            }
        case .failure(let error):
            print("❌ TCF Import error: \(error)")
        }
    }
    
    private func importThemeWithPassword(url: URL, password: String) {
        do {
            let accessGranted = url.startAccessingSecurityScopedResource()
            defer {
                if accessGranted {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            // Import encrypted theme
            let importedTheme = try tcf.importAndAdaptTheme(from: url, password: password)
            
            // Activate the imported theme
            tcf.selectedThemeId = importedTheme.id
            print("✅ TCF: Encrypted theme imported and adapted: \(importedTheme.name)")
            
            if logThemeChanges {
                Task {
                    await webhookManager.logThemeChange(themeName: importedTheme.name)
                }
            }
        } catch {
            print("❌ TCF: Failed to import encrypted theme: \(error)")
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
                tcf.selectedThemeId = themeId
                tcf.objectWillChange.send() // Force UI update
                // Mark that user has manually set a theme
                UserDefaults.standard.set(true, forKey: "themeWasSetByUser")
            }
        }
        
        // Theme vollständig laden lassen und UI aktualisieren
        if animationsEnabled {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 Sekunden
        } else {
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 Sekunden
        }
        
        // Discord Logging (if enabled)
        if logThemeChanges,
           let theme = tcf.availableThemes.first(where: { $0.id == themeId }) {
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
        tcf.selectedThemeId = selectedId
        tcf.objectWillChange.send() // Force UI update
        if logThemeChanges,
           let theme = tcf.availableThemes.first(where: { $0.id == selectedId }) {
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

// MARK: - Developer Info View
struct DeveloperInfoView: View {
    @EnvironmentObject var tcf: TCF
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        tcf.colors.accent.opacity(0.3),
                                        tcf.colors.accent.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(tcf.colors.accent)
                    }
                    .padding(.top, 20)
                    
                    Text("Developer Information")
                        .font(.title2.bold())
                        .foregroundColor(tcf.colors.text)
                    
                    VStack(spacing: 20) {
                        InfoRow(title: "Device UUID", value: getDeviceUUID())
                        InfoRow(title: "App Name", value: appName)
                        InfoRow(title: "App Version", value: appVersion)
                        InfoRow(title: "Build Number", value: buildNumber)
                        InfoRow(title: "Bundle Identifier", value: bundleIdentifier)
                        InfoRow(title: "TCF Version", value: ThemeControllingFramework.version)
                        InfoRow(title: "iOS Version", value: iosVersion)
                        InfoRow(title: "Device Model", value: deviceModel)
                        InfoRow(title: "Device Name", value: deviceName)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical, 20)
            }
            .background(tcf.colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(tcf.colors.accent)
                }
            }
        }
    }
    
    // MARK: - App Information
    private var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? 
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? 
        "Zentra"
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    private var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "gv.Zentra"
    }
    
    private var iosVersion: String {
        UIDevice.current.systemVersion
    }
    
    private var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        return modelCode ?? UIDevice.current.model
    }
    
    @AppStorage("deviceUUID") private var deviceUUID: String = ""
    
    private var deviceName: String {
        UIDevice.current.name
    }
    
    private func getDeviceUUID() -> String {
        // Try multiple sources for UUID - Keychain has priority (survives app reinstall)
        let keychainService = "com.zentra.deviceUUID"
        let keychainAccount = "deviceUUID"
        
        // First check Keychain (persists after app reinstall)
        if let keychainUUID = KeychainHelper.shared.read(service: keychainService, account: keychainAccount), !keychainUUID.isEmpty {
            return keychainUUID
        }
        
        // Then check @AppStorage
        if !deviceUUID.isEmpty {
            return deviceUUID
        }
        
        // Then check UserDefaults directly
        if let uuid = UserDefaults.standard.string(forKey: "deviceUUID"), !uuid.isEmpty {
            return uuid
        }
        
        return "Not set"
    }
}

// MARK: - Info Row Component
private struct InfoRow: View {
    let title: String
    let value: String
    
    @EnvironmentObject var tcf: TCF
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(tcf.colors.text.opacity(0.7))
            
            Text(value)
                .font(.body.weight(.semibold))
                .foregroundColor(tcf.colors.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(tcf.colors.accent.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Theme Loading View
struct ThemeLoadingView: View {
    @EnvironmentObject var tcf: TCF
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
                                    tcf.colors.accent.opacity(0.3),
                                    tcf.colors.accent.opacity(0.1)
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
                                    tcf.colors.accent,
                                    tcf.colors.accent.opacity(0.6)
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
                    .foregroundColor(tcf.colors.text)
            }
            .padding(40)
            .liquidGlassCard()
            .shadow(color: tcf.colors.accent.opacity(0.3), radius: 20, x: 0, y: 10)
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
    var isDisabled: Bool = false
    var onChanged: ((Bool) -> Void)? = nil
    @EnvironmentObject var tcf: TCF

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(isDisabled ? tcf.colors.text.opacity(0.5) : tcf.colors.text)
            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { newValue in
                    if !isDisabled {
                        isOn = newValue
                        onChanged?(newValue)
                    }
                }
            ))
            .labelsHidden()
            .tint(tcf.colors.accent)
            .disabled(isDisabled)
        }
        .padding(16)
        .liquidGlassBackground(cornerRadius: 12)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

