import Foundation

/// A countdown flattened for the Watch: plain values only, so it can travel over
/// WatchConnectivity and be read by the complication process. The phone owns the
/// real `CountdownEvent`; the Watch only ever sees these.
public struct WatchEventSnapshot: Codable, Identifiable, Sendable, Equatable, Hashable {
    public var id: UUID
    public var title: String
    public var iconRaw: String
    public var colorName: String
    public var date: Date
    public var hasTime: Bool

    public init(id: UUID, title: String, iconRaw: String, colorName: String, date: Date, hasTime: Bool) {
        self.id = id
        self.title = title
        self.iconRaw = iconRaw
        self.colorName = colorName
        self.date = date
        self.hasTime = hasTime
    }

    public init(from event: CountdownEvent) {
        self.id = event.id
        self.title = event.title
        self.iconRaw = event.icon.rawValue
        self.colorName = event.colorName
        self.date = event.date
        self.hasTime = event.hasTime
    }

    public var icon: EventIcon { EventIcon.from(stored: iconRaw) }

    public var daysRemaining: Int { DaysUntil.days(to: date) }

    public func daysRemaining(from now: Date, calendar: Calendar = .current) -> Int {
        DaysUntil.days(from: now, to: date, calendar: calendar)
    }
}

public extension WatchEventSnapshot {
    static func snapshots(from events: [CountdownEvent]) -> [WatchEventSnapshot] {
        events.map(WatchEventSnapshot.init(from:))
    }

    /// The soonest countdowns that haven't happened yet, soonest first.
    static func upcoming(
        from snapshots: [WatchEventSnapshot],
        limit: Int = 5,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [WatchEventSnapshot] {
        Array(
            snapshots
                .filter { $0.daysRemaining(from: now, calendar: calendar) >= 0 }
                .sorted { $0.date < $1.date }
                .prefix(limit)
        )
    }
}
