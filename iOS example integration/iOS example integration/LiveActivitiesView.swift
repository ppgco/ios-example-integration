//
//  LiveActivitiesView.swift
//  iOS example integration
//
//  Created by PushPushGo on 26/08/2026.
//

import SwiftUI
import PPG_LiveActivities

/// Entry point for the Live Activities tab. The PPG Live Activities SDK
/// requires iOS 17.2, so older systems get an explanatory placeholder.
struct LiveActivitiesView: View {
    var body: some View {
        if #available(iOS 17.2, *) {
            LiveActivitiesContentView()
        } else {
            UnsupportedOSView()
                .navigationTitle("Live Activities")
        }
    }
}

@available(iOS 17.2, *)
struct LiveActivitiesContentView: View {
    @StateObject private var viewModel = LiveActivitiesViewModel()
    @State private var hotMessageText: String = "Goal!"
    @FocusState private var focusedField: Bool

    /// Phases exposed in the demo picker — they match the `statusLabels`
    /// configured for the demo activity.
    private let demoPhases: [MatchPhase] = [
        .preMatch, .firstHalf, .halfTimeBreak, .secondHalf, .fullTime, .matchEnded
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Device status
                GroupBox(label: Label("Device", systemImage: "iphone")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Live Activities must be allowed in Settings → Face ID & Passcode and in the app's own notification settings.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            Image(systemName: viewModel.activitiesEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(viewModel.activitiesEnabled ? .green : .red)
                            Text(viewModel.activitiesEnabled ? "Live Activities enabled" : "Live Activities disabled")
                                .font(.subheadline)
                        }

                        Button(action: { viewModel.refresh() }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 4)
                }

                // Campaign subscription — the production flow
                GroupBox(label: Label("Campaign", systemImage: "antenna.radiowaves.left.and.right")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Subscribe this device to a Live Notification created in the PPG dashboard. The backend then starts, updates and ends the activity over APNs — the app does not need to be running.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Live Notification ID (24-char hex)", text: $viewModel.liveNotificationId)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($focusedField)

                        Button(action: { viewModel.subscribe() }) {
                            Label("Subscribe", systemImage: "bell.badge.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)

                        Button(action: { viewModel.unsubscribe() }) {
                            Label("Unsubscribe", systemImage: "bell.slash.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)

                        Text("Status: \(viewModel.subscriptionStatus)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }

                // App-driven demo — works without the backend
                GroupBox(label: Label("Local Demo", systemImage: "play.rectangle")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Start a Live Activity straight from the app. Useful while integrating — push-to-start does not work in the simulator. These activities are not reachable by backend pushes.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Every action below is addressed to the activity id returned by startActivity, so it only touches this one activity — exactly like a backend update targets a single campaign.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Stepper("Bayern München: \(viewModel.homeScore)", value: $viewModel.homeScore, in: 0...20)
                        Stepper("Borussia Dortmund: \(viewModel.awayScore)", value: $viewModel.awayScore, in: 0...20)

                        Picker("Phase", selection: $viewModel.phase) {
                            ForEach(demoPhases, id: \.self) { phase in
                                Text(phase.displayText).tag(phase)
                            }
                        }
                        .pickerStyle(.menu)

                        Button(action: { viewModel.startDemoActivity() }) {
                            Label("Start Activity", systemImage: "play.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .disabled(viewModel.demoActivityId != nil)

                        Button(action: { viewModel.updateDemoActivity() }) {
                            Label("Update Score & Phase", systemImage: "arrow.up.circle.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.demoActivityId == nil)

                        TextField("Hot message (e.g. Goal!)", text: $hotMessageText)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField)

                        Button(action: { viewModel.sendHotMessage(hotMessageText) }) {
                            Label("Send Hot Message", systemImage: "flame.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .disabled(viewModel.demoActivityId == nil)

                        Button(action: { viewModel.endDemoActivity() }) {
                            Label("End Activity", systemImage: "stop.fill")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .disabled(viewModel.demoActivityId == nil)
                    }
                    .padding(.top, 4)
                }

                // Running activities
                GroupBox(label: Label("Running Activities", systemImage: "list.bullet")) {
                    VStack(alignment: .leading, spacing: 12) {
                        if viewModel.activities.isEmpty {
                            Text("No activity is running on this device.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(viewModel.activities, id: \.activityId) { activity in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(activity.activityId)
                                        .font(.caption.monospaced())
                                    Text(activity.activityId == viewModel.demoActivityId
                                         ? "template: \(activity.templateId) · local demo"
                                         : "template: \(activity.templateId)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
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
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = false }
            }
        }
        .navigationTitle("Live Activities")
        .onAppear { viewModel.refresh() }
    }
}

private struct UnsupportedOSView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("PPG Live Activities require iOS 17.2 or newer.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        LiveActivitiesView()
    }
}
