import Combine
import Foundation
import WatchConnectivity
import WidgetKit
import CountdownKit

/// Read-only mirror of the phone's countdowns.
///
/// The phone pushes a small payload over WatchConnectivity; we cache it in the
/// App Group so the complication process reads the same numbers, and republish it
/// to the UI. Nothing here ever writes an event — the phone stays authoritative.
@MainActor
final class WatchStore: ObservableObject {
    @Published private(set) var events: [WatchEventSnapshot] = []
    @Published private(set) var lastUpdated: Date?

    private let session = WatchSessionListener()

    init() {
        loadCache()
        session.onPayload = { [weak self] payload in
            Task { @MainActor in self?.apply(payload) }
        }
        session.activate()
    }

    /// Re-reads the cache and picks up any context that arrived while asleep.
    func refresh() {
        loadCache()
        if let payload = session.currentContextPayload() {
            apply(payload)
        }
    }

    private func loadCache() {
        guard let payload = WatchSnapshotStore.load() else { return }
        events = WatchEventSnapshot.upcoming(from: payload.events)
        lastUpdated = payload.sentAt
    }

    private func apply(_ payload: WatchPayload) {
        // A queued `transferUserInfo` backup can land after a newer context.
        guard WatchSnapshotStore.save(payload) else { return }
        events = WatchEventSnapshot.upcoming(from: payload.events)
        lastUpdated = payload.sentAt
        WidgetCenter.shared.reloadAllTimelines()
    }
}

/// Thin `WCSessionDelegate` wrapper: delegate callbacks arrive off the main
/// thread, so it hands payloads to `WatchStore` rather than touching UI state.
private final class WatchSessionListener: NSObject, WCSessionDelegate {
    var onPayload: ((WatchPayload) -> Void)?

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func currentContextPayload() -> WatchPayload? {
        guard WCSession.isSupported() else { return nil }
        return WatchSnapshotStore.payload(from: WCSession.default.receivedApplicationContext)
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        guard activationState == .activated else { return }
        deliver(session.receivedApplicationContext)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        deliver(applicationContext)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        deliver(userInfo)
    }

    private func deliver(_ message: [String: Any]) {
        guard let payload = WatchSnapshotStore.payload(from: message) else { return }
        onPayload?(payload)
    }
}
