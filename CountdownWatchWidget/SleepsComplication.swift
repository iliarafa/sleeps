import WidgetKit
import SwiftUI
import CountdownKit

@main
struct SleepsComplicationBundle: WidgetBundle {
    var body: some Widget {
        SleepsComplication()
    }
}

struct SleepsComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SleepsComplication", provider: SleepsComplicationProvider()) { entry in
            SleepsComplicationView(entry: entry)
        }
        .configurationDisplayName("Sleeps")
        .description("How many sleeps until the fun stuff.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

struct SleepsComplicationEntry: TimelineEntry {
    let date: Date
    let event: WatchEventSnapshot?

    /// Days left as of this entry's date, so the count ticks over at midnight
    /// without waiting for a reload.
    var days: Int? {
        event?.daysRemaining(from: date)
    }
}

/// Reads the App Group cache the Watch app fills from WatchConnectivity pushes.
/// The complication never talks to the session itself.
struct SleepsComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> SleepsComplicationEntry {
        SleepsComplicationEntry(date: .now, event: SleepsComplicationProvider.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (SleepsComplicationEntry) -> Void) {
        let event = context.isPreview ? SleepsComplicationProvider.sample : nextEvent(at: .now)
        completion(SleepsComplicationEntry(date: .now, event: event))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SleepsComplicationEntry>) -> Void) {
        let calendar = Calendar.current
        let cached = WatchSnapshotStore.load()?.events ?? []

        var entries = [SleepsComplicationEntry(date: .now, event: nextEvent(in: cached, at: .now))]
        for dayOffset in 1...5 {
            guard let midnight = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: calendar.startOfDay(for: .now)
            ) else { continue }
            entries.append(SleepsComplicationEntry(date: midnight, event: nextEvent(in: cached, at: midnight)))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func nextEvent(at date: Date) -> WatchEventSnapshot? {
        nextEvent(in: WatchSnapshotStore.load()?.events ?? [], at: date)
    }

    private func nextEvent(in events: [WatchEventSnapshot], at date: Date) -> WatchEventSnapshot? {
        WatchEventSnapshot.upcoming(from: events, limit: 1, now: date).first
    }

    static let sample = WatchEventSnapshot(
        id: UUID(),
        title: "Summer Camp",
        iconRaw: EventIcon.tent.rawValue,
        colorName: "green",
        date: .now.addingTimeInterval(86_400 * 3),
        hasTime: false
    )
}
