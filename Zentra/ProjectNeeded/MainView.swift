import SwiftUI

struct NebulaBackground: View {
    @EnvironmentObject var tcf: TCF
    
    var body: some View {
        // Static background without animation
        tcf.colors.background
            .ignoresSafeArea()
    }
}

struct MainView: View {
    @Binding var selectedPage: String?
    @State private var showMenu = false
    @AppStorage("animationsEnabled") private var animationsEnabled: Bool = true
    @EnvironmentObject var tcf: TCF

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background color always as first view to fill completely
                tcf.colors.background.ignoresSafeArea()

                if !showMenu {
                    if selectedPage == nil || selectedPage == "start" {
                        // New, unique start page animation: Particle Nebula
                        ZStack {
                            NebulaBackground()
                                .environmentObject(tcf)
                            VStack(spacing: 24) {
                                Spacer(minLength: 56)
                                
                                GitHubPromoCard()
                                    .environmentObject(tcf)
                                    .padding(.horizontal, 24)
                                
                                Spacer()
                            }
                            .frame(maxWidth: 510)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(animationsEnabled ? .opacity : .identity)
                        .conditionalAnimation(.easeInOut(duration: 0.3), value: showMenu)
                    } else if selectedPage == "bazaar" || selectedPage == "bazaarProfit" {
                        // Views removed - functionality disabled
                        EmptyView()
                    }
                }

                VStack {
                    ZStack {
                        Text("Home")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .foregroundColor(tcf.colors.text)
                        .opacity(showMenu ? 0 : 1)
                        .conditionalAnimation(.easeInOut(duration: 0.2), value: showMenu)

                        HStack {
                            Button {
                                conditionalWithAnimation(.easeInOut(duration: 0.3)) {
                                    showMenu.toggle()
                                }
                            } label: {
                                Image(systemName: "sidebar.squares.leading")
                                    .font(.title)
                                    .foregroundColor(tcf.colors.text)
                                    .padding()
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.3)
                                    )
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)

                    Spacer()
                }
                .zIndex(2)

                if showMenu {
                    Sidebar(selectedPage: $selectedPage, onCollapse: { conditionalWithAnimation { showMenu = false } })
                        .frame(width: geo.size.width * 0.78)
                        .transition(animationsEnabled ? .move(edge: .leading) : .opacity)
                        .zIndex(3)
                }

                if showMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            conditionalWithAnimation {
                                showMenu = false
                            }
                        }
                        .zIndex(1)
                }

                if !showMenu {
                    Color.clear
                        .frame(width: 30)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture().onEnded { value in
                                if value.translation.width > 80 {
                                    conditionalWithAnimation {
                                        showMenu = true
                                    }
                                }
                            }
                        )
                        .allowsHitTesting(true)
                }

                if showMenu {
                    Color.clear
                        .frame(width: geo.size.width * 0.22)
                        .offset(x: geo.size.width * 0.78)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture().onEnded { value in
                                if value.translation.width < -80 {
                                    conditionalWithAnimation {
                                        showMenu = false
                                    }
                                }
                            }
                        )
                        .allowsHitTesting(true)
                }
            }
            .onChange(of: selectedPage) { newPage in
                if newPage != nil && newPage != "start" {
                    conditionalWithAnimation { showMenu = false }
                }
            }
        }
    }
}

struct GitHubPromoCard: View {
    @EnvironmentObject var tcf: TCF
    @State private var isPressed = false
    
    var body: some View {
        Button {
            if let url = URL(string: "https://github.com/YannickGalow/Zentra-iOS") {
                UIApplication.shared.open(url)
            }
        } label: {
            VStack(spacing: 20) {
                // GitHub Icon
                Image(systemName: "star.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                tcf.colors.accent,
                                tcf.colors.accent.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: tcf.colors.accent.opacity(0.5), radius: 12, y: 4)
                
                VStack(spacing: 12) {
                    Text("Star us on GitHub")
                        .font(.title2.bold())
                        .foregroundColor(tcf.colors.text)
                    
                    Text("Check out the source code and contribute to Zentra")
                        .font(.subheadline)
                        .foregroundColor(tcf.colors.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(tcf.colors.accent)
                            Text("GitHub")
                                .font(.caption.bold())
                                .foregroundColor(tcf.colors.text)
                        }
                        
                        Text("•")
                            .foregroundColor(tcf.colors.text.opacity(0.4))
                        
                        Text("YannickGalow/Zentra-iOS")
                            .font(.caption)
                            .foregroundColor(tcf.colors.text.opacity(0.8))
                    }
                    .padding(.top, 4)
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // Liquid Glass Background
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .opacity(0.5)
                    
                    // Accent Gradient Overlay
                    LinearGradient(
                        colors: [
                            tcf.colors.accent.opacity(0.15),
                            tcf.colors.accent.opacity(0.05),
                            tcf.colors.accent.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(0.6)
                    
                    // White Gradient Overlay
                    LinearGradient(
                        colors: [
                            .white.opacity(0.15),
                            .white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(0.4)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.5),
                                tcf.colors.accent.opacity(0.6),
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: tcf.colors.accent.opacity(0.2), radius: 20, x: 0, y: 10)
            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .conditionalAnimation(.easeInOut(duration: 0.2), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { pressing in
            isPressed = pressing
        } perform: {}
    }
}

struct AnimatedClockView: View {
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        Text(timeString)
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .foregroundColor(Color.accentColor)
            .shadow(color: Color.accentColor.opacity(0.18), radius: 12, y: 4)
            .onReceive(timer) { input in
                conditionalWithAnimation(.easeInOut(duration: 0.5)) {
                    currentTime = input
                }
            }
            .transition(.opacity)
            .id(currentTime)
    }
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: currentTime)
    }
}
