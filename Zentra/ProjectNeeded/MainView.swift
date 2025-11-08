import SwiftUI
import Foundation

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
                            // Server Statistics Dashboard
                            VStack(alignment: .leading, spacing: 0) {
                                // Server Status Card - positioned below header
                                ServerStatusCard()
                                    .environmentObject(tcf)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 100) // Space for header (60) + some padding
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .frame(maxWidth: 510)
                            .transition(animationsEnabled ? .opacity : .identity)
                            .conditionalAnimation(.easeInOut(duration: 0.3), value: showMenu)
                    } else if selectedPage == "bazaar" || selectedPage == "bazaarProfit" {
                        // Views removed - functionality disabled
                        EmptyView()
                    }
                }

                VStack {
                    ZStack {
                        Text(selectedPage == nil || selectedPage == "start" ? "Server Statistics" : "")
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

// MARK: - Server Statistics Dashboard Components

struct ServerStatusCard: View {
    @EnvironmentObject var tcf: TCF
    @StateObject private var serverManager = ServerManager.shared
    @State private var serverStatus: ServerStatus?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var refreshTask: Task<Void, Never>?
    
    var isOnline: Bool {
        if let status = serverStatus {
            return status.online
        }
        // If we have an error, assume offline
        return errorMessage == nil
    }
    
    var statusMessage: String {
        if let error = errorMessage {
            return error
        }
        if let status = serverStatus {
            return status.message
        }
        return "Checking status..."
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Server Status")
                .font(.headline)
                .foregroundColor(tcf.colors.text.opacity(0.7))
            
            // Status Content
            HStack(spacing: 20) {
                // Status Indicator
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    (isOnline ? Color.green : Color.red).opacity(0.3),
                                    (isOnline ? Color.green : Color.red).opacity(0.1),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: tcf.colors.accent))
                    } else {
                        Circle()
                            .fill(isOnline ? Color.green : Color.red)
                            .frame(width: 16, height: 16)
                            .shadow(color: (isOnline ? Color.green : Color.red).opacity(0.6), radius: 8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(isOnline ? "Online" : "Offline")
                        .font(.title2.bold())
                        .foregroundColor(tcf.colors.text)
                    
                    HStack(spacing: 6) {
                        if !isLoading {
                            Circle()
                                .fill(isOnline ? Color.green : Color.red)
                                .frame(width: 6, height: 6)
                        }
                        Text(statusMessage)
                            .font(.subheadline)
                            .foregroundColor(tcf.colors.text.opacity(0.6))
                    }
                }
                
                Spacer()
            }
        }
        .padding(24)
        .liquidGlassCard()
        .task {
            await loadServerStatus()
            // Auto-refresh every 10 seconds
            refreshTask = Task {
                await startAutoRefresh()
            }
        }
        .onDisappear {
            // Cancel refresh task when view disappears
            refreshTask?.cancel()
        }
        .refreshable {
            await loadServerStatus()
        }
    }
    
    private func loadServerStatus() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let status = try await serverManager.fetchServerStatus()
            await MainActor.run {
                self.serverStatus = status
                self.isLoading = false
                // Clear error if we got a successful response
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                // If server is unreachable, show offline
                self.serverStatus = ServerStatus(online: false, timestamp: Date().iso8601, message: "Server unreachable")
                self.isLoading = false
                self.errorMessage = nil
            }
        }
    }
    
    private func startAutoRefresh() async {
        while !Task.isCancelled {
            do {
                try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
                // Check if task was cancelled during sleep
                if Task.isCancelled {
                    break
                }
                await loadServerStatus()
            } catch {
                // Task was cancelled
                break
            }
        }
    }
}

extension Date {
    var iso8601: String {
        // Use a static formatter to avoid thread-safety issues
        struct StaticFormatter {
            static let formatter: ISO8601DateFormatter = {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return formatter
            }()
        }
        return StaticFormatter.formatter.string(from: self)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    @EnvironmentObject var tcf: TCF
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(color.opacity(0.15))
                    )
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(tcf.colors.text.opacity(0.7))
                
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(tcf.colors.text)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(tcf.colors.text.opacity(0.6))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlassCard()
    }
}

struct PerformanceMetricsCard: View {
    @EnvironmentObject var tcf: TCF
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundColor(tcf.colors.accent)
                
                Text("Performance Metrics")
                    .font(.headline)
                    .foregroundColor(tcf.colors.text)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                MetricRow(
                    label: "CPU Usage",
                    value: "23%",
                    progress: 0.23,
                    color: .blue
                )
                .environmentObject(tcf)
                
                MetricRow(
                    label: "Memory Usage",
                    value: "4.2 GB / 8 GB",
                    progress: 0.525,
                    color: .green
                )
                .environmentObject(tcf)
                
                MetricRow(
                    label: "Network Traffic",
                    value: "1.2 TB",
                    progress: 0.45,
                    color: .orange
                )
                .environmentObject(tcf)
                
                MetricRow(
                    label: "Disk Usage",
                    value: "156 GB / 500 GB",
                    progress: 0.312,
                    color: .purple
                )
                .environmentObject(tcf)
            }
        }
        .padding(24)
        .liquidGlassCard()
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    let progress: Double
    let color: Color
    
    @EnvironmentObject var tcf: TCF
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(tcf.colors.text.opacity(0.8))
                
                Spacer()
                
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundColor(tcf.colors.text)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(tcf.colors.text.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

struct RecentActivityCard: View {
    @EnvironmentObject var tcf: TCF
    
    let activities = [
        ("person.fill", "New player joined", "2 minutes ago", Color.green),
        ("exclamationmark.triangle.fill", "Server restart scheduled", "15 minutes ago", Color.orange),
        ("checkmark.circle.fill", "Backup completed", "1 hour ago", Color.blue),
        ("arrow.up.circle.fill", "Performance optimization", "2 hours ago", Color.purple)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.title3)
                    .foregroundColor(tcf.colors.accent)
                
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundColor(tcf.colors.text)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                ForEach(Array(activities.enumerated()), id: \.offset) { index, activity in
                    ActivityRow(
                        icon: activity.0,
                        text: activity.1,
                        time: activity.2,
                        color: activity.3
                    )
                    .environmentObject(tcf)
                    
                    if index < activities.count - 1 {
                        Divider()
                            .background(tcf.colors.text.opacity(0.1))
                    }
                }
            }
        }
        .padding(24)
        .liquidGlassCard()
    }
}

struct ActivityRow: View {
    let icon: String
    let text: String
    let time: String
    let color: Color
    
    @EnvironmentObject var tcf: TCF
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(tcf.colors.text)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(tcf.colors.text.opacity(0.6))
            }
            
            Spacer()
        }
    }
}
