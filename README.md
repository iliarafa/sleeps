# Sleeps — a countdown app for kids

"How long until August?" — now the answer lives on the home screen.

Kids (and parents) create countdowns to events and see how many **sleeps** are left — in the app, on a widget, via Siri, and through gentle reminders.

## Stack

- SwiftUI + SwiftData (CloudKit private-database sync), iOS 17+
- WidgetKit (small + medium, configurable), App Intents (Siri), local notifications
- Project generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) — `project.yml` is the source of truth, `Countdown.xcodeproj` is gitignored

## Layout

```
CountdownKit/       Swift package: model, date math, notification planner (unit-tested)
Countdown/          App target: views, notification scheduler, Siri shortcuts
CountdownWidget/    Widget extension
Shared/             App Intents entity + widget config intent (compiled into both targets)
docs/superpowers/specs/  Design doc
```

## Build & run

```sh
xcodegen generate
open Countdown.xcodeproj      # or:
xcodebuild -project Countdown.xcodeproj -scheme Countdown \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Run unit tests: `cd CountdownKit && swift test`

Dev sample data: launch with `-seedSampleData` (DEBUG only, only fills an empty store).

## Before App Store submission (office checklist)

1. Set `DEVELOPMENT_TEAM` in `project.yml` (or Xcode Signing & Capabilities) — needed for App Groups + CloudKit on device.
2. Register the App Group `group.net.csrllc.countdown` and CloudKit container `iCloud.net.csrllc.countdown` in the developer portal (Xcode automatic signing does this for you).
3. Decide the final app name (Siri phrases include it — short wins: "…in **Sleeps**"). Rename bundle id if desired before first upload.
4. App icon (1024×1024) into `Countdown/Assets.xcassets/AppIcon.appiconset`.
5. Host the privacy policy and update the URL in `SettingsView.swift`.
6. App Store Connect: Made for Kids category (age band 6–8), privacy label "Data Not Collected".
7. Test on a real device signed into iCloud to verify sync; test Siri: "How long until Summer Camp in Sleeps?"

## Notes

- Day counts are **calendar days** (start-of-day to start-of-day), never `seconds / 86400` — DST-safe, covered by tests in `DaysUntilTests`.
- The store lives in the App Group container so the widget and Siri read the same data. CloudKit sync gracefully falls back to local-only when no iCloud account/entitlement is present (SwiftData asserts rather than throws on missing entitlements — see `SharedStore`).
- Notifications: milestones at 7/3/1 days + day-of, at a parent-chosen time (default 8:00 AM), capped at 60 pending.
