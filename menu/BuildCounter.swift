import Foundation

/// Utility zur automatischen Zählung von App-Builds (bei Updates).
/// Die Build-Nummer wird bei jeder neuen Version hochgezählt und in UserDefaults gespeichert.
@MainActor
enum BuildCounter {
    private static let buildKey = "buildCount"
    private static let versionKey = "lastVersionString"
    
    /// Wird beim App-Start aufgerufen. Prüft, ob sich die Version geändert hat, und zählt ggf. den Build hoch.
    static func incrementIfNeeded() {
        let bundle = Bundle.main
        let currentVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let lastVersion = UserDefaults.standard.string(forKey: versionKey)
        if lastVersion != currentVersion {
            // Neue Version erkannt, Build erhöhen
            let oldBuild = UserDefaults.standard.integer(forKey: buildKey)
            UserDefaults.standard.set(oldBuild + 1, forKey: buildKey)
            UserDefaults.standard.set(currentVersion, forKey: versionKey)
        }
    }

    /// Liefert die aktuelle Build-Nummer (mindestens 1)
    static var currentBuild: Int {
        max(1, UserDefaults.standard.integer(forKey: buildKey))
    }
    
    /// Liefert den String für "Build X"
    static var buildString: String {
        "Build \(currentBuild)"
    }
}
