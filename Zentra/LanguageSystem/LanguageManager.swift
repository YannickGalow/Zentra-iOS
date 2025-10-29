// LanguageManager.swift
// Verwalte Spracheinstellungen und Textlokalisierung
import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case de
    case en
    
    var id: String { rawValue }
    var description: String {
        switch self {
        case .system: return "Systemsprache"
        case .de: return "Deutsch"
        case .en: return "English"
        }
    }
    var locale: Locale {
        switch self {
        case .system: return Locale.current
        case .de: return Locale(identifier: "de")
        case .en: return Locale(identifier: "en")
        }
    }
}

final class LanguageManager: ObservableObject {
    @AppStorage("selectedLanguage") var selectedLanguage: String = AppLanguage.system.rawValue
    
    static let shared = LanguageManager()
    
    func currentLanguage() -> AppLanguage {
        AppLanguage(rawValue: selectedLanguage) ?? .system
    }
    
    func localizedString(_ key: String) -> String {
        let lang = currentLanguage()
        if lang == .system {
            return NSLocalizedString(key, comment: "")
        }
        guard let path = Bundle.main.path(forResource: lang.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

extension String {
    var localized: String { LanguageManager.shared.localizedString(self) }
}
