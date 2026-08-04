import ActivityKit
import Foundation

/// Local-only Live Activity for the last sleep / final-day ticking window.
/// No push tokens are requested and no analytics are attached — kids-safe by
/// design. Lives in `Shared` so both the app (starts/ends activities) and the
/// widget extension (renders them) compile the same type.
public struct SleepsActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var eventDate: Date
        public var hasTime: Bool

        public init(eventDate: Date, hasTime: Bool) {
            self.eventDate = eventDate
            self.hasTime = hasTime
        }
    }

    public var eventID: UUID
    public var title: String
    public var colorName: String
    public var emoji: String

    public init(eventID: UUID, title: String, colorName: String, emoji: String) {
        self.eventID = eventID
        self.title = title
        self.colorName = colorName
        self.emoji = emoji
    }
}
