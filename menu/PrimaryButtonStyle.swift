// PrimaryButtonStyle.swift
// Shared button style for usage across the app.
import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.1 : 0.25), radius: 2, y: 2)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
