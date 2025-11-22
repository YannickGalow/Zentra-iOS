import SwiftUI

struct ThemePasswordView: View {
    @Binding var password: String
    var onConfirm: () -> Void
    var onCancel: () -> Void
    
    @EnvironmentObject var tcf: TCF
    @FocusState private var isPasswordFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Encrypted Theme")
                    .font(.title2.bold())
                    .foregroundColor(tcf.colors.text)
                    .padding(.top, 20)
                
                Text("This theme is password protected. Please enter the password to import it.")
                    .font(.subheadline)
                    .foregroundColor(tcf.colors.text.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .liquidGlassBackground(cornerRadius: 12)
                    .foregroundColor(tcf.colors.text)
                    .focused($isPasswordFocused)
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .buttonStyle(PrimaryButtonStyle(
                        backgroundColor: tcf.colors.accent.opacity(0.5),
                        foregroundColor: tcf.colors.text
                    ))
                    
                    Button("Import") {
                        onConfirm()
                    }
                    .buttonStyle(PrimaryButtonStyle(
                        backgroundColor: tcf.colors.accent,
                        foregroundColor: tcf.colors.background
                    ))
                    .disabled(password.isEmpty)
                    .opacity(password.isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(tcf.colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(tcf.colors.accent)
                }
            }
            .onAppear {
                isPasswordFocused = true
            }
        }
    }
}

