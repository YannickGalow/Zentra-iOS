import Foundation

enum TrademarkInfo {
    static var string: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let year = Calendar.current.component(.year, from: Date())
        return "Zentra Client v\(version) © \(year)"
    }
}

/// Usage:
/// Text(TrademarkInfo.string)
