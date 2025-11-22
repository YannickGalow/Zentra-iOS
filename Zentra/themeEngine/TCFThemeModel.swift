import SwiftUI
import Foundation
import CryptoKit
import UIKit

/// Enhanced Theme Model for Theme Controlling Framework (TCF)
/// Supports individual item definitions for optimal customization
struct TCFThemeModel: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var version: String = "1.0"
    var isEncrypted: Bool = false
    var passwordHash: String? = nil // SHA256 hash of password for verification
    
    // Individual color definitions for optimal customization
    struct ColorDefinition: Codable, Equatable {
        var hex: String
        var opacity: Double = 1.0
        var description: String? = nil // Optional description for customization tools
    }
    
    // Individual item definitions
    var background: ColorDefinition
    var text: ColorDefinition
    var accent: ColorDefinition
    var icon: ColorDefinition
    var buttonBackground: ColorDefinition
    var buttonText: ColorDefinition
    var fieldBackground: ColorDefinition
    var border: ColorDefinition
    var navbarBackground: ColorDefinition
    var navbarText: ColorDefinition
    var error: ColorDefinition
    var warning: ColorDefinition
    
    // Additional customization options
    var cornerRadius: Double? = nil
    var blurRadius: Double? = nil
    var shadowOpacity: Double? = nil
    
    // Device default adaptation
    var adaptsToDeviceDefaults: Bool = true
    var deviceDefaultBase: String? = nil // "light", "dark", or nil for custom
    
    func toThemeColors() -> ThemeColors {
        ThemeColors(
            background: Color(hex: background.hex).opacity(background.opacity),
            text: Color(hex: text.hex).opacity(text.opacity),
            accent: Color(hex: accent.hex).opacity(accent.opacity),
            icon: Color(hex: icon.hex).opacity(icon.opacity),
            buttonBackground: Color(hex: buttonBackground.hex).opacity(buttonBackground.opacity),
            buttonText: Color(hex: buttonText.hex).opacity(buttonText.opacity),
            fieldBackground: Color(hex: fieldBackground.hex).opacity(fieldBackground.opacity),
            border: Color(hex: border.hex).opacity(border.opacity),
            navbarBackground: Color(hex: navbarBackground.hex).opacity(navbarBackground.opacity),
            navbarText: Color(hex: navbarText.hex).opacity(navbarText.opacity),
            error: Color(hex: error.hex).opacity(error.opacity),
            warning: Color(hex: warning.hex).opacity(warning.opacity)
        )
    }
    
    
    /// Adapts theme to device defaults
    func adaptedToDeviceDefaults() -> TCFThemeModel {
        guard adaptsToDeviceDefaults else { return self }
        
        let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        let isDarkMode = userInterfaceStyle == .dark
        
        // Auto-adapt colors based on device appearance
        var adapted = self
        
        if isDarkMode {
            // Enhance contrast for dark mode
            adapted.background.opacity = max(background.opacity, 0.95)
            adapted.text.opacity = max(text.opacity, 0.95)
        } else {
            // Adjust for light mode
            adapted.background.opacity = min(background.opacity, 0.98)
            adapted.text.opacity = max(text.opacity, 0.9)
        }
        
        return adapted
    }
}

/// Theme Encryption Manager
class ThemeEncryptionManager {
    static let shared = ThemeEncryptionManager()
    
    private init() {}
    
    /// Encrypts theme data with password
    func encryptTheme(_ theme: TCFThemeModel, password: String) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let themeData = try encoder.encode(theme)
        
        // Generate key from password
        let key = SymmetricKey(data: SHA256.hash(data: password.data(using: .utf8)!))
        
        // Encrypt using AES-GCM
        let sealedBox = try AES.GCM.seal(themeData, using: key)
        
        // Create encrypted theme structure
        var encryptedTheme = theme
        encryptedTheme.isEncrypted = true
        encryptedTheme.passwordHash = SHA256.hash(data: password.data(using: .utf8)!).compactMap { String(format: "%02x", $0) }.joined()
        
        // Combine metadata with encrypted data
        var encryptedPackage: [String: Any] = [:]
        encryptedPackage["metadata"] = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(encryptedTheme)) as? [String: Any]
        encryptedPackage["encryptedData"] = sealedBox.combined?.base64EncodedString()
        
        return try JSONSerialization.data(withJSONObject: encryptedPackage, options: .prettyPrinted)
    }
    
    /// Decrypts theme data with password
    func decryptTheme(_ data: Data, password: String) throws -> TCFThemeModel {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let encryptedDataString = json["encryptedData"] as? String,
              let encryptedData = Data(base64Encoded: encryptedDataString) else {
            throw TCFError.invalidEncryptedFormat
        }
        
        // Generate key from password
        let key = SymmetricKey(data: SHA256.hash(data: password.data(using: .utf8)!))
        
        // Decrypt
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        // Verify password hash if present
        if let metadata = json["metadata"] as? [String: Any],
           let storedHash = metadata["passwordHash"] as? String {
            let providedHash = SHA256.hash(data: password.data(using: .utf8)!).compactMap { String(format: "%02x", $0) }.joined()
            guard storedHash == providedHash else {
                throw TCFError.invalidPassword
            }
        }
        
        return try JSONDecoder().decode(TCFThemeModel.self, from: decryptedData)
    }
    
    /// Checks if data is encrypted
    func isEncrypted(_ data: Data) -> Bool {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return false
        }
        return json["encryptedData"] != nil
    }
}

enum TCFError: LocalizedError {
    case invalidPassword
    case invalidEncryptedFormat
    case invalidFileFormat
    case encryptionFailed
    case decryptionFailed
    case corruptedFile
    
    var errorDescription: String? {
        switch self {
        case .invalidPassword:
            return "Invalid password for encrypted theme"
        case .invalidEncryptedFormat:
            return "Invalid encrypted theme format"
        case .invalidFileFormat:
            return "Invalid file format. Only .gtheme files are supported. File appears to be corrupted or renamed."
        case .encryptionFailed:
            return "Failed to encrypt theme"
        case .decryptionFailed:
            return "Failed to decrypt theme"
        case .corruptedFile:
            return "Theme file appears corrupted or invalid"
        }
    }
}

