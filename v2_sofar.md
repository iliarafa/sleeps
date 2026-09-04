# Sleeps V2 — So Far

**Branch merged:** `feature/v2-features` → `main` (fast-forward)  
**As of:** 2026-08-04  
**Status:** Code complete on `main`. Device / App Store follow-ups still open (see below).

V2 keeps Sleeps Made for Kids (free, no ads / IAP / accounts / analytics) and targets how families actually use it: kids look at a **parent’s iPhone** or a **shared / kid iPad**, not their own phone.

---

## Product decisions

| Decision | Choice |
|---|---|
| Goal mix | Delight + App Store appeal + light parent power, stay simple |
| Compliance | Stay Made for Kids |
| Gaps to close | Glance / “feel” the countdown + get it onto other family devices |
| Package | Balanced: widgets + share + yearly + Watch + Live Activity |
| Usage model | Parent phone / kid iPad first; Watch = parent wrist glance |
| Watch priority | Should (read-only), not full CRUD |

**Product rule:** one-glance answer for a five-year-old; parent can get that answer onto another family device in under ~30 seconds.

Planning artifacts:

- Spec: `docs/superpowers/specs/2026-08-04-v2-features-design.md`
- Plan: `docs/superpowers/plans/2026-08-04-v2-features.md`

---

## What shipped

### 1. Lock Screen & StandBy widgets
- Accessory families: circular, rectangular, inline
- Day count from existing `DaysUntil` snapshots; tap uses `sleeps://event/<uuid>`
- Compact empty states; system accessory backgrounds (not loud event color)

### 2. Large home widgets & iPad layout
- `.systemLarge` and `.systemExtraLarge`
- Hero countdown + upcoming rows
- Wider detail banner and list padding on regular width (no sidebar planner)

### 3. Share a countdown across Apple IDs
- Encode event fields into an import payload (`EventImport` in CountdownKit)
- Create a **new** UUID on import (CloudKit-safe)
- App handles `sleeps://import?d=…`
- **SHARE** on detail originally shared bare `sleeps://` (sparse system sheet)
- Fixed to share **HTTPS** `https://iliarafa.github.io/sleeps/i/?d=…` with a short message
- Landing page `docs/i/index.html` redirects into `sleeps://import…`
- Note: Simulator share sheet stays thin; real device needed for Messages / Mail / AirDrop

### 4. Yearly repeating events
- `CountdownEvent.repeatsYearly` (default `false`, CloudKit-safe)
- “EVERY YEAR” toggle in add/edit
- `YearlyRepeat` advances past dates; Feb 29 → Feb 28 in non-leap years
- Runs on app launch paths and widget timeline builds

### 5. Apple Watch companion
- New watchOS app + complication extension (XcodeGen / `project.yml`)
- Read-only list + detail; phone is source of truth
- WatchConnectivity push + App Group cache
- Complications (accessory families)
- `@2x` event icon PNGs so watchOS assets aren’t thinned to empty
- CountdownKit platforms include `.watchOS(.v10)`

### 6. Live Activities
- Window: 1 sleep away **or** timed `.ticking` phase (`LiveActivityWindow`)
- Local-only ActivityKit (no push analytics)
- Title / color / icon live in `ContentState` so edits refresh
- Arrived / past show TODAY! / IT’S TIME! (not stuck on “1”)
- Lock Screen presentation has `.widgetURL` to open the event
- `NSSupportsLiveActivities` enabled

### 7. Richer arrival moment
- More confetti + larger TODAY/IT’S TIME on regular width
- One-shot haptic on arrive (not every TimelineView tick)

### 8. Docs & project wiring
- `README.md` and `HANDOFF.md` updated for V2 surfaces
- Residual manual QA listed honestly (not marked verified)
- Owner decision noted: whether SHARE needs `ParentalGate` for Kids review
- Watch **AppIcon** called out as App Store submission blocker
- Building iOS scheme now requires watchOS platform installed (`xcodebuild -downloadPlatform watchOS`)

### 9. Tests
- CountdownKit suite grew from **49 → 69** tests  
  (import, yearly leap day, Live Activity window, Watch snapshots, etc.)

---

## Commits on the V2 feature line (newest first)

1. Share countdowns via HTTPS so Messages and Mail appear  
2. LiveActivity: show arrived/past copy + lock screen deep link  
3. Docs: clarify V2 manual QA and icon scales  
4. Docs: note V2 features in HANDOFF and README  
5. Polish: richer TODAY celebration on large screens  
6. LiveActivity: move title/color/icon into ContentState so edits refresh  
7. App: Live Activity for one-sleep-away and ticking events  
8. Kit: ship @2x event icons so they render on watchOS  
9. Watch: read-only Sleeps glance app and complications  
10. Add yearly repeating countdowns with Feb 29 → Feb 28 rule  
11. App: share countdowns via sleeps://import and openURL import  
12. Kit: add sleeps://import payload encode/decode  
13. Widget: add large/extra-large families and roomier iPad layout  
14. Widget: compact accessory empty states and single background path  
15. Widget: add Lock Screen and StandBy accessory families  

Also on `main` from planning: V2 design spec, implementation plan, ignore `.worktrees/` / `.superpowers/`.

---

## Still open

### Owner decisions
- ~~Whether **SHARE** should sit behind the existing parental gate~~ — decided 2026-09-04: **gated** (see HANDOFF)
- When to open TestFlight (`main` is pushed)

### Before App Store / release polish
- ~~Add **Watch app icon** assets~~ — done 2026-09-04: derived from `docs/art/app-icon.png` into `CountdownWatch/Assets.xcassets/AppIcon.appiconset` (see HANDOFF)
- ~~Deploy / confirm GitHub Pages serves `docs/i/`~~ — confirmed live 2026-09-04 (`https://iliarafa.github.io/sleeps/i/` returns 200)
- ~~Register Watch bundle IDs + App Group on the developer team~~ — done 2026-09-04 via `xcodebuild -allowProvisioningUpdates`; the complication bundle ID was renamed to `com.iamilias.sleeps.watchkitapp.widget` because the original `….complication` ID is unavailable on Apple's portal (see HANDOFF)

### Device QA (code complete, not fully verified on hardware)
- Lock Screen / StandBy gallery visuals + deep-link taps  
- Large / extra-large widgets on iPad  
- Cross-device share (different Apple ID) via Messages / AirDrop  
- Paired Watch sync + complication refresh without opening the Watch app  
- Live Activity visuals and day-boundary behavior on a real phone  
- iPad arrival celebration + haptic  

---

## How to run

```sh
xcodegen generate
# first-time / CI machines with Watch embedded:
xcodebuild -downloadPlatform watchOS

open Countdown.xcodeproj   # ⌘R
# or:
xcodebuild -project Countdown.xcodeproj -scheme Countdown \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

cd CountdownKit && swift test   # 69 tests
```

Dev sample data: launch with `-seedSampleData` (DEBUG, empty store).
