import Foundation
import SwiftUI

/// TCF (Theme Controlling Framework) - Fully TCF-based theme management
/// TCF is now a type alias for ThemeControllingFramework
typealias TCF = ThemeControllingFramework

// Backward compatibility alias (deprecated - use TCF instead)
@available(*, deprecated, renamed: "TCF", message: "Use TCF instead of ThemeEngine")
typealias ThemeEngine = ThemeControllingFramework
