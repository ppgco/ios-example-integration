//
//  iOS_example_integrationApp.swift
//  iOS example integration
//
//  Created by PushPushGo on 22/08/2024.
//

import SwiftUI

@main
struct iOS_example_integrationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
