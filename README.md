# 🎨 Zentra iOS

<div align="center">

**A modern iOS application with liquid glass design**

*Current purpose and identity are yet to be determined*

[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)]()

</div>

---

## 📑 Table of Contents

- [📱 For Users](#-for-users)
  - [Welcome](#welcome)
  - [Key Features](#key-features)
  - [Getting Started](#getting-started)
  - [Tips & Troubleshooting](#tips--troubleshooting)
- [👨‍💻 For Developers](#-for-developers)
  - [Project Overview](#project-overview)
  - [Architecture](#architecture)
  - [Setup & Development](#setup--development)
  - [API Integration](#api-integration)
- [📝 Version History](#-version-history)
- [🔗 Resources](#-resources)

---

## 📱 For Users

### Welcome

**Zentra** is a sleek iOS application featuring a beautiful **liquid glass design** with modern glassmorphism effects, providing an elegant and intuitive user experience.

> **Note:** The app's specific purpose and identity are currently under development.

---

### Key Features

#### 🔧 Core Features

| Feature | Status | Description |
|---------|--------|-------------|
| **Server Statistics Dashboard** | ✅ Active | Real-time server status monitoring with automatic updates |
| **Bazaar Tracker** | ❌ Removed | Buttons remain in sidebar but disabled |
| **Bazaar Profit Calculator** | ❌ Removed | Buttons remain in sidebar but disabled |

**Server Statistics Dashboard:**
- ✅ Live server status display (Online/Offline)
- ✅ Automatic status updates every 10 seconds
- ✅ Pull-to-refresh support
- ✅ Custom status messages support
- ✅ **Login required** - Only visible when logged in
- ✅ Login prompt shown when not authenticated

---

#### 🎨 Theming System (TCF)

**Theme Controlling Framework** - A powerful theming system with:

**Pre-installed Themes:**
- 🌊 **Liquid Glass** (Default) - Deep blue with glassmorphism effects
- 🌅 **Liquid Glass Light** - Light variant with softer colors
- 🌑 **Liquid Glass Dark** - Dark variant with enhanced contrast

**Smart Theme Selection:**
- 🎯 **Auto-detection** - Theme automatically matches system appearance on first launch
- 🌙 **Dark Mode** → Liquid Glass Dark Theme
- ☀️ **Light Mode** → Liquid Glass Light Theme
- 🔄 **Manual Override** - Change theme anytime in Settings

**Custom Themes:**
- 📁 Import your own theme configurations via `.gtheme` files
- 🔒 Password protection for encrypted themes
- 🎨 Advanced `.gtheme` format with individual color definitions
- 📱 Device adaptation (automatic light/dark mode)
- ⚡ Instant switching with real-time preview
- ✨ Beautiful loading animations

---

#### 🔧 Developer Options

**Hidden by Default** - Must be activated:

1. **Activation:** Tap the profile avatar/logo **5 times** (only when logged in)
2. **Visual Feedback:** Haptic feedback and toast notification
3. **Features:**
   - ⚙️ **Performance Settings**
     - Animation Control: Toggle app-wide animations
     - Smooth Performance: Disable for better performance on older devices
   - ℹ️ **Developer Information**
     - App version and build number
     - TCF version
     - Bundle identifier
     - Device information
   - 🔔 **Send Test Notification**
     - Test push notification functionality
     - Verify notification permissions

---

#### 🔐 Security Features

- 🔑 **Face ID / Touch ID** - Biometric authentication support
- 🔒 **Passcode Protection** - Secure your app with device passcode
- 💾 **Secure Storage** - Credentials stored safely in iOS Keychain
- 💭 **Remember Login** - Optionally save login state

---

#### 📡 Discord Integration

**Webhook Logging** - Log events to your Discord server:

| Event Type | Icon | Description |
|------------|------|-------------|
| Login/Logout | 🔐 | Authentication events |
| Theme Changes | 🎨 | Theme switching events |
| Settings Changes | ⚙️ | Configuration updates |
| Custom Messages | 💬 | User-defined messages |

**Features:**
- ✅ Easy setup - Configure webhook URL in settings
- ✅ Smart display - Settings only appear when valid webhook URL is entered
- ✅ Quick messages - Send custom messages directly to Discord

---

### Getting Started

#### 🚀 First Launch

**1. Setup Process**
- On first launch, you'll see a **4-page setup guide**:
  - **Page 1:** App introduction and features overview
  - **Page 2:** Login prompt (optional)
  - **Page 3:** Support and Discord community information
  - **Page 4:** Ready to use message
- Theme automatically matches your system appearance (Dark/Light Mode)
- Swipe or tap "Weiter" to navigate through setup

**2. App Start**
- After setup, the app starts directly
- You can use the app without logging in
- To access login-protected features, log in via the side menu

**2. Navigation**
- Swipe from the **left edge** of the screen to open the menu
- Or tap the **menu icon** (☰) in the top-left corner
- Navigate between:
  - 📊 **Dashboard** - Server Statistics dashboard
  - 🛒 **Bazaar Tracker** - *Currently disabled*
  - 💰 **Bazaar Profit** - *Currently disabled*
  - ⚙️ **Settings** - Configure app preferences

**3. Login** (Optional)
- Open the side menu
- Tap **"Login"** in the Profile section
- Or tap "Login" on the Dashboard if not logged in
- Server-based authentication with token management
- Default test credentials:
  - Username: `admin` / Password: `1234`
  - Username: `user` / Password: `1234`
- Enable "Remember login" for persistence
- Enable "Face ID / Passcode" for added security
- **Note:** Login is required to access Server Statistics and Settings

---

#### 🎯 Quick Setup Guides

**Activating Developer Options:**
1. Log in to your account (required)
2. Open the side menu
3. **Tap the profile avatar/logo 5 times** (within 2 seconds)
4. Feel haptic feedback and see toast notification
5. Developer Options now appear in Settings

**Setting Up Discord Webhooks:**
1. Go to **Settings** → **Discord Integration Settings**
2. Create a webhook in your Discord server
3. Copy and paste the webhook URL
4. Configure event types to log
5. Test with "Send test post" button

**Customizing Themes:**
- **Pre-installed:** Settings → Design → Select theme
- **Custom:** Settings → Design → Upload theme → Select `.gtheme` file
- **Password-protected:** Enter password when prompted

---

### Tips & Troubleshooting

#### 💡 Tips & Tricks

- ⚡ **Quick Menu Access** - Swipe from left edge for faster navigation
- 🔓 **No Login Required** - App works without logging in
- 🔍 **Profile Status** - Check login status in Profile section
- 🔒 **Secure Browsing** - Disable "Trust links from unknown sources"
- 🎨 **Theme Switching** - Change themes anytime to match your mood
- ⚡ **Performance Mode** - Disable animations for better performance

---

#### 🐛 Troubleshooting

<details>
<summary><b>App won't start</b></summary>

- Ensure you're using iOS 15.0 or later
- Try restarting your device
- Delete and reinstall the app

</details>

<details>
<summary><b>Discord webhooks not working</b></summary>

- Verify webhook URL contains "discord.com/api/webhooks/"
- Check that the Discord bot hasn't been deleted
- Ensure internet connectivity
- Try the "Send test post" button

</details>

<details>
<summary><b>Themes not loading</b></summary>

- Check that theme files use the `.gtheme` extension
- Ensure file is not corrupted or renamed
- For encrypted themes, verify the password is correct
- Try restarting the app

</details>

<details>
<summary><b>Login issues</b></summary>

- Login is optional - app works without authentication
- Default credentials are for testing only
- Ensure "Remember login" is enabled for persistence
- Check Face ID/Touch ID settings if using biometrics

</details>

---

### Privacy & Security

- 🔒 **Data Storage** - All data stored locally on your device
- 🔐 **Keychain Security** - Credentials encrypted using iOS Keychain
- 🚫 **No Telemetry** - App doesn't collect personal data
- 📡 **Offline Support** - Core features work without internet
- 🔒 **Discord Integration** - Only sends data you explicitly enable

---

## 👨‍💻 For Developers

### Project Overview

**Zentra** is a SwiftUI-based iOS application built with modern design principles and a modular architecture. The app demonstrates advanced UI techniques including glassmorphism, custom theming, and reactive state management.

---

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
├── themeEngine/                # Theme Controlling Framework (TCF)
│   ├── ThemeControllingFramework.swift  # Core TCF implementation
│   ├── TCFThemeModel.swift     # Enhanced theme model with encryption
│   ├── ThemeColors.swift       # Color definitions structure
│   ├── Theme.swift             # Theme enumeration
│   ├── ThemePasswordView.swift # Password input for encrypted themes
│   ├── LiquidGlassModifier.swift  # Glassmorphism view modifiers
│   └── Color+Hex.swift         # Color hex conversion utilities
│
├── HypixelSkyblock/           # Features (purpose yet to be determined)
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
│   ├── AnimationHelper.swift    # Conditional animation utilities
│   ├── TrademarkInfo.swift   # App branding information
│   └── ServerManager.swift  # Server API communication manager
│
└── Assets.xcassets/         # App icons and images
```

---

### Tech Stack

| Component | Technology |
|-----------|-----------|
| **Framework** | SwiftUI |
| **Language** | Swift 5.0+ |
| **Minimum iOS** | 15.0 |
| **Deployment Target** | iOS 18.4 |
| **Bundle ID** | `gv.Zentra` |
| **Design Pattern** | MVVM with ObservableObject |

**State Management:**
- `@State` - Local component state
- `@Binding` - Two-way data flow
- `@AppStorage` - Persistent user preferences
- `@EnvironmentObject` - Shared application state

---

### Key Components

#### 🎨 Theme Controlling Framework (TCF)

**Core Class:** `ThemeControllingFramework`

**Features:**
- ✅ Loads themes from `.gtheme` files in `Documents/themes/`
- ✅ Three default themes (Liquid Glass variants)
- ✅ Password encryption/decryption support
- ✅ Device default adaptation (automatic light/dark mode)
- ✅ File extension validation (`.gtheme` only)
- ✅ Corruption detection for renamed files
- ✅ Individual color definitions with opacity control

**Theme File Structure:**
```json
{
  "id": "custom-theme",
  "name": "My Custom Theme",
  "version": "1.0",
  "isEncrypted": false,
  "background": {
    "hex": "#0A0E27",
    "opacity": 1.0
  },
  "text": {
    "hex": "#FFFFFF",
    "opacity": 1.0
  },
  "accent": {
    "hex": "#5B8DEF",
    "opacity": 1.0
  },
  "adaptsToDeviceDefaults": true,
  "deviceDefaultBase": null
}
```

**Usage Example:**
```swift
@EnvironmentObject var tcf: TCF

var body: some View {
    Text("Hello")
        .foregroundColor(tcf.colors.text)
        .background(tcf.colors.background)
}
```

> **Note:** `ThemeEngine` is deprecated - use `TCF` directly for new code.

---

#### 🌊 Liquid Glass Design System

**Available Modifiers:**
1. `.liquidGlassCard()` - Frosted glass cards with multiple layers
2. `.liquidGlassBackground()` - Transparent backgrounds with blur
3. `.liquidGlassButton()` - Buttons with gradient overlays

**Implementation:**
- Uses `.ultraThinMaterial` for blur effects
- Multi-layer gradients for depth
- Custom stroke overlays for glass edges
- Multiple shadow layers for realism

**Usage:**
```swift
VStack {
    Text("Content")
}
.liquidGlassCard()

TextField("Input", text: $text)
    .liquidGlassBackground(cornerRadius: 12)
```

---

#### 🔐 Authentication System

**Components:**
- `LoginView` - Main authentication interface
- `KeychainHelper` - Secure credential storage
- `@AppStorage` - Login state persistence
- `LocalAuthentication` - Biometric authentication

**Current Implementation:**
- **Server-based authentication** - Token-based session management
- App starts without requiring login (after setup)
- Login is optional but required for certain features
- Server authentication endpoints:
  - `/api/auth/login` - User authentication
  - `/api/auth/logout` - Session termination
  - `/api/auth/verify` - Token validation
- Default test credentials:
  - `admin` / `1234`
  - `user` / `1234`
- Credentials stored in iOS Keychain
- Session management via `@AppStorage` and server tokens
- Biometric authentication support
- **Auto-logout protection** - Token validation prevents unauthorized access
- **Logout warning** - Users informed about settings reset on logout

**Security Example:**
```swift
// Credential storage
KeychainHelper.shared.save(
    password,
    service: "com.example.LoginApp",
    account: username
)

// Session state
@AppStorage("isLoggedIn") var isLoggedIn: Bool = false
@AppStorage("currentUsername") var currentUsername: String = ""
```

---

#### 📡 Discord Integration

**Architecture:**
- `DiscordWebhookManager` - Singleton manager class
- Async/await pattern for network requests
- Configurable via `@AppStorage`
- Conditional UI display based on webhook validity

**Event Types:**
| Event | Icon | Description |
|-------|------|-------------|
| Login Events | 🔐 | User login/logout |
| Theme Changes | 🎨 | Theme switching |
| Settings Changes | ⚙️ | Configuration updates |
| Custom Messages | 💬 | User-defined messages |
| Test Posts | ✅ | Webhook verification |

**Implementation:**
```swift
@StateObject var discordWebhookManager = DiscordWebhookManager()

// Log an event
Task {
    await discordWebhookManager.logLogin(username: username)
}

// Send custom message
Task {
    await discordWebhookManager.logCustomMessage(text: "Hello from Zentra!")
}
```

---

### Setup & Development

#### 📋 Prerequisites

- ✅ macOS 13.0 or later
- ✅ Xcode 15.0 or later
- ✅ iOS 15.0+ SDK
- ✅ Swift 5.0+
- ✅ Apple Developer Account (for device deployment)

---

#### 🚀 Installation

**1. Clone the Repository**
```bash
git clone https://github.com/YannickGalow/Zentra-iOS.git
cd Zentra-iOS
```

**2. Open in Xcode**
```bash
open Zentra.xcodeproj
```
Or double-click `Zentra.xcodeproj` in Finder

**3. Configure Signing**
- Select the project in Xcode
- Go to "Signing & Capabilities"
- Select your development team
- Xcode will automatically manage provisioning profiles

**4. Build Configuration**
- **Debug** - Development build with debug symbols
- **Release** - Optimized build for distribution

**5. Run the App**
- Select target device or simulator
- Press `Cmd + R` or click the Run button
- First build may take several minutes

---

#### 💻 Development Workflow

**Code Style Guidelines:**

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

**Naming Conventions:**
- Views: PascalCase with `View` suffix (`LoginView`, `SettingsView`)
- ViewModels: PascalCase with `ViewModel` suffix
- Models: PascalCase (`ThemeModel`, `BazaarItem`)
- Functions: camelCase with descriptive names
- Variables: camelCase

**Adding New Features:**

1. **Create View Component**
2. **Add Navigation Route** in `MainView.swift`
3. **Add Menu Item** in `SideMenu.swift`
4. **Theme Support** - Always use `tcf.colors.*` for colors

---

#### 🧪 Testing

**Manual Testing Checklist:**
- [ ] Setup process displays correctly on first launch
- [ ] Theme matches system appearance on first start
- [ ] App starts without requiring login (after setup)
- [ ] Side menu displays correctly
- [ ] Login flow works correctly with server authentication
- [ ] Token validation works on app start
- [ ] Logout warning displays correctly
- [ ] Settings are disabled when not logged in
- [ ] Server Statistics only visible when logged in
- [ ] Theme switching functions properly
- [ ] Navigation works on all pages
- [ ] Discord webhooks send correctly
- [ ] Settings persist after app restart
- [ ] Biometric authentication works

**Testing on Different Devices:**
- iPhone SE (small screen)
- iPhone 15/16 (standard)
- iPhone Pro Max (large screen)

---

### API Integration

#### 📡 Server API Integration

**ServerManager.swift:**
- Manages communication with local server
- Fetches server status and statistics
- Automatic retry and error handling
- Timeout configuration (5s request, 10s resource)

**Endpoints:**
- `/api/status` - Server status (online/offline, custom messages)
- `/api/stats` - Detailed server statistics (if needed)
- `/api/auth/login` - User authentication (POST)
- `/api/auth/logout` - Session termination (POST, requires Bearer token)
- `/api/auth/verify` - Token validation (POST, requires Bearer token)
- `/api/control` - Server control (start/stop/set_status)

**Implementation Notes:**
- Async/await pattern for network requests
- URLSession with custom timeout configuration (5s request, 10s resource)
- Automatic status refresh every 10 seconds
- Task cancellation on view disappearance
- Graceful error handling (network errors treated as offline)
- Token-based authentication with automatic validation
- Error codes displayed for debugging (format: `DBG-XXXXX-XXXX-HTTPXXX`)

> **Note:** Server endpoints and configuration are private and restricted to authorized access only.

---

### Dependencies

**Apple Frameworks:**
- SwiftUI - Core UI framework
- Foundation - Core functionality
- UIKit - Legacy UI components
- LocalAuthentication - Biometric authentication
- UserNotifications - Push notifications
- UniformTypeIdentifiers - File type handling (`.gtheme` file import)
- CryptoKit - Theme encryption/decryption (AES-GCM)

**External Dependencies:**
- None currently (pure SwiftUI implementation)

---

### Debugging

**Common Debugging Scenarios:**

<details>
<summary><b>Theme Not Loading</b></summary>

- Check `Documents/themes/` directory exists
- Verify `.gtheme` file format (not `.json` or renamed files)
- Check file extension is `.gtheme` (lowercase)
- For encrypted themes, verify password is correct
- Check console for decoding/decryption errors

</details>

<details>
<summary><b>Discord Webhook Issues</b></summary>

- Test webhook URL manually
- Check network connectivity
- Verify webhook permissions
- Review error logs

</details>

<details>
<summary><b>Navigation Problems</b></summary>

- Check `selectedPage` binding state
- Verify menu gesture recognizers
- Review animation transitions
- Check z-index layering

</details>

---

### Contributing

**Development Process:**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes following code style guidelines
4. Test thoroughly on multiple devices
5. Commit with descriptive messages
6. Push to your branch
7. Create a Pull Request

**Code Review Checklist:**
- [ ] Code follows style guidelines
- [ ] Tests pass (if applicable)
- [ ] Documentation updated
- [ ] No console warnings
- [ ] All themes tested
- [ ] Responsive on all screen sizes

---

### Future Roadmap

**Planned Features:**
- [ ] Define and implement primary app purpose
- [ ] Remote authentication system
- [ ] Cloud theme synchronization
- [ ] Push notifications for price alerts
- [ ] Home Screen widgets
- [ ] iPad optimization
- [ ] Watch app companion

**Technical Improvements:**
- [ ] Unit test suite
- [ ] UI test automation
- [ ] CI/CD pipeline
- [ ] Code documentation automation
- [ ] Performance monitoring
- [ ] Crash reporting

---

## 📝 Version History

### Version 1.0 (Current)

**Initial Release:**
- ✅ Liquid glass design system
- ✅ **TCF (Theme Controlling Framework)** - Complete migration from ThemeEngine
- ✅ **Password-protected themes** - Encrypt themes with passwords
- ✅ **`.gtheme` file format** - Advanced theme format with individual color definitions
- ✅ **File validation** - Only `.gtheme` files accepted, corruption detection
- ✅ **Smart Theme Selection** - Automatically matches system appearance on first launch
- ✅ **Setup Process** - 4-page onboarding guide on first launch
- ✅ **Server Statistics Dashboard** - Real-time server status monitoring (login required)
- ✅ **Server-based Authentication** - Token-based session management
- ✅ **Login Required Card** - Beautiful login prompt with support links
- ✅ **Developer Options** - Hidden settings activated by 5-tap gesture
- ✅ **Test Notification** - Send test notifications from Developer Options
- ✅ Discord Integration Settings with conditional display
- ✅ Custom Discord message support
- ✅ Theme loading animation
- ✅ Optional authentication (app starts without login requirement after setup)
- ✅ Login integrated in side menu and dashboard
- ✅ Complete English localization
- ✅ Enhanced animation controls throughout the app
- ✅ **Server integration** - Local server communication for status monitoring
- ✅ **Error Code System** - Debug error codes with HTTP status codes
- ✅ **Logout Warning** - Users informed about settings reset
- ✅ **Protected Settings** - Settings disabled when not logged in

> **Note:** App purpose and identity are yet to be determined

---

## 🔗 Resources

- **GitHub Repository:** [Zentra-iOS](https://github.com/YannickGalow/Zentra-iOS)
- **Developer:** Yannick Galow
- **Platform:** iOS 15.0+
- **Language:** Swift 5.0+

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

<div align="center">

**Last updated:** November 8th, 2025

**Recent Updates:**
- ✅ Setup process with 4 pages
- ✅ Server-based authentication system
- ✅ Smart theme selection based on system appearance
- ✅ Login Required Card with support links
- ✅ Developer Options expanded (Test Notification)
- ✅ Protected features (Settings, Server Statistics)
- ✅ Discord support link updated

Made with ❤️ by Yannick Galow

</div>
