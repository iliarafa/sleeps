import SwiftData
import WidgetKit
import CountdownKit

/// Deletes an event and keeps notifications + widgets in sync.
@MainActor
func deleteEvent(_ event: CountdownEvent, modelContext: ModelContext) {
    modelContext.delete(event)
    try? modelContext.save()
    let remaining = (try? modelContext.fetch(FetchDescriptor<CountdownEvent>())) ?? []
    Task {
        await NotificationScheduler.rescheduleAll(events: remaining)
    }
    WidgetCenter.shared.reloadAllTimelines()
    WatchSync.pushUpcoming(events: remaining)
}
