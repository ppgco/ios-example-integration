//
//  ContentView.swift
//  iOS example integration
//
//  Created by PushPushGo on 22/08/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ButtonsViewModel()
    @State private var showBeaconCard = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                viewModel.sendBeacon()
                showBeaconCard = true
            }) {
                Text("Send Beacon")
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // Conditionally display the card
            if showBeaconCard {
                BeaconCardView(viewModel: viewModel, showBeaconCard: $showBeaconCard)
            }
            
            Button(action: {
                viewModel.unregisterSubscriber()
            }) {
                Text("Unregister")
                    .font(.headline)
                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                viewModel.getSubscriberId()
            }) {
                Text("SubscriberID")
                    .font(.headline)
                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if !viewModel.message.isEmpty {
                Text(viewModel.message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
