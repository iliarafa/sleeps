import ActivityKit
import Foundation

/// Local-only Live Activity for the last sleep / final-day ticking window.
/// No push tokens are requested and no analytics are attached — kids-safe by
/// design. Lives in `Shared` so both the app (starts/ends activities) and the
/// widget extension (renders them) compile the same type.
public struct SleepsActivityAttributes: ActivityAttributes {
    /// Everything that can change while an activity is running — title, color,
    /// and icon are editable on the event at any time, so they live here
    /// (not in the immutable `ActivityAttributes`) so `activity.update` keeps
    /// the Lock Screen/Island in sync with those edits.
    public struct ContentState: Codable, Hashable {
        public var title: String
        public var colorName: String
        public var emoji: String
        public var eventDate: Date
        public var hasTime: Bool

        public init(title: String, colorName: String, emoji: String, eventDate: Date, hasTime: Bool) {
            self.title = title
            self.colorName = colorName
            self.emoji = emoji
            self.eventDate = eventDate
            self.hasTime = hasTime
        }
    }

    /// Stable identity only — fixed for the activity's lifetime.
    public var eventID: UUID

    public init(eventID: UUID) {
        self.eventID = eventID
    }
}
