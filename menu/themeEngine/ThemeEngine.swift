import SwiftUI

class ThemeEngine: ObservableObject {
    @Published var availableThemes: [ThemeModel] = []
    @AppStorage("selectedThemeId") var selectedThemeId: String = "default"

    var currentTheme: ThemeModel {
        availableThemes.first(where: { $0.id == selectedThemeId }) ?? defaultTheme
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
        name: "Standard",
        background: "#1E1E1E",
        text: "#FFFFFF",
        accent: "#007AFF",
        icon: "#FFFFFF",
        buttonBackground: "#007AFF",
        buttonText: "#000000",
        fieldBackground: "#2C2C2E",
        border: "#3A3A3C",
        navbarBackground: "#1E1E1E",
        navbarText: "#FFFFFF"
    )

    private let lightTheme = ThemeModel(
        id: "light",
        name: "Light",
        background: "#FFFFFF",
        text: "#000000",
        accent: "#007AFF",
        icon: "#000000",
        buttonBackground: "#E0E0E0",
        buttonText: "#000000",
        fieldBackground: "#F2F2F2",
        border: "#CCCCCC",
        navbarBackground: "#F9F9F9",
        navbarText: "#000000"
    )

    private let darkTheme = ThemeModel(
        id: "dark",
        name: "Dark",
        background: "#121212",
        text: "#FFFFFF",
        accent: "#FF9500",
        icon: "#FFFFFF",
        buttonBackground: "#1F1F1F",
        buttonText: "#FFFFFF",
        fieldBackground: "#1C1C1E",
        border: "#333333",
        navbarBackground: "#121212",
        navbarText: "#FFFFFF"
    )

    private func setupThemesFolderIfNeeded() {
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let themesDir = docsURL.appendingPathComponent("themes")

        do {
            if !fileManager.fileExists(atPath: themesDir.path) {
                try fileManager.createDirectory(at: themesDir, withIntermediateDirectories: true)
                print("✅ Themes-Ordner erstellt.")
            }

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let themesToCreate = [
                ("default.json", defaultTheme),
                ("light.json", lightTheme),
                ("dark.json", darkTheme)
            ]

            for (filename, theme) in themesToCreate {
                let filePath = themesDir.appendingPathComponent(filename)
                if !fileManager.fileExists(atPath: filePath.path) {
                    let data = try encoder.encode(theme)
                    try data.write(to: filePath)
                    print("✅ \(filename) erstellt.")
                }
            }

            // Standard-Theme setzen, falls noch nie gesetzt
            if selectedThemeId.isEmpty {
                selectedThemeId = defaultTheme.id
            }

        } catch {
            print("❌ Fehler beim Setup des Themes-Ordners:", error)
        }
    }

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
                    let theme = try JSONDecoder().decode(ThemeModel.self, from: data)
                    availableThemes.append(theme)
                    print("✅ Theme geladen:", theme.name)
                } catch {
                    print("❌ Fehler beim Dekodieren:", file.lastPathComponent, error)
                }
            }

            if !availableThemes.contains(where: { $0.id == selectedThemeId }) {
                selectedThemeId = defaultTheme.id
            }

            // 🆕 Watch-Sync
            WatchThemeManager.shared.sendThemesToWatch(availableThemes)
            WatchThemeManager.shared.updateApplicationContext(with: availableThemes)

        } catch {
            print("⚠️ Fehler beim Lesen des Themes-Ordners:", error)
        }
    }
}
