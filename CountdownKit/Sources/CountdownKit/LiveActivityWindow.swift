import Foundation

/// When a Live Activity should be visible for an event: the last sleep (exactly
/// one day away) or the final-24h ticking clock. Pure and unit-testable so the
/// app/widget-extension wiring stays a thin ActivityKit shell.
public enum LiveActivityWindow {
    public static func shouldPresent(
        eventDate: Date,
        hasTime: Bool,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        let days = DaysUntil.days(from: now, to: eventDate, calendar: calendar)
        if days == 1 { return true }
        if case .ticking = CountdownPhase.phase(eventDate: eventDate, hasTime: hasTime, now: now, calendar: calendar) {
            return true
        }
        return false
    }
}
