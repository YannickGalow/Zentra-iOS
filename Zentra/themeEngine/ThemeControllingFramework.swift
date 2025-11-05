import Foundation
import SwiftUI
import CryptoKit
import UIKit

/// Theme Controlling Framework (TCF)
/// Manages themes with support for .gtheme files, encryption, and device adaptation
class ThemeControllingFramework: ObservableObject {
    /// TCF Framework Version
    static let version = "1.0.0"
    
    @Published var availableThemes: [TCFThemeModel] = []
    @AppStorage("selectedThemeId") var selectedThemeId: String = "default" {
        didSet {
            objectWillChange.send()
        }
    }
    
    var currentTheme: TCFThemeModel {
        loadTheme(withId: selectedThemeId) ?? defaultTheme
    }
    
    var colors: ThemeColors {
        let theme = currentTheme
        // Auto-adapt to device defaults if enabled
        return theme.adaptsToDeviceDefaults ? theme.adaptedToDeviceDefaults().toThemeColors() : theme.toThemeColors()
    }
    
    init() {
        setupThemesFolderIfNeeded()
        loadThemes()
    }
    
    private let defaultTheme = TCFThemeModel(
        id: "default",
        name: "Liquid Glass",
        background: TCFThemeModel.ColorDefinition(hex: "#0A0E27"),
        text: TCFThemeModel.ColorDefinition(hex: "#FFFFFF"),
        accent: TCFThemeModel.ColorDefinition(hex: "#5B8DEF"),
        icon: TCFThemeModel.ColorDefinition(hex: "#FFFFFF"),
        buttonBackground: TCFThemeModel.ColorDefinition(hex: "#5B8DEF"),
        buttonText: TCFThemeModel.ColorDefinition(hex: "#FFFFFF"),
        fieldBackground: TCFThemeModel.ColorDefinition(hex: "#1A1F3A"),
        border: TCFThemeModel.ColorDefinition(hex: "#2A3F5F"),
        navbarBackground: TCFThemeModel.ColorDefinition(hex: "#0A0E27"),
        navbarText: TCFThemeModel.ColorDefinition(hex: "#FFFFFF"),
        error: TCFThemeModel.ColorDefinition(hex: "#FF6B6B"),
        warning: TCFThemeModel.ColorDefinition(hex: "#FFD93D"),
        adaptsToDeviceDefaults: true
    )
    
    private let lightTheme = TCFThemeModel(
        id: "light",
        name: "Liquid Glass Light",
        background: TCFThemeModel.ColorDefinition(hex: "#F0F4FF"),
        text: TCFThemeModel.ColorDefinition(hex: "#1A1F3A"),
        accent: TCFThemeModel.ColorDefinition(hex: "#5B8DEF"),
        icon: TCFThemeModel.ColorDefinition(hex: "#1A1F3A"),
        buttonBackground: TCFThemeModel.ColorDefinition(hex: "#5B8DEF"),
        buttonText: TCFThemeModel.ColorDefinition(hex: "#FFFFFF"),
        fieldBackground: TCFThemeModel.ColorDefinition(hex: "#FFFFFF"),
        border: TCFThemeModel.ColorDefinition(hex: "#D0D9F0"),
        navbarBackground: TCFThemeModel.ColorDefinition(hex: "#F0F4FF"),
        navbarText: TCFThemeModel.ColorDefinition(hex: "#1A1F3A"),
        error: TCFThemeModel.ColorDefinition(hex: "#FF6B6B"),
        warning: TCFThemeModel.ColorDefinition(hex: "#FFD93D"),
        adaptsToDeviceDefaults: true,
        deviceDefaultBase: "light"
    )
    
    private let darkTheme = TCFThemeModel(
        id: "dark",
        name: "Liquid Glass Dark",
        background: TCFThemeModel.ColorDefinition(hex: "#0A0E27"),
        text: TCFThemeModel.ColorDefinition(hex: "#FFFFFF"),
        accent: TCFThemeModel.ColorDefinition(hex: "#9BB5FF"),
        icon: TCFThemeModel.ColorDefinition(hex: "#FFFFFF"),
        buttonBackground: TCFThemeModel.ColorDefinition(hex: "#9BB5FF"),
        buttonText: TCFThemeModel.ColorDefinition(hex: "#0A0E27"),
        fieldBackground: TCFThemeModel.ColorDefinition(hex: "#1A1F3A"),
        border: TCFThemeModel.ColorDefinition(hex: "#2A3F5F"),
        navbarBackground: TCFThemeModel.ColorDefinition(hex: "#0A0E27"),
        navbarText: TCFThemeModel.ColorDefinition(hex: "#FFFFFF"),
        error: TCFThemeModel.ColorDefinition(hex: "#FF6B6B"),
        warning: TCFThemeModel.ColorDefinition(hex: "#FFD93D"),
        adaptsToDeviceDefaults: true,
        deviceDefaultBase: "dark"
    )
    
    /// Setup themes folder and create default themes
    private func setupThemesFolderIfNeeded() {
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let themesDir = docsURL.appendingPathComponent("themes")
        
        do {
            if !fileManager.fileExists(atPath: themesDir.path) {
                try fileManager.createDirectory(at: themesDir, withIntermediateDirectories: true)
                print("✅ TCF: Themes folder created.")
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            // Create default themes as .gtheme files
            let builtInThemes: [(TCFThemeModel, String)] = [
                (defaultTheme, "default.gtheme"),
                (lightTheme, "light.gtheme"),
                (darkTheme, "dark.gtheme")
            ]
            
            for (theme, filename) in builtInThemes {
                let themeFile = themesDir.appendingPathComponent(filename)
                if !fileManager.fileExists(atPath: themeFile.path) {
                    let data = try encoder.encode(theme)
                    try data.write(to: themeFile)
                    print("✅ TCF: \(filename) created.")
                }
            }
            
            // Set default theme if never set or invalid
            if selectedThemeId.isEmpty || loadTheme(withId: selectedThemeId) == nil {
                selectedThemeId = defaultTheme.id
            }
            
        } catch {
            print("❌ TCF Error setting up themes folder: \(error)")
        }
    }
    
    /// Loads all available themes
    func loadThemes() {
        availableThemes = []
        
        // Always add Built-in Themes
        let builtInThemes = [defaultTheme, lightTheme, darkTheme]
        let builtInThemeIds = Set(builtInThemes.map { $0.id })
        availableThemes.append(contentsOf: builtInThemes)
        
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let themesDir = docsURL.appendingPathComponent("themes")
        
        do {
            let files = try fileManager.contentsOfDirectory(at: themesDir, includingPropertiesForKeys: nil)
            for file in files where file.pathExtension == "gtheme" {
                do {
                    let data = try Data(contentsOf: file)
                    
                    // Check if encrypted
                    if ThemeEncryptionManager.shared.isEncrypted(data) {
                        // Skip encrypted themes from metadata list (require password to load)
                        continue
                    }
                    
                    // Decode as TCFThemeModel
                    if let tcfTheme = try? JSONDecoder().decode(TCFThemeModel.self, from: data) {
                        if !builtInThemeIds.contains(tcfTheme.id) {
                            availableThemes.append(tcfTheme)
                            print("✅ TCF: Theme loaded: \(tcfTheme.name)")
                        }
                    }
                } catch {
                    print("❌ TCF Error reading theme: \(file.lastPathComponent) - \(error)")
                }
            }
            
            // Fallback if no themes found
            if availableThemes.isEmpty {
                availableThemes = builtInThemes
            }
            
        } catch {
            print("⚠️ TCF Error reading themes folder: \(error)")
            availableThemes = builtInThemes
        }
    }
    
    /// Loads a single theme by ID
    func loadTheme(withId id: String, password: String? = nil) -> TCFThemeModel? {
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let themesDir = docsURL.appendingPathComponent("themes")
        let filename = "\(id).gtheme"
        let fileURL = themesDir.appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                
                // Check if encrypted
                if ThemeEncryptionManager.shared.isEncrypted(data) {
                    guard let password = password else {
                        print("⚠️ TCF: Theme '\(id)' is encrypted but no password provided")
                        return nil
                    }
                    
                    do {
                        let decrypted = try ThemeEncryptionManager.shared.decryptTheme(data, password: password)
                        // Auto-adapt on load
                        return decrypted.adaptsToDeviceDefaults ? decrypted.adaptedToDeviceDefaults() : decrypted
                    } catch {
                        print("❌ TCF: Failed to decrypt theme '\(id)': \(error)")
                        return nil
                    }
                }
                
                // Decode TCF format
                let tcfTheme = try JSONDecoder().decode(TCFThemeModel.self, from: data)
                return tcfTheme.adaptsToDeviceDefaults ? tcfTheme.adaptedToDeviceDefaults() : tcfTheme
                
            } catch {
                print("❌ TCF Error loading theme '\(id)': \(error)")
                return nil
            }
        }
        
        // Fallback to built-in themes
        switch id {
        case defaultTheme.id:
            return defaultTheme.adaptsToDeviceDefaults ? defaultTheme.adaptedToDeviceDefaults() : defaultTheme
        case lightTheme.id:
            return lightTheme.adaptsToDeviceDefaults ? lightTheme.adaptedToDeviceDefaults() : lightTheme
        case darkTheme.id:
            return darkTheme.adaptsToDeviceDefaults ? darkTheme.adaptedToDeviceDefaults() : darkTheme
        default:
            return nil
        }
    }
    
    /// Saves a theme with optional encryption
    func saveTheme(_ theme: TCFThemeModel, password: String? = nil) throws {
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let themesDir = docsURL.appendingPathComponent("themes")
        
        if !fileManager.fileExists(atPath: themesDir.path) {
            try fileManager.createDirectory(at: themesDir, withIntermediateDirectories: true)
        }
        
        let filename = "\(theme.id).gtheme"
        let fileURL = themesDir.appendingPathComponent(filename)
        
        let data: Data
        if let password = password {
            // Encrypt theme
            data = try ThemeEncryptionManager.shared.encryptTheme(theme, password: password)
        } else {
            // Save as plain JSON
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            data = try encoder.encode(theme)
        }
        
        try data.write(to: fileURL)
        loadThemes() // Refresh available themes
        print("✅ TCF: Theme saved: \(theme.name)")
    }
    
    /// Imports and adapts a theme automatically
    func importAndAdaptTheme(from url: URL, password: String? = nil) throws -> TCFThemeModel {
        // Only accept .gtheme files - reject files renamed to .txt or other extensions
        guard url.pathExtension.lowercased() == "gtheme" else {
            print("❌ TCF: Invalid file extension '\(url.pathExtension)'. Only .gtheme files are supported.")
            throw TCFError.invalidFileFormat
        }
        
        let data = try Data(contentsOf: url)
        
        // Check if encrypted
        if ThemeEncryptionManager.shared.isEncrypted(data) {
            guard let password = password else {
                throw TCFError.invalidPassword
            }
            let theme = try ThemeEncryptionManager.shared.decryptTheme(data, password: password)
            // Auto-adapt to device defaults
            let adapted = theme.adaptsToDeviceDefaults ? theme.adaptedToDeviceDefaults() : theme
            try saveTheme(adapted, password: password)
            return adapted
        }
        
        // Decode TCF format
        let tcfTheme = try JSONDecoder().decode(TCFThemeModel.self, from: data)
        // Auto-adapt on import
        let adapted = tcfTheme.adaptsToDeviceDefaults ? tcfTheme.adaptedToDeviceDefaults() : tcfTheme
        try saveTheme(adapted, password: password)
        return adapted
    }
    
    /// Deletes a theme
    func deleteTheme(_ theme: TCFThemeModel) {
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let themesDir = docsURL.appendingPathComponent("themes")
        let filename = "\(theme.id).gtheme"
        let fileURL = themesDir.appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                print("✅ TCF: Theme deleted: \(theme.name)")
            } catch {
                print("❌ TCF Error deleting theme: \(error)")
            }
        }
        
        loadThemes() // Refresh available themes
    }
    
    private func sendDiscordWidgetMessage(themeName: String, isSetupMessage: Bool = false) {
        // Discord integration code here (keeping existing implementation)
    }
}


