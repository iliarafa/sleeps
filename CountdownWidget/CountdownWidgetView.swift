import WidgetKit
import SwiftUI
import CountdownKit

struct CountdownWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CountdownEntry

    var body: some View {
        if entry.events.isEmpty {
            emptyView
        } else {
            switch family {
            case .systemMedium:
                MediumView(events: entry.events)
            default:
                SmallView(event: entry.events[0])
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 6) {
            Text("🗓️").font(.title)
            Text("Add a countdown!")
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
    }
}

private struct SmallView: View {
    let event: EventSnapshot

    var body: some View {
        VStack(spacing: 2) {
            Text(event.emoji)
                .font(.system(size: 32))
            Text(CountdownText.headline(days: event.days))
                .font(.system(size: event.days > 0 ? 40 : 22, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            if event.days > 0 {
                Text(event.days == 1 ? "sleep until" : "sleeps until")
                    .font(.caption2.bold())
                    .opacity(0.85)
            }
            Text(event.title)
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MediumView: View {
    let events: [EventSnapshot]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(events) { event in
                HStack(spacing: 10) {
                    Text(event.emoji)
                        .font(.title3)
                    Text(event.title)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                    Spacer()
                    if event.days > 0 {
                        Text("\(event.days)")
                            .font(.system(.title3, design: .rounded, weight: .heavy))
                        Text(event.days == 1 ? "sleep" : "sleeps")
                            .font(.caption2.bold())
                            .opacity(0.85)
                    } else {
                        Text("Today! 🎉")
                            .font(.subheadline.bold())
                    }
                }
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
