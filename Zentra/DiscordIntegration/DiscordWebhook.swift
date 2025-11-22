import Foundation
import SwiftUI
let version = "0.1.0"

// MARK: - DiscordStatus

struct DiscordStatus: Identifiable {
    var id = UUID()
    var isConnected: Bool
    var serverName: String
    var channelName: String
    var errorMessage: String? = nil
}

// MARK: - DiscordEmbed

struct DiscordEmbedAuthor: Codable {
    var name: String
    var icon_url: String?
}

struct DiscordEmbedThumbnail: Codable {
    var url: String
}

struct DiscordEmbedField: Codable {
    var name: String
    var value: String
    var inline: Bool?
}

struct DiscordEmbed: Codable {
    var title: String?
    var description: String?
    var color: Int?
    var footer: DiscordEmbedFooter?
    var author: DiscordEmbedAuthor?
    var thumbnail: DiscordEmbedThumbnail?
    var fields: [DiscordEmbedField]?
}

struct DiscordEmbedFooter: Codable {
    var text: String
}

// MARK: - DiscordWebhookManager

class DiscordWebhookManager: ObservableObject {
    @AppStorage("discordWebhookURL") private var webhookURL: String = ""

    @Published var status = DiscordStatus(isConnected: false, serverName: "My Discord Server", channelName: "#general")
    @Published var logMessages: [String] = []

    private let serverName = "My Discord Server"
    private let channelName = "#general"

    // MARK: - Public Logging Methods

    func logLogin(username: String, sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let content = "\(username) logged in."
        let embed = sendEmbed ? DiscordEmbed(
            title: "🔐 Login",
            description: content,
            color: 0x00FF00,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)),
            author: DiscordEmbedAuthor(name: "Zentra App", icon_url: "https://i.imgur.com/zPyOczX.png")
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : content, embed: embed, onlyLocal: onlyLocal)
    }

    func logLogout(username: String, sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let content = "\(username) logged out."
        let embed = sendEmbed ? DiscordEmbed(
            title: "🚪 Logout",
            description: content,
            color: 0xFF0000,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)),
            author: DiscordEmbedAuthor(name: "Zentra App", icon_url: "https://i.imgur.com/zPyOczX.png")
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : content, embed: embed, onlyLocal: onlyLocal)
    }

    func logThemeChange(themeName: String, sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let content = "Theme changed to \(themeName)"
        let embed = sendEmbed ? DiscordEmbed(
            title: "🎨 Theme Change",
            description: content,
            color: 0x5865F2,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)),
            author: DiscordEmbedAuthor(name: "Zentra App", icon_url: "https://i.imgur.com/zPyOczX.png"),
            thumbnail: DiscordEmbedThumbnail(url: "https://i.imgur.com/zPyOczX.png"),
            fields: [DiscordEmbedField(name: "New Theme", value: themeName, inline: false)]
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : content, embed: embed, onlyLocal: onlyLocal)
    }

    func logSettingsChange(setting: String, newValue: String, sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let content = "**\(setting)** was set to **\(newValue)**"
        let embed = sendEmbed ? DiscordEmbed(
            title: "⚙️ Settings Change",
            description: content,
            color: 0xFFA500,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)),
            author: DiscordEmbedAuthor(name: "Zentra App", icon_url: "https://i.imgur.com/zPyOczX.png"),
            fields: [DiscordEmbedField(name: "Setting", value: setting, inline: true), DiscordEmbedField(name: "Value", value: newValue, inline: true)]
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : content, embed: embed, onlyLocal: onlyLocal)
    }

    func logCustomMessage(text: String, sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let embed = sendEmbed ? DiscordEmbed(
            title: "💬 Custom Message",
            description: text,
            color: 0x5865F2,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)),
            author: DiscordEmbedAuthor(name: "Zentra App", icon_url: "https://i.imgur.com/zPyOczX.png"),
            thumbnail: DiscordEmbedThumbnail(url: "https://i.imgur.com/zPyOczX.png")
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : text, embed: embed, onlyLocal: onlyLocal)
    }

    func logTestPost(sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let content = ""
        let embed = sendEmbed ? DiscordEmbed(
            title: "✅ Test Post",
            description: "This is a test message from Zentra App to verify Discord webhook integration.",
            color: 0x5865F2,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)),
            author: DiscordEmbedAuthor(name: "Zentra App", icon_url: "https://i.imgur.com/zPyOczX.png"),
            thumbnail: DiscordEmbedThumbnail(url: "https://i.imgur.com/zPyOczX.png")
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : content, embed: embed, onlyLocal: onlyLocal)
    }

    // MARK: - Private Send Method

    private struct DiscordPayload: Codable {
        var content: String?
        var embeds: [DiscordEmbed]?
    }

    private func sendDiscordMessage(content: String?, embed: DiscordEmbed?, onlyLocal: Bool) async {
        if onlyLocal {
            await MainActor.run {
                if let c = content {
                    self.logMessages.append(c)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                        self?.logMessages.removeAll(where: { $0 == c })
                    }
                } else if let e = embed {
                    let embedTitle = e.title ?? "Embed"
                    self.logMessages.append("[Embed] \(embedTitle)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                        self?.logMessages.removeAll(where: { $0 == "[Embed] \(embedTitle)" })
                    }
                }
            }
            return
        }

        guard webhookURL.hasPrefix("https://"), let url = URL(string: webhookURL) else {
            await MainActor.run {
                self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Invalid webhook URL. Please enter it in settings!")
            }
            return
        }

        let payload = DiscordPayload(content: content, embeds: embed != nil ? [embed!] : nil)

        guard let jsonData = try? JSONEncoder().encode(payload) else {
            await MainActor.run {
                self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Could not serialize JSON.")
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                await MainActor.run {
                    if httpResponse.statusCode == 204 || httpResponse.statusCode == 200 {
                        self.status = DiscordStatus(isConnected: true, serverName: self.serverName, channelName: self.channelName, errorMessage: nil)
                    } else {
                        let responseBody = String(data: data, encoding: .utf8) ?? "No response"
                        self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Discord response code \(httpResponse.statusCode): \(responseBody)")
                    }
                    if let c = content {
                        self.logMessages.append(c)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                            self?.logMessages.removeAll(where: { $0 == c })
                        }
                    } else if let e = embed {
                        let embedTitle = e.title ?? "Embed"
                        self.logMessages.append("[Embed] \(embedTitle)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                            self?.logMessages.removeAll(where: { $0 == "[Embed] \(embedTitle)" })
                        }
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Error sending: \(error.localizedDescription)")
                if let c = content {
                    self.logMessages.append(c)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                        self?.logMessages.removeAll(where: { $0 == c })
                    }
                } else if let e = embed {
                    let embedTitle = e.title ?? "Embed"
                    self.logMessages.append("[Embed] \(embedTitle)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                        self?.logMessages.removeAll(where: { $0 == "[Embed] \(embedTitle)" })
                    }
                }
            }
        }
    }
}

// MARK: - DiscordWebhookStatusView

struct DiscordWebhookStatusView: View {
    @StateObject private var webhookManager = DiscordWebhookManager()
    @State private var messageText = ""
    @FocusState private var messageFieldIsFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if webhookManager.status.isConnected {
                    Text("Connected to Discord ✅")
                        .font(.headline)
                    Text("Server: \(webhookManager.status.serverName)")
                    Text("Channel: \(webhookManager.status.channelName)")
                } else {
                    Text("Not connected ❌")
                        .font(.headline)
                }

                TextField("Enter message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .focused($messageFieldIsFocused)

                Button("Send message") {
                    Task {
                        await webhookManager.logCustomMessage(text: messageText)
                    }
                    messageText = ""
                }
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { messageFieldIsFocused = false }
            }
        }
    }
}
