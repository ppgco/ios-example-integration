//
//  InAppMessagesView.swift
//  iOS example integration
//
//  Created by PushPushGo on 08/04/2025.
//

import SwiftUI
import PPG_InAppMessages

struct InAppMessagesView: View {
    @State private var routeInput: String = "home"
    @State private var triggerKey: String = "action"
    @State private var triggerValue: String = "button_clicked"
    @State private var statusMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Route Simulation
                GroupBox(label: Label("Route Simulation", systemImage: "map")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Simulate navigation to a named route. SDK will look for messages configured to show on that route.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Route name (e.g. home)", text: $routeInput)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        Button(action: simulateRouteChange) {
                            Label("Set Route", systemImage: "arrow.right.circle.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 4)
                }

                // Custom Trigger
                GroupBox(label: Label("Custom Trigger", systemImage: "bolt")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fire a custom key-value trigger. SDK will display messages that match this trigger pair.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Key (e.g. action)", text: $triggerKey)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        TextField("Value (e.g. purchase_complete)", text: $triggerValue)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        Button(action: fireCustomTrigger) {
                            Label("Fire Trigger", systemImage: "bolt.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    .padding(.top, 4)
                }

                // Cache
                GroupBox(label: Label("Cache", systemImage: "trash")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Clear local message cache. Useful during testing to force fresh data from the API.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button(action: clearCache) {
                            Label("Clear Cache", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .padding(.top, 4)
                }

                // Status
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .padding()
        }
        .navigationTitle("In-App Messages")
        .onAppear {
            InAppMessagesSDK.shared.onRouteChanged(routeInput)
            setStatus("Route set to '\(routeInput)' on appear")
        }
    }

    // Actions

    private func simulateRouteChange() {
        let route = routeInput.trimmingCharacters(in: .whitespaces)
        guard !route.isEmpty else {
            setStatus("Route name cannot be empty")
            return
        }
        InAppMessagesSDK.shared.onRouteChanged(route)
        setStatus("Route changed to '\(route)'")
    }

    private func fireCustomTrigger() {
        let key = triggerKey.trimmingCharacters(in: .whitespaces)
        let value = triggerValue.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty, !value.isEmpty else {
            setStatus("Key and value cannot be empty")
            return
        }
        InAppMessagesSDK.shared.showMessagesOnTrigger(key: key, value: value)
        setStatus("Trigger fired: \(key) = \(value)")
    }

    private func clearCache() {
        InAppMessagesSDK.shared.clearMessageCache()
        setStatus("Message cache cleared")
    }

    private func setStatus(_ message: String) {
        statusMessage = "[\(timeString())] \(message)"
    }

    private func timeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

#Preview {
    NavigationStack {
        InAppMessagesView()
    }
}
