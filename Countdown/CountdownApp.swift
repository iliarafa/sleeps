import SwiftUI
import SwiftData
import WidgetKit
import CountdownKit

@main
struct CountdownApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        #if DEBUG
        seedSampleDataIfRequested()
        #endif
        WatchSync.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            EventListView()
                .preferredColorScheme(.light)
        }
        .modelContainer(SharedStore.shared)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                WidgetCenter.shared.reloadAllTimelines()
                pushToWatch()
            }
        }
    }
}

/// Sends the current store contents to the Watch. The Watch has no store of its
/// own, so we re-push whenever the app leaves the foreground.
@MainActor
private func pushToWatch() {
    let context = ModelContext(SharedStore.shared)
    let events = (try? context.fetch(FetchDescriptor<CountdownEvent>())) ?? []
    WatchSync.pushUpcoming(events: events)
}

#if DEBUG
/// Dev-only: `simctl launch ... -seedSampleData` fills an empty store with
/// sample events so simulator runs have something to show.
@MainActor
private func seedSampleDataIfRequested() {
    guard CommandLine.arguments.contains("-seedSampleData") else { return }
    let context = ModelContext(SharedStore.shared)
    guard ((try? context.fetchCount(FetchDescriptor<CountdownEvent>())) ?? 0) == 0 else { return }

    let cal = Calendar.current
    let samples: [(String, Int, String, String)] = [
        ("My Birthday", 0, EventIcon.cake.rawValue, "pink"),
        ("Summer Camp", 3, EventIcon.tent.rawValue, "green"),
        ("Trip to Greece", 18, EventIcon.plane.rawValue, "blue"),
        ("Christmas", 164, EventIcon.tree.rawValue, "red"),
    ]
    for (title, daysAway, emoji, color) in samples {
        let date = cal.date(byAdding: .day, value: daysAway, to: cal.startOfDay(for: .now))!
        context.insert(CountdownEvent(title: title, date: date, emoji: emoji, colorName: color))
    }
    try? context.save()
}
#endif
