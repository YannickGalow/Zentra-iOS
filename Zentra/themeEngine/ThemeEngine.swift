import Foundation
import SwiftUI

class ThemeEngine: ObservableObject {
    @Published var availableThemes: [ThemeModel] = []
    @AppStorage("selectedThemeId") var selectedThemeId: String = "default" {
        didSet {
            objectWillChange.send()
        }
    }

    var currentTheme: ThemeModel {
        // Lazy loading: Lade Theme erst bei Zugriff anhand der ausgewählten ID
        loadTheme(withId: selectedThemeId) ?? defaultTheme
    }

    var colors: ThemeColors {
        currentTheme.toThemeColors()
    }

    init() {
        setupThemesFolderIfNeeded()
        loadThemes()
    }

    private let defaultTheme = ThemeModel(
        id: "default",
        name: "Liquid Glass",
        background: "#0A0E27",
        text: "#FFFFFF",
        accent: "#5B8DEF",
        icon: "#FFFFFF",
        buttonBackground: "#5B8DEF",
        buttonText: "#FFFFFF",
        fieldBackground: "#1A1F3A",
        border: "#2A3F5F",
        navbarBackground: "#0A0E27",
        navbarText: "#FFFFFF",
        error: "#FF6B6B",
        warning: "#FFD93D"
    )

    private let lightTheme = ThemeModel(
        id: "light",
        name: "Liquid Glass Light",
        background: "#F0F4FF",
        text: "#1A1F3A",
        accent: "#5B8DEF",
        icon: "#1A1F3A",
        buttonBackground: "#5B8DEF",
        buttonText: "#FFFFFF",
        fieldBackground: "#FFFFFF",
        border: "#D0D9F0",
        navbarBackground: "#F0F4FF",
        navbarText: "#1A1F3A",
        error: "#FF6B6B",
        warning: "#FFD93D"
    )

    private let darkTheme = ThemeModel(
        id: "dark",
        name: "Liquid Glass Dark",
        background: "#0A0E27",
        text: "#FFFFFF",
        accent: "#9BB5FF",
        icon: "#FFFFFF",
        buttonBackground: "#9BB5FF",
        buttonText: "#0A0E27",
        fieldBackground: "#1A1F3A",
        border: "#2A3F5F",
        navbarBackground: "#0A0E27",
        navbarText: "#FFFFFF",
        error: "#FF6B6B",
        warning: "#FFD93D"
    )

    /// Setup des Themes-Ordners: Nur das defaultTheme wird bei Bedarf automatisch angelegt.
    private func setupThemesFolderIfNeeded() {
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let themesDir = docsURL.appendingPathComponent("themes")

        do {
            if !fileManager.fileExists(atPath: themesDir.path) {
                try fileManager.createDirectory(at: themesDir, withIntermediateDirectories: true)
                print("✅ Themes folder created.")
                sendDiscordWidgetMessage(themeName: defaultTheme.name, isSetupMessage: true)
            }

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            // Nur das Default Theme wird bei Bedarf neu angelegt
            let defaultThemeFile = themesDir.appendingPathComponent("default.json")
            if !fileManager.fileExists(atPath: defaultThemeFile.path) {
                let data = try encoder.encode(defaultTheme)
                try data.write(to: defaultThemeFile)
                print("✅ default.json erstellt.")
            }

            // Standard-Theme setzen, falls noch nie gesetzt oder fehlerhaft
            if selectedThemeId.isEmpty || loadTheme(withId: selectedThemeId) == nil {
                selectedThemeId = defaultTheme.id
            }

        } catch {
            print("❌ Error setting up themes folder: \(error)")
        }
    }

    /// Lädt die Metadaten (id und name) aller verfügbaren Themes ohne komplettes Decodieren
    func loadThemes() {
        availableThemes = []

        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let themesDir = docsURL.appendingPathComponent("themes")

        do {
            let files = try fileManager.contentsOfDirectory(at: themesDir, includingPropertiesForKeys: nil)
            for file in files where file.pathExtension == "json" {
                do {
                    let data = try Data(contentsOf: file)
                    // Versuche nur id und name zu lesen, ohne alles zu decodieren
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let id = jsonObject["id"] as? String,
                       let name = jsonObject["name"] as? String {
                        let themeModel = ThemeModel(
                            id: id,
                            name: name,
                            background: "",
                            text: "",
                            accent: "",
                            icon: "",
                            buttonBackground: "",
                            buttonText: "",
                            fieldBackground: "",
                            border: "",
                            navbarBackground: "",
                            navbarText: "",
                            error: "",
                            warning: ""
                        )
                        availableThemes.append(themeModel)
                        print("✅ Theme-Metadaten geladen: \(name)")
                    } else {
                        print("❌ Fehlende id oder name im Theme: \(file.lastPathComponent)")
                    }
                } catch {
                    print("❌ Fehler beim Lesen der Theme-Metadaten: \(file.lastPathComponent) - \(error)")
                }
            }

            // Fallback, falls kein Theme gefunden wurde
            if availableThemes.isEmpty {
                // Nur id und name der Default-Themes
                availableThemes = [
                    ThemeModel(
                        id: defaultTheme.id,
                        name: defaultTheme.name,
                        background: defaultTheme.background,
                        text: defaultTheme.text,
                        accent: defaultTheme.accent,
                        icon: defaultTheme.icon,
                        buttonBackground: defaultTheme.buttonBackground,
                        buttonText: defaultTheme.buttonText,
                        fieldBackground: defaultTheme.fieldBackground,
                        border: defaultTheme.border,
                        navbarBackground: defaultTheme.navbarBackground,
                        navbarText: defaultTheme.navbarText,
                        error: defaultTheme.error,
                        warning: defaultTheme.warning
                    ),
                    ThemeModel(
                        id: lightTheme.id,
                        name: lightTheme.name,
                        background: lightTheme.background,
                        text: lightTheme.text,
                        accent: lightTheme.accent,
                        icon: lightTheme.icon,
                        buttonBackground: lightTheme.buttonBackground,
                        buttonText: lightTheme.buttonText,
                        fieldBackground: lightTheme.fieldBackground,
                        border: lightTheme.border,
                        navbarBackground: lightTheme.navbarBackground,
                        navbarText: lightTheme.navbarText,
                        error: lightTheme.error,
                        warning: lightTheme.warning
                    ),
                    ThemeModel(
                        id: darkTheme.id,
                        name: darkTheme.name,
                        background: darkTheme.background,
                        text: darkTheme.text,
                        accent: darkTheme.accent,
                        icon: darkTheme.icon,
                        buttonBackground: darkTheme.buttonBackground,
                        buttonText: darkTheme.buttonText,
                        fieldBackground: darkTheme.fieldBackground,
                        border: darkTheme.border,
                        navbarBackground: darkTheme.navbarBackground,
                        navbarText: darkTheme.navbarText,
                        error: darkTheme.error,
                        warning: darkTheme.warning
                    )
                ]
            }

            // Ensure default theme is always on top
            if let defaultIndex = availableThemes.firstIndex(where: { $0.id == defaultTheme.id }), defaultIndex > 0 {
                let defaultTheme = availableThemes.remove(at: defaultIndex)
                availableThemes.insert(defaultTheme, at: 0)
            }

            if !availableThemes.contains(where: { $0.id == selectedThemeId }) {
                selectedThemeId = defaultTheme.id
            }

        } catch {
            print("⚠️ Fehler beim Lesen des Themes-Ordners: \(error)")
            availableThemes = [
                ThemeModel(
                    id: defaultTheme.id,
                    name: defaultTheme.name,
                    background: defaultTheme.background,
                    text: defaultTheme.text,
                    accent: defaultTheme.accent,
                    icon: defaultTheme.icon,
                    buttonBackground: defaultTheme.buttonBackground,
                    buttonText: defaultTheme.buttonText,
                    fieldBackground: defaultTheme.fieldBackground,
                    border: defaultTheme.border,
                    navbarBackground: defaultTheme.navbarBackground,
                    navbarText: defaultTheme.navbarText,
                    error: defaultTheme.error,
                    warning: defaultTheme.warning
                ),
                ThemeModel(
                    id: lightTheme.id,
                    name: lightTheme.name,
                    background: lightTheme.background,
                    text: lightTheme.text,
                    accent: lightTheme.accent,
                    icon: lightTheme.icon,
                    buttonBackground: lightTheme.buttonBackground,
                    buttonText: lightTheme.buttonText,
                    fieldBackground: lightTheme.fieldBackground,
                    border: lightTheme.border,
                    navbarBackground: lightTheme.navbarBackground,
                    navbarText: lightTheme.navbarText,
                    error: lightTheme.error,
                    warning: lightTheme.warning
                ),
                ThemeModel(
                    id: darkTheme.id,
                    name: darkTheme.name,
                    background: darkTheme.background,
                    text: darkTheme.text,
                    accent: darkTheme.accent,
                    icon: darkTheme.icon,
                    buttonBackground: darkTheme.buttonBackground,
                    buttonText: darkTheme.buttonText,
                    fieldBackground: darkTheme.fieldBackground,
                    border: darkTheme.border,
                    navbarBackground: darkTheme.navbarBackground,
                    navbarText: darkTheme.navbarText,
                    error: darkTheme.error,
                    warning: darkTheme.warning
                )
            ]
            selectedThemeId = defaultTheme.id
        }
    }

    /// Lädt ein einzelnes Theme anhand der ID, gibt nil zurück, falls nicht vorhanden oder Fehler
    func loadTheme(withId id: String) -> ThemeModel? {
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let themesDir = docsURL.appendingPathComponent("themes")
        let filename = "\(id).json"
        let fileURL = themesDir.appendingPathComponent(filename)

        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let theme = try JSONDecoder().decode(ThemeModel.self, from: data)
                return theme
            } catch {
                print("❌ Fehler beim Laden des Themes '\(id)': \(error)")
                return nil
            }
        } else {
            // Fallback für default, light, dark, falls Datei nicht existiert
            switch id {
            case defaultTheme.id:
                return defaultTheme
            case lightTheme.id:
                return lightTheme
            case darkTheme.id:
                return darkTheme
            default:
                return nil
            }
        }
    }

    private func sendDiscordWidgetMessage(themeName: String, isSetupMessage: Bool = false) {
        guard let url = URL(string: "DEIN_DISCORD_WEBHOOK_URL") else {
            print("❌ Discord Webhook URL fehlt oder ungültig.")
            return
        }
        
        let accentColor = 5814783
        
        let footerText: String
        let title: String
        let description: String
        
        if isSetupMessage {
            title = "🎨 Theme erstellt"
            description = "Das Theme **\(themeName)** wurde erfolgreich eingerichtet und ist jetzt verfügbar."
            footerText = "✨ Zentra App Logging • \(formattedCurrentDateTime())"
        } else {
            title = "🎨 Theme geändert"
            description = "Das Theme wurde geändert auf **\(themeName)**."
            footerText = "✨ Zentra App Logging • \(formattedCurrentDateTime())"
        }
        
        let embed: [String: Any] = [
            "title": title,
            "description": description,
            "color": accentColor,
            "footer": [
                "text": footerText
            ]
        ]
        
        let payload: [String: Any] = [
            "embeds": [embed]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request).resume()
    }

    private func formattedCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy, HH:mm"
        return formatter.string(from: Date())
    }
    
    public func logThemeChanged(to theme: ThemeModel) {
        sendDiscordWidgetMessage(themeName: theme.name, isSetupMessage: false)
    }
}
