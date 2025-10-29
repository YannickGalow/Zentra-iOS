// BazaarTrackerView.swift
// Zentra App
// No @main attribute should ever be present in this file.

// Hinweis: Standardmäßig wird ENCHANTED_DIAMOND beim ersten Start angezeigt.

import Foundation
import SwiftUI
import Combine
import UserNotifications
import UIKit

struct BazaarItem: Decodable {
    let buyPrice: Double
    let instaBuyPrice: Double
    let sellPrice: Double
    let instaSellPrice: Double
}

extension BazaarItem {
    static let empty = BazaarItem(buyPrice: 0, instaBuyPrice: 0, sellPrice: 0, instaSellPrice: 0)
}

struct PriceAlert: Codable, Identifiable, Equatable {
    let id: UUID
    let itemId: String
    let targetPrice: Double
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
        // Updated mapping: corrected assignment of prices according to actual API meanings
        return BazaarItem(
            buyPrice: info.quick_status.sellPrice,           // Buy Offer
            instaBuyPrice: BazaarItem.empty.instaBuyPrice,   // Insta Buy
            sellPrice: info.quick_status.sellPrice,          // Sell Offer
            instaSellPrice: info.quick_status.buyPrice       // Insta Sell
        )
    }
}

extension String {
    var capitalizingFirstLetter: String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
    var titleCasedWithSpaces: String {
        self.replacingOccurrences(of: "_", with: " ")
            .lowercased()
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct BazaarTrackerView: View {
    @EnvironmentObject var themeEngine: ThemeEngine
    @State private var item: BazaarItem? = .empty
    @State private var isLoading = true
    @State private var showItem = false
    @State private var searchItemId: String = "ENCHANTED_DIAMOND"
    @State private var keyboardHeight: CGFloat = 0
    @State private var priceRefreshTimer: Timer? = nil
    @State private var showSavedConfirmation = false
    @State private var showItemSavedConfirmation = false

    // Neue States für mehrere gespeicherte Items
    @State private var savedItemIds: [String] = []
    @State private var savedItems: [String: BazaarItem] = [:]
    @State private var isLoadingSavedItems: [String: Bool] = [:]
    @State private var showSavedItemsSheet = false
    
    // New state to track selected saved item
    @State private var selectedSavedItemId: String? = nil

    @State private var searchTask: Task<Void, Never>? = nil
    @FocusState private var searchFieldFocused: Bool
    
    @State private var searchFieldText: String = "" // Sichtbarer Text im Suchfeld (bleibt initial leer)

    // New states for alert menu
    @State private var showAlertMenu = false
    @State private var alertPrice: Double? = nil
    @State private var tempAlertPrice: String = ""
    @State private var showAlertConfirmation = false

    // New states for price alerts list
    @State private var priceAlerts: [PriceAlert] = []
    @State private var showPriceAlertsSheet = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 32) {
                // MARK: - Title and Search Bar
                Text("")
                    .font(.largeTitle.bold())
                    .foregroundColor(themeEngine.colors.text)
                    .padding(.top, 28)
                    .padding(.horizontal)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(themeEngine.colors.accent)
                    TextField("Item-ID eingeben", text: $searchFieldText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(themeEngine.colors.text)
                        .submitLabel(.search)
                        .focused($searchFieldFocused)
                        .onSubmit {
                            selectedSavedItemId = nil
                            let searchId = searchFieldText.uppercased().replacingOccurrences(of: " ", with: "_")
                            searchItemId = searchId
                            fetchBazaarData(for: searchId)
                        }
                    
                    Button {
                        // On plus button tap reset selectedSavedItemId for new manual item save
                        selectedSavedItemId = nil
                        saveCurrentSearchedItem()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(themeEngine.colors.accent)
                    }
                    .padding(.leading, 6)
                    .disabled(
                        searchItemId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        item == nil ||
                        selectedSavedItemId != nil
                    )
                }
                .padding(12)
                .background(themeEngine.colors.background.opacity(0.7))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeEngine.colors.accent.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: themeEngine.colors.accent.opacity(0.07), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.top, 24)
                
                // MARK: - Button to show saved items sheet and price alerts sheet
                HStack(spacing: 16) {
                    Spacer()
                    Button {
                        showSavedItemsSheet = true
                    } label: {
                        Text("Gespeicherte Items")
                            .font(.headline)
                            .foregroundColor(themeEngine.colors.accent)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeEngine.colors.accent.opacity(0.7), lineWidth: 1)
                            )
                    }
                    Button {
                        showPriceAlertsSheet = true
                    } label: {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 22))
                            .foregroundColor(themeEngine.colors.accent)
                            .padding(10)
                            .background(themeEngine.colors.background.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // MARK: - Saved Items Sheet
                .sheet(isPresented: $showSavedItemsSheet, onDismiss: {
                    // Do nothing on dismiss; detail card remains visible if an item selected
                }) {
                    NavigationView {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                if savedItemIds.isEmpty {
                                    Text("Keine gespeicherten Items")
                                        .foregroundColor(themeEngine.colors.text.opacity(0.7))
                                        .padding()
                                }
                                ForEach(savedItemIds, id: \.self) { id in
                                    let loading = isLoadingSavedItems[id] ?? false
                                    let savedItem = savedItems[id]
                                    BazaarSavedItemRow(
                                        id: id,
                                        loading: loading,
                                        savedItem: savedItem,
                                        themeEngine: themeEngine,
                                        onShow: {
                                            // Select this saved item, fetch and show detail
                                            selectedSavedItemId = id
                                            showItem = true
                                            fetchBazaarData(for: id, isForSavedItem: true)
                                            showSavedItemsSheet = false
                                            // Keyboard should be dismissed reliably
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                                searchFieldFocused = false
                                            }
                                        },
                                        onDelete: {
                                            deleteSavedItemId(at: id)
                                            // If deleted selected item, clear selection and hide detail
                                            if selectedSavedItemId == id {
                                                selectedSavedItemId = nil
                                                showItem = false
                                                item = nil
                                            }
                                        },
                                        onSetLiveActivity: {
                                            // Removed live activity functionality
                                        }
                                    )
                                }
                            }
                            .padding(.vertical)
                        }
                        .navigationTitle("Gespeicherte Items")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Schließen") {
                                    showSavedItemsSheet = false
                                }
                            }
                        }
                        .background(themeEngine.colors.background.ignoresSafeArea())
                        .onAppear {
                            // Always fetch all saved items when sheet appears
                            for id in savedItemIds {
                                fetchBazaarData(for: id, isForSavedItem: true)
                            }
                        }
                    }
                }
                // MARK: - Price Alerts Sheet
                .sheet(isPresented: $showPriceAlertsSheet) {
                    NavigationView {
                        List {
                            if priceAlerts.isEmpty {
                                Text("Keine Preisalarme")
                                    .foregroundColor(themeEngine.colors.text.opacity(0.7))
                            } else {
                                ForEach(priceAlerts) { alert in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(alert.itemId.titleCasedWithSpaces)
                                                .font(.headline)
                                            Text("Alarm bei ≤ \(String(format: "%.2f", alert.targetPrice)) Coins")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Button(role: .destructive) {
                                            deletePriceAlert(at: alert.id)
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .navigationTitle("Preisalarme")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Schließen") {
                                    showPriceAlertsSheet = false
                                }
                            }
                        }
                        .background(themeEngine.colors.background.ignoresSafeArea())
                    }
                }

                // MARK: - Main Item Detail View
                if let item = item, showItem {
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
                                Text((selectedSavedItemId ?? searchItemId).titleCasedWithSpaces)
                                    .font(.title2.bold())
                                    .foregroundColor(themeEngine.colors.text)
                                Text((selectedSavedItemId ?? searchItemId).isEmpty ? "" : "skyblock:\((selectedSavedItemId ?? searchItemId).lowercased())")
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
                                    Text("\(item.buyPrice, specifier: "%.1f") Coins")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                        .onTapGesture {
                                            searchFieldFocused = false
                                            showAlertMenu = true
                                        }
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Insta Buy")
                                        .font(.headline)
                                        .foregroundColor(themeEngine.colors.text)
                                    Text("\(item.instaBuyPrice, specifier: "%.1f") Coins")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                }
                            }
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Sell Offer")
                                        .font(.headline)
                                        .foregroundColor(themeEngine.colors.text)
                                    Text("\(item.sellPrice, specifier: "%.1f") Coins")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Insta Sell")
                                        .font(.headline)
                                        .foregroundColor(themeEngine.colors.text)
                                    Text("\(item.instaSellPrice, specifier: "%.1f") Coins")
                                        .font(.title3.bold())
                                        .foregroundColor(themeEngine.colors.accent)
                                }
                            }
                        }
                        
                        Divider()
                        
                    }
                    .padding(30)
                    .background(themeEngine.colors.background.opacity(0.85))
                    .cornerRadius(24)
                    .padding(.bottom, keyboardHeight)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            searchFieldFocused = false
        }
        .onAppear {
            startKeyboardObservers()
            requestNotificationPermission()
            
            // Always load savedItemIds and priceAlerts first
            loadSavedItemIds()
            loadPriceAlerts()
            
            // Use async dispatch to ensure savedItemIds state is updated before fetching saved items
            DispatchQueue.main.async {
                // Always fetch all saved items on appear, regardless of search or selection
                for id in savedItemIds {
                    fetchBazaarData(for: id, isForSavedItem: true)
                }
                
                // Fetch single item if a saved item is selected
                if let selectedId = selectedSavedItemId {
                    fetchBazaarData(for: selectedId)
                } 
                // Otherwise, fetch for current searchItemId if not empty
                else if !searchItemId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let searchId = searchItemId.uppercased().replacingOccurrences(of: " ", with: "_")
                    fetchBazaarData(for: searchId)
                }
                // If neither saved item selected nor search id, do not fetch anything else, but saved items are loaded and can be shown immediately
            }
            
            priceRefreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                if let selectedId = selectedSavedItemId {
                    fetchBazaarData(for: selectedId)
                } else if !searchItemId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let searchId = searchItemId.uppercased().replacingOccurrences(of: " ", with: "_")
                    fetchBazaarData(for: searchId)
                }
                for id in savedItemIds {
                    fetchBazaarData(for: id, isForSavedItem: true)
                }
                
            }
        }
        .onDisappear {
            stopKeyboardObservers()
            priceRefreshTimer?.invalidate()
            priceRefreshTimer = nil
        }
        .sheet(isPresented: $showAlertMenu, onDismiss: {
            withAnimation {
                showAlertConfirmation = false
            }
            tempAlertPrice = ""
            searchFieldFocused = false
        }) {
            VStack(spacing: 20) {
                Text("Preisalarm setzen für Buy Offer")
                    .font(.headline)
                Text("Item: \((selectedSavedItemId ?? searchItemId).titleCasedWithSpaces)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("Alarm wenn Buy Offer <= ...", text: $tempAlertPrice)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .focused($searchFieldFocused)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.searchFieldFocused = true
                        }
                    }
                Button("Alarm setzen") {
                    if let value = Double(tempAlertPrice.replacingOccurrences(of: ",", with: ".")), value > 0 {
                        alertPrice = value
                        schedulePriceAlertNotification(for: value)
                        withAnimation {
                            showAlertConfirmation = true
                        }
                        tempAlertPrice = ""
                        searchFieldFocused = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showAlertMenu = false
                        }
                    }
                }
                .font(.title3.bold())
                .padding()
                .frame(maxWidth: .infinity)
                .background(themeEngine.colors.accent.opacity(0.85))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                Button("Abbrechen") {
                    showAlertMenu = false
                    tempAlertPrice = ""
                    searchFieldFocused = false
                }
                .foregroundColor(.red)
                .padding(.top, 8)
            }
            .padding()
        }
        .alert("Preis-Alarm aktiviert!", isPresented: $showAlertConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Du wirst benachrichtigt, wenn Buy Offer <= \(String(format: "%.2f", alertPrice ?? 0)) Coins ist.")
        }
    }

    // MARK: - Netzwerk, Laden von Daten
    
    func fetchBazaarData(for itemId: String = "ENCHANTED_DIAMOND", isForSavedItem: Bool = false) {
        if isForSavedItem {
            DispatchQueue.main.async {
                self.isLoadingSavedItems[itemId] = true
            }
        } else {
            self.showItem = false
            self.isLoading = true
            // Cancel any previous search task
            searchTask?.cancel()
        }
        let url = URL(string: "https://api.hypixel.net/v2/skyblock/bazaar")!
        let task = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoded = try JSONDecoder().decode(HypixelBazaarResponse.self, from: data)
                if let result = decoded.toBazaarItem(for: itemId.uppercased()) {
                    await MainActor.run {
                        if isForSavedItem {
                            self.savedItems[itemId] = result
                            self.isLoadingSavedItems[itemId] = false
                            // If this is the selected saved item, update main detail display as well
                            if selectedSavedItemId == itemId {
                                self.item = result
                                self.isLoading = false
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    self.showItem = true
                                }
                            }
                        } else {
                            self.item = result
                            self.isLoading = false
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                self.showItem = true
                            }
                        }
                    }
                } else {
                    await MainActor.run {
                        if isForSavedItem {
                            self.isLoadingSavedItems[itemId] = false
                            self.savedItems[itemId] = nil
                            if selectedSavedItemId == itemId {
                                self.isLoading = false
                                self.showItem = false
                                self.item = nil
                            }
                        } else {
                            self.isLoading = false
                            self.showItem = false
                            self.item = nil
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    if isForSavedItem {
                        self.isLoadingSavedItems[itemId] = false
                        self.savedItems[itemId] = nil
                        if selectedSavedItemId == itemId {
                            self.isLoading = false
                            self.showItem = false
                            self.item = nil
                        }
                    } else {
                        self.isLoading = false
                        self.showItem = false
                        self.item = nil
                    }
                }
                print("Bazaar fetch error: \(error)")
            }
        }
        if !isForSavedItem {
            searchTask = task // Only assign/cancel for search, not for saved item
        }
    }

    // MARK: - Keyboard Observers
    
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
    
    // MARK: - Speicherung Verwaltung
    
    private func loadSavedItemIds() {
        if let savedIds = UserDefaults.standard.array(forKey: "savedBazaarItemIds") as? [String] {
            savedItemIds = savedIds
        } else {
            savedItemIds = []
        }
    }
    
    private func saveItemIds() {
        UserDefaults.standard.set(savedItemIds, forKey: "savedBazaarItemIds")
    }
    
    private func deleteSavedItemId(at id: String) {
        if let index = savedItemIds.firstIndex(of: id) {
            savedItemIds.remove(at: index)
            savedItems[id] = nil
            isLoadingSavedItems[id] = nil
            saveItemIds()
        }
    }
    
    private func saveCurrentSearchedItem() {
        searchTask?.cancel()
        let itemId = searchItemId.uppercased().replacingOccurrences(of: " ", with: "_")
        if !itemId.isEmpty, item != nil {
            if !savedItemIds.contains(itemId) {
                savedItemIds.append(itemId)
                saveItemIds()
                // Sofort für das neue Item die Daten laden
                fetchBazaarData(for: itemId, isForSavedItem: true)
            }
            showItemSavedConfirmation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation { showItemSavedConfirmation = false }
                searchItemId = ""
            }
        }
    }

    // MARK: - Price Alert Notification

    func schedulePriceAlertNotification(for target: Double) {
        // Hier wird die Notification vorbereitet. Die eigentliche Preis-Prüfung sollte im Timer-Callback erfolgen.
        // Wenn item?.buyPrice <= target, triggere eine Notification:
        if let actual = item?.buyPrice, actual <= target {
            let content = UNMutableNotificationContent()
            content.title = "Preis Notification"
            content.body = "Buy Offer ist bei \(String(format: "%.1f", actual)) Coins"
            content.sound = .default
            let request = UNNotificationRequest(identifier: "priceAlert_\(selectedSavedItemId ?? searchItemId)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
        // Add alert to priceAlerts list if not exist yet
        let newAlert = PriceAlert(id: UUID(), itemId: (selectedSavedItemId ?? searchItemId), targetPrice: target)
        if !priceAlerts.contains(where: { $0.itemId == newAlert.itemId && $0.targetPrice == newAlert.targetPrice }) {
            priceAlerts.append(newAlert)
            savePriceAlerts()
        }
    }
    
    // MARK: - Repeat Price Notification
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    

    // MARK: - Price Alerts Persistence
    
    private func loadPriceAlerts() {
        if let data = UserDefaults.standard.data(forKey: "priceAlerts"),
           let loaded = try? JSONDecoder().decode([PriceAlert].self, from: data) {
            priceAlerts = loaded
        } else {
            priceAlerts = []
        }
    }

    private func savePriceAlerts() {
        if let data = try? JSONEncoder().encode(priceAlerts) {
            UserDefaults.standard.set(data, forKey: "priceAlerts")
        }
    }

    private func deletePriceAlert(at id: UUID) {
        priceAlerts.removeAll { $0.id == id }
        savePriceAlerts()
    }
}

struct BazaarSavedItemRow: View {
    let id: String
    let loading: Bool
    let savedItem: BazaarItem?
    let themeEngine: ThemeEngine
    let onShow: () -> Void
    let onDelete: () -> Void
    let onSetLiveActivity: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(themeEngine.colors.background.opacity(0.85))
                .shadow(color: themeEngine.colors.accent.opacity(0.1), radius: 4, x: 0, y: 2)
            HStack(spacing: 16) {
                Image(systemName: "diamond.fill")
                    .font(.system(size: 40))
                    .foregroundColor(themeEngine.colors.accent)
                    .padding(10)
                    .background(themeEngine.colors.background.opacity(0.5))
                    .clipShape(Circle())
                    .padding(.leading, 8)
                VStack(alignment: .leading, spacing: 4) {
                    Text(id.titleCasedWithSpaces)
                        .font(.title3.bold())
                        .foregroundColor(themeEngine.colors.text)
                    Text("skyblock:\(id.lowercased())")
                        .font(.subheadline)
                        .foregroundColor(themeEngine.colors.text.opacity(0.6))
                    if loading {
                        Text("Lädt …")
                            .foregroundColor(themeEngine.colors.accent)
                            .font(.caption.bold())
                    } else if savedItem == nil {
                        Text("Fehler beim Laden")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                Spacer()
                HStack(spacing: 12) {
                    Button {
                        onShow()
                    } label: {
                        Text("Anzeigen")
                            .font(.subheadline.bold())
                            .foregroundColor(themeEngine.colors.accent)
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeEngine.colors.accent, lineWidth: 1)
                            )
                    }
                }
                .padding(.trailing, 8)
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
    }
}

// Note: Do NOT use @main in view files like this. The @main attribute should only be applied to the main App struct entry point.
// Retain this #Preview macro for SwiftUI previews.
#Preview {
    BazaarTrackerView().environmentObject(ThemeEngine())
}

