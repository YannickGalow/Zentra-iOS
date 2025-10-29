import SwiftUI
// Add this if missing:
// import RotatingIcon

struct NebulaBackground: View {
    @State private var animate = false
    @EnvironmentObject var themeEngine: ThemeEngine
    let particleCount = 22
    
    var body: some View {
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
                    let opacity = 0.41 + 0.36 * abs(cosWPlusT)
                    let color = Color(hue: hue, saturation: saturation, brightness: brightness, opacity: opacity)
                    let blend = Gradient(colors: [themeEngine.colors.accent.opacity(0.63), color.opacity(0.47), themeEngine.colors.background.opacity(0.19)])
                    let width = 54 + CGFloat(sinWPlusT * 8)
                    let height = 54 + CGFloat(cosWPlusT * 12)
                    let ellipseRect = CGRect(x: x, y: y, width: width, height: height)
                    let path = Path(ellipseIn: ellipseRect)
                    let startPoint = CGPoint(x: x, y: y)
                    let endPoint = CGPoint(x: x + 25, y: y + 25)
                    context.fill(path, with: .linearGradient(blend, startPoint: startPoint, endPoint: endPoint))
                }
            }
            .blur(radius: 44)
            .animation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true), value: animate)
            .onAppear { animate = true }
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
                                Text("Willkommen!")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(colors: [themeEngine.colors.accent, themeEngine.colors.text.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                                    )
                                    .shadow(color: themeEngine.colors.accent.opacity(0.18), radius: 12, y: 4)
                                    .padding(.bottom, 12)
                                Text("Swipe das Menu um Funktionen zu entdecken!")
                                    .font(.title3)
                                    .foregroundColor(themeEngine.colors.text.opacity(0.82))
                                    .padding(.bottom, 30)
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
                            (selectedPage == "bazaarProfit" ? "Bazaar Profit\nCalculator" : "Startseite")
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
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)

                    Spacer()

                    Text("")
                        .underline()
                        .foregroundColor(themeEngine.colors.accent)
                        .onTapGesture {
                            Links.openInstagram()
                        }
                        .opacity(showMenu ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: showMenu)
                        .position(x: geo.size.width / 2, y: geo.size.height - 60)
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

