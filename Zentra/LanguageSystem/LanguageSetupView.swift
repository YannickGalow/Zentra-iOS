// LanguageSetupView.swift
// Sprachwahl-Setup beim ersten Start
import SwiftUI

struct LanguageSetupView: View {
    @AppStorage("didShowLanguageSetup") private var didShowLanguageSetup: Bool = false

    @EnvironmentObject var themeEngine: ThemeEngine

    @State private var showContinue = false

    var body: some View {
        ZStack {
            themeEngine.colors.background.ignoresSafeArea()
            VStack(spacing: 38) {
                Spacer().frame(height: 60)
                Text("Setup")
                    .font(.largeTitle.bold())
                    .foregroundColor(themeEngine.colors.text)
                Text("Please select your language")
                    .font(.title3)
                    .foregroundColor(themeEngine.colors.text.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)

                Button(action: {
                    didShowLanguageSetup = true
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeEngine.colors.accent)
                        .foregroundColor(themeEngine.colors.background)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 32)
                Spacer()
            }
        }
    }
}

#if DEBUG
#Preview {
    LanguageSetupView()
        .environmentObject(ThemeEngine())
}
#endif // DEBUG

