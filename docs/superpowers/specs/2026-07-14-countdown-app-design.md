# Countdown App for Kids — "How long until…?"

## Context

Inspired by the user's son, who asks Siri every day "how long until August?", "how long until [X]?" while traveling. The app lets kids (and parents) create countdowns to events and see how many days are left — in the app, on a home screen widget, via Siri, and through gentle notifications.

**Decisions made with the user:**
- **Platform:** Native iOS app (SwiftUI)
- **Distribution:** Publish to the App Store (Kids Category compliance matters)
- **V1 features:** Core countdowns + Siri/App Intents + home screen widgets + notifications (skipped "gamified" visuals like progress rockets — keep it clean and kid-friendly)
- **Data:** iCloud sync across same-account devices via SwiftData + CloudKit
- **Stack:** SwiftUI + SwiftData (CloudKit-backed), App Intents, WidgetKit, local notifications. Minimum iOS 17.
- **Business:** Free, no ads, no IAP, no analytics in v1 (also simplifies Kids Category review).

## Prerequisites (user-side, at the office)

- Xcode 16+ installed
- Apple Developer Program membership (needed for CloudKit, App Groups, and App Store publishing)
- An app name decision — working title **"Sleeps"** or **"How Long Until"** (placeholder bundle id `com.iamilias.sleeps`; easy to rename before submission)

## Architecture

Single Xcode project, three targets sharing code via a local Swift package (or shared framework):

```
Countdown.xcodeproj
├── Countdown            (main app target — SwiftUI)
├── CountdownWidget      (WidgetKit extension)
└── CountdownKit         (shared: SwiftData model, date math, formatting, App Intents)
```

- **App Group** (`group.com.iamilias.sleeps`) so the widget and Siri intents read the same SwiftData store as the app.
- **CloudKit container** (`iCloud.com.iamilias.sleeps`) with SwiftData's `cloudKitDatabase: .automatic` for private-database sync.

### Data model (SwiftData)

```swift
@Model final class CountdownEvent {
    var id: UUID = UUID()
    var title: String = ""
    var date: Date = Date()          // the event day (compared by calendar day, not 24h intervals)
    var emoji: String = "🎉"
    var colorName: String = "blue"   // maps to a small curated palette
    var createdAt: Date = Date()
    var notificationsEnabled: Bool = true
}
```

CloudKit constraint: all properties need defaults (no `@Attribute(.unique)`), which the model above respects.

### Date math (the heart of the app — get this right)

- "Days until" = **calendar days** between `Calendar.current.startOfDay(for: now)` and `startOfDay(for: event.date)` — never `timeIntervalSince / 86400` (DST and time-of-day bugs).
- Central `DaysUntil` utility in CountdownKit, fully unit-tested: today → "It's today! 🎉", tomorrow → "1 more sleep", past events handled gracefully ("was 3 days ago" or auto-archive).
- Kid-friendly phrasing: primary display is big number of days; subtitle in "sleeps" ("12 more sleeps").

### App screens (SwiftUI)

1. **Event list** — cards sorted by soonest, each with emoji, title, big days-remaining number. Empty state invites creating the first countdown.
2. **Add/edit event** — title, date picker, emoji picker (curated grid, not full keyboard), color choice. Big touch targets, minimal typing.
3. **Event detail** — full-screen friendly countdown; simple confetti/celebration when days == 0 (cheap to do with a particle emitter, worth it).
4. **Settings** — notification time-of-day preference, about/privacy. External links (privacy policy) go behind a parental gate per Kids Category rules.

### Siri / App Intents (the inspiration feature)

- `CountdownEventEntity` (AppEntity) + `EntityQuery` over the shared store.
- `HowLongUntilIntent` (AppIntent) returning a spoken + visual snippet: "12 days until Summer Vacation — that's 12 more sleeps!"
- Registered via `AppShortcutsProvider` with phrases like "How long until \(\.$event) in **[AppName]**".
- **Honest limitation to note:** Siri requires the app name in the phrase ("…in Sleeps"). Fully open-ended "how long until August" without the app name isn't possible for third-party apps. Mitigation: short app name, and the intent also appears in Spotlight/Shortcuts.

### Widgets (WidgetKit)

- **Small widget:** next upcoming event — emoji + days number.
- **Medium widget:** next 2–3 events.
- Configurable (via `WidgetConfigurationIntent`) to pin a specific event instead of "next up".
- Timeline: one entry per day, refreshing after midnight; also `WidgetCenter.reloadAllTimelines()` on any data change in the app.

### Notifications (local only — no server)

- On event create/edit, schedule `UNCalendarNotificationTrigger` notifications at milestones: 7 days, 3 days, 1 day ("1 more sleep until…!"), and day-of morning — at the user-chosen time (default 8:00 AM).
- Re-schedule on app launch (notification limit is 64 pending — fine for this scale; schedule nearest milestones only).
- Standard permission prompt; app fully functional if declined.

### Kids Category / App Store compliance

- Category: Made for Kids (choose age band, likely 6–8).
- No third-party ads/analytics/tracking SDKs — we have none.
- Privacy policy URL required (simple static page — can host free on Vercel/GitHub Pages later).
- Parental gate before any external link out of the app.
- Privacy nutrition label: "Data Not Collected."

## Implementation order

1. **Project scaffold** — Xcode project, three targets, App Group + CloudKit entitlements, shared package wiring.
2. **CountdownKit core** — `CountdownEvent` model, `DaysUntil` date math + unit tests, formatting helpers.
3. **Main app UI** — list, add/edit, detail screens with SwiftData; iCloud sync verified between simulator + a real device.
4. **Widget extension** — small + medium widgets, timeline provider, reload hooks.
5. **App Intents / Siri** — entity, query, intent, App Shortcuts phrases; test via Shortcuts app and Siri.
6. **Notifications** — scheduling engine + settings screen, permission flow.
7. **Polish & compliance** — app icon, celebration animation, parental gate, privacy policy, App Store metadata/screenshots, TestFlight → submission.

Steps 1–3 make a usable family app; 4–6 are each independently shippable increments.

## Verification

- **Unit tests** (CountdownKit): date math across DST boundaries, year rollovers, today/tomorrow/past cases; notification scheduling logic.
- **Manual/simulator:** run in iOS Simulator; verify sync by running on two simulators/devices with the same iCloud account; test widgets via widget gallery; test Siri phrases via Shortcuts app and voice.
- **TestFlight with the real user** — the son. If he actually asks the app instead of Siri-the-assistant, v1 succeeded.

## Notes / later ideas (not v1)

- Family sharing across different iCloud accounts (CloudKit shared database)
- Greek (or other) localization
- Fun visual progress themes (rocket, calendar-of-sleeps)
- Lock Screen widgets / Apple Watch complication
- Recurring events (birthdays auto-advance each year)
