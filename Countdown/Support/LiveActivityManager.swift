import ActivityKit
import Foundation
import CountdownKit

/// Starts/updates/ends Live Activities for events in the last-sleep or
/// final-day ticking window (`LiveActivityWindow.shouldPresent`). Local-only:
/// no push tokens are requested (`Activity.request` is called without a
/// `pushType`), and nothing is logged — kids-safe by design.
@MainActor
enum LiveActivityManager {
    /// Reconciles running activities against the current event list. Safe to
    /// call often (app launch, foreground, background, and after any event
    /// edit) — it's a no-op for events whose state hasn't changed.
    static func sync(events: [CountdownEvent], now: Date = .now, calendar: Calendar = .current) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            await endAll()
            return
        }

        let eligible = events.filter {
            !$0.isPast && LiveActivityWindow.shouldPresent(
                eventDate: $0.date,
                hasTime: $0.hasTime,
                now: now,
                calendar: calendar
            )
        }
        let eligibleIDs = Set(eligible.map(\.id))

        var running: [UUID: Activity<SleepsActivityAttributes>] = [:]
        for activity in Activity<SleepsActivityAttributes>.activities {
            running[activity.attributes.eventID] = activity
        }

        for (eventID, activity) in running where !eligibleIDs.contains(eventID) {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        for event in eligible {
            let state = SleepsActivityAttributes.ContentState(eventDate: event.date, hasTime: event.hasTime)
            let content = ActivityContent(state: state, staleDate: nil)

            if let activity = running[event.id] {
                await activity.update(content)
            } else {
                let attributes = SleepsActivityAttributes(
                    eventID: event.id,
                    title: event.title,
                    colorName: event.colorName,
                    emoji: event.emoji
                )
                // Local-only: no `pushType`, so no device token is ever requested.
                _ = try? Activity.request(attributes: attributes, content: content)
            }
        }
    }

    /// Ends every running Sleeps activity, e.g. when Live Activities become disabled.
    static func endAll() async {
        for activity in Activity<SleepsActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
