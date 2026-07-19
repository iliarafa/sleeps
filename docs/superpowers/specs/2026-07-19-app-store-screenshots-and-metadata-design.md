# App Store Screenshots + Listing Metadata

## Context

All of Sleeps' code is done. What stands between the repo and a submission is the
App Store Connect record, which is owner-side, and the screenshot + metadata
assets, which are not. This spec covers the assets.

The audience for an App Store listing is **the parent**, not the kid. The kid
never sees it. Every decision below follows from that: the screenshots show the
kid-facing joy, but the captions and the description argue to an adult deciding
in about three seconds whether this app is safe to hand over.

**Decisions made with the user:**

- **Treatment:** captioned marketing shots, not raw captures. A raw screen can't
  explain widgets or the privacy story.
- **Set size:** six shots, not the permitted ten. Only the first two or three get
  looked at; padding dilutes and costs work.
- **Siri is excluded from the initial set** — see "The Siri question" below.
- **Device classes:** 6.9" iPhone and 13" iPad only.

## Deliverables

```
docs/art/store-shots.html                    layout source (reviewable in a browser)
docs/store/iphone-69/01..06.png              1320 × 2868, RGB, no alpha
docs/store/ipad-13/01..06.png                2064 × 2752, RGB, no alpha
docs/store/metadata.md                       copy for paste into App Store Connect
```

Screenshots are a build artifact, but they get committed: they must be
regenerable *and* diffable when the UI changes for v1.1.

## The six shots

| # | Screen | Caption | Slab | Type |
|---|---|---|---|---|
| 1 | Countdown list | HOW MANY SLEEPS UNTIL THE FUN STUFF? | `#FFFCF2` paper | ink |
| 2 | Detail, big number (Summer Camp, 3) | ONE BIG NUMBER. NOTHING ELSE. | `#00A878` green | white |
| 3 | Detail, TODAY! + confetti (birthday) | THE BIG DAY GETS CONFETTI. | `#FF4D8D` pink | white |
| 4 | Widgets on the home screen | RIGHT THERE ON THE HOME SCREEN. | `#2D6CDF` blue | white |
| 5 | Add sheet — calendar + icon picker | PICK A DAY. PICK A PICTURE. | `#FFB800` sun | ink |
| 6 | Parent shot | NO ADS. NO ACCOUNTS. NOTHING COLLECTED. | `#191919` ink | paper |

Three properties of this set are deliberate:

**Slab color matches the event on screen.** Summer Camp is green, the birthday is
pink, Greece is blue — values taken from `EventColor`, not eyeballed. Scrolled as
a row in the App Store, the set reads as the app's own list view.

**Shot 6 is the only dark one.** It is the only shot addressed to the adult, and
the register change signals that before a word is read. Its copy is lifted
verbatim from the privacy page so site, store, and description agree.

**The existing seed data already produces shots 1–4.** `-seedSampleData` seeds My
Birthday at 0 days (pink), Summer Camp at 3 (green), Trip to Greece at 18 (blue),
Christmas at 164 (red). No content invention required; the screenshots show the
real app with its real sample content.

## Frame template

The marketing canvas uses the app's own `loudBox` language rather than a generic
template — flat saturated slab, 3pt ink outline, hard offset ink shadow,
`AvenirNext-Heavy` uppercase.

- Caption occupies roughly the top quarter, one line of thought, tight leading.
  One line only: the app shows one big thing per screen and the listing should too.
- The capture sits below, framed as a loud box, bleeding off the bottom edge.
- Ink `#191919`, paper `#FFFCF2`, sun `#FFB800` — from `LoudTheme`.
- iPad reuses the same captions with a shorter caption block, since 2064 × 2752 is
  a squatter canvas than 1320 × 2868.

Exact proportions are tuned empirically at composite time against a real capture,
not specified here — the only hard constraints are the canvas dimensions.

**Two shots need per-device treatment on iPad, not a re-crop of the iPhone image:**

- **Shot 4 (widgets)** requires placing widgets on an *iPad* home screen; the
  iPhone capture cannot be reused, since the iPad home screen grid and widget
  proportions differ. This doubles the one manual step.
- **Shot 5 (add sheet)** presents as a form sheet on iPad rather than a full-height
  sheet, so the composition differs. Captured natively and framed to suit.

The other four shots are the same screens captured natively at iPad size.

## Pipeline

### 1. Code changes (all DEBUG-only)

Three small changes, each reusing machinery the app already ships:

1. **Deterministic UUIDs in the seeder.** `CountdownEvent` currently gets a random
   id, so nothing can address a specific event. Fixed ids let the shipped
   `sleeps://event/<uuid>` deep link drive shots 2 and 3 through `simctl openurl`,
   adding no navigation code.
2. **`-screenshotAddSheet` launch argument** opens the add sheet over the list with
   a pre-filled draft, so shot 5 shows a populated calendar and a selected icon
   rather than an empty form. Mirrors the existing `-seedSampleData` pattern. This
   is the only genuinely new code.
3. **Anchor Christmas to the real Dec 25.** The seeder hardcodes `+164 days`, which
   was Dec 25 when written on 2026-07-14 and reads Dec 30 today. A correctness fix
   that happens to matter for screenshots.

None of this ships in a Release build.

### 2. Capture

Simulator UDIDs are **pinned**, because two of each device exist and the handoff
already documents containers landing on the wrong one.

- iPhone 17 Pro Max → `0A290AC8-DB60-4CA6-847A-121DAB1208B3` → native 1320 × 2868
- iPad Pro 13-inch (M5) → `BD72DAAA-5CFD-43A8-917A-1107CE387CA5` → native 2064 × 2752

Status bar overridden to 9:41, full battery, full bars via `simctl status_bar`.
Captures taken with `simctl io screenshot` at native size — no scaling, so the
composite is pixel-exact.

**Shot 4 is a manual step.** Widgets have to be placed on a simulator home screen
by hand; nothing automates it. Done once, captured, and the raw capture committed
so it never has to be repeated unless the widget design changes.

### 3. Composite

A `docs/art/store-shots.html` lays out each frame in CSS at exact canvas size,
rendered per-shot by headless Chrome — the same toolchain already used for the
event icons. `AvenirNext` is a macOS system font, so captions render in the real
typeface. The whole set is reviewable in a browser before anything is uploaded.

### 4. Verify

A check script asserts, for every output file:

- exact pixel dimensions for its device class
- RGB color space
- **no alpha channel** — App Store Connect hard-rejects PNGs carrying one, and
  Chrome emits an alpha channel even against an opaque background
- at most 10 files per class

Alpha is flattened with CoreGraphics, not `sips`, per the existing handoff warning
that `sips` silently mangles images.

## Store metadata

| Field | Value |
|---|---|
| **Name** | `Sleeps: Kids Countdown` |
| **Subtitle** | `How long until the fun stuff?` |
| **Keywords** | `days until,birthday,holiday,vacation,children,family,calendar,widget,christmas,trip,school,advent` |
| **Support URL** | `https://iliarafa.github.io/sleeps/support.html` |
| **Privacy URL** | `https://iliarafa.github.io/sleeps/privacy.html` |
| **Privacy label** | Data Not Collected |
| **Age rating** | 4+, Made for Kids, ages 6–8 |

**The store Name and the bundle display name are separate fields.** Listing as
"Sleeps: Kids Countdown" buys search visibility — "Sleeps" alone is nearly
unfindable — while `CFBundleDisplayName` stays `Sleeps`, leaving the home screen
icon and the Siri phrase (`.applicationName`) untouched. Discoverability without
breaking *"…in Sleeps."*

Keywords deliberately omit *countdown* and *sleeps*: Apple indexes the name and
subtitle separately, so repeating them wastes characters.

### Promotional text

> Big numbers, bright colors, zero fuss. Sleeps counts down to the day your kid
> can't stop asking about — right on the home screen.

### Description

> **How many sleeps until the fun stuff?**
>
> Kids don't think in dates. They think in sleeps. Sleeps turns "when is my
> birthday?" into one enormous number a five-year-old can read across the room —
> and then counts it down, one sleep at a time, until the day arrives with confetti.
>
> **MADE FOR SMALL HANDS**
> • One huge number per countdown. No menus to learn, no settings to hunt for.
> • 24 built-in pictures — a cake, a tent, a plane, a Christmas tree — so a kid who
>   can't read yet still knows which countdown is theirs.
> • Bright, chunky cards in seven colors they pick themselves.
> • When the day finally arrives: TODAY!, and confetti.
>
> **ON THE HOME SCREEN**
> Add a widget and the number is simply there, every time the phone lights up. No
> opening the app, no asking. Small and medium sizes.
>
> **ASK OUT LOUD**
> "Hey Siri, how many sleeps until Summer Camp in Sleeps?"
>
> **GENTLE REMINDERS**
> Optional nudges a week out, three days out, the day before, and on the morning
> itself.
>
> **ON ALL YOUR DEVICES**
> Countdowns sync privately through your own iCloud account, so what you add on the
> iPhone turns up on the iPad.
>
> **MADE FOR KIDS, AND BUILT LIKE IT**
> No ads. No in-app purchases. No accounts. No analytics, no trackers, no
> third-party SDKs. Sleeps collects nothing about you or your child — countdowns
> live on the device and sync privately through your own iCloud account, which even
> we can't see. There is nothing in this app to buy and no way to reach the internet
> from inside it.

Wording checked against the code: seven colors matches `EventColor`, 24 pictures
matches the imagesets, small + medium matches the widget families, and the 7/3/1 +
day-of reminder schedule matches `NotificationPlanner`. The icons are described as
"built-in" rather than "hand-drawn" because they are generated SVG art.

## The Siri question

Siri is the app's most distinctive feature and the reason the name is one short
word. It is excluded from the launch screenshot set anyway.

The code is sound — phrases include `.applicationName` as Apple requires, and
`CountdownEventQuery` implements all three `EntityStringQuery` methods. What can't
be verified from a simulator is the environmental half: whether Siri indexes the
`AppShortcutsProvider` phrases, and whether its transcription of a spoken event
title survives `localizedCaseInsensitiveContains`. Third-party App Shortcut
phrases are genuinely finicky and often need a launch, sometimes a reboot, before
the index updates.

There is a second reason. `SharedStore.hasAppGroup` tests
`containerURL(forSecurityApplicationGroupIdentifier:)`, which per the handoff only
resolves under a real Apple Development signature. In the simulator both the app
and the intent fall back to the same local file and therefore agree — which means
the simulator cannot demonstrate they agree *on device*, where entitlements are
evaluated for real. Because the intent lives in the app target rather than an
extension it should share the app's process and entitlements, so this is expected
to work; "expected" is doing real work in that sentence.

App Review rejection is a real but modest risk — reviewers do not reliably test
Siri phrases, though Made for Kids draws extra scrutiny and a Siri screenshot
invites a test. The likelier cost is a parent who bought in on that screenshot and
finds the phrase doesn't catch.

**Resolution:** Siri stays in the description text, where a feature claim is
normal, and out of the screenshots, where it is a demonstration. One utterance on
a real device —*"How many sleeps until Summer Camp in Sleeps?"* — clears the whole
chain including the App Group question. If it lands, Siri is promoted to a seventh
shot on a sun-yellow slab, caption **JUST ASK SIRI.** The pipeline makes adding one
shot cheap, so deferring costs nothing.

## Open questions

1. **Primary category.** The handoff says "Made for Kids, 6–8", but that is an age
   band, not a category. Education is defensible; Lifestyle is arguably more
   honest. Owner's call.
2. **"Free, and it stays free."** Considered as a description closer and left out:
   it is a commitment about future monetization that only the owner can make.

## Out of scope

App Store Connect record creation, the archive/TestFlight/submission flow, and the
on-device verification list — all owner-side. Localized screenshots (English only
for v1). The 1024 × 500 App Store promotional artwork, which is only required for
featuring consideration.
