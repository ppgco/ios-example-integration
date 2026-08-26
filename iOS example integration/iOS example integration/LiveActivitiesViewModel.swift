//
//  LiveActivitiesViewModel.swift
//  iOS example integration
//
//  Created by PushPushGo on 26/08/2026.
//

import Foundation
import SwiftUI
import PPG_LiveActivities

@available(iOS 17.2, *)
@MainActor
class LiveActivitiesViewModel: ObservableObject {

    @Published var message: String = ""

    // Backend-driven flow
    @Published var liveNotificationId: String = ""
    @Published var isSubscribed: Bool = false
    @Published var subscriptionStatus: String = "not subscribed"

    // App-driven (local) demo flow
    @Published var homeScore: Int = 0
    @Published var awayScore: Int = 0
    @Published var phase: MatchPhase = .preMatch

    /// Activity id returned by `startActivity`. Every later call is addressed
    /// to this one activity — an app must keep its own campaign -> activity
    /// mapping, because `getActiveActivities()` reports every Live Activity on
    /// the device, including ones started by backend pushes for other campaigns.
    @Published private(set) var demoActivityId: String?

    // Diagnostics
    @Published var activitiesEnabled: Bool = false
    @Published var activities: [LiveActivityInfo] = []

    /// Template identifier reported to the backend statistics.
    private let templateId = "football-match"

    init() {
        refresh()
    }

    // Diagnostics

    func refresh() {
        activitiesEnabled = LiveActivitiesSDK.shared.areActivitiesEnabled()
        activities = LiveActivitiesSDK.shared.getActiveActivities()

        if let trackedId = demoActivityId {
            // Dropped if it ended meanwhile (backend stop, user swipe, timeout).
            if !activities.contains(where: { $0.activityId == trackedId }) {
                demoActivityId = nil
            }
        } else {
            // The app may have been relaunched while the demo activity was still
            // running — the SDK restores its registry, so the demo template id is
            // enough to pick it up again. A production app would persist its own
            // campaign -> activity mapping instead.
            demoActivityId = activities.first { $0.templateId == templateId }?.activityId
        }
    }

    // Backend-driven flow (push-to-start)

    /// Subscribe this device to a campaign created in the PPG dashboard.
    /// The backend then starts / updates / ends the Live Activity over APNs —
    /// the app does not need to be running.
    func subscribe() {
        let campaignId = liveNotificationId.trimmingCharacters(in: .whitespaces)
        guard !campaignId.isEmpty else {
            setStatus("Live Notification ID cannot be empty")
            return
        }

        LiveActivitiesSDK.shared.subscribe(
            MatchActivityAttributes.self,
            liveNotificationId: campaignId,
            onCampaignAlreadyActive: { payload in
                // Late subscriber: the campaign is already ONGOING, so no
                // push-to-start will arrive. Build the activity from the REST
                // payload instead, prefetching the badges first.
                let dto = try PPGLiveNotificationDTO.decode(from: payload)
                if let homeUrl = dto.footballMatchConfiguration?.content.homeTeamImage, !homeUrl.isEmpty {
                    await LiveActivityImageManager.shared.prefetch(from: homeUrl, imageType: .homeTeamBadge, campaignId: dto.id)
                }
                if let awayUrl = dto.footballMatchConfiguration?.content.awayTeamImage, !awayUrl.isEmpty {
                    await LiveActivityImageManager.shared.prefetch(from: awayUrl, imageType: .awayTeamBadge, campaignId: dto.id)
                }
                return MatchActivityAttributes.from(dto: dto)
            }
        ) { [weak self] status in
            Task { @MainActor in
                self?.handle(status)
            }
        }

        isSubscribed = true
        subscriptionStatus = "subscribing…"
        setStatus("Subscribing to campaign \(campaignId)")
    }

    /// Stop following the campaign — deletes the subscriber on the backend.
    func unsubscribe() {
        let campaignId = liveNotificationId.trimmingCharacters(in: .whitespaces)
        guard !campaignId.isEmpty else {
            setStatus("Live Notification ID cannot be empty")
            return
        }
        LiveActivitiesSDK.shared.unsubscribe(liveNotificationId: campaignId)
        isSubscribed = false
        subscriptionStatus = "unsubscribing…"
        setStatus("Unsubscribing from campaign \(campaignId)")
    }

    private func handle(_ status: LiveNotificationSubscriptionStatus) {
        switch status {
        case .registered:
            subscriptionStatus = "registered — waiting for match start"
            setStatus("Subscriber registered")
        case .activityStarted(let activityId):
            subscriptionStatus = "activity running"
            setStatus("Live Activity started: \(activityId)")
            refresh()
        case .updateTokenSent:
            // Never fires for broadcast-channel campaigns (iOS 18+) — expected.
            setStatus("Update token forwarded to backend")
        case .activityEnded(let activityId):
            subscriptionStatus = "registered — match ended"
            setStatus("Live Activity ended: \(activityId)")
            refresh()
        case .unsubscribed:
            isSubscribed = false
            subscriptionStatus = "not subscribed"
            setStatus("Unsubscribed")
        case .error(let error):
            subscriptionStatus = "error"
            setStatus("Subscriber error: \(error)")
        }
    }

    // App-driven (local) demo flow

    /// Start a Live Activity straight from the app — handy while integrating,
    /// because push-to-start does not work in the simulator. Activities started
    /// this way are not reachable by PPG backend pushes.
    func startDemoActivity() {
        guard demoActivityId == nil else {
            setStatus("Demo activity already running — end it first")
            return
        }
        Task {
            // The widget resolves badges by campaign id + image type, so the
            // local flow has to prefetch them under the same scope. In the
            // subscriber flow the SDK does this on its own.
            async let home = LiveActivityImageManager.shared.prefetch(
                from: Self.homeBadgeUrl, imageType: .homeTeamBadge, campaignId: Self.demoCampaignId
            )
            async let away = LiveActivityImageManager.shared.prefetch(
                from: Self.awayBadgeUrl, imageType: .awayTeamBadge, campaignId: Self.demoCampaignId
            )
            let prefetched = [await home, await away].filter { $0 }.count
            setStatus("Prefetched \(prefetched)/2 badges")

            let activityId = LiveActivitiesSDK.shared.startActivity(
                attributes: Self.demoAttributes,
                initialState: buildState(),
                templateId: templateId
            )

            if let activityId {
                demoActivityId = activityId
                setStatus("Demo activity started: \(activityId)")
            } else {
                setStatus("Failed to start demo activity — check the SDK logs")
            }
            refresh()
        }
    }

    /// Push the current score / phase into the demo activity.
    ///
    /// Note the `activityId`: an update is addressed to one specific activity,
    /// never broadcast to everything running. The backend flow works the same
    /// way — an `event:update` push carries the campaign's `liveNotificationId`
    /// and only that campaign's activity changes.
    func updateDemoActivity() {
        guard let activityId = demoActivityId else {
            setStatus("No demo activity running — start one first")
            return
        }
        LiveActivitiesSDK.shared.updateActivity(
            MatchActivityAttributes.self,
            activityId: activityId,
            state: buildState()
        )
        setStatus("Updated \(activityId) — \(homeScore):\(awayScore) \(phase.rawValue)")
    }

    /// Send a transient banner ("Goal!", "Red card") shown for up to 10 seconds.
    /// A hot message travels inside the content state, so this is a regular
    /// update of the same activity.
    func sendHotMessage(_ text: String) {
        guard let activityId = demoActivityId else {
            setStatus("No demo activity running — start one first")
            return
        }
        LiveActivitiesSDK.shared.updateActivity(
            MatchActivityAttributes.self,
            activityId: activityId,
            state: buildState(hotMessage: PPGHotMessage(
                id: UUID().uuidString,
                text: text,
                expiresAt: Date(timeIntervalSinceNow: 10)
            ))
        )
        setStatus("Hot message sent: \(text)")
    }

    func endDemoActivity() {
        guard let activityId = demoActivityId else {
            setStatus("No demo activity running")
            return
        }
        LiveActivitiesSDK.shared.endActivity(
            MatchActivityAttributes.self,
            activityId: activityId,
            finalState: buildState(),
            // `.default` would leave the activity dimmed on the Lock Screen for
            // up to ~4 h, which is what a real match end usually wants.
            dismissPolicy: .immediate
        )
        demoActivityId = nil
        setStatus("Ended demo activity \(activityId)")
        // ActivityKit needs a moment to propagate the change before the list refreshes.
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            refresh()
        }
    }

    // Builders

    private func buildState(hotMessage: PPGHotMessage? = nil) -> MatchActivityAttributes.ContentState {
        MatchActivityAttributes.ContentState(
            homeTeamScore: homeScore,
            awayTeamScore: awayScore,
            status: phase,
            hotMessage: hotMessage,
            // Back-dated so playing phases render the live match clock.
            statusChangedAt: phase.isPlaying ? Date() : nil
        )
    }

    private static let demoCampaignId = "demo-match-001"
    private static let homeBadgeUrl = "https://crests.football-data.org/5.png"
    private static let awayBadgeUrl = "https://crests.football-data.org/4.png"

    /// Static part of the demo activity — the same shape the backend sends in
    /// the `event:start` push (title, teams, colors, action buttons).
    private static let demoAttributes = MatchActivityAttributes(
        liveNotificationId: demoCampaignId,
        content: PPGFootballMatchContent(
            title: "Bundesliga · Round 30",
            homeTeamName: "Bayern München",
            homeTeamImage: homeBadgeUrl,
            awayTeamName: "Borussia Dortmund",
            awayTeamImage: awayBadgeUrl
        ),
        design: PPGFootballMatchDesign(
            ios: PPGFootballMatchIOSDesign(
                statusBackground: PPGColorSet(
                    .gradient(fromHex: "#1E3A8A", toHex: "#0F172A", direction: .topToBottom)
                )
            )
        ),
        statusLabels: [
            MatchPhase.preMatch.rawValue: "Pre-Match",
            MatchPhase.firstHalf.rawValue: "1st Half",
            MatchPhase.halfTimeBreak.rawValue: "Half Time",
            MatchPhase.secondHalf.rawValue: "2nd Half",
            MatchPhase.fullTime.rawValue: "Full Time",
            MatchPhase.matchEnded.rawValue: "Match Ended"
        ],
        actionSet: [
            .url(name: "Match statistics", url: "https://example.com/stats", design: actionDesign(bgHex: "#2563EB")),
            .close(name: "Stop following", design: actionDesign(bgHex: "#374151"))
        ],
        timeout: PPGLiveActivityTimeout(minutes: 180)
    )

    private static func actionDesign(bgHex: String) -> PPGActionDesign {
        let appearance = PPGActionIOSAppearance(
            textColor: .basic(hex: "#FFFFFF"),
            backgroundColor: .basic(hex: bgHex),
            border: nil
        )
        return PPGActionDesign(ios: PPGActionIOSDesign(
            alignment: .center,
            borderRadius: 8,
            appearance: PPGActionIOSAppearanceSet(lightMode: appearance, darkMode: appearance)
        ))
    }

    // Status

    private func setStatus(_ text: String) {
        message = "[\(timeString())] \(text)"
    }

    private func timeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}
