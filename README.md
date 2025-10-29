# Zentra iOS

A modern iOS application with liquid glass design featuring Hypixel Skyblock integration, Discord webhook logging, and advanced theming system.

---

## 📱 For Users

### Welcome to Zentra

Zentra is a sleek iOS application designed for Hypixel Skyblock players and enthusiasts. The app features a beautiful liquid glass design with modern glassmorphism effects, providing an elegant and intuitive user experience.

### Key Features

#### 🎮 Hypixel Skyblock Integration
- **Bazaar Tracker**: Track and monitor Hypixel Skyblock bazaar prices in real-time
- **Bazaar Profit Calculator**: Calculate potential profits from bazaar trading opportunities
- **Price Alerts**: Set up alerts for specific item prices
- **Saved Items**: Save frequently tracked items for quick access

#### 🎨 Theming System
- **Pre-installed Themes**:
  - Liquid Glass (Default): Deep blue with glassmorphism effects
  - Liquid Glass Light: Light variant with softer colors  
  - Liquid Glass Dark: Dark variant with enhanced contrast
- **Custom Themes**: Import your own theme configurations via JSON files
- **Instant Switching**: Change themes with real-time preview
- **Beautiful Design**: Liquid glass aesthetics with smooth animations

#### 🔐 Security Features
- **Face ID / Touch ID**: Biometric authentication support
- **Passcode Protection**: Secure your app with device passcode
- **Secure Storage**: Credentials stored safely in iOS Keychain
- **Remember Login**: Optionally save login state

#### 📡 Discord Integration
- **Webhook Logging**: Log events to your Discord server
- **Event Types**:
  - Login/Logout events
  - Theme changes
  - Settings modifications
- **Easy Setup**: Configure webhook URL in settings

### Getting Started

#### First Launch

1. **Login**:
   - Default test credentials:
     - Username: `admin` / Password: `1234`
     - Username: `user` / Password: `1234`
   - Tap "Login" to proceed
   - Enable "Remember login" if you want to stay logged in
   - Enable "Face ID / Passcode" for added security

2. **Navigation**:
   - Swipe from the **left edge** of the screen to open the menu
   - Or tap the **menu icon** (☰) in the top-left corner
   - Navigate between:
     - **Home**: Main dashboard with animated background
     - **Bazaar Tracker**: Monitor item prices
     - **Bazaar Profit**: Calculate trading profits
     - **Settings**: Configure app preferences

#### Using Bazaar Tracker

1. Open the side menu
2. Select "Bazaar Tracker"
3. Search for items or browse saved items
4. Set price alerts by tapping on item details
5. Save frequently used items for quick access

#### Setting Up Discord Webhooks

1. Go to **Settings** → **Discord Logging**
2. Create a webhook in your Discord server:
   - Server Settings → Integrations → Webhooks
   - Create a new webhook
   - Copy the webhook URL
3. Paste the URL into Zentra settings
4. Enable the logging options you want:
   - ✅ Post login/logout
   - ✅ Post theme changes
   - ✅ Post settings changes
5. Test the connection by tapping "Send test post"

#### Customizing Themes

**Using Pre-installed Themes**:
1. Go to **Settings** → **Design**
2. Use the picker to select a theme
3. Changes apply immediately

**Importing Custom Themes**:
1. Prepare a theme JSON file (see developer section for format)
2. Go to **Settings** → **Design** → **Upload theme**
3. Select your JSON file
4. The theme will be imported and activated

**Managing Themes**:
- Delete custom themes by tapping the trash icon
- Default themes cannot be deleted
- Themes are saved locally on your device

### Tips & Tricks

- **Quick Menu Access**: Swipe from the left edge for faster navigation
- **Secure Browsing**: Disable "Trust links from unknown sources" for extra security
- **Discord Notifications**: Set up webhooks to keep track of app activity
- **Theme Switching**: Change themes anytime to match your mood
- **Biometric Security**: Enable Face ID/Touch ID for seamless yet secure access

### Troubleshooting

**App won't start**
- Ensure you're using iOS 15.0 or later
- Try restarting your device
- Delete and reinstall the app

**Discord webhooks not working**
- Verify your webhook URL is correct
- Check that the Discord bot hasn't been deleted
- Ensure you have internet connectivity
- Try the "Send test post" button to verify

**Themes not loading**
- Check that theme JSON files are properly formatted
- Ensure file extension is `.json`
- Try restarting the app

**Login issues**
- Default credentials are for testing only
- Ensure "Remember login" is enabled if you want persistence
- Check Face ID/Touch ID settings if using biometric authentication

**Navigation problems**
- Use the menu icon if swipe gesture doesn't work
- Close and reopen the app if menu gets stuck

### Privacy & Security

- **Data Storage**: All data is stored locally on your device
- **Keychain Security**: Credentials are encrypted using iOS Keychain
- **No Telemetry**: The app doesn't collect personal data
- **Offline Support**: Core features work without internet connection
- **Discord Integration**: Only sends data you explicitly enable

### Support & Feedback

For issues, suggestions, or feedback, please contact the development team or submit an issue on GitHub.

---

## 👨‍💻 For Developers

### Project Overview

Zentra is a SwiftUI-based iOS application built with modern design principles and a modular architecture. The app demonstrates advanced UI techniques including glassmorphism, custom theming, and reactive state management.

### Architecture

```
Zentra/
├── ProjectNeeded/              # Core application components
│   ├── MenuApp.swift           # App entry point and lifecycle
│   ├── MainView.swift          # Main container view with navigation
│   ├── LoginView.swift         # Authentication interface
│   ├── SettingsView.swift      # Settings and configuration UI
│   └── SideMenu.swift          # Navigation sidebar component
│
├── themeEngine/                # Theming system
│   ├── ThemeEngine.swift       # Core theme management
│   ├── ThemeModel.swift        # Theme data model (Codable)
│   ├── ThemeColors.swift       # Color definitions structure
│   ├── Theme.swift             # Theme enumeration
│   ├── LiquidGlassModifier.swift  # Glassmorphism view modifiers
│   └── Color+Hex.swift         # Color hex conversion utilities
│
├── HypixelSkyblock/           # Hypixel Skyblock features
│   ├── BazaarTrackerView.swift     # Real-time price tracking
│   └── BazaarProfitCalculatorView.swift  # Profit calculations
│
├── DiscordIntegration/        # Discord webhook integration
│   └── DiscordWebhook.swift   # Webhook manager and utilities
│
├── LanguageSystem/           # Localization system
│   ├── LanguageManager.swift  # Language management
│   └── LanguageSetupView.swift  # Language selection UI
│
├── AppleServices/            # iOS native services
│   └── KeychainHelper.swift  # Secure storage utilities
│
├── Unassigned/              # Shared components
│   ├── Links.swift           # External link handlers
│   ├── PrimaryButtonStyle.swift  # Reusable button styles
│   └── TrademarkInfo.swift   # App branding information
│
└── Assets.xcassets/         # App icons and images
```

### Tech Stack

- **Framework**: SwiftUI
- **Language**: Swift 5.0+
- **Minimum iOS**: 15.0
- **Deployment Target**: iOS 18.4
- **Bundle ID**: `gv.Zentra`
- **Design Pattern**: MVVM with ObservableObject
- **State Management**: 
  - `@State` for local component state
  - `@Binding` for two-way data flow
  - `@AppStorage` for persistent user preferences
  - `@EnvironmentObject` for shared application state

### Key Components Deep Dive

#### Theme Engine System

The `ThemeEngine` class is the heart of the theming system:

**Features**:
- Loads themes from JSON files in `Documents/themes/`
- Provides three default themes (Liquid Glass variants)
- Handles theme persistence using `@AppStorage`
- Sends Discord notifications on theme changes
- Lazy loading of theme data

**Theme File Structure** (`Documents/themes/{themeId}.json`):
```json
{
  "id": "custom-theme",
  "name": "My Custom Theme",
  "background": "#0A0E27",
  "text": "#FFFFFF",
  "accent": "#5B8DEF",
  "icon": "#FFFFFF",
  "buttonBackground": "#5B8DEF",
  "buttonText": "#FFFFFF",
  "fieldBackground": "#1A1F3A",
  "border": "#2A3F5F",
  "navbarBackground": "#0A0E27",
  "navbarText": "#FFFFFF",
  "error": "#FF6B6B",
  "warning": "#FFD93D"
}
```

**Usage Example**:
```swift
@EnvironmentObject var themeEngine: ThemeEngine

var body: some View {
    Text("Hello")
        .foregroundColor(themeEngine.colors.text)
        .background(themeEngine.colors.background)
}
```

#### Liquid Glass Design System

The app implements a sophisticated glassmorphism design system:

**Available Modifiers**:
1. `.liquidGlassCard()` - Frosted glass cards with multiple layers
2. `.liquidGlassBackground()` - Transparent backgrounds with blur
3. `.liquidGlassButton()` - Buttons with gradient overlays

**Implementation Details**:
- Uses `.ultraThinMaterial` for blur effects
- Multi-layer gradients for depth
- Custom stroke overlays for glass edges
- Multiple shadow layers for realism

**Usage**:
```swift
VStack {
    Text("Content")
}
.liquidGlassCard()

TextField("Input", text: $text)
    .liquidGlassBackground(cornerRadius: 12)
```

#### Authentication System

**Components**:
- `LoginView`: Main authentication interface
- `KeychainHelper`: Secure credential storage
- `@AppStorage`: Login state persistence
- `LocalAuthentication`: Biometric authentication

**Current Implementation**:
- Hardcoded credentials for testing:
  - `admin` / `1234`
  - `user` / `1234`
- Credentials stored in iOS Keychain
- Session management via `@AppStorage`
- Biometric authentication support

**Security Considerations**:
```swift
// Credential storage
KeychainHelper.shared.save(
    password,
    service: "com.example.LoginApp",
    account: username
)

// Session state
@AppStorage("isLoggedIn") var isLoggedIn: Bool = false
```

**Future Improvements**:
- Replace with proper authentication server
- Implement token-based authentication
- Add password reset functionality
- Support for multiple authentication providers

#### Discord Integration

**Architecture**:
- `DiscordWebhookManager`: Singleton manager class
- Async/await pattern for network requests
- Configurable via `@AppStorage`
- Error handling with fallbacks

**Event Types**:
1. **Login Events**: User login/logout
2. **Theme Changes**: Theme switching
3. **Settings Changes**: Configuration updates
4. **Test Posts**: Webhook verification

**Implementation**:
```swift
@StateObject var discordWebhookManager = DiscordWebhookManager()

// Log an event
Task {
    await discordWebhookManager.logLogin(username: username)
}
```

**Webhook Payload Structure**:
- JSON format with embeds
- Color-coded by event type
- Timestamp included
- Configurable via Discord webhook settings

#### Navigation System

**Page Routing**:
- `selectedPage` binding controls current view
- Routes: `"start"`, `"bazaar"`, `"bazaarProfit"`, `"settings"`
- Side menu handles navigation
- Smooth transitions between pages

**Menu System**:
- Swipe gesture from left edge
- Tap gesture on menu icon
- Animated transitions
- Drag-to-dismiss functionality

### Setup Instructions

#### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 15.0+ SDK
- Swift 5.0+
- Apple Developer Account (for device deployment)

#### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/YannickGalow/Zentra-iOS.git
   cd Zentra-iOS
   ```

2. **Open in Xcode**:
   ```bash
   open Zentra.xcodeproj
   ```
   Or double-click `Zentra.xcodeproj` in Finder

3. **Configure Signing**:
   - Select the project in Xcode
   - Go to "Signing & Capabilities"
   - Select your development team
   - Xcode will automatically manage provisioning profiles

4. **Build Configuration**:
   - **Debug**: Development build with debug symbols
   - **Release**: Optimized build for distribution

5. **Run the App**:
   - Select target device or simulator
   - Press `Cmd + R` or click the Run button
   - First build may take several minutes

#### Environment Setup

**Required Configurations**:
- Bundle Identifier: `gv.Zentra` (update if needed)
- Deployment Target: iOS 18.4
- Swift Version: 5.0
- Minimum iOS: 15.0

**Optional Configurations**:
- Update keychain service identifier
- Configure custom URL schemes
- Set up push notification certificates

### Development Workflow

#### Code Style Guidelines

**SwiftUI Best Practices**:
- Use declarative syntax consistently
- Keep views small and focused (single responsibility)
- Extract reusable components
- Use proper state management for each case

**Naming Conventions**:
- Views: PascalCase with `View` suffix (`LoginView`, `SettingsView`)
- ViewModels: PascalCase with `ViewModel` suffix
- Models: PascalCase (`ThemeModel`, `BazaarItem`)
- Functions: camelCase with descriptive names
- Variables: camelCase

**Code Organization**:
```swift
struct MyView: View {
    // MARK: - Properties
    @State private var localState = ""
    @EnvironmentObject var sharedState
    
    // MARK: - Body
    var body: some View {
        // Implementation
    }
    
    // MARK: - Private Methods
    private func helperFunction() {
        // Implementation
    }
}
```

#### Adding New Features

**Step-by-Step Guide**:

1. **Create View Component**:
   ```swift
   struct NewFeatureView: View {
       @EnvironmentObject var themeEngine: ThemeEngine
       
       var body: some View {
           VStack {
               // Content
           }
           .liquidGlassCard()
       }
   }
   ```

2. **Add Navigation Route**:
   - Update `MainView.swift`:
   ```swift
   } else if selectedPage == "newFeature" {
       NewFeatureView()
           .environmentObject(themeEngine)
   }
   ```

3. **Add Menu Item**:
   - Update `SideMenu.swift`:
   ```swift
   SideMenuButtonView(label: "New Feature", icon: "star.fill", style: .primary) {
       selectedPage = "newFeature"
       onCollapse?()
   }
   ```

4. **Theme Support**:
   - Always use `themeEngine.colors.*` for colors
   - Apply liquid glass modifiers for consistency
   - Test with all theme variants

#### State Management Patterns

**Local State** (`@State`):
```swift
@State private var isToggled = false
@State private var inputText = ""
```

**Shared State** (`@EnvironmentObject`):
```swift
@EnvironmentObject var themeEngine: ThemeEngine
@EnvironmentObject var webhookManager: DiscordWebhookManager
```

**Persistent State** (`@AppStorage`):
```swift
@AppStorage("rememberLogin") var rememberLogin: Bool = false
@AppStorage("isLoggedIn") var isLoggedIn: Bool = false
```

**Two-Way Binding** (`@Binding`):
```swift
@Binding var selectedPage: String?

// Usage
SomeView(selectedPage: $selectedPage)
```

### Testing

#### Manual Testing Checklist

- [ ] Login flow works correctly
- [ ] Theme switching functions properly
- [ ] Navigation works on all pages
- [ ] Discord webhooks send correctly
- [ ] Settings persist after app restart
- [ ] Biometric authentication works
- [ ] Bazaar features function correctly
- [ ] All themes display properly
- [ ] Input fields are readable
- [ ] Animations are smooth

#### Testing on Different Devices

- iPhone SE (small screen)
- iPhone 15/16 (standard)
- iPhone Pro Max (large screen)
- iPad (if supported in future)

#### Known Issues

1. **Deprecated API Warning**:
   - `windows` property in `BazaarTrackerView.swift:576`
   - Will need migration to `UIWindowScene.windows`
   - Currently doesn't affect functionality, but should be fixed

2. **Hardcoded Credentials**:
   - Authentication uses hardcoded test credentials
   - Should be replaced with proper auth system

3. **Theme File Management**:
   - No validation for malformed JSON
   - Should add error handling for invalid theme files

### Build Process

#### Debug Build
```bash
xcodebuild -scheme Zentra \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -configuration Debug \
  build
```

#### Release Build
```bash
xcodebuild -scheme Zentra \
  -destination 'generic/platform=iOS' \
  -configuration Release \
  archive
```

#### Clean Build
```bash
xcodebuild -scheme Zentra \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  clean build
```

#### Install on Simulator
```bash
xcrun simctl install <DEVICE_ID> \
  <BUILD_PRODUCTS_PATH>/Zentra.app

xcrun simctl launch <DEVICE_ID> gv.Zentra
```

### File Structure Details

#### Core Views

**MenuApp.swift**:
- Application entry point
- Lifecycle management
- State initialization
- Environment object setup
- Push notification handling

**MainView.swift**:
- Main container view
- Page routing logic
- Nebula background animation
- Side menu integration
- Gesture handling

**LoginView.swift**:
- Authentication UI
- Liquid glass input fields
- Biometric authentication UI
- Credential validation
- Error handling

**SettingsView.swift**:
- Settings interface
- Theme picker with wheel style
- Discord webhook configuration
- Privacy/security toggles
- Theme import/export

**SideMenu.swift**:
- Slide-out navigation menu
- User profile display
- Quick navigation buttons
- Social links
- Logout functionality

#### Theme System

**ThemeEngine.swift**:
- Singleton pattern for theme management
- File I/O for theme persistence
- Default theme initialization
- Theme metadata loading
- Discord integration for theme changes

**ThemeModel.swift**:
- Codable structure for JSON serialization
- Color property definitions
- Theme validation
- Conversion to `ThemeColors` structure

**LiquidGlassModifier.swift**:
- Custom view modifiers
- Glassmorphism implementation
- Gradient overlays
- Shadow and blur effects
- Reusable design components

#### Hypixel Integration

**BazaarTrackerView.swift**:
- Real-time API integration
- Item search functionality
- Price tracking and alerts
- Saved items management
- Error handling and retry logic

**BazaarProfitCalculatorView.swift**:
- Profit calculation algorithms
- Market analysis
- (Currently placeholder - to be implemented)

### API Integration

#### Hypixel Skyblock API

**Endpoints Used**:
- Bazaar data endpoint
- Item information endpoint
- Price history endpoint

**Implementation Notes**:
- Async/await pattern
- Error handling with retries
- Caching for performance
- Background refresh support

### Dependencies

**Apple Frameworks**:
- SwiftUI: Core UI framework
- Foundation: Core functionality
- UIKit: Legacy UI components (for specific features)
- LocalAuthentication: Biometric authentication
- UserNotifications: Push notifications
- UniformTypeIdentifiers: File type handling

**External Dependencies**:
- None currently (pure SwiftUI implementation)

### Configuration Files

**Info.plist**:
- Bundle identifier
- Face ID usage description
- URL schemes
- Supported orientations
- Status bar configuration

**Entitlements**:
- `Zentra.entitlements`: Release configuration
- `ZentraDebug.entitlements`: Debug configuration
- Keychain access groups
- App Sandbox settings

### Debugging

#### Common Debugging Scenarios

**Theme Not Loading**:
- Check `Documents/themes/` directory exists
- Verify JSON file format
- Check console for decoding errors
- Verify file permissions

**Discord Webhook Issues**:
- Test webhook URL manually
- Check network connectivity
- Verify webhook permissions
- Review error logs

**Navigation Problems**:
- Check `selectedPage` binding state
- Verify menu gesture recognizers
- Review animation transitions
- Check z-index layering

**Performance Issues**:
- Profile with Instruments
- Check for memory leaks
- Optimize image loading
- Review animation performance

### Contributing

#### Development Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes following code style guidelines
4. Test thoroughly on multiple devices
5. Commit with descriptive messages
6. Push to your branch
7. Create a Pull Request

#### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] Tests pass (if applicable)
- [ ] Documentation updated
- [ ] No console warnings
- [ ] All themes tested
- [ ] Responsive on all screen sizes

### Future Roadmap

#### Planned Features
- [ ] Remote authentication system
- [ ] Cloud theme synchronization
- [ ] Push notifications for price alerts
- [ ] Home Screen widgets
- [ ] iPad optimization
- [ ] Watch app companion
- [ ] Advanced analytics dashboard
- [ ] Social features
- [ ] Marketplace integration

#### Technical Improvements
- [ ] Unit test suite
- [ ] UI test automation
- [ ] CI/CD pipeline
- [ ] Code documentation automation
- [ ] Performance monitoring
- [ ] Crash reporting
- [ ] Analytics integration
- [ ] Accessibility improvements

### License

© 2025 Yannick Galow

This project is for development and testing purposes.

---

## 📝 Version History

### Version 1.0 (Current)
- Initial release
- Liquid glass design system
- Basic Hypixel Skyblock integration
- Discord webhook logging
- Theme system implementation
- Secure authentication

---

## 🔗 Resources

- **GitHub Repository**: [Zentra-iOS](https://github.com/YannickGalow/Zentra-iOS)
- **Developer**: Yannick Galow
- **Platform**: iOS 15.0+
- **Language**: Swift 5.0+

---

## ⚠️ Important Notes

- This is a **Debugger Version** - for development and testing
- Some features may be incomplete or experimental
- Always test thoroughly before production use
- Never commit sensitive credentials or API keys
- Keep theme files in secure locations
- Review Discord webhook URLs before sharing

---

## 🐛 Reporting Issues

When reporting issues, please include:
- iOS version
- Device model
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Console logs if available

---

*Last updated: 2025*
