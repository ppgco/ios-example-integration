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

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Initialize PPG
        PPG.initializeNotifications(projectId: "YOUR PROJECT ID", apiToken: "YOUR API KEY")
        
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
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
      // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

      PPG.sendEventsDataToApi()
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PPG.sendDeviceToken(deviceToken) { _ in }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Display notification when app is in foreground, optional
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        // Send information about clicked notification to framework
        PPG.notificationClicked(response: response)

        // Open external link from push notification
        // Remove this section if this behavior is not expected
        guard let url = PPG.getUrlFromNotificationResponse(response: response)
            else {
                completionHandler()
                return
            }
        UIApplication.shared.open(url)
        //
        completionHandler()
    }
}
