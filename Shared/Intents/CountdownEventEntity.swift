import AppIntents
import SwiftData
import CountdownKit

/// App Intents representation of a countdown — what Siri, Shortcuts, and the
/// widget configuration UI see. Compiled into both the app and widget targets.
struct CountdownEventEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Countdown"
    static let defaultQuery = CountdownEventQuery()

    let id: UUID
    let title: String
    let icon: EventIcon
    let date: Date

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(CountdownText.sleeps(days: DaysUntil.days(to: date)))"
        )
    }

    init(event: CountdownEvent) {
        self.id = event.id
        self.title = event.title
        self.icon = event.icon
        self.date = event.date
    }
}

struct CountdownEventQuery: EntityStringQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [CountdownEventEntity] {
        allEntities().filter { identifiers.contains($0.id) }
    }

    @MainActor
    func entities(matching string: String) async throws -> [CountdownEventEntity] {
        allEntities().filter { $0.title.localizedCaseInsensitiveContains(string) }
    }

    @MainActor
    func suggestedEntities() async throws -> [CountdownEventEntity] {
        allEntities()
    }

    @MainActor
    private func allEntities() -> [CountdownEventEntity] {
        let context = ModelContext(SharedStore.shared)
        return SharedStore.upcomingFirst(in: context).map(CountdownEventEntity.init)
    }
}
