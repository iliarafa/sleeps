import WidgetKit
import SwiftUI
import SwiftData
import CountdownKit

@main
struct CountdownWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountdownWidget()
    }
}

struct CountdownWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "CountdownWidget",
            intent: SelectEventIntent.self,
            provider: CountdownTimelineProvider()
        ) { entry in
            CountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("Countdown")
        .description("How many sleeps until the fun stuff.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

/// Plain snapshot so the timeline entry doesn't hold SwiftData objects.
struct EventSnapshot: Identifiable {
    let id: UUID
    let title: String
    let icon: EventIcon
    let colorName: String
    let days: Int
}

struct CountdownEntry: TimelineEntry {
    let date: Date
    let events: [EventSnapshot]
}

struct CountdownTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: .now, events: [
            EventSnapshot(id: UUID(), title: "Summer Vacation", icon: .beach, colorName: "blue", days: 12)
        ])
    }

    func snapshot(for configuration: SelectEventIntent, in context: Context) async -> CountdownEntry {
        await entry(for: configuration, at: .now)
    }

    func timeline(for configuration: SelectEventIntent, in context: Context) async -> Timeline<CountdownEntry> {
        // One entry now plus one at each of the next few midnights, so the day
        // count ticks over without needing a reload.
        let calendar = Calendar.current
        var entries: [CountdownEntry] = [await entry(for: configuration, at: .now)]
        for dayOffset in 1...5 {
            if let midnight = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: .now)) {
                entries.append(await entry(for: configuration, at: midnight))
            }
        }
        return Timeline(entries: entries, policy: .atEnd)
    }

    @MainActor
    private func entry(for configuration: SelectEventIntent, at date: Date) async -> CountdownEntry {
        let context = ModelContext(SharedStore.shared)
        var events = SharedStore.upcomingFirst(in: context).filter { !$0.isPast }

        if let pinnedID = configuration.event?.id {
            events = events.filter { $0.id == pinnedID } + events.filter { $0.id != pinnedID }
        }

        let snapshots = events.prefix(3).map { event in
            EventSnapshot(
                id: event.id,
                title: event.title,
                icon: event.icon,
                colorName: event.colorName,
                days: DaysUntil.days(from: date, to: event.date)
            )
        }
        return CountdownEntry(date: date, events: Array(snapshots))
    }
}
