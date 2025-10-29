// LanguageSetupView.swift
// Sprachwahl-Setup beim ersten Start
import SwiftUI

struct LanguageSetupView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = AppLanguage.system.rawValue
    @AppStorage("didShowLanguageSetup") private var didShowLanguageSetup = false

    @EnvironmentObject var themeEngine: ThemeEngine

    @State private var showContinue = false

    var body: some View {
        ZStack {
            themeEngine.colors.background.ignoresSafeArea()
            VStack(spacing: 38) {
                Spacer().frame(height: 60)
                Text("language_setupTitle".localized)
                    .font(.largeTitle.bold())
                    .foregroundColor(themeEngine.colors.text)
                Text("language_setupSubtitle".localized)
                    .font(.title3)
                    .foregroundColor(themeEngine.colors.text.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                Picker("language_select".localized, selection: $selectedLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.description).tag(lang.rawValue)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 140)

                Button(action: {
                    didShowLanguageSetup = true
                }) {
                    Text("language_continue".localized)
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
    LanguageSetupView().environmentObject(ThemeEngine())
}
#endif
