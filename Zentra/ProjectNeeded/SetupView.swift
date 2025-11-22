// SetupView.swift
import SwiftUI

struct SetupView: View {
    @Binding var hasCompletedSetup: Bool
    @State private var currentPage = 0
    @State private var showLoginView = false
    @State private var registrationLimitReached = false
    @State private var isCheckingLimit = false
    @State private var accountCount = 0
    @State private var remainingRegistrations = 3
    @AppStorage("deviceUUID") private var deviceUUID: String = ""
    @EnvironmentObject var tcf: TCF
    
    private let totalPages = 3
    private let serverManager = ServerManager.shared
    
    var body: some View {
        ZStack {
            // Background
            tcf.colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $currentPage) {
                    // Page 1: App erklärt
                    SetupPage1()
                        .tag(0)
                    
                    // Page 2: Login-Aufforderung
                    SetupPage2(
                        showLoginView: $showLoginView,
                        registrationLimitReached: $registrationLimitReached,
                        accountCount: $accountCount,
                        remainingRegistrations: $remainingRegistrations
                    )
                        .tag(1)
                    
                    // Page 3: Spaß mit der App haben
                    SetupPage4(hasCompletedSetup: $hasCompletedSetup)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Page Indicator & Navigation
                VStack(spacing: 20) {
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? tcf.colors.accent : tcf.colors.text.opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .conditionalAnimation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Navigation Buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    currentPage -= 1
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Zurück")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(tcf.colors.text)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                            .buttonStyle(SecondaryButtonStyle(backgroundColor: tcf.colors.text.opacity(0.1), foregroundColor: tcf.colors.text))
                        }
                        
                        if currentPage < totalPages - 1 {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    currentPage += 1
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text(currentPage == 1 ? "Login" : "Weiter")
                                        .font(.system(size: 17, weight: .semibold))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                            .buttonStyle(PrimaryButtonStyle(backgroundColor: tcf.colors.accent, foregroundColor: .white))
                        } else {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    hasCompletedSetup = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text("Los geht's")
                                        .font(.system(size: 17, weight: .semibold))
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                            }
                            .buttonStyle(PrimaryButtonStyle(backgroundColor: tcf.colors.accent, foregroundColor: .white))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showLoginView) {
            LoginView(onLogin: {
                showLoginView = false
                // Auto-advance to next page after login
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        currentPage = 2
                    }
                }
            })
            .environmentObject(tcf)
        }
        .task {
            await checkRegistrationLimit()
        }
    }
    
    private func checkRegistrationLimit() async {
        // Get UUID from Keychain or UserDefaults
        let keychainService = "com.zentra.deviceUUID"
        let keychainAccount = "deviceUUID"
        
        var uuidToCheck = deviceUUID
        
        if uuidToCheck.isEmpty {
            if let keychainUUID = KeychainHelper.shared.read(service: keychainService, account: keychainAccount), !keychainUUID.isEmpty {
                uuidToCheck = keychainUUID
            } else if let defaultsUUID = UserDefaults.standard.string(forKey: "deviceUUID"), !defaultsUUID.isEmpty {
                uuidToCheck = defaultsUUID
            }
        }
        
        guard !uuidToCheck.isEmpty else {
            // No UUID yet, allow registration (will be generated)
            await MainActor.run {
                registrationLimitReached = false
                isCheckingLimit = false
            }
            return
        }
        
        do {
            let response = try await serverManager.checkRegistrationLimit(deviceUUID: uuidToCheck)
            
            await MainActor.run {
                registrationLimitReached = response.limit_reached
                accountCount = response.account_count
                remainingRegistrations = response.remaining_registrations
                isCheckingLimit = false
            }
        } catch {
            // On error, allow registration attempt (server will reject if limit reached)
            await MainActor.run {
                registrationLimitReached = false
                isCheckingLimit = false
            }
        }
    }
}

// MARK: - Setup Page 1: App erklärt

struct SetupPage1: View {
    @EnvironmentObject var tcf: TCF
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 60)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    tcf.colors.accent.opacity(0.3),
                                    tcf.colors.accent.opacity(0.1),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                    
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 70, weight: .medium))
                        .foregroundColor(tcf.colors.accent)
                }
                
                VStack(spacing: 20) {
                    Text("Willkommen bei Zentra")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(tcf.colors.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Deine moderne App für Server-Management und mehr")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(tcf.colors.text.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(
                        icon: "server.rack",
                        title: "Server Status",
                        description: "Überwache deine Server in Echtzeit und behalte den Status immer im Blick."
                    )
                    
                    FeatureRow(
                        icon: "paintbrush.fill",
                        title: "Themes",
                        description: "Passe die App an deinen Stil an mit verschiedenen Themes und Designs."
                    )
                    
                    FeatureRow(
                        icon: "slider.horizontal.3",
                        title: "Anpassbare Einstellungen",
                        description: "Konfiguriere die App nach deinen Wünschen und Bedürfnissen."
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer().frame(height: 40)
            }
        }
    }
}

// MARK: - Setup Page 2: Login-Aufforderung

struct SetupPage2: View {
    @Binding var showLoginView: Bool
    @Binding var registrationLimitReached: Bool
    @Binding var accountCount: Int
    @Binding var remainingRegistrations: Int
    @EnvironmentObject var tcf: TCF
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 60)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    tcf.colors.accent.opacity(0.3),
                                    tcf.colors.accent.opacity(0.1),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                    
                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 70, weight: .medium))
                        .foregroundColor(tcf.colors.accent)
                }
                
                VStack(spacing: 20) {
                    Text("Melde dich an")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(tcf.colors.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Für den vollen Zugriff auf alle Features benötigst du einen Account.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(tcf.colors.text.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    BenefitRow(
                        icon: "checkmark.circle.fill",
                        text: "Voller Zugriff auf Server-Status"
                    )
                    
                    BenefitRow(
                        icon: "checkmark.circle.fill",
                        text: "Persönliche Einstellungen speichern"
                    )
                    
                    BenefitRow(
                        icon: "checkmark.circle.fill",
                        text: "Synchronisierung zwischen Geräten"
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Button(action: {
                    showLoginView = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.badge.key.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Jetzt anmelden")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: tcf.colors.accent, foregroundColor: .white))
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Registration limit warning
                if registrationLimitReached {
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(tcf.colors.error.opacity(0.8))
                            Text("Registrierung nicht möglich")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(tcf.colors.text)
                        }
                        
                        Text("Aus Sicherheitsgründen (Exploit-Schutz) ist dieses Gerät von weiteren Registrierungen ausgeschlossen.")
                            .font(.system(size: 14))
                            .foregroundColor(tcf.colors.text.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 4) {
                            Text("Du hast bereits \(accountCount)/3 Accounts auf diesem Gerät erstellt.")
                                .font(.system(size: 13))
                                .foregroundColor(tcf.colors.text.opacity(0.7))
                                .multilineTextAlignment(.center)
                            
                            Text("Für weitere Accounts kontaktiere bitte den Support.")
                                .font(.system(size: 12))
                                .foregroundColor(tcf.colors.text.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tcf.colors.error.opacity(0.15))
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                } else {
                    Text("Du kannst dich auch später anmelden")
                        .font(.system(size: 14))
                        .foregroundColor(tcf.colors.text.opacity(0.6))
                        .padding(.top, 8)
                }
                
                Spacer().frame(height: 40)
            }
        }
    }
}

// MARK: - Setup Page 4: Spaß mit der App haben

struct SetupPage4: View {
    @Binding var hasCompletedSetup: Bool
    @EnvironmentObject var tcf: TCF
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 60)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    tcf.colors.accent.opacity(0.3),
                                    tcf.colors.accent.opacity(0.1),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                    
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 70, weight: .medium))
                        .foregroundColor(tcf.colors.accent)
                }
                
                VStack(spacing: 20) {
                    Text("Alles bereit!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(tcf.colors.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Du bist jetzt bereit, Zentra zu nutzen. Viel Spaß!")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(tcf.colors.text.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(
                        icon: "star.fill",
                        title: "Entdecke Features",
                        description: "Erkunde alle Funktionen der App und finde heraus, was möglich ist."
                    )
                    
                    FeatureRow(
                        icon: "paintpalette.fill",
                        title: "Passe es an",
                        description: "Wähle ein Theme, das zu dir passt, und mache die App zu deiner."
                    )
                    
                    FeatureRow(
                        icon: "gearshape.fill",
                        title: "Konfiguriere",
                        description: "Stelle die App nach deinen Wünschen ein und optimiere deine Erfahrung."
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer().frame(height: 40)
            }
        }
    }
}

// MARK: - Helper Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    @EnvironmentObject var tcf: TCF
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(tcf.colors.accent.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(tcf.colors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(tcf.colors.text)
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(tcf.colors.text.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .liquidGlassCard()
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    @EnvironmentObject var tcf: TCF
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(tcf.colors.accent)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(tcf.colors.text.opacity(0.9))
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(backgroundColor)
                    
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
                                .white.opacity(0.3),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .foregroundColor(foregroundColor)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .conditionalAnimation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

