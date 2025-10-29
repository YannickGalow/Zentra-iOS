import SwiftUI

struct NebulaBackground: View {
    @State private var animate = false
    @EnvironmentObject var themeEngine: ThemeEngine
    let particleCount = 22
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground(
                colors: [
                    Color(hex: themeEngine.colors.background.hexString ?? "0A0E27"),
                    themeEngine.colors.accent.opacity(0.3),
                    Color(hex: themeEngine.colors.background.hexString ?? "0A0E27")
                ]
            )
            
            GeometryReader { geo in
                Canvas { context, size in
                    for i in 0..<particleCount {
                        let iDouble = Double(i)
                        let particlesDouble = Double(particleCount)
                        let angle = (iDouble / particlesDouble) * 2 * .pi
                        let baseRadius = min(size.width, size.height) * 0.38
                        let t = animate ? 1.0 : 0.0
                        let w = iDouble * 0.28 + t * 2.1
                        let sinW = sin(w)
                        let sinWPlusT = sin(w + t)
                        let cosW = cos(w)
                        let cosWPlusT = cos(w + t)
                        let centerX = size.width / 2
                        let centerY = size.height / 2
                        let radiusX = baseRadius + CGFloat(sinWPlusT * 18)
                        let radiusY = baseRadius + CGFloat(cosW * 14)
                        let x = centerX + cos(angle + t + w) * radiusX
                        let y = centerY + sin(angle + t + w) * radiusY
                        let hue = ((iDouble / particlesDouble) + t * 0.21).truncatingRemainder(dividingBy: 1.0)
                        let saturation = 0.50 + 0.5 * abs(sinW)
                        let brightness = 1.0
                        let opacity = 0.25 + 0.25 * abs(cosWPlusT)
                        let color = Color(hue: hue, saturation: saturation, brightness: brightness, opacity: opacity)
                        let blend = Gradient(colors: [themeEngine.colors.accent.opacity(0.5), color.opacity(0.35), themeEngine.colors.background.opacity(0.15)])
                        let width = 54 + CGFloat(sinWPlusT * 8)
                        let height = 54 + CGFloat(cosWPlusT * 12)
                        let ellipseRect = CGRect(x: x, y: y, width: width, height: height)
                        let path = Path(ellipseIn: ellipseRect)
                        let startPoint = CGPoint(x: x, y: y)
                        let endPoint = CGPoint(x: x + 25, y: y + 25)
                        context.fill(path, with: .linearGradient(blend, startPoint: startPoint, endPoint: endPoint))
                    }
                }
                .blur(radius: 60)
                .animation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true), value: animate)
                .onAppear { animate = true }
            }
        }
        .ignoresSafeArea()
    }
}

struct MainView: View {
    @Binding var selectedPage: String?
    @State private var showMenu = false
    @EnvironmentObject var themeEngine: ThemeEngine

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Hintergrundfarbe immer als erste View, um komplett zu füllen
                themeEngine.colors.background.ignoresSafeArea()

                if !showMenu {
                    if selectedPage == nil || selectedPage == "start" {
                        // Neue, einzigartige Startseiten-Animation: Partikel-Nebula
                        ZStack {
                            NebulaBackground()
                                .environmentObject(themeEngine)
                            VStack(spacing: 0) {
                                Spacer(minLength: 56)
                                Spacer()
                            }
                            .padding(24)
                            .frame(maxWidth: 510)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: showMenu)
                    } else if selectedPage == "bazaar" {
                        BazaarTrackerView()
                            .environmentObject(themeEngine)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: showMenu)
                    } else if selectedPage == "bazaarProfit" {
                        BazaarProfitCalculatorView()
                            .environmentObject(themeEngine)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: showMenu)
                    }
                }

                VStack {
                    ZStack {
                        Text(
                            selectedPage == "bazaar" ? "Bazaar Tracker" :
                            (selectedPage == "bazaarProfit" ? "Bazaar Profit\nCalculator" : "Home")
                        )
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .foregroundColor(themeEngine.colors.text)
                        .opacity(showMenu ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: showMenu)

                        HStack {
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showMenu.toggle()
                                }
                            } label: {
                                Image(systemName: "sidebar.squares.leading")
                                    .font(.title)
                                    .foregroundColor(themeEngine.colors.text)
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
                    SideMenu(selectedPage: $selectedPage, onCollapse: { withAnimation { showMenu = false } })
                        .frame(width: geo.size.width * 0.73)
                        .transition(.move(edge: .leading))
                        .zIndex(3)
                }

                if showMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
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
                                    withAnimation {
                                        showMenu = true
                                    }
                                }
                            }
                        )
                        .allowsHitTesting(true)
                }

                if showMenu {
                    Color.clear
                        .frame(width: geo.size.width * 0.27)
                        .offset(x: geo.size.width * 0.73)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture().onEnded { value in
                                if value.translation.width < -80 {
                                    withAnimation {
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
                    withAnimation { showMenu = false }
                }
            }
        }
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
                withAnimation(.easeInOut(duration: 0.5)) {
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
