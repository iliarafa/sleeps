import Foundation
import SwiftData

/// Identifiers shared across the app, widget, and intents.
public enum AppIDs {
    public static let appGroup = "group.com.iamilias.sleeps"
    public static let cloudKitContainer = "iCloud.com.iamilias.sleeps"
}

/// Builds the ModelContainer that every process (app, widget, Siri intent) shares
/// via the App Group container.
public enum SharedStore {
    /// Process-wide container. In the app this is CloudKit-synced; in the widget
    /// and intent extensions (no iCloud entitlement) the CloudKit init throws and
    /// we transparently fall back to the same local store file.
    public static let shared = makeAppContainer()

    /// Whether this process has a usable App Group container. SwiftData asserts
    /// (doesn't throw) when the entitlement is missing, so check up front.
    private static var hasAppGroup: Bool {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppIDs.appGroup) != nil
    }

    /// Whether an iCloud account is signed in and available to this app.
    private static var hasICloud: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    /// The main app's container: CloudKit-synced, falling back to local-only when
    /// CloudKit isn't available (no iCloud account, simulator without login, no
    /// developer entitlements yet). The app stays fully functional either way.
    public static func makeAppContainer() -> ModelContainer {
        if hasAppGroup && hasICloud {
            let schema = Schema([CountdownEvent.self])
            let config = ModelConfiguration(
                schema: schema,
                groupContainer: .identifier(AppIDs.appGroup),
                cloudKitDatabase: .private(AppIDs.cloudKitContainer)
            )
            if let container = try? ModelContainer(for: schema, configurations: [config]) {
                return container
            }
        }
        return makeLocalContainer()
    }

    /// Local-only access to the same store file. Used by the widget and Siri
    /// extensions (they read data; sync is the app's job) and as the app's fallback.
    public static func makeLocalContainer() -> ModelContainer {
        let schema = Schema([CountdownEvent.self])
        let group: ModelConfiguration.GroupContainer = hasAppGroup ? .identifier(AppIDs.appGroup) : .none
        do {
            let config = ModelConfiguration(
                schema: schema,
                groupContainer: group,
                cloudKitDatabase: .none
            )
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Last resort (e.g. broken store file in some dev setup): in-memory,
            // so the process still runs instead of crashing.
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [config])
        }
    }

    /// Fetch all events sorted soonest-first (past events at the end).
    public static func upcomingFirst(in context: ModelContext) -> [CountdownEvent] {
        let descriptor = FetchDescriptor<CountdownEvent>(sortBy: [SortDescriptor(\.date)])
        let all = (try? context.fetch(descriptor)) ?? []
        let upcoming = all.filter { !$0.isPast }
        let past = all.filter(\.isPast).reversed()
        return upcoming + past
    }
}
