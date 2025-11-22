// PrimaryButtonStyle.swift
// Shared button style for usage across the app.
import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .liquidGlassButton(accentColor: backgroundColor, isPressed: configuration.isPressed)
            .foregroundColor(foregroundColor)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .conditionalAnimation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
