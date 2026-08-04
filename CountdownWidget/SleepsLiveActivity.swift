import ActivityKit
import WidgetKit
import SwiftUI
import CountdownKit

/// Lock Screen + Dynamic Island UI for the last-sleep / final-day ticking
/// window. Reads only what `SleepsActivityAttributes`/`ContentState` carry —
/// no network, no push, no analytics.
struct SleepsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SleepsActivityAttributes.self) { context in
            SleepsLockScreenView(context: context)
                .activityBackgroundTint(EventColor.named(context.state.colorName).color)
                .activitySystemActionForegroundColor(.white)
                .widgetURL(deepLink(for: context.attributes))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    LoudChip(icon: icon(for: context.state), size: 40)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    SleepsCountdownText(context: context)
                        .font(Loud.heavy(28))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.title.uppercased())
                        .font(Loud.bold(14))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
            } compactLeading: {
                icon(for: context.state).image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            } compactTrailing: {
                SleepsCountdownText(context: context)
                    .font(Loud.bold(14))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            } minimal: {
                icon(for: context.state).image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            .widgetURL(deepLink(for: context.attributes))
            .keylineTint(EventColor.named(context.state.colorName).color)
        }
    }

    private func icon(for state: SleepsActivityAttributes.ContentState) -> EventIcon {
        EventIcon.from(stored: state.emoji)
    }

    private func deepLink(for attributes: SleepsActivityAttributes) -> URL? {
        URL(string: "sleeps://event/\(attributes.eventID.uuidString)")
    }
}

private struct SleepsLockScreenView: View {
    let context: ActivityViewContext<SleepsActivityAttributes>

    var body: some View {
        HStack(spacing: 14) {
            LoudChip(icon: EventIcon.from(stored: context.state.emoji), size: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(context.state.title.uppercased())
                    .font(Loud.heavy(16))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(subtitle)
                    .font(Loud.demi(12))
                    .opacity(0.85)
            }

            Spacer(minLength: 8)

            SleepsCountdownText(context: context)
                .font(Loud.heavy(30))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(16)
    }

    private var subtitle: String {
        let phase = CountdownPhase.phase(
            eventDate: context.state.eventDate,
            hasTime: context.state.hasTime,
            now: .now
        )
        switch phase {
        case .ticking: return "TODAY"
        case .arrived: return "HOORAY! 🎉"
        case .past: return context.state.hasTime ? "already happened" : "already passed"
        case .sleeps: return "ONE MORE SLEEP"
        }
    }
}

/// Big numeral for "1" sleep away, a live native ticking clock for the
/// final-day window (`Text(timerInterval:)` updates on-device with no
/// re-render pushes from the app), or the same "TODAY!"/"IT'S TIME!"
/// copy `EventDetailView` shows once the moment arrives.
private struct SleepsCountdownText: View {
    let context: ActivityViewContext<SleepsActivityAttributes>

    var body: some View {
        let phase = CountdownPhase.phase(
            eventDate: context.state.eventDate,
            hasTime: context.state.hasTime,
            now: .now
        )
        switch phase {
        case .ticking:
            if context.state.hasTime {
                Text(timerInterval: Date.now...max(Date.now, context.state.eventDate), countsDown: true)
                    .monospacedDigit()
            } else {
                arrivedText
            }
        case .sleeps(let days):
            Text("\(days)")
        case .arrived:
            arrivedText
        case .past(let days):
            Text(CountdownText.headline(days: days).uppercased())
        }
    }

    private var arrivedText: Text {
        Text(context.state.hasTime ? "IT'S TIME!" : "TODAY!")
    }
}
