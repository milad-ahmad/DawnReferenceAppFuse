# DawnReferenceAppFuse

# Feature Implementation Details

This document summarizes the shared features built using Skip for cross-platform development. It explains the implementation specifics, platform differences, and current limitations to be aware of.

Before you can run this project you must install Skip. In order to do that you can follow this quick [install guide](https://skip.dev/docs/gettingstarted/$0).

### 1. Audio Recorder
* **Goal:** Tests microphone access and basic audio recording capabilities.
* **Implementation:** Utilizes the `SkipAV` package instead of the native `AVFoundation` (which is iOS-exclusive).
* **Developer Notes:** Microphone permissions must be explicitly requested and configured in both `AndroidManifest.xml` and `Main.kt` for Android. Certain SwiftUI modifiers (like `truncationMode`) and specific functions are shielded for Android using `#if !SKIP` compiler directives.

### 2. Notifications
* **Goal:** Tests scheduling and displaying local device notifications.
* **Implementation:** Uses the `UserNotifications` framework on iOS. On Android, this functionality is abstracted within `SkipUI` without requiring a direct import.
* **Developer Notes:** Android requires explicit notification permissions in `AndroidManifest.xml`.
* **Current Limitations:** Local notifications currently fail silently on Android (no UI appears, no errors in the logs). Push notifications are supported in theory but remain untested due to Apple Developer program requirements.

### 3. Date & Time
* **Goal:** Tests standard date parsing, formatting, and time calculations.
* **Implementation:** Native Swift date and time handling.
* **Developer Notes:** Current time, formatting, timezone conversions (UTC vs. Local), live clocks, calendar calculations, and daylight saving transitions transpile and work flawlessly on both iOS and Android.

### 4. Camera & Photo Library
* **Goal:** Tests accessing device hardware (camera) and local file storage (gallery).
* **Implementation:** Relies on the `SkipKit` library instead of `UIKit`.
* **Developer Notes:** Requires camera and storage permissions, plus a `FileProvider` configuration in `AndroidManifest.xml`.
* **Current Limitations:** While opening the camera and capturing photos works, displaying selected gallery images on Android is highly problematic and does not work.
* **Recommendation:** Do not use shared transpiled UI for photo selection; build separate native interfaces for media handling.

### 5. State Behavior (Loading States)
* **Goal:** Tests UI state management using complex Swift enums.
* **Implementation:** UI state management utilizing Swift enums with associated types to handle states like Loading, Empty, Error, and Success.
* **Developer Notes:** The transpiler handles complex Swift enums perfectly. No problems detected and view updates across both platforms without any workarounds.

### 6. Network Requests
* **Goal:** Tests external API fetching, JSON parsing, and error handling.
* **Implementation:** Standard `URLSession` data fetching and `JSONDecoder` parsing.
* **Developer Notes:** Works without any problems on both platforms. Fully supports both happy and unhappy paths, handling invalid URLs, network disconnections, and server timeouts with correct errors. No platform limitations found.

### 7. Biometrics (Face ID / Touch ID)
* **Goal:** Tests hardware-backed local authentication.
* **Implementation:** Built using the native iOS `LocalAuthentication` framework for local unlocking.
* **Current Limitations:** This feature cannot be transpiled. There is currently no Skip package that supports Android biometric mapping. 
* **Recommendation:** Android biometric authentication must be written completely natively in Android Studio (Kotlin).

### 8. Location Services
* **Goal:** Tests requesting location permissions and reading live GPS coordinates.
* **Implementation:** Platform-specific logic separated via `#if os(iOS)` directives. Uses native `CoreLocation` for iOS, and `SkipDevice` / `SkipKit` (`LocationProvider`) for Android.
* **Developer Notes:** Implementations must be written per platform. Ensure `NSLocationWhenInUseUsageDescription` is set in `Info.plist` (iOS) and the corresponding location permissions are added to `AndroidManifest.xml` (Android).

### 9. Presentations & Sheets
* **Goal:** Tests overlaying screens, specifically modals and full-screen covers.
* **Implementation:** Built entirely with native SwiftUI modifiers (`.sheet` and `.fullScreenCover`).
* **Developer Notes:** These views transpile perfectly to Jetpack Compose out of the box. No platform-specific workarounds or compiler directives are required.

### 10. Deep Links & Routing
* **Goal:** Tests opening the application via external URL schemes (e.g., `dawnapp://`) and routing to specific internal views.
* **Implementation:** Driven by a centralized `@Observable` `AppRouter` object that parses incoming URLs and updates the `NavigationPath` dynamically.
* **Developer Notes:** The routing logic works without any issues on both platforms. However, you must manually set up Intent Filters in Android and URL Types in iOS to bind the custom scheme to the app.

### 11. App Lifecycle & State Restoration
* **Goal:** Tests foreground/background transitions and state retention after OS-level app termination.
* **Implementation:** Utilizes `@Environment(\.scenePhase)` to track active states. State restoration is shielded with `#if os(IOS)` to use native `@SceneStorage` on iOS.
* **Developer Notes:** `@SceneStorage` cannot be translated to Android yet. Therefore, UI state restoration is limited to iOS, while Android falls back to standard in-memory state. Additionally, temporary system interruptions (like opening the notification center) trigger the `.inactive` state on iOS, whereas Android keeps the underlying activity in the `.active` (Resumed) state. It takes a bit longer on Android to register wether the app is running in the background or foreground, whereas it happens almost instantly on iOS. 
