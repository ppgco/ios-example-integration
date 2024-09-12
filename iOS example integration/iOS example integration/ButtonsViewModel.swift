//
//  ButtonsViewModel.swift
//  iOS example integration
//
//  Created by PushPushGo on 22/08/2024.
//

import Foundation
import SwiftUI
import PPG_framework

class ButtonsViewModel: ObservableObject {
    @Published var message: String = ""
    
    // This function is triggered by the Send Beacon button
    func sendBeacon() {
        // Placeholder for any initial action when Send Beacon is clicked
        message = "Send Beacon button clicked"
    }
    
    func sendBeaconWithData(tag: String, label: String, ttl: Int) {
        let beacon = Beacon()
        beacon.appendTag(tag, label, Int64(ttl))
        beacon.send() { result in
            DispatchQueue.main.async {
                self.message = "Beacon sent. Status: \(result)"
            }
            
        }
    }

    
    func unregisterSubscriber() {
        PPG.unsubscribeUser { result in
            // Ensure the update happens on the main thread
            DispatchQueue.main.async {
                self.message = "\(result)"
            }
        }
    }
    
    func getSubscriberId() {
        self.message = PPG.subscriberId
    }
}
