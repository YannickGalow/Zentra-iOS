// BazaarTrackerView.swift
// Zentra App

import SwiftUI

struct BazaarTrackerView: View {
    @EnvironmentObject var themeEngine: ThemeEngine
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "cart.fill")
                .font(.system(size: 44))
                .foregroundColor(themeEngine.colors.accent)
            Text("Bazaar Tracker")
                .font(.title.bold())
                .foregroundColor(themeEngine.colors.text)
            Text("Hier erscheint in Kürze der Bazaar Tracker.")
                .foregroundColor(themeEngine.colors.text.opacity(0.73))
        }
        .padding(30)
        .background(themeEngine.colors.background.opacity(0.85))
        .cornerRadius(24)
        .shadow(color: themeEngine.colors.accent.opacity(0.08), radius: 8, y: 4)
    }
}

#Preview {
    BazaarTrackerView().environmentObject(ThemeEngine())
}
