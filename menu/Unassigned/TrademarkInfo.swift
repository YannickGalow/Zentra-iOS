import Foundation

enum TrademarkInfo {
    // The version is expected to be incremented by a build script in build_version.txt.
    static func string() async -> String {
        let versionString: String = await MainActor.run {
            let version = TrademarkInfo.readBuildVersionFromFile()
            let year = Calendar.current.component(.year, from: Date())
            return "Zentra Client \(version) © \(year)"
        }
        return versionString
    }
    
    // Reads build_version.txt from the main bundle, or returns "0.001" if not found
    private static func readBuildVersionFromFile() -> String {
        let fileName = "build_version.txt"
        if let url = Bundle.main.url(forResource: "build_version", withExtension: "txt"),
           let version = try? String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines), !version.isEmpty {
            return version
        } else {
            return "0.001"
        }
    }
}

/// Usage:
/// await TrademarkInfo.string()

// Note: The file build_version.txt must be updated by a build phase script to increment the version on each build.
