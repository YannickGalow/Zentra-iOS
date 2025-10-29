import SwiftUI

struct ThemeModel: Identifiable, Codable, Equatable {
    var id: String
    var name: String

    var background: String
    var text: String
    var accent: String
    var icon: String
    var buttonBackground: String
    var buttonText: String
    var fieldBackground: String
    var border: String
    var navbarBackground: String
    var navbarText: String
    var error: String
    var warning: String

    func toThemeColors() -> ThemeColors {
        ThemeColors(
            background: Color(hex: background),
            text: Color(hex: text),
            accent: Color(hex: accent),
            icon: Color(hex: icon),
            buttonBackground: Color(hex: buttonBackground),
            buttonText: Color(hex: buttonText),
            fieldBackground: Color(hex: fieldBackground),
            border: Color(hex: border),
            navbarBackground: Color(hex: navbarBackground),
            navbarText: Color(hex: navbarText),
            error: Color(hex: error),
            warning: Color(hex: warning)
        )
    }

    enum CodingKeys: String, CodingKey {
        case id, name, background, text, accent, icon, buttonBackground, buttonText, fieldBackground, border, navbarBackground, navbarText, error, warning
    }

    init(id: String, name: String,
         background: String,
         text: String,
         accent: String,
         icon: String,
         buttonBackground: String,
         buttonText: String,
         fieldBackground: String,
         border: String,
         navbarBackground: String,
         navbarText: String,
         error: String,
         warning: String) {
        self.id = id
        self.name = name
        self.background = background
        self.text = text
        self.accent = accent
        self.icon = icon
        self.buttonBackground = buttonBackground
        self.buttonText = buttonText
        self.fieldBackground = fieldBackground
        self.border = border
        self.navbarBackground = navbarBackground
        self.navbarText = navbarText
        self.error = error
        self.warning = warning
    }

    // Provide a custom init(from:) to support fallback for error and warning properties when missing in JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        background = try container.decode(String.self, forKey: .background)
        text = try container.decode(String.self, forKey: .text)
        accent = try container.decode(String.self, forKey: .accent)
        icon = try container.decode(String.self, forKey: .icon)
        buttonBackground = try container.decode(String.self, forKey: .buttonBackground)
        buttonText = try container.decode(String.self, forKey: .buttonText)
        fieldBackground = try container.decode(String.self, forKey: .fieldBackground)
        border = try container.decode(String.self, forKey: .border)
        navbarBackground = try container.decode(String.self, forKey: .navbarBackground)
        navbarText = try container.decode(String.self, forKey: .navbarText)
        error = (try? container.decode(String.self, forKey: .error)) ?? "#FF3B30"
        warning = (try? container.decode(String.self, forKey: .warning)) ?? "#FFD600"
    }

    // Default initializers presets with error and warning included:
    static let `default` = ThemeModel(
        id: "default",
        name: "Default",
        background: "#FFFFFF",
        text: "#000000",
        accent: "#007AFF",
        icon: "#007AFF",
        buttonBackground: "#007AFF",
        buttonText: "#FFFFFF",
        fieldBackground: "#F2F2F7",
        border: "#C6C6C8",
        navbarBackground: "#FFFFFF",
        navbarText: "#000000",
        error: "#FF3B30",
        warning: "#FFD600"
    )

    static let light = ThemeModel(
        id: "light",
        name: "Light",
        background: "#FFFFFF",
        text: "#1C1C1E",
        accent: "#0A84FF",
        icon: "#0A84FF",
        buttonBackground: "#0A84FF",
        buttonText: "#FFFFFF",
        fieldBackground: "#E5E5EA",
        border: "#C7C7CC",
        navbarBackground: "#FFFFFF",
        navbarText: "#1C1C1E",
        error: "#FF453A",
        warning: "#FFD600"
    )

    static let dark = ThemeModel(
        id: "dark",
        name: "Dark",
        background: "#000000",
        text: "#FFFFFF",
        accent: "#0A84FF",
        icon: "#0A84FF",
        buttonBackground: "#0A84FF",
        buttonText: "#FFFFFF",
        fieldBackground: "#1C1C1E",
        border: "#3A3A3C",
        navbarBackground: "#000000",
        navbarText: "#FFFFFF",
        error: "#FF375F",
        warning: "#FFD600"
    )
}
