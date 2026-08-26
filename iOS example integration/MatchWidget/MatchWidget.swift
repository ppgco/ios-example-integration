//
//  MatchWidget.swift
//  MatchWidget
//
//  Widget Extension hosting the PPG Live Activity (Lock Screen + Dynamic Island).
//  The views come from the SDK — this target only declares the ActivityConfiguration
//  and wires up the shared App Group.
//

import WidgetKit
import SwiftUI
import ActivityKit
import PPG_LiveActivities

@main
struct MatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        MatchLiveActivityWidget()
    }
}

struct MatchLiveActivityWidget: Widget {

    init() {
        // The widget runs in its own process and does not inherit configuration
        // from the host app — point it at the same App Group so it can read the
        // cached team badges, the design and hot-message timestamps.
        LiveActivitiesSDK.configureWidgetExtension(appGroupId: "group.ppgios")
    }

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MatchActivityAttributes.self) { context in
            // Lock Screen / banner presentation
            PPGMatchLockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island (compact + expanded)
            PPGMatchDynamicIsland(context: context).body()
        }
    }
}
