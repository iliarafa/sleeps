import Foundation

/// A notification we intend to schedule. Pure value — actual UNUserNotificationCenter
/// scheduling happens in the app layer.
public struct PlannedNotification: Equatable {
    public let id: String
    public let fireDate: Date
    public let title: String
    public let body: String

    public init(id: String, fireDate: Date, title: String, body: String) {
        self.id = id
        self.fireDate = fireDate
        self.title = title
        self.body = body
    }
}

/// Decides which milestone notifications an event should get.
public enum NotificationPlanner {
    /// Days before the event at which we notify. 0 = the morning of the event.
    public static let milestones = [7, 3, 1, 0]

    /// Plan notifications for an event: milestones at 7/3/1 days before and day-of,
    /// each at `hour:minute` local time, skipping any that are already in the past.
    public static func plan(
        eventID: UUID,
        title: String,
        eventDate: Date,
        hour: Int,
        minute: Int = 0,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [PlannedNotification] {
        let eventDay = calendar.startOfDay(for: eventDate)
        return milestones.compactMap { daysBefore in
            guard
                let milestoneDay = calendar.date(byAdding: .day, value: -daysBefore, to: eventDay),
                let fireDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: milestoneDay),
                fireDate > now
            else { return nil }
            let body = daysBefore == 0
                ? "It's today! Hooray! 🎉"
                : "\(CountdownText.sleeps(days: daysBefore)) to go!"
            return PlannedNotification(
                id: "\(eventID.uuidString)-\(daysBefore)",
                fireDate: fireDate,
                title: title,
                body: body
            )
        }
    }
}
