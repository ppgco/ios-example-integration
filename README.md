# ios-example-integration

Example integration of the PPG iOS SDK with a SwiftUI application. Covers **Push Notifications**, **In-App Messages** and **Live Activities**.

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

   // Live Activities (iOS 17.2+)
   LiveActivitiesSDK.shared.initialize(apiKey: "YOUR API KEY", projectId: "YOUR PROJECT ID", appGroupId: "YOUR APP GROUP ID")
   ```

5. Enable the App Group (`group.ppgios` in this repo) on **all three** bundle IDs in the
   Apple Developer portal — the app, `PPGNotificationServiceExtension` and `MatchWidget`.
   The widget reads cached team badges and design from that shared container.

6. Build and run the app on a physical device (push notifications and push-to-start
   Live Activities require real hardware).

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

### Live Activities tab (`sportscourt` icon)

Requires iOS 17.2+; older systems get a placeholder screen. The Live Activity itself is
rendered by the **MatchWidget** widget extension using the views shipped in the SDK
(`PPGMatchLockScreenView`, `PPGMatchDynamicIsland`) — the extension only declares the
`ActivityConfiguration` and points the SDK at the shared App Group.

- **Device** – shows `LiveActivitiesSDK.shared.areActivitiesEnabled()`, i.e. whether the user
  allows Live Activities for this app
- **Campaign** – `subscribe(_:liveNotificationId:onCampaignAlreadyActive:onStatus:)` registers
  this device for a Live Notification created in the PPG dashboard. The backend then starts,
  updates and ends the activity over APNs — the app does not need to be running. A device that
  subscribes to an already ONGOING campaign bootstraps the activity from the REST payload
  instead of waiting for a push-to-start. **Unsubscribe** deletes the subscriber on the backend.
- **Local Demo** – `startActivity` / `updateActivity` / `endActivity` drive an activity
  straight from the app. Handy while integrating, because push-to-start does not work in the
  simulator; these activities are *not* reachable by backend pushes. Includes a hot-message
  button (the transient "Goal!" banner, shown for up to 10 s). The view model keeps the
  activity id returned by `startActivity` and addresses every later call to it — an app has to
  maintain that campaign → activity mapping itself, because `getActiveActivities()` reports
  every Live Activity on the device, including ones started by pushes for other campaigns.
- **Running Activities** – `getActiveActivities()` output for this device

Taps on the activity body and on its action buttons arrive as `ppg-la://…` URLs and are routed
through `LiveActivitiesSDK.handleURL(_:closeHandler:)` in `iOS_example_integrationApp.swift`,
which records click statistics and opens the right destination.

## SDK Packages

| Package | Purpose |
|---------|---------|
| `PPG_framework` | Push notifications, beacons, subscriber management |
| `PPG_InAppMessages` | In-app message display with route and trigger targeting |
| `PPG_LiveActivities` | Live Activities on the Lock Screen and Dynamic Island (iOS 17.2+) |

All three are installed via CocoaPods from `https://github.com/ppgco/ios-sdk`.
`PPG_LiveActivities` is linked into both the app target and the `MatchWidget` extension.

## Project Targets

| Target | Purpose |
|--------|---------|
| `iOS example integration` | The app |
| `PPGNotificationServiceExtension` | Notification Service Extension (rich push) |
| `MatchWidget` | Widget Extension hosting the Live Activity (iOS 17.2+) |

## Troubleshooting In-App Messages

- Enable debug logs during development:
  ```swift
  InAppMessagesSDK.shared.initialize(apiKey: "...", projectId: "...", isDebug: true)
  ```
- Route names must exactly match the configuration in the PPG dashboard (case-sensitive).
- Messages with "Show once" rule won't re-appear after dismissal — use **Clear Cache** to reset.
- The SDK checks for eligible messages automatically every 60 seconds while a view is active.

## Troubleshooting Live Activities

- The activity never appears: check `areActivitiesEnabled()` on the Device card, then confirm
  the App Group id is identical in `AppDelegate.swift`, in `MatchWidget.swift` and in both
  targets' entitlements.
- Push-to-start requires a physical device on iOS 17.2+ and an APNs environment that matches
  the build (a sandbox PPG project only reaches development-signed builds). Use the **Local
  Demo** section to verify the UI without the backend.
- Enable verbose SDK logs with `isDebug: true` in `LiveActivitiesSDK.shared.initialize(...)`.
