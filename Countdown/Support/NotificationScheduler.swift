import Foundation
import UserNotifications
import CountdownKit

/// User preference for when the daily-ish reminders fire, shared with extensions
/// through the app group.
enum NotificationPrefs {
    private static let key = "notificationMinutesFromMidnight"
    private static var defaults: UserDefaults { UserDefaults(suiteName: AppIDs.appGroup) ?? .standard }

    /// Minutes from midnight, default 8:00 AM.
    static var minutesFromMidnight: Int {
        get { defaults.object(forKey: key) as? Int ?? 480 }
        set { defaults.set(newValue, forKey: key) }
    }

    /// Same preference exposed as a Date (today at that time) for DatePicker binding.
    static var time: Date {
        get {
            Calendar.current.date(
                bySettingHour: minutesFromMidnight / 60,
                minute: minutesFromMidnight % 60,
                second: 0,
                of: .now
            ) ?? .now
        }
        set {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            minutesFromMidnight = (comps.hour ?? 8) * 60 + (comps.minute ?? 0)
        }
    }
}

/// Bridges `NotificationPlanner` plans into UNUserNotificationCenter.
enum NotificationScheduler {
    static func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
    }

    /// Wipe and re-schedule everything. Called after any event change, settings
    /// change, and on app launch (keeps milestones fresh as days pass).
    static func rescheduleAll(events: [CountdownEvent]) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let minutes = NotificationPrefs.minutesFromMidnight
        let planned = events
            .filter { $0.notificationsEnabled && !$0.isPast }
            .flatMap { event in
                NotificationPlanner.plan(
                    eventID: event.id,
                    title: event.title,
                    eventDate: event.date,
                    hour: minutes / 60,
                    minute: minutes % 60
                )
            }
            .sorted { $0.fireDate < $1.fireDate }
            .prefix(60) // iOS caps pending notifications at 64

        for plan in planned {
            let content = UNMutableNotificationContent()
            content.title = plan.title
            content.body = plan.body
            content.sound = .default
            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: plan.fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: plan.id, content: content, trigger: trigger))
        }
    }
}
