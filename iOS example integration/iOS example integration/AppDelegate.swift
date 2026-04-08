//
//  AppDelegate.swift
//  iOS example integration
//
//  Created by PushPushGo on 11/09/2024.
//

import Foundation
import UIKit
import UserNotifications
import PPG_framework
import PPG_InAppMessages

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Initialize PPG Push Notifications
        PPG.initializeNotifications(
            projectId: "YOUR PROJECT ID",
            apiToken: "YOUR API KEY",
            appGroupId: "YOUR APP GROUP ID"
        )
        
        // Initialize PPG In-App Messages
        InAppMessagesSDK.shared.initialize(
            apiKey: "YOUR API KEY",
            projectId: "YOUR PROJECT ID"
        )
        
        // Register for notifications
        PPG.registerForNotifications(application: application) { result in
            switch result {
            case .error(let error):
                print(error)
                return
            case .success:
                print("Successfully registered")
                return
            }
        }
        
        PPGUserNotificationCenterDelegateSetUp()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
      // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

      PPG.sendEventsDataToApi()
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PPGdidRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PPGdidReceiveRemoteNotification(userInfo, completionHandler: completionHandler)
    }
}
