# 🎨 Zentra iOS

<div align="center">

**A modern iOS application with liquid glass design**

*Elegant, intuitive, and beautifully designed*

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
  - [Privacy & Security](#privacy--security)
- [👨‍💻 For Developers](#-for-developers)
  - [Project Overview](#project-overview)
  - [Architecture](#architecture)
  - [Setup & Development](#setup--development)
  - [Key Components](#key-components)
  - [Testing](#testing)
  - [Debugging](#debugging)
  - [Contributing](#contributing)
- [📝 Version History](#-version-history)
- [🔗 Resources](#-resources)

---

## 📱 For Users

### Welcome

**Zentra** is a sleek iOS application featuring a beautiful **liquid glass design** with modern glassmorphism effects. The app provides an elegant and intuitive user experience with advanced theming capabilities and a focus on user privacy and security.

---

### Key Features

#### 🎨 Advanced Theming System (TCF)

**Theme Controlling Framework** - A powerful and flexible theming system that allows complete customization of the app's appearance.

**Pre-installed Themes:**
- 🌊 **Liquid Glass** (Default) - Deep blue with stunning glassmorphism effects
- 🌅 **Liquid Glass Light** - Light variant with softer colors and enhanced readability
- 🌑 **Liquid Glass Dark** - Dark variant with enhanced contrast for low-light environments

**Smart Theme Selection:**
- 🎯 **Auto-detection** - Theme automatically matches your system appearance on first launch
- 🌙 **Dark Mode** → Automatically applies Liquid Glass Dark Theme
- ☀️ **Light Mode** → Automatically applies Liquid Glass Light Theme
- 🔄 **Manual Override** - Change theme anytime in Settings to match your preference

**Custom Theme Support:**
- 📁 **Import Custom Themes** - Import your own theme configurations via `.gtheme` files
- 🔒 **Password Protection** - Secure your themes with password encryption
- 🎨 **Advanced Format** - Individual color definitions with opacity control
- 📱 **Device Adaptation** - Themes automatically adapt to device light/dark mode settings
- ⚡ **Instant Switching** - Real-time theme preview and instant application
- ✨ **Beautiful Animations** - Smooth transitions when switching themes

**Theme File Format:**
Themes use the `.gtheme` file format, which supports:
- Individual color definitions (background, text, accent, etc.)
- Opacity control for each color
- Encryption support for sensitive themes
- Device default adaptation settings

---

#### 🔧 Developer Options

**Hidden Feature** - Must be activated manually:

**Activation Process:**
1. **Login Required** - You must be logged in to access developer options
2. **Activation Gesture** - Tap the profile avatar/logo **5 times** within 2 seconds
3. **Visual Feedback** - Haptic feedback and toast notification confirm activation
4. **Access** - Developer Options now appear in Settings menu

**Available Features:**

**⚙️ Performance Settings:**
- **Animation Control** - Toggle app-wide animations on/off
- **Performance Mode** - Disable animations for better performance on older devices
- **Smooth Experience** - Balance between visual appeal and performance

**ℹ️ Developer Information:**
- **App Version** - Current version and build number
- **TCF Version** - Theme Controlling Framework version
- **Bundle Identifier** - App bundle identifier
- **Device Information** - Detailed device specifications

**🔔 Notification Testing:**
- **Send Test Notification** - Test push notification functionality
- **Permission Verification** - Verify notification permissions are working correctly
- **Debug Tool** - Useful for troubleshooting notification issues

---

#### 🔐 Security Features

**Comprehensive Security Implementation:**

- 🔑 **Biometric Authentication** - Face ID / Touch ID support for secure access
- 🔒 **Passcode Protection** - Secure your app with device passcode
- 💾 **Secure Storage** - All credentials stored safely in iOS Keychain
- 💭 **Remember Login** - Optional login state persistence
- 🚫 **No Data Collection** - App doesn't collect personal data
- 🔒 **Local Storage** - All data stored locally on your device

---

#### 📡 Discord Integration

**Webhook Logging** - Log important events to your Discord server:

| Event Type | Icon | Description |
|------------|------|-------------|
| Login/Logout | 🔐 | Authentication events |
| Theme Changes | 🎨 | Theme switching events |
| Settings Changes | ⚙️ | Configuration updates |
| Custom Messages | 💬 | User-defined messages |

**Features:**
- ✅ **Easy Setup** - Configure webhook URL in settings
- ✅ **Smart Display** - Settings only appear when valid webhook URL is entered
- ✅ **Quick Messages** - Send custom messages directly to Discord
- ✅ **Privacy Control** - Only sends data you explicitly enable

---

#### 🌐 Server Connection

**Important:** Zentra requires a backend server to function properly. The app connects to a server for:

- 🔐 **Authentication** - User login and registration
- 💾 **Data Synchronization** - Account and user data management
- 📊 **Feature Support** - Various app features depend on server connectivity

**Note:** Server connection details are configured automatically and are not user-configurable. The app handles all server communication securely in the background.

**Connection Status:**
- The app will display connection status when server is unavailable
- Some features may be limited when offline
- Login and registration require server connectivity

---

### Getting Started

#### 🚀 First Launch

**1. Initial Setup Process**

On first launch, you'll see a **3-page setup guide**:

- **Page 1: Introduction**
  - App introduction and features overview
  - Welcome message and key highlights
  
- **Page 2: Login Prompt** (Optional)
  - Option to log in immediately
  - Can be skipped and done later
  
- **Page 3: Ready to Use**
  - Confirmation that setup is complete
  - Ready to start using the app

**Navigation:**
- Swipe left/right or tap "Weiter" (Next) to navigate through setup
- Theme automatically matches your system appearance (Dark/Light Mode)

**2. App Start**

After setup:
- App starts directly to the main interface
- You can use the app without logging in
- To access login-protected features, log in via the side menu

**3. Navigation**

**Side Menu Access:**
- Swipe from the **left edge** of the screen to open the menu
- Or tap the **menu icon** (☰) in the top-left corner

**Available Sections:**
- ⚙️ **Settings** - Configure app preferences and themes
- 🔐 **Login** - Access authentication (in Profile section)

**4. Login** (Optional)

**Accessing Login:**
- Open the side menu
- Tap **"Login"** in the Profile section
- Enter your credentials

**Login Options:**
- ✅ **Remember Login** - Enable for persistent login state
- ✅ **Face ID / Passcode** - Enable for added security with biometric authentication

**Note:** Login is required to access Settings and Developer Options

---

#### 🎯 Quick Setup Guides

**Activating Developer Options:**

1. **Prerequisites:**
   - Must be logged in to your account
   
2. **Activation Steps:**
   - Open the side menu
   - Navigate to Profile section
   - **Tap the profile avatar/logo 5 times** (within 2 seconds)
   - Feel haptic feedback and see toast notification
   - Developer Options now appear in Settings

**Setting Up Discord Webhooks:**

1. **Create Webhook:**
   - Go to your Discord server settings
   - Navigate to Integrations → Webhooks
   - Create a new webhook
   - Copy the webhook URL

2. **Configure in App:**
   - Go to **Settings** → **Discord Integration Settings**
   - Paste the webhook URL
   - Configure event types to log
   - Test with "Send test post" button

**Customizing Themes:**

**Using Pre-installed Themes:**
- Settings → Design → Select theme
- Choose from Liquid Glass variants

**Importing Custom Themes:**
- Settings → Design → Upload theme
- Select `.gtheme` file from Files app
- Theme will be imported and available

**Password-Protected Themes:**
- When importing encrypted theme, enter password when prompted
- Theme will be decrypted and loaded

---

### Tips & Troubleshooting

#### 💡 Tips & Tricks

**Navigation:**
- ⚡ **Quick Menu Access** - Swipe from left edge for faster navigation
- 🔄 **Gesture Support** - Use swipe gestures throughout the app

**Usage:**
- 🔓 **No Login Required** - App works without logging in for basic features
- 🔍 **Profile Status** - Check login status in Profile section of side menu
- 🎨 **Theme Switching** - Change themes anytime to match your mood or environment
- ⚡ **Performance Mode** - Disable animations for better performance on older devices

**Privacy:**
- 🔒 **Secure Browsing** - Disable "Trust links from unknown sources" for enhanced security
- 💾 **Local Storage** - All data stored locally on your device
- 🌐 **Server Communication** - Secure connection to backend server for authentication and data management

---

#### 🐛 Troubleshooting

<details>
<summary><b>App won't start</b></summary>

**Possible Solutions:**
- Ensure you're using iOS 15.0 or later
- Check available storage space on your device
- Try restarting your device
- Delete and reinstall the app (note: this will remove local data)

</details>

<details>
<summary><b>Discord webhooks not working</b></summary>

**Troubleshooting Steps:**
- Verify webhook URL contains "discord.com/api/webhooks/"
- Check that the Discord webhook hasn't been deleted
- Ensure internet connectivity is available
- Try the "Send test post" button to verify connection
- Check Discord server permissions

</details>

<details>
<summary><b>Themes not loading</b></summary>

**Common Issues:**
- Check that theme files use the `.gtheme` extension (not `.json` or other formats)
- Ensure file is not corrupted or renamed
- For encrypted themes, verify the password is correct
- Try restarting the app
- Check that file was imported correctly

</details>

<details>
<summary><b>Login issues</b></summary>

**Solutions:**
- Login is optional - app works without authentication for basic features
- **Server Connection Required** - Login requires backend server connectivity
- Ensure "Remember login" is enabled for persistence
- Check Face ID/Touch ID settings if using biometrics
- Verify credentials are correct
- Check server connection status in the app
- Try logging out and logging back in

</details>

<details>
<summary><b>Server connection issues</b></summary>

**Troubleshooting:**
- Check internet connectivity
- Verify server is online and accessible
- Some features may be limited when server is unavailable
- The app will display connection status when server is unreachable
- Login and registration require server connectivity

</details>

<details>
<summary><b>Developer Options not appearing</summary>

**Activation Requirements:**
- Must be logged in to your account
- Tap profile avatar/logo exactly 5 times within 2 seconds
- Look for haptic feedback and toast notification
- Check Settings menu after activation

</details>

---

### Privacy & Security

**Data Protection:**
- 🔒 **Local Storage** - All data stored locally on your device
- 🔐 **Keychain Security** - Credentials encrypted using iOS Keychain
- 🚫 **No Telemetry** - App doesn't collect personal data or usage statistics
- 📡 **Offline Support** - Core features work without internet connection
- 🔒 **Discord Integration** - Only sends data you explicitly enable
- 🌐 **Secure Server Communication** - All server communication is encrypted and secure
- 🔐 **Server Authentication** - Secure token-based authentication with backend server

**Security Features:**
- Biometric authentication support
- Secure credential storage
- No third-party tracking
- Privacy-first design

---

## 👨‍💻 For Developers

### Project Overview

**Zentra** is a SwiftUI-based iOS application built with modern design principles and a modular architecture. The app demonstrates advanced UI techniques including glassmorphism, custom theming, and reactive state management.

**Key Technologies:**
- SwiftUI for declarative UI
- MVVM architecture pattern
- ObservableObject for state management
- Modern Swift concurrency (async/await)

---

### Architecture

```
Zentra/
├── ProjectNeeded/              # Core application components
│   ├── MenuApp.swift           # App entry point and lifecycle management
│   ├── MainView.swift          # Main container view with navigation
│   ├── LoginView.swift         # Authentication interface
│   ├── RegisterView.swift      # User registration interface
│   ├── SettingsView.swift      # Settings and configuration UI
│   ├── SetupView.swift         # First-launch setup flow
│   ├── SideMenu.swift          # Navigation sidebar component
│   └── ThemePasswordView.swift # Password input for encrypted themes
│
├── themeEngine/                # Theme Controlling Framework (TCF)
│   ├── ThemeControllingFramework.swift  # Core TCF implementation
│   ├── TCFThemeModel.swift     # Enhanced theme model with encryption
│   ├── ThemeColors.swift       # Color definitions structure
│   ├── Theme.swift             # Theme enumeration
│   ├── ThemeModel.swift        # Theme data model
│   ├── ThemeEngine.swift       # Legacy theme engine (deprecated)
│   ├── LiquidGlassModifier.swift  # Glassmorphism view modifiers
│   └── Color+Hex.swift         # Color hex conversion utilities
│
├── HypixelSkyblock/           # Feature modules
│   ├── BazaarTrackerView.swift     # Real-time price tracking interface
│   └── BazaarProfitCalculatorView.swift  # Profit calculation tools
│
├── DiscordIntegration/        # Discord webhook integration
│   └── DiscordWebhook.swift   # Webhook manager and utilities
│
├── LanguageSystem/           # Localization system
│   ├── LanguageManager.swift  # Language management
│   └── LanguageSetupView.swift  # Language selection UI
│
├── AppleServices/            # iOS native services integration
│   └── KeychainHelper.swift  # Secure storage utilities
│
├── Unassigned/              # Shared components and utilities
│   ├── Links.swift           # External link handlers
│   ├── PrimaryButtonStyle.swift  # Reusable button styles
│   ├── AnimationHelper.swift    # Conditional animation utilities
│   ├── ServerManager.swift     # Network communication manager
│   └── TrademarkInfo.swift   # App branding information
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
- `@StateObject` - Observable object lifecycle management

---

### Key Components

#### 🎨 Theme Controlling Framework (TCF)

**Core Class:** `ThemeControllingFramework`

**Features:**
- ✅ Loads themes from `.gtheme` files in `Documents/themes/`
- ✅ Three default themes (Liquid Glass variants)
- ✅ Password encryption/decryption support using AES-GCM
- ✅ Device default adaptation (automatic light/dark mode)
- ✅ File extension validation (`.gtheme` only)
- ✅ Corruption detection for renamed files
- ✅ Individual color definitions with opacity control
- ✅ Real-time theme switching with animations

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
    VStack {
        Text("Hello, Zentra!")
            .foregroundColor(tcf.colors.text)
            .background(tcf.colors.background)
        
        Button("Action") {
            // Action
        }
        .foregroundColor(tcf.colors.accent)
    }
    .background(tcf.colors.background)
}
```

**Theme Loading:**
```swift
// Load theme from file
let theme = try TCF.loadTheme(from: fileURL)

// Apply theme
tcf.applyTheme(theme)

// Check if theme is encrypted
if theme.isEncrypted {
    // Prompt for password
    let password = await requestPassword()
    let decryptedTheme = try theme.decrypt(password: password)
    tcf.applyTheme(decryptedTheme)
}
```

> **Note:** `ThemeEngine` is deprecated - use `TCF` directly for all new code.

---

#### 🌊 Liquid Glass Design System

**Available Modifiers:**

1. **`.liquidGlassCard()`** - Frosted glass cards with multiple layers
   - Multi-layer gradients for depth
   - Blur effects using `.ultraThinMaterial`
   - Custom stroke overlays for glass edges
   - Multiple shadow layers for realism

2. **`.liquidGlassBackground()`** - Transparent backgrounds with blur
   - Configurable corner radius
   - Adaptive opacity based on theme
   - Smooth blur effects

3. **`.liquidGlassButton()`** - Buttons with gradient overlays
   - Interactive states (pressed, disabled)
   - Gradient animations
   - Glass edge effects

**Implementation Details:**
- Uses `.ultraThinMaterial` for blur effects
- Multi-layer gradients for depth perception
- Custom stroke overlays for glass edges
- Multiple shadow layers for realistic appearance
- Adaptive opacity based on theme settings

**Usage Examples:**
```swift
// Glass card
VStack {
    Text("Content")
    Image(systemName: "star.fill")
}
.padding()
.liquidGlassCard()

// Glass background
TextField("Input", text: $text)
    .padding()
    .liquidGlassBackground(cornerRadius: 12)

// Glass button
Button("Action") {
    // Action
}
.liquidGlassButton()
```

---

#### 🔐 Authentication System

**Components:**
- `LoginView` - Main authentication interface
- `RegisterView` - User registration interface
- `KeychainHelper` - Secure credential storage
- `@AppStorage` - Login state persistence
- `LocalAuthentication` - Biometric authentication

**Current Implementation:**
- App starts without requiring login (after setup)
- Login is optional but required for certain features
- **Server-based authentication** - Requires backend server connection
- Credentials stored securely in iOS Keychain
- Session management via `@AppStorage` and server tokens
- Biometric authentication support (Face ID / Touch ID)
- **Logout warning** - Users informed about settings reset on logout

**Server Integration:**
- Authentication requests are handled through `ServerManager`
- Secure token-based session management
- Automatic token refresh and validation
- Graceful handling of server unavailability

**Security Implementation:**
```swift
// Credential storage
KeychainHelper.shared.save(
    password,
    service: "gv.Zentra",
    account: username
)

// Retrieve credentials
if let password = KeychainHelper.shared.load(
    service: "gv.Zentra",
    account: username
) {
    // Use password
}

// Session state
@AppStorage("isLoggedIn") var isLoggedIn: Bool = false
@AppStorage("currentUsername") var currentUsername: String = ""

// Biometric authentication
let context = LAContext()
if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
    context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: "Authenticate to access Zentra"
    ) { success, error in
        // Handle result
    }
}
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

// Log theme change
Task {
    await discordWebhookManager.logThemeChange(themeName: "Liquid Glass Dark")
}
```

**Webhook Configuration:**
```swift
// Store webhook URL
@AppStorage("discordWebhookURL") private var webhookURL: String = ""

// Validate webhook URL
guard webhookURL.hasPrefix("https://discord.com/api/webhooks/") else {
    // Invalid URL
    return
}
```

---

### Setup & Development

#### 📋 Prerequisites

**Required:**
- ✅ macOS 13.0 or later
- ✅ Xcode 15.0 or later
- ✅ iOS 15.0+ SDK
- ✅ Swift 5.0+
- ✅ Apple Developer Account (for device deployment)

**Recommended:**
- Git for version control
- CocoaPods or SPM for dependency management (if needed)
- iOS Simulator for testing

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
- Select the project in Xcode navigator
- Go to "Signing & Capabilities" tab
- Select your development team
- Xcode will automatically manage provisioning profiles

**4. Build Configuration**
- **Debug** - Development build with debug symbols and logging
- **Release** - Optimized build for distribution

**5. Run the App**
- Select target device or simulator from the device menu
- Press `Cmd + R` or click the Run button
- First build may take several minutes (dependency resolution)

---

#### 💻 Development Workflow

**Code Style Guidelines:**

```swift
struct MyView: View {
    // MARK: - Properties
    @State private var localState = ""
    @EnvironmentObject var sharedState: SharedState
    
    // MARK: - Body
    var body: some View {
        VStack {
            // Implementation
        }
    }
    
    // MARK: - Private Methods
    private func helperFunction() {
        // Implementation
    }
}
```

**Naming Conventions:**
- **Views:** PascalCase with `View` suffix (`LoginView`, `SettingsView`)
- **ViewModels:** PascalCase with `ViewModel` suffix
- **Models:** PascalCase (`ThemeModel`, `BazaarItem`)
- **Functions:** camelCase with descriptive names
- **Variables:** camelCase
- **Constants:** camelCase or UPPER_SNAKE_CASE for global constants

**Adding New Features:**

1. **Create View Component**
   ```swift
   struct NewFeatureView: View {
       var body: some View {
           // Implementation
       }
   }
   ```

2. **Add Navigation Route** in `MainView.swift`
   ```swift
   case .newFeature:
       NewFeatureView()
   ```

3. **Add Menu Item** in `SideMenu.swift`
   ```swift
   MenuItem(icon: "star", title: "New Feature", page: .newFeature)
   ```

4. **Theme Support** - Always use `tcf.colors.*` for colors
   ```swift
   .foregroundColor(tcf.colors.text)
   .background(tcf.colors.background)
   ```

**File Organization:**
- Group related files in folders
- Use MARK comments for code organization
- Keep views and view models separate
- Use extensions for protocol conformance

---

### Testing

#### 🧪 Manual Testing Checklist

**Setup & First Launch:**
- [ ] Setup process displays correctly on first launch
- [ ] Theme matches system appearance on first start
- [ ] App starts without requiring login (after setup)
- [ ] Navigation through setup pages works correctly

**Navigation:**
- [ ] Side menu displays correctly
- [ ] Swipe gesture opens/closes menu
- [ ] Menu icon button works
- [ ] Navigation between pages functions properly

**Authentication:**
- [ ] Login flow works correctly (requires server connection)
- [ ] Registration flow works correctly (requires server connection)
- [ ] Logout warning displays correctly
- [ ] Biometric authentication works
- [ ] Remember login persists after app restart
- [ ] Server connection status displays correctly
- [ ] Graceful handling when server is unavailable

**Settings:**
- [ ] Settings are disabled when not logged in
- [ ] Settings accessible when logged in
- [ ] Theme switching functions properly
- [ ] Settings persist after app restart

**Themes:**
- [ ] Default themes load correctly
- [ ] Custom theme import works
- [ ] Encrypted themes require password
- [ ] Theme switching is smooth
- [ ] Theme adapts to device appearance

**Developer Options:**
- [ ] Activation gesture works (5 taps)
- [ ] Developer options appear after activation
- [ ] Test notification sends correctly
- [ ] Performance settings work

**Discord Integration:**
- [ ] Webhook configuration works
- [ ] Events are logged correctly
- [ ] Custom messages send successfully
- [ ] Settings only appear with valid webhook

**Testing on Different Devices:**
- iPhone SE (small screen, older hardware)
- iPhone 15/16 (standard screen size)
- iPhone Pro Max (large screen)
- iPad (if supported)

---

### Debugging

**Common Debugging Scenarios:**

<details>
<summary><b>Theme Not Loading</b></summary>

**Checklist:**
- Verify `Documents/themes/` directory exists
- Check `.gtheme` file format (not `.json` or renamed files)
- Ensure file extension is `.gtheme` (lowercase, not `.Gtheme`)
- For encrypted themes, verify password is correct
- Check console for decoding/decryption errors
- Verify file permissions

**Debug Code:**
```swift
// Check theme directory
let themesURL = FileManager.default.urls(
    for: .documentDirectory,
    in: .userDomainMask
)[0].appendingPathComponent("themes")

print("Themes directory: \(themesURL.path)")
print("Directory exists: \(FileManager.default.fileExists(atPath: themesURL.path))")

// List files
if let files = try? FileManager.default.contentsOfDirectory(at: themesURL, includingPropertiesForKeys: nil) {
    for file in files {
        print("Found file: \(file.lastPathComponent)")
    }
}
```

</details>

<details>
<summary><b>Discord Webhook Issues</b></summary>

**Troubleshooting:**
- Test webhook URL manually using curl or Postman
- Check network connectivity
- Verify webhook permissions in Discord
- Review error logs in console
- Check webhook URL format

**Debug Code:**
```swift
// Test webhook URL
let testURL = URL(string: webhookURL)!
var request = URLRequest(url: testURL)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

let testPayload = ["content": "Test message"]
request.httpBody = try? JSONSerialization.data(withJSONObject: testPayload)

let (data, response) = try await URLSession.shared.data(for: request)
print("Response: \(response)")
print("Data: \(String(data: data, encoding: .utf8) ?? "nil")")
```

</details>

<details>
<summary><b>Navigation Problems</b></summary>

**Checklist:**
- Verify `selectedPage` binding state is correct
- Check menu gesture recognizers are properly configured
- Review animation transitions
- Check z-index layering
- Verify menu state management

**Debug Code:**
```swift
// Print navigation state
print("Current page: \(selectedPage)")
print("Menu open: \(isMenuOpen)")

// Check gesture recognizer
.onTapGesture {
    print("Menu tapped")
    isMenuOpen.toggle()
}
```

</details>

<details>
<summary><b>Authentication Issues</b></summary>

**Troubleshooting:**
- Check Keychain access permissions
- Verify credentials are stored correctly
- Check biometric authentication availability
- Review session state management

**Debug Code:**
```swift
// Check Keychain
let password = KeychainHelper.shared.load(
    service: "gv.Zentra",
    account: username
)
print("Password loaded: \(password != nil)")

// Check biometric availability
let context = LAContext()
var error: NSError?
let available = context.canEvaluatePolicy(
    .deviceOwnerAuthenticationWithBiometrics,
    error: &error
)
print("Biometrics available: \(available)")
```

</details>

---

### Contributing

**Development Process:**

1. **Fork the Repository**
   - Create your own fork of the repository
   - Clone your fork locally

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```

3. **Make Changes**
   - Follow code style guidelines
   - Write clear, descriptive commit messages
   - Test thoroughly on multiple devices

4. **Commit Changes**
   ```bash
   git commit -m "Add amazing feature"
   ```

5. **Push to Branch**
   ```bash
   git push origin feature/AmazingFeature
   ```

6. **Create Pull Request**
   - Open a pull request on GitHub
   - Provide detailed description of changes
   - Reference any related issues

**Code Review Checklist:**
- [ ] Code follows style guidelines
- [ ] Tests pass (if applicable)
- [ ] Documentation updated
- [ ] No console warnings or errors
- [ ] All themes tested
- [ ] Responsive on all screen sizes
- [ ] Accessibility considered
- [ ] Performance impact assessed

**Commit Message Format:**
```
Type: Brief description

Detailed explanation of changes and reasoning.
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions/changes
- `chore:` Maintenance tasks

---

### Dependencies

**Apple Frameworks:**
- **SwiftUI** - Core UI framework for declarative interfaces
- **Foundation** - Core functionality and data types
- **UIKit** - Legacy UI components and integration
- **LocalAuthentication** - Biometric authentication support
- **UserNotifications** - Push notification functionality
- **UniformTypeIdentifiers** - File type handling (`.gtheme` file import)
- **CryptoKit** - Theme encryption/decryption (AES-GCM)

**External Dependencies:**
- None (pure SwiftUI implementation)
- All functionality uses native iOS frameworks

---

### Future Roadmap

**Planned Features:**
- [ ] Enhanced theme customization options
- [ ] Cloud theme synchronization
- [ ] Push notifications for important events
- [ ] Home Screen widgets
- [ ] iPad optimization
- [ ] Apple Watch companion app
- [ ] macOS version

**Technical Improvements:**
- [ ] Unit test suite
- [ ] UI test automation
- [ ] CI/CD pipeline
- [ ] Code documentation automation
- [ ] Performance monitoring
- [ ] Crash reporting integration
- [ ] Accessibility improvements

---

## 📝 Version History

### Version 1.0 (Current)

**Initial Release Features:**

**Core Functionality:**
- ✅ Liquid glass design system with glassmorphism effects
- ✅ **TCF (Theme Controlling Framework)** - Complete migration from ThemeEngine
- ✅ **Password-protected themes** - Encrypt themes with passwords
- ✅ **`.gtheme` file format** - Advanced theme format with individual color definitions
- ✅ **File validation** - Only `.gtheme` files accepted, corruption detection
- ✅ **Smart Theme Selection** - Automatically matches system appearance on first launch

**User Experience:**
- ✅ **Setup Process** - 3-page onboarding guide on first launch
- ✅ **Login Required Card** - Beautiful login prompt with support links
- ✅ **Optional Authentication** - App starts without login requirement after setup
- ✅ **Login Integration** - Login accessible from side menu
- ✅ **Logout Warning** - Users informed about settings reset

**Developer Features:**
- ✅ **Developer Options** - Hidden settings activated by 5-tap gesture
- ✅ **Test Notification** - Send test notifications from Developer Options
- ✅ **Performance Settings** - Toggle animations for better performance
- ✅ **Developer Information** - App version, TCF version, device info

**Integration:**
- ✅ Discord Integration Settings with conditional display
- ✅ Custom Discord message support
- ✅ Webhook event logging

**Polish:**
- ✅ Theme loading animation
- ✅ Complete English localization
- ✅ Enhanced animation controls throughout the app
- ✅ **Protected Settings** - Settings disabled when not logged in

> **Note:** App purpose and identity are yet to be determined

---

## 🔗 Resources

**Project Information:**
- **GitHub Repository:** [Zentra-iOS](https://github.com/YannickGalow/Zentra-iOS)
- **Developer:** Yannick Galow
- **Platform:** iOS 15.0+
- **Language:** Swift 5.0+

**Documentation:**
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)

---

## ⚠️ Important Notes

**Development:**
- This is a **Development Version** - for development and testing purposes
- Some features may be incomplete or experimental
- Always test thoroughly before production use

**Security:**
- Never commit sensitive credentials or API keys
- Keep theme files in secure locations
- Review Discord webhook URLs before sharing
- Use secure storage for all sensitive data

**Best Practices:**
- Follow iOS Human Interface Guidelines
- Test on multiple devices and iOS versions
- Consider accessibility in all implementations
- Optimize for performance

---

## 🐛 Reporting Issues

**When reporting issues, please include:**

**Environment:**
- iOS version
- Device model
- App version

**Issue Details:**
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Console logs if available

**Additional Information:**
- Frequency of occurrence
- Workarounds (if any)
- Related issues (if any)

---

<div align="center">

**Last updated:** November 9th, 2025

**Recent Updates:**
- ✅ Comprehensive documentation for users and developers
- ✅ Detailed architecture documentation
- ✅ Complete setup and development guides
- ✅ Troubleshooting and debugging sections

Made with ❤️ by Yannick Galow

</div>
