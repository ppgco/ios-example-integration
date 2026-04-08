//
//  ContentView.swift
//  iOS example integration
//
//  Created by PushPushGo on 22/08/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                PushNotificationsView()
            }
            .tabItem {
                Label("Push", systemImage: "bell")
            }

            NavigationStack {
                InAppMessagesView()
            }
            .tabItem {
                Label("In-App", systemImage: "message")
            }
        }
    }
}

struct PushNotificationsView: View {
    @StateObject private var viewModel = ButtonsViewModel()
    @State private var showBeaconSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Subscriber
                GroupBox(label: Label("Subscriber", systemImage: "person.crop.circle")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Show the current PPG subscriber ID or unsubscribe this device from push notifications.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button(action: { viewModel.getSubscriberId() }) {
                            Label("Show Subscriber ID", systemImage: "person.badge.key.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)

                        Button(action: { viewModel.unregisterSubscriber() }) {
                            Label("Unregister", systemImage: "person.crop.circle.badge.minus")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .padding(.top, 4)
                }

                // Beacon
                GroupBox(label: Label("Beacon", systemImage: "antenna.radiowaves.left.and.right")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Send a beacon event with a custom tag, label and TTL to the PPG platform.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button(action: { showBeaconSheet = true }) {
                            Label("Send Beacon", systemImage: "paperplane.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                    .padding(.top, 4)
                }

                if !viewModel.message.isEmpty {
                    Text(viewModel.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .padding()
        }
        .navigationTitle("Push Notifications")
        .sheet(isPresented: $showBeaconSheet) {
            NavigationStack {
                BeaconCardView(viewModel: viewModel, showBeaconCard: $showBeaconSheet)
                    .navigationTitle("Send Beacon")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    ContentView()
}
