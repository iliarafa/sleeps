import WidgetKit
import SwiftUI
import CountdownKit

/// Complication faces. Watch faces tint their content, so everything here is
/// plain type — no colour fills, no ink outlines.
struct SleepsComplicationView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SleepsComplicationEntry

    var body: some View {
        switch family {
        case .accessoryCorner:
            corner
        case .accessoryInline:
            Text(inlineText)
        case .accessoryRectangular:
            rectangular
        default:
            circular
        }
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: -2) {
                Text(bigLabel)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                if let days = entry.days, days > 0 {
                    Text(days == 1 ? "SLEEP" : "SLEEPS")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                }
            }
            .padding(2)
        }
        .containerBackground(for: .widget) { Color.clear }
    }

    private var corner: some View {
        Text(bigLabel)
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .minimumScaleFactor(0.4)
            .lineLimit(1)
            .widgetLabel(cornerLabel)
            .containerBackground(for: .widget) { Color.clear }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.event?.title.uppercased() ?? "SLEEPS")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .lineLimit(1)
            Text(detailText)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) { Color.clear }
    }

    /// The numeral, or a short word when there's no number to show.
    private var bigLabel: String {
        guard let days = entry.days else { return "–" }
        return days == 0 ? "NOW" : "\(days)"
    }

    private var cornerLabel: String {
        entry.event?.title ?? "Sleeps"
    }

    private var detailText: String {
        guard let days = entry.days else { return "Nothing yet" }
        return days == 0 ? "It's today!" : (days == 1 ? "1 more sleep" : "\(days) more sleeps")
    }

    private var inlineText: String {
        guard let event = entry.event, let days = entry.days else { return "Sleeps · nothing yet" }
        return days == 0 ? "Today! · \(event.title)" : "\(days) sleeps · \(event.title)"
    }
}
