# Sleeps V2 — Features Design

## Context

V1 of **Sleeps** shipped: a Made-for-Kids countdown app that answers “how many sleeps until…?” with big flashcard numerals, home-screen widgets (small + medium), Siri, local notifications, and same-account iCloud sync. It is free, with no ads, accounts, IAP, or analytics.

V2 is not a rewrite. It extends V1 for how families actually use the app.

**Decisions made with the user:**

- **Goal mix:** delight for daily kid use + App Store appeal + light parent-power — keep the app simple.
- **Compliance box:** stay Made for Kids — free, no ads / IAP / accounts / analytics.
- **Primary gaps after V1:** (A) looking at / feeling the countdown; (C) getting it onto other people’s devices.
- **Package:** balanced V2 (glance upgrade + pragmatic share + small parent feature), not glance-only or share-only.
- **Usage model (north star):** kids under ~10 rarely have their own phone. They use a **parent’s iPhone** for a minute, or a **shared / kid iPad**. Glance surfaces must work on shared adult devices and family tablets — not assume a child’s personal lock screen.
- **Apple Watch is in V2 scope** (added after initial shortlist): primarily the **parent’s wrist** when the kid asks; also usable on a kid Watch paired via Family Setup when it shares the parent’s phone data path.

### Product rule

> If a five-year-old is holding a parent’s phone, sitting with an iPad, or asking a parent who glances at their Watch, can they still get the answer in one glance — and can a parent get that answer onto the other family device in under 30 seconds?

## V1 baseline (verified in repo)

| Area | Current state |
|---|---|
| Widgets | `.systemSmall` + `.systemMedium` only (`CountdownWidget.swift`) |
| Deep links | `sleeps://event/<uuid>` opens a **local** event by id (`EventListView.onOpenURL`) |
| Devices | Universal iPhone + iPad (`TARGETED_DEVICE_FAMILY: "1,2"` in `project.yml`); **no watchOS target yet** |
| Model | `CountdownEvent` — title, date, icon (stored in `emoji`), color, notifications, `hasTime`; no recurrence |
| Celebration | Detail “TODAY!” / “IT’S TIME!” + `ConfettiView` |
| Sync today | SwiftData + CloudKit **private** DB via App Group / container — same Apple ID only |
| Color scheme | Light-only (`.preferredColorScheme(.light)` in `CountdownApp.swift`) |

Intentionally out of V1 (per `HANDOFF.md`): Lock Screen widgets, Large widget, Apple Watch / complications, family sharing across Apple IDs, localization, recurring events.

## Usage model implications

| Reality | Design consequence |
|---|---|
| Kid looks at parent’s phone | Lock Screen / StandBy / Live Activity are for **shared nightstand and borrowed phone**, not “kid’s device all day” |
| Kid asks; parent is busy | **Apple Watch** is the fastest adult glance — big sleeps number on the wrist without unlocking a phone |
| Kid often uses iPad | Large widget + iPad layout are first-class, not afterthoughts |
| Two parents / grandparent / kid iPad | Often **different Apple IDs** — same-account CloudKit is not enough |
| Parent creates, kid consumes | Share is “send this countdown,” not a social graph; Watch is **read-mostly** in V2 |
| Made for Kids | No accounts, no chat, no feeds; parental gate stays for leaving the app |

**Deprioritized under this model:** always-on notification spam to parents, parent-dashboard UI, full Watch editing/CRUD, full real-time multi-editor CloudKit collab in V2.

---

## Feature shortlist

### Must — 1. Lock Screen + StandBy widgets

**Job:** Put the sleeps number where a shared phone already sits — nightstand StandBy, Lock Screen above the fold when the kid asks.

**Scope:**

- Add accessory / Lock Screen families appropriate for a single big number + icon (exact `WidgetFamily` set chosen at implementation; must include StandBy-capable families).
- Reuse existing timeline provider patterns: day-granular `DaysUntil`, pin via `SelectEventIntent`, deep link `sleeps://event/<uuid>` for events already on that device.
- Visual language: Big & Loud — large Avenir Next Heavy numeral, event color / paper, ink outline where the family allows; avoid tiny metadata rows.

**Non-goals:** Turning Sleeps into a Lock Screen calendar. One countdown per small accessory surface.

**Why this ranks Must:** Highest leverage for the parent-phone + bedtime ritual pattern.

---

### Must — 2. iPad-first large home widget (+ roomier app feel)

**Job:** Make the shared iPad a place the countdown *lives*, not a stretched phone UI.

**Scope:**

- Add `.systemLarge` (and evaluate `.systemExtraLarge` on iPad if it stays one clear composition).
- Large widget content: next event hero (icon + huge sleeps) plus up to a few upcoming rows — still one job, not a dashboard.
- App UI: use size classes so list/detail feel at home on iPad (wider numeral, less phone chrome); do not invent a sidebar planner unless it still reads as kid flashcards.

**Non-goals:** iPad-only features that leave iPhone behind; multi-column parent tools.

---

### Must — 3. Share countdown via system share sheet (import on another device)

**Job:** Parent A creates on their phone → sends to partner’s phone or kid’s iPad → event lands in *their* Sleeps, under 30 seconds, no accounts.

**Why not reuse `sleeps://event/<uuid>`:** That URL only navigates to an event **already in the local store**. Cross-device / cross-Apple-ID needs a **payload** URL (or equivalent) that can create an event on import.

**Proposed shape (implementation may refine encoding):**

```
sleeps://import?<payload>
```

Payload carries at least: title, date, hasTime, icon raw value, colorName. Prefer a compact, versioned encoding (e.g. base64url JSON or query items) with a schema version field. On open:

1. Parse + validate.
2. Create a **new** `CountdownEvent` with a **new** UUID (do not reuse sender id — two stores, CloudKit-safe).
3. Save, reschedule notifications, reload widgets.
4. Navigate to the new event’s detail.

**UI:**

- Share action from detail (and optionally list context menu): system `ShareLink` / share sheet with the import URL (and optionally a plain-text fallback line for Messages).
- Receiving device: if Sleeps installed, open → import. If not, URL fails gracefully (App Store destination can be a later polish; not required for V2 MVP).
- Parental gate: only if the flow leaves the app to an external browser/store; in-app import stays ungated (same as opening a widget deep link).

**Non-goals for V2:**

- Live two-way sync / co-editing across Apple IDs (CloudKit sharing DB).
- User profiles, friend lists, or “shared family space.”
- Editing on device B updating device A automatically.

**Success criteria:** Different Apple ID, Messages or AirDrop, event appears with correct sleeps count and icon/color.

---

### Should — 4. Apple Watch app + complications

**Job:** When the kid asks “how many sleeps?”, the parent answers from the wrist without unlocking the phone. Same big-number language as the phone.

**Why this fits the usage model:** The Watch is usually on the **parent**, not the kid. That is still a kid-serving glance surface — faster than handing over a phone. A kid Watch on Family Setup is a bonus when it rides the paired parent iPhone’s data.

**Scope:**

- New **watchOS app** target (XcodeGen / `project.yml`) depending on `CountdownKit`.
- **Glance UI:** next upcoming event (or pinned, if config is cheap) — icon + huge sleeps numeral + short title; “TODAY!” when days == 0. Light, Big & Loud, readable at arm’s length.
- **Complications:** at least one family that shows the sleeps number (and ideally icon/title where space allows) for modular / circular / rectangular as practical in V2 — prefer shipping 1–2 solid complications over every slot half-done.
- **Data:** read the same countdowns as the paired iPhone. Prefer a simple sync path (e.g. WatchConnectivity snapshot / application context from the iOS app when the store changes, plus refresh on Watch foreground). Watch does **not** need its own CloudKit writer in V2.
- Day math stays `DaysUntil` on the Watch snapshot’s dates — calendar days, not seconds.

**Non-goals for V2:**

- Full add/edit/delete on Watch (create stays on iPhone/iPad).
- Independent Watch-only store that drifts from the phone.
- watchOS-only social or sharing flows.

**Success criteria:** Paired parent Watch shows the same sleeps count as the phone for the next (or pinned) event within a short time after a phone-side create/edit.

---

### Should — 5. Live Activity for last sleep / almost-there

**Job:** On the parent phone the kid borrows, make “tomorrow / tonight” impossible to miss — then go away.

**Scope:**

- Start a Live Activity when an upcoming event enters a narrow window: **1 sleep left**, and/or **timed event within 24h** (align with existing `CountdownPhase` ticking window).
- Show title, icon cue, sleeps or ticking state; tap opens detail.
- End on arrival / past / user dismiss.

**Constraints:**

- ActivityKit + Push (if any) must stay Kids-safe: local-only start/update preferred; no analytics.
- Do not run Live Activities for every event weeks out — that spams the parent phone.

**Non-goals:** Always-on Live Activities for all countdowns; Dynamic Island as primary brand surface over widgets.

---

### Should — 6. Recurring yearly events

**Job:** Birthdays and annual holidays without re-entering every year.

**Scope:**

- Add a defaulted CloudKit-safe field on `CountdownEvent`: `repeatsYearly: Bool = false` (must be defaulted, never `.unique`).
- When the event’s calendar day has passed and `repeatsYearly` is true, advance the stored date to the next future occurrence (pure helper in CountdownKit, unit-tested). Leap day rule: a Feb 29 event in a non-leap year lands on **Feb 28** (last day of February — predictable for kids/parents; tested).
- Advance runs on app launch / save paths that already touch the store (and before widget snapshot reads), so widgets/Siri/Watch see the next year without orphan “past” birthdays.
- Add/edit UI: simple toggle (“EVERY YEAR”) with big touch target.

**Non-goals:** Weekly/monthly recurrence, RRULE complexity, auto-archive of one-off past events (can stay as today).

---

### Could — 7. Richer arrival moment

**Job:** Bigger delight on the big day, especially on iPad.

**Scope:** Stronger “TODAY!” / “IT’S TIME!” presentation — scale confetti / layout for large screens; optional short haptics. Stay local; do not share the celebration socially. Watch can show a simple “TODAY!” state; full confetti stays on phone/iPad.

**Non-goals:** Mini-games, rewards economies, streaks/leaderboards (Kids + simplicity risk).

---

## Explicitly out of V2

- Accounts, social feeds, chat  
- Ads, IAP, tip jar, analytics  
- Full add/edit CRUD on Apple Watch  
- Full CloudKit CKShare multi-editor collaboration (revisit after share-import proves demand)  
- Localization as the main V2 bet (fine as a later slice)  
- Leaving Made for Kids  

---

## Architecture notes

- **CountdownKit** stays the home of pure logic: date math, import payload encode/decode, yearly advance, phase rules for Live Activity windows. Unit-test these; UI stays thin. Today `Package.swift` declares `.iOS(.v17)` and `.macOS(.v14)` only — **add `.watchOS`** (min version aligned with project, likely watchOS 10+) when the Watch target lands so the kit links cleanly.
- **Widgets / Live Activities** keep using `SharedStore` + App Group; day math remains `DaysUntil` (calendar days only). Live ticking stays detail/Live Activity only — list, standard widgets, and Watch glance stay day-granular (V1 rule).
- **Watch data path:** iPhone is source of truth; push snapshots to Watch on store changes. Do not give Watch a separate CloudKit write path in V2.
- **CloudKit schema:** only additive defaulted properties (e.g. `repeatsYearly`). No rename of `emoji`; no `.unique`.
- **Deep links:** keep `sleeps://event/<uuid>` for local navigation; add a distinct `sleeps://import…` (or equivalent) host/path for cross-device create. Do not overload `event` to mean import.
- **Kids compliance:** no new tracking SDKs; share uses system sheet; external URLs remain behind the existing parental gate in Settings.

## Suggested implementation order

1. Lock Screen + StandBy widgets (reuse widget pipeline)  
2. Large / iPad widget + light iPad layout pass  
3. Share import URL + share sheet + openURL handling  
4. Apple Watch app + complications (read-only glance + phone→Watch sync)  
5. Yearly repeat (model + advance helper + UI toggle)  
6. Live Activity last-sleep window  
7. Arrival polish  

Each step is shippable alone; 1–3 are the V2 spine; Watch is the next glance surface after phone/iPad widgets.

## Verification

- **Unit tests (CountdownKit):** import payload round-trip; yearly advance (including year boundary + leap day); any new phase helpers for Live Activity windows.  
- **Manual:** StandBy on a charging parent phone; Lock Screen widget; large widget on iPad; share from phone A → Messages → phone B / iPad on a **different** Apple ID; paired Watch shows updated sleeps after phone edit; Live Activity appears at 1 sleep and clears after the day; Made-for-Kids checklist unchanged (no accounts/ads/analytics).  
- **Regression:** existing `sleeps://event/<uuid>` widget taps; calendar-day math; CloudKit local fallback when iCloud unavailable.

## Success for V2

A parent can put Sleeps on a nightstand, iPad, or wrist where the answer is asked for, and can send a countdown to the other household device without creating an account — while the app still reads as one big number for a five-year-old.
