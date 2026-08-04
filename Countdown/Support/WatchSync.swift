import Foundation
import WatchConnectivity
import CountdownKit

/// Phone → Watch push. The phone is the source of truth: the Watch shows a
/// read-only glance, so we only ever send the soonest few countdowns.
///
/// Call `pushUpcoming(events:)` wherever the widget timelines are reloaded.
final class WatchSync: NSObject, WCSessionDelegate {
    static let shared = WatchSync()

    /// The Watch glance and complication only ever show a short list.
    private static let maxEvents = 5

    private let lock = NSLock()
    /// Newest payload we haven't managed to hand over yet, replayed once the
    /// session activates or the watch state changes.
    private var pending: WatchPayload?
    private var started = false

    private override init() {
        super.init()
    }

    func start() {
        guard WCSession.isSupported() else { return }
        lock.lock()
        let alreadyStarted = started
        started = true
        lock.unlock()
        guard !alreadyStarted else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    @MainActor
    static func pushUpcoming(events: [CountdownEvent]) {
        let snapshots = WatchEventSnapshot.upcoming(
            from: WatchEventSnapshot.snapshots(from: events),
            limit: maxEvents
        )
        shared.push(WatchPayload(events: snapshots))
    }

    private func push(_ payload: WatchPayload) {
        guard WCSession.isSupported() else { return }
        start()

        let session = WCSession.default
        guard session.activationState == .activated, session.isPaired, session.isWatchAppInstalled else {
            lock.lock()
            pending = payload
            lock.unlock()
            return
        }

        guard let message = try? WatchSnapshotStore.message(for: payload) else { return }
        do {
            try session.updateApplicationContext(message)
            lock.lock()
            pending = nil
            lock.unlock()
        } catch {
            lock.lock()
            pending = payload
            lock.unlock()
        }
        // Backup path. The complication transfer also wakes the Watch app in the
        // background so the complication redraws without being opened, but it has
        // a daily budget — fall back to a plain queued transfer once it runs out.
        if session.isComplicationEnabled, session.remainingComplicationUserInfoTransfers > 0 {
            session.transferCurrentComplicationUserInfo(message)
        } else if session.isReachable {
            session.transferUserInfo(message)
        }
    }

    private func pushPending() {
        lock.lock()
        let payload = pending
        lock.unlock()
        guard let payload else { return }
        push(payload)
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        guard activationState == .activated else { return }
        pushPending()
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        pushPending()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        pushPending()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    /// Switching watches deactivates the session; reactivate for the new one.
    func sessionDidDeactivate(_ session: WCSession) {
        lock.lock()
        started = false
        lock.unlock()
        start()
    }
}
