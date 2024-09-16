# ios-example-integration

Example of integration PPG ios sdk with SwiftUI iOS application

## Description

Repository contains complete APP integrated with PPG iOS native sdk.
**To run APP you need to provide Project ID and API KEY from PPG application panel. You also need to upload APSN certificate.**

## Installation
1. Generate certificate and upload it - https://docs.pushpushgo.company/application/providers/mobile-push/apns
2. Clone repo and open project by iOS example integration.xcworkspace file
3. Provide PPG credentials in AppDelegate.swift - project id and api key

```swift
        // Initialize PPG
        PPG.initializeNotifications(projectId: "YOUR PROJECT ID", apiToken: "YOUR API KEY")
```
4. Build and run APP

## Functionalities

This test app implements registering to notifications, sending beacon, unregistering subscriber, displaying subscriber's id'
