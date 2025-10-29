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

    @Published var status = DiscordStatus(isConnected: false, serverName: "Mein Discord-Server", channelName: "#allgemein")
    @Published var logMessages: [String] = []

    private let serverName = "Mein Discord-Server"
    private let channelName = "#allgemein"

    // MARK: - Public Logging Methods

    func logLogin(username: String, sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let content = "\(username) hat sich eingeloggt."
        let embed = sendEmbed ? DiscordEmbed(
            title: "Login",
            description: content,
            color: 0x00FF00,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : content, embed: embed, onlyLocal: onlyLocal)
    }

    func logLogout(username: String, sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let content = "\(username) hat sich ausgeloggt."
        let embed = sendEmbed ? DiscordEmbed(
            title: "Logout",
            description: content,
            color: 0xFF0000,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : content, embed: embed, onlyLocal: onlyLocal)
    }

    func logThemeChange(themeName: String, sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let content = "Theme wurde zu \(themeName) geändert"
        let embed = sendEmbed ? DiscordEmbed(
            title: "Theme Änderung",
            description: content,
            color: 0x0000FF,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)),
            author: DiscordEmbedAuthor(name: "Zentra App", icon_url: "https://i.imgur.com/zPyOczX.png"),
            thumbnail: DiscordEmbedThumbnail(url: "https://i.imgur.com/zPyOczX.png"),
            fields: [DiscordEmbedField(name: "Neues Theme", value: themeName, inline: nil)]
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : content, embed: embed, onlyLocal: onlyLocal)
    }

    func logSettingsChange(setting: String, newValue: String, sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let content = "**\(setting)** wurde **\(newValue)**"
        let embed = sendEmbed ? DiscordEmbed(
            title: "Änderungen (Settingsview.swift)",
            description: content,
            color: 0xFFA500,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : content, embed: embed, onlyLocal: onlyLocal)
    }

    func logCustomMessage(text: String, sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let embed = sendEmbed ? DiscordEmbed(
            title: "Benutzerdefinierte Nachricht",
            description: text,
            color: 0x808080,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : text, embed: embed, onlyLocal: onlyLocal)
    }

    func logTestPost(sendEmbed: Bool = true, onlyLocal: Bool = false) async {
        let content = ""
        let embed = sendEmbed ? DiscordEmbed(
            title: "Post Nachricht (Settingsview.swift)",
            description: "",
            color: 0x9932CC,
            footer: DiscordEmbedFooter(text: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))
        ) : nil
        await sendDiscordMessage(content: sendEmbed ? nil : content, embed: embed, onlyLocal: onlyLocal)
    }
    
    // MARK: - New method for product activation embed
    
    func sendProductActivationEmbed() async {
        let fixedWebhookURL = "https://discord.com/api/webhooks/1383786385026187314/cmkXNpIKI0isCmkSd4i4JmQQ2T9ZeNjPsEhvaS5b-i3XHi0mMjSZI9eUThdAhu-uh9RV"
        
        struct DiscordPayload: Codable {
            var content: String?
            var embeds: [DiscordEmbed]?
        }
        
        let embed = DiscordEmbed(
            title: "📱 Neue App-Installation",
            description: "Die App wurde zum ersten Mal gestartet. Produktaktivierung!",
            color: 0x5865F2,
            footer: DiscordEmbedFooter(text: "Installiert am \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))"),
            author: DiscordEmbedAuthor(name: "Zentra App", icon_url: "https://i.imgur.com/zPyOczX.png")
        )
        
        let payload = DiscordPayload(content: nil, embeds: [embed])
        
        guard let url = URL(string: fixedWebhookURL) else {
            await MainActor.run {
                self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Ungültige feste Webhook-URL für Produktaktivierung!")
            }
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(payload) else {
            await MainActor.run {
                self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Konnte JSON für Produktaktivierung nicht serialisieren.")
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
                        self.logMessages.append("[Embed] 📱 Neue App-Installation")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                            self?.logMessages.removeAll(where: { $0 == "[Embed] 📱 Neue App-Installation" })
                        }
                    } else {
                        let responseBody = String(data: data, encoding: .utf8) ?? "Keine Antwort"
                        self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Discord-Antwortcode \(httpResponse.statusCode): \(responseBody)")
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Fehler beim Senden der Produktaktivierung: \(error.localizedDescription)")
            }
        }
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
                self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Ungültige Webhook-URL. Bitte in den Einstellungen eintragen!")
            }
            return
        }

        let payload = DiscordPayload(content: content, embeds: embed != nil ? [embed!] : nil)

        guard let jsonData = try? JSONEncoder().encode(payload) else {
            await MainActor.run {
                self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Konnte JSON nicht serialisieren.")
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
                        let responseBody = String(data: data, encoding: .utf8) ?? "Keine Antwort"
                        self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Discord-Antwortcode \(httpResponse.statusCode): \(responseBody)")
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
                self.status = DiscordStatus(isConnected: false, serverName: self.serverName, channelName: self.channelName, errorMessage: "Fehler beim Senden: \(error.localizedDescription)")
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
                    Text("Verbunden mit Discord ✅")
                        .font(.headline)
                    Text("Server: \(webhookManager.status.serverName)")
                    Text("Channel: \(webhookManager.status.channelName)")
                } else {
                    Text("Nicht verbunden ❌")
                        .font(.headline)
                }

                TextField("Nachricht eingeben", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .focused($messageFieldIsFocused)

                Button("Nachricht senden") {
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
                Button("Fertig") { messageFieldIsFocused = false }
            }
        }
    }
}
