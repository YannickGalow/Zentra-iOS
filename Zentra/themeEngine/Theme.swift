import SwiftUI

enum Theme: Equatable {
    case light
    case dark
    case custom(ColorScheme)

    static func == (lhs: Theme, rhs: Theme) -> Bool {
        switch (lhs, rhs) {
        case (.light, .light), (.dark, .dark):
            return true
        case (.custom(let a), .custom(let b)):
            return a == b
        default:
            return false
        }
    }

    var primaryColor: Color {
        switch self {
        case .light:
            return .white
        case .dark:
            return .black
        case .custom(let colorScheme):
            switch colorScheme {
            case .light: return .white
            case .dark: return .black
            @unknown default:
                return .gray
            }
        }
    }

    var secondaryColor: Color {
        switch self {
        case .light:
            return .gray
        case .dark:
            return .white.opacity(0.8)
        case .custom(let colorScheme):
            switch colorScheme {
            case .light: return .gray
            case .dark: return .white.opacity(0.8)
            @unknown default:
                return .gray
            }
        }
    }
}
