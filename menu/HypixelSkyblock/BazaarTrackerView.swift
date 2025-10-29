// BazaarTrackerView.swift
// Zentra App

import Foundation
import SwiftUI

struct BazaarItem: Decodable {
    let buyPrice: Double
    let instaBuyPrice: Double
    let sellPrice: Double
    let instaSellPrice: Double
}

struct HypixelBazaarResponse: Decodable {
    struct ProductInfo: Decodable {
        struct QuickStatus: Decodable {
            let buyPrice: Double
            let sellPrice: Double
            let buyVolume: Int?
            let sellVolume: Int?
        }
        let quick_status: QuickStatus
    }
    let products: [String: ProductInfo]
}

// Hilfsfunktion, um für ENCHANTED_DIAMOND die Werte zu extrahieren
extension HypixelBazaarResponse {
    func toBazaarItem(for id: String) -> BazaarItem? {
        guard let info = products[id] else { return nil }
        // Die API unterscheidet nicht explizit zwischen "Offer" und "InstaBuy/Sell", aber die korrekte Zuordnung ist:
        // buyPrice: aktueller "Buy Offer" Preis (höchster Preis, den Käufer bieten) = quick_status.sellPrice
        // instaBuyPrice: aktueller Instant-Kauf-Preis = quick_status.buyPrice
        // sellPrice: aktueller "Sell Offer" Preis (niedrigster Preis, zu dem Verkäufer verkaufen) = quick_status.buyPrice
        // instaSellPrice: aktueller Instant-Verkauf-Preis = quick_status.sellPrice
        return BazaarItem(
            buyPrice: info.quick_status.sellPrice, // Buy Offer
            instaBuyPrice: info.quick_status.buyPrice, // Insta Buy
            sellPrice: info.quick_status.buyPrice, // Sell Offer
            instaSellPrice: info.quick_status.sellPrice // Insta Sell
        )
    }
}

extension String {
    var capitalizingFirstLetter: String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}

struct BazaarTrackerView: View {
    @EnvironmentObject var themeEngine: ThemeEngine
    @State private var item: BazaarItem? = nil
    @State private var isLoading = true
    @State private var showItem = false
    @State private var searchItemId: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var priceRefreshTimer: Timer? = nil
    @State private var showSavedConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 64) {
            Text("")
                .font(.largeTitle.bold())
                .foregroundColor(themeEngine.colors.text)
                .padding(.horizontal)
                .padding(.top, 10)

            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeEngine.colors.accent)
                        TextField("Item-ID eingeben", text: $searchItemId)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(themeEngine.colors.text)
                            .submitLabel(.search)
                            .onSubmit { fetchBazaarData(for: searchItemId.uppercased().replacingOccurrences(of: " ", with: "_")) }
                    }
                    .padding(12)
                    .background(themeEngine.colors.background.opacity(0.7))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeEngine.colors.accent.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: themeEngine.colors.accent.opacity(0.07), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)

                VStack(spacing: 24) {
                    // Item-Icon und Name
                    HStack(spacing: 16) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 40))
                            .foregroundColor(themeEngine.colors.accent)
                            .padding(10)
                            .background(themeEngine.colors.background.opacity(0.5))
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text(searchItemId.capitalizingFirstLetter)
                                .font(.title2.bold())
                                .foregroundColor(themeEngine.colors.text)
                            Text(searchItemId.isEmpty ? "skyblock:item" : "skyblock:\(searchItemId.lowercased())")
                                .font(.subheadline)
                                .foregroundColor(themeEngine.colors.text.opacity(0.6))
                        }
                    }

                    Divider()

                    // Preis-Anzeige
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Buy Offer")
                                    .font(.headline)
                                    .foregroundColor(themeEngine.colors.text)
                                if isLoading {
                                    Text("Lädt …")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                } else if let item = item {
                                    Text("\(item.buyPrice, specifier: "%.1f") Coins")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                } else {
                                    Text("Fehler")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Insta Buy")
                                    .font(.headline)
                                    .foregroundColor(themeEngine.colors.text)
                                if isLoading {
                                    Text("Lädt …")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                } else if let item = item {
                                    Text("\(item.instaBuyPrice, specifier: "%.1f") Coins")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                } else {
                                    Text("Fehler")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                }
                            }
                        }
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Sell Offer")
                                    .font(.headline)
                                    .foregroundColor(themeEngine.colors.text)
                                if isLoading {
                                    Text("Lädt …")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                } else if let item = item {
                                    Text("\(item.sellPrice, specifier: "%.1f") Coins")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                } else {
                                    Text("Fehler")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Insta Sell")
                                    .font(.headline)
                                    .foregroundColor(themeEngine.colors.text)
                                if isLoading {
                                    Text("Lädt …")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                } else if let item = item {
                                    Text("\(item.instaSellPrice, specifier: "%.1f") Coins")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                } else {
                                    Text("Fehler")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    if let item = item, !isLoading {
                        Button("Preise ins Widget übernehmen") {
                            savePricesToWidget(item)
                            showSavedConfirmation = true
                        }
                        .buttonStyle(PrimaryButtonStyle(backgroundColor: themeEngine.colors.accent, foregroundColor: themeEngine.colors.background))
                    }
                    if showSavedConfirmation {
                        Text("Preise gespeichert!")
                            .foregroundColor(.green)
                            .font(.footnote.bold())
                            .transition(.opacity)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                    withAnimation { showSavedConfirmation = false }
                                }
                            }
                    }
                }
                .opacity(showItem ? 1 : 0)
                .scaleEffect(showItem ? 1 : 0.92)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showItem)
                .padding(30)
                .background(themeEngine.colors.background.opacity(0.85))
                .cornerRadius(24)
            }
            .padding(.bottom, keyboardHeight)
        }
        .onAppear {
            startKeyboardObservers()
            fetchBazaarData(for: searchItemId.uppercased().replacingOccurrences(of: " ", with: "_"))
            priceRefreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                fetchBazaarData(for: searchItemId.uppercased().replacingOccurrences(of: " ", with: "_"))
            }
        }
        .onDisappear {
            stopKeyboardObservers()
            priceRefreshTimer?.invalidate()
            priceRefreshTimer = nil
        }
    }

    func fetchBazaarData(for itemId: String = "ENCHANTED_DIAMOND") {
        self.showItem = false
        let url = URL(string: "https://api.hypixel.net/v2/skyblock/bazaar")!
        isLoading = true
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoded = try JSONDecoder().decode(HypixelBazaarResponse.self, from: data)
                if let result = decoded.toBazaarItem(for: itemId.uppercased()) {
                    await MainActor.run {
                        self.item = result
                        self.isLoading = false
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            self.showItem = true
                        }
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                        self.showItem = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.showItem = false
                }
                print("Bazaar fetch error: \(error)")
            }
        }
    }

    func startKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
            if let value = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardHeight = value.height - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
        }
    }

    func stopKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func savePricesToWidget(_ item: BazaarItem) {
        if let defaults = UserDefaults(suiteName: "group.bazaartracker") {
            defaults.set(item.buyPrice, forKey: "price1")
            defaults.set(item.instaBuyPrice, forKey: "price2")
            defaults.set(item.sellPrice, forKey: "price3")
            defaults.synchronize()
        }
    }
}

#Preview {
    BazaarTrackerView().environmentObject(ThemeEngine())
}
