import Foundation
import SwiftData

/// A single countdown. All properties have defaults and nothing is `.unique`
/// — required for SwiftData + CloudKit sync.
@Model
public final class CountdownEvent {
    public var id: UUID = UUID()
    public var title: String = ""
    public var date: Date = Date()
    public var emoji: String = "🎉"
    public var colorName: String = "blue"
    public var createdAt: Date = Date()
    public var notificationsEnabled: Bool = true

    public init(
        title: String = "",
        date: Date = Date(),
        emoji: String = "🎉",
        colorName: String = "blue"
    ) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.emoji = emoji
        self.colorName = colorName
        self.createdAt = Date()
        self.notificationsEnabled = true
    }
}

public extension CountdownEvent {
    /// The event's picture. The stored `emoji` field holds an `EventIcon`
    /// rawValue for new events, or a literal emoji from pre-icon builds.
    var icon: EventIcon {
        EventIcon.from(stored: emoji)
    }

    /// Calendar days from now until the event (0 = today, negative = past).
    var daysRemaining: Int {
        DaysUntil.days(to: date)
    }

    var isPast: Bool { daysRemaining < 0 }
    var isToday: Bool { daysRemaining == 0 }
}
