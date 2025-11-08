// SetupView.swift
import SwiftUI

struct SetupView: View {
    @Binding var hasCompletedSetup: Bool
    @State private var currentPage = 0
    @State private var showLoginView = false
    @EnvironmentObject var tcf: TCF
    
    private let totalPages = 4
    
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
                    SetupPage2(showLoginView: $showLoginView)
                        .tag(1)
                    
                    // Page 3: Support Discord
                    SetupPage3()
                        .tag(2)
                    
                    // Page 4: Spaß mit der App haben
                    SetupPage4(hasCompletedSetup: $hasCompletedSetup)
                        .tag(3)
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
                
                Text("Du kannst dich auch später anmelden")
                    .font(.system(size: 14))
                    .foregroundColor(tcf.colors.text.opacity(0.6))
                    .padding(.top, 8)
                
                Spacer().frame(height: 40)
            }
        }
    }
}

// MARK: - Setup Page 3: Support Discord

struct SetupPage3: View {
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
                                    Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.3),
                                    Color(red: 0.4, green: 0.5, blue: 0.9).opacity(0.1),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                    
                    Image(systemName: "message.fill")
                        .font(.system(size: 70, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.9))
                }
                
                VStack(spacing: 20) {
                    Text("Support & Community")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(tcf.colors.text)
                        .multilineTextAlignment(.center)
                    
                    Text("Tritt unserer Discord-Community bei für Support, Updates und mehr!")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(tcf.colors.text.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    BenefitRow(
                        icon: "headphones",
                        text: "Schneller Support bei Fragen"
                    )
                    
                    BenefitRow(
                        icon: "megaphone.fill",
                        text: "Erhalte Updates und Neuigkeiten"
                    )
                    
                    BenefitRow(
                        icon: "person.3.fill",
                        text: "Tausche dich mit anderen Nutzern aus"
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                VStack(spacing: 12) {
                    Text("Discord Server")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tcf.colors.text.opacity(0.7))
                    
                    Text("discord.gg/qqdjXgcDh9")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.9))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                }
                .frame(maxWidth: .infinity)
                .liquidGlassCard()
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
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

