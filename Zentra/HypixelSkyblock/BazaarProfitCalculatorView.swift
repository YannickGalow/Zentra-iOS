// BazaarProfitCalculatorView.swift
// Zentra App

import SwiftUI

struct BazaarProfitCalculatorView: View {
    @EnvironmentObject var themeEngine: ThemeEngine
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "eurosign.circle")
                .font(.system(size: 44))
                .foregroundColor(themeEngine.colors.accent)
            Text("Bazaar Profit Calculator")
                .font(.title.bold())
                .foregroundColor(themeEngine.colors.text)
            Text("Hier erscheint in Kürze der Bazaar Profit Calculator.")
                .foregroundColor(themeEngine.colors.text.opacity(0.73))
        }
        .padding(30)
        .background(themeEngine.colors.background.opacity(0.85))
        .cornerRadius(24)
        .shadow(color: themeEngine.colors.accent.opacity(0.08), radius: 8, y: 4)
    }
}

#Preview {
        BazaarProfitCalculatorView().environmentObject(ThemeEngine())
}
