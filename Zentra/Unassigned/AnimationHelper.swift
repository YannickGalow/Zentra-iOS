import SwiftUI

/// Helper extension for conditional animations based on user preferences
extension View {
    /// Applies animation only if animations are enabled in settings
    @ViewBuilder
    func conditionalAnimation<T: Equatable>(_ animation: Animation?, value: T) -> some View {
        let animationsEnabled = UserDefaults.standard.bool(forKey: "animationsEnabled")
        if animationsEnabled {
            self.animation(animation, value: value)
        } else {
            self
        }
    }
    
    /// Conditionally applies animation modifier
    @ViewBuilder
    func conditionalAnimation(_ animation: Animation? = .default) -> some View {
        let animationsEnabled = UserDefaults.standard.bool(forKey: "animationsEnabled")
        if animationsEnabled {
            self.animation(animation)
        } else {
            self
        }
    }
}

/// Helper function for conditional withAnimation
func conditionalWithAnimation<T>(_ animation: Animation? = .default, _ body: () throws -> T) rethrows -> T {
    let animationsEnabled = UserDefaults.standard.bool(forKey: "animationsEnabled")
    if animationsEnabled {
        return try withAnimation(animation, body)
    } else {
        return try body()
    }
}

