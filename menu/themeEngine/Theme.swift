import SwiftUI

struct Theme {
    struct Colors {
        static let background = Color(red: 30/255, green: 30/255, blue: 30/255)
        static let card = Color.white.opacity(0.1)
        static let accent = Color.green
        static let error = Color.red
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
    }

    struct Fonts {
        static let title = Font.system(size: 24, weight: .bold)
        static let headline = Font.headline
        static let body = Font.body
        static let footnote = Font.footnote
    }

    struct Sizes {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
    }
}
