//
//  BeaconCardView.swift
//  iOS example integration
//
//  Created by PushPushGo on 12/09/2024.
//

import Foundation
import SwiftUI

struct BeaconCardView: View {
    @ObservedObject var viewModel: ButtonsViewModel
    @Binding var showBeaconCard: Bool
    
    @State private var tag: String = ""
    @State private var label: String = ""
    @State private var ttl: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Text input fields
            TextField("Enter tag", text: $tag)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            TextField("Enter label", text: $label)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            TextField("Enter ttl", text: $ttl)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            HStack(spacing: 20) {
                // Send button
                Button(action: {
                    viewModel.sendBeaconWithData(tag: tag, label: label, ttl: Int(ttl) ?? 0)
                    showBeaconCard = false
                }) {
                    Text("Send")
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Cancel button
                Button(action: {
                    showBeaconCard = false
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
