# ios-example-integration

Example integration of the PPG iOS SDK with a SwiftUI application. Covers both **Push Notifications** and **In-App Messages**.

## Description

Repository contains a complete app integrated with the PPG iOS native SDK.
**To run the app you need a Project ID and API Key from the PPG dashboard, as well as an APNS certificate.**

## Requirements

- iOS 16.0+
- Xcode 15+
- CocoaPods
- Access to Apple Developer Console
- PPG project with API Key and Project ID

> Approximate setup time: ~15 min

## Installation

1. Generate an APNS certificate and upload it to the PPG dashboard:
   https://docs.pushpushgo.company/application/providers/mobile-push/apns
   > **Important:** the certificate Bundle ID must match the one configured in Xcode.

2. Clone the repo and install pods:
   ```bash
   cd "iOS example integration"
   pod install
   ```

3. Open the workspace (not the `.xcodeproj`):
   ```
   iOS example integration.xcworkspace
   ```

4. Set your PPG credentials in `AppDelegate.swift`:
   ```swift
   // Push Notifications
   PPG.initializeNotifications(projectId: "YOUR PROJECT ID", apiToken: "YOUR API KEY", appGroupId: "YOUR APP GROUP ID")

   // In-App Messages
   InAppMessagesSDK.shared.initialize(apiKey: "YOUR API KEY", projectId: "YOUR PROJECT ID")
   ```

5. Build and run the app on a physical device (push notifications require real hardware).

## App Structure

The app uses a two-tab layout:

### Push Notifications tab (`bell` icon)
- **Register** – automatically registers the device for push notifications on app launch
- **Send Beacon** – sends a beacon event with optional tag, label and TTL
- **Unregister** – unsubscribes the current device
- **SubscriberID** – displays the current PPG subscriber ID

### In-App Messages tab (`message` icon)
- **Route Simulation** – calls `InAppMessagesSDK.shared.onRouteChanged(route)` to trigger messages configured for a specific route in the PPG dashboard
- **Custom Trigger** – calls `InAppMessagesSDK.shared.showMessagesOnTrigger(key:value:)` to display messages bound to a custom event
- **Clear Cache** – calls `InAppMessagesSDK.shared.clearMessageCache()` — useful when testing to force a fresh API fetch

## SDK Packages

| Package | Purpose |
|---------|---------|
| `PPG_framework` | Push notifications, beacons, subscriber management |
| `PPG_InAppMessages` | In-app message display with route and trigger targeting |

Both are installed via CocoaPods from `https://github.com/ppgco/ios-sdk`.

## Troubleshooting In-App Messages

- Enable debug logs during development:
  ```swift
  InAppMessagesSDK.shared.initialize(apiKey: "...", projectId: "...", isDebug: true)
  ```
- Route names must exactly match the configuration in the PPG dashboard (case-sensitive).
- Messages with "Show once" rule won't re-appear after dismissal — use **Clear Cache** to reset.
- The SDK checks for eligible messages automatically every 60 seconds while a view is active.
