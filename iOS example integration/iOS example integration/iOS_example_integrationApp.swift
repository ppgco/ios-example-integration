//
//  iOS_example_integrationApp.swift
//  iOS example integration
//
//  Created by PushPushGo on 22/08/2024.
//

import SwiftUI
import PPG_LiveActivities

@main
struct iOS_example_integrationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    // Taps on the Live Activity body and its action buttons arrive
                    // as `ppg-la://…` URLs. The SDK records click statistics and
                    // opens the right destination; anything it does not recognise
                    // is left for the app's own deep links.
                    if #available(iOS 17.2, *) {
                        let handled = LiveActivitiesSDK.handleURL(url, closeHandler: { _ in
                            LiveActivitiesSDK.shared.endAllActivities(ofType: MatchActivityAttributes.self)
                        })
                        if !handled {
                            print("Unhandled deep link: \(url)")
                        }
                    }
                }
        }
    }
}
