import SwiftUI

struct LiquidGlassBackground: ViewModifier {
    var opacity: Double = 0.25
    var blurRadius: CGFloat = 20
    var cornerRadius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.white.opacity(0.1))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct LiquidGlassCard: ViewModifier {
    var opacity: Double = 0.3
    var blurRadius: CGFloat = 30
    var cornerRadius: CGFloat = 24
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(opacity)
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.15),
                                    .white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.4),
                                .white.opacity(0.1),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct LiquidGlassButton: ViewModifier {
    var accentColor: Color
    var isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    accentColor.opacity(0.8),
                                    accentColor.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.5),
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: accentColor.opacity(0.3), radius: isPressed ? 5 : 15, x: 0, y: isPressed ? 2 : 8)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func liquidGlassBackground(opacity: Double = 0.25, blurRadius: CGFloat = 20, cornerRadius: CGFloat = 20) -> some View {
        self.modifier(LiquidGlassBackground(opacity: opacity, blurRadius: blurRadius, cornerRadius: cornerRadius))
    }
    
    func liquidGlassCard(opacity: Double = 0.3, blurRadius: CGFloat = 30, cornerRadius: CGFloat = 24) -> some View {
        self.modifier(LiquidGlassCard(opacity: opacity, blurRadius: blurRadius, cornerRadius: cornerRadius))
    }
    
    func liquidGlassButton(accentColor: Color, isPressed: Bool = false) -> some View {
        self.modifier(LiquidGlassButton(accentColor: accentColor, isPressed: isPressed))
    }
}

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    var colors: [Color]
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            let animationsEnabled = UserDefaults.standard.bool(forKey: "animationsEnabled")
            if animationsEnabled {
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
        }
    }
}

