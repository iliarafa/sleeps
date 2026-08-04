import SwiftUI

@main
struct SleepsWatchApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = WatchStore()

    var body: some Scene {
        WindowGroup {
            WatchEventListView()
                .environmentObject(store)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                store.refresh()
            }
        }
    }
}
