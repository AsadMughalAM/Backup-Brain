# TECH_STACK.md — Backup Brain (Flutter + Firebase)

> **Status:** Final for hackathon. Stack decision: **Firebase-only**.
> **Read together with:** `ARCHITECTURE.md` (what we build and why) and `DESIGN.md` (how it looks). Start at `CLAUDE.md` for the doc map.
> **Precedence:** technology, folders, data layout, rules → **this file wins**. Product behaviour, formulas, and feature specs → `ARCHITECTURE.md`. Token **values**, fonts, icons and component visuals → `DESIGN.md`.

## Contents

1. [Decision Summary](#1-decision-summary) · 2. [Stack](#2-stack) · 3. [How the Pieces Talk](#3-how-the-pieces-talk) · 4. [Firestore Data Layout](#4-firestore-data-layout) · 5. [Root Structure](#5-root-structure) · 6. [Design System Mechanics](#6-design-system-packagesbb_ui) · 7. [Structure Rules](#7-structure-rules) · 8. [Setup Commands](#8-setup-commands-summary--keep-readmemd-as-the-full-version) · 9. [Build Order](#9-build-order-maps-to-architecturemd-11)

---

## 1. Decision Summary

**We use Flutter + Firebase only.** Supabase is not used in the hackathon build.

Why:

1. **Offline is the top requirement.** Firestore's offline cache is on by default on Android and iOS, with automatic sync when the network returns. Load-shedding often takes down home Wi-Fi and mobile towers at the same time.
2. **The core features don't need a server at all.** F1 (backup time), F2 (what to turn off), F3 solar model, F5 (solar cost) and F6 (battery health) run in a pure Dart engine on the phone.
3. **Vector search exists in Firestore** (server-side, via Cloud Functions) if we ever need it for the assistant. Our assistant uses engine results, not document search, so it is optional anyway.
4. **Geo search is not a database problem for us.** Nearby repair shops come live from the Google Places API through a Cloud Function. If we later store our own shops, Firestore geohash queries are enough at our scale.
5. **One SDK, one security model, one console** = fastest hackathon velocity.

**Future escape hatch:** if the marketplace (F7) grows into vendors, inventory, orders and reviews, add Supabase/Postgres **for the marketplace only**, using Firebase Auth as its third-party login. Nothing else migrates. Record that decision in `docs/decisions/` when it happens.

---

## 2. Stack

### 2.1 Services

| Layer | Technology | Used for |
|---|---|---|
| Mobile app | **Flutter** (stable channel), Dart 3 | All UI, Android first, iOS second. A web build (`flutter run -d chrome`) exists as a **dev preview only**: offline behaviour and the airplane-mode check are verified on Android, never on web |
| State management | **Riverpod** (`flutter_riverpod` + `riverpod_annotation`) | Controllers, dependency injection |
| Navigation | **go_router** | Routes, deep links from notifications |
| Calculation engine | **Pure Dart package** `packages/energy_engine` | F1, F2, F3 model, F5, F6, F8 pattern |
| Design system | **Flutter package** `packages/bb_ui` (tokens, light/dark themes, reusable components) | Every screen — see Section 6 |
| Auth | **Firebase Auth** + `google_sign_in` | Sign-in required: Intro → Sign up / Login with **Google or email + password**, then Home. A new account gets the demo household (server-checked, never over existing data) until the setup form exists. Leftover anonymous accounts are linked on sign-up (same uid). Phone OTP later (needs Blaze) |
| Database | **Cloud Firestore** (offline persistence default) | User data, logs, catalog, config |
| Server logic | **Cloud Functions for Firebase (2nd gen), TypeScript, Node LTS** | AI proxy, Places proxy, admin jobs |
| Secrets | **Firebase / Google Secret Manager** via `defineSecret` | AI API key, Places API key |
| Push | **Firebase Cloud Messaging (FCM)** | Server-sent alerts (P1/P2) |
| Local alerts | **flutter_local_notifications** | Schedule-based outage alerts that fire offline |
| Weather | **Open-Meteo** (free, no key), called from the app | F3, F4 |
| Places | **Google Places API**, called only from Cloud Functions | F7 shop finder |
| AI | **Claude API**, called only from Cloud Functions | F9 assistant, advice text |
| Crash reporting | **Firebase Crashlytics** | Field stability |
| Analytics (optional) | **Firebase Analytics** | Demo funnel metrics |
| Local dev | **Firebase Local Emulator Suite** (Auth, Firestore, Functions) | Develop without touching production |

### 2.2 Flutter packages (use latest stable at setup; `pubspec.lock` is committed)

| Purpose | Package |
|---|---|
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`, `firebase_messaging`, `firebase_crashlytics`, `firebase_analytics` |
| State / DI | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` (dev) |
| Models | `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation`, `build_runner` (dev) |
| Routing | `go_router` |
| Network | `dio` (Open-Meteo) |
| Connectivity | `connectivity_plus` |
| Notifications | `flutter_local_notifications`, `timezone` |
| Location | `geolocator` |
| Charts | `fl_chart` (colors always from `EnergyColors` / chart tokens) |
| Icons | `phosphor_icons` — used only through `BbIcons` (see `DESIGN.md` §6) |
| Theme preference | `shared_preferences` (stores light/dark/system locally for instant start-up) |
| Illustrations | `flutter_svg` (empty states, onboarding) |
| Fonts | Bundled as assets in `bb_ui` — **not** downloaded at runtime (must work offline) |
| i18n | `flutter_localizations`, `intl` (ARB files via `gen_l10n`) |
| Lint | `flutter_lints` or `very_good_analysis` (pick one, enforce in CI) |
| Tests | `flutter_test`, `mocktail`, `fake_cloud_firestore` |

### 2.3 Cloud Functions packages

`firebase-functions`, `firebase-admin`, `@anthropic-ai/sdk`, `zod` (input validation). Dev: `typescript`, `eslint`, `vitest` (or `jest`).

### 2.4 Cost & plan

- Firebase project must be on the **Blaze (pay-as-you-go) plan** because Cloud Functions require it. The no-cost tier covers hackathon usage.
- **Set a budget alert** (e.g. USD 5) in Google Cloud Billing on day one.
- AI model name and max tokens live in Functions config, never hardcoded in multiple places.

---

## 3. How the Pieces Talk

```
┌────────────────────────── FLUTTER APP ───────────────────────────┐
│ presentation (screens, widgets)                                   │
│        │ watches                                                  │
│ controllers (Riverpod notifiers)                                  │
│        │ call                                     │ call           │
│ repositories ──────────────────────────┐   energy_engine (pure)   │
│   │            │            │          │   backup · loads · solar │
│ Firestore   Open-Meteo   Callable     Local    sizing · health    │
│ (cached)    (dio)        Functions    notifications              │
└───┼────────────┼────────────┼────────────────────────────────────┘
    │            │            │ HTTPS (Auth token attached)
    ▼            ▼            ▼
 Firestore   Open-Meteo   Cloud Functions (TypeScript)
                            ├─ assistantChat  ──► Claude API
                            ├─ findNearbyShops ─► Google Places API
                            └─ admin/seed jobs ─► Firestore (admin)
```

### 3.1 The AI assistant and the engine (important)

The calculation engine exists **only in Dart**. It is **never re-implemented in TypeScript.** The assistant gets engine numbers like this:

- **Phase 1 (hackathon): context snapshot.** Before calling `assistantChat`, the app runs the engine and sends a compact JSON snapshot: current backup time, top switch-off suggestions, today's solar forecast summary, battery health, next likely outage. The function puts this in the system prompt and the model explains it. The model is told it must not invent numbers outside the snapshot.
- **Phase 2: client-executed tools.** The function returns the model's tool requests to the app; the app runs the Dart engine and sends results back; the loop continues until the model answers. Same single engine, richer questions ("what if I turn off 2 fans?").

### 3.2 Callable Cloud Functions (replace the REST list in ARCHITECTURE.md §9)

| Function | Input | Output | Feature |
|---|---|---|---|
| `assistantChat` | `{messages[], snapshot, language}` | `{reply, toolRequests?}` | F9 |
| `findNearbyShops` | `{lat, lon, radiusM, kind: 'battery'\|'ups_repair'\|'solar_installer'}` | `{shops[]}` (name, address, distance, rating, mapsUrl) | F7 |
| `generateAdviceCards` *(P1)* | `{snapshot, language}` | `{cards[]}` | Dashboard |
| `seedCatalog` *(admin only)* | — | writes `batteryCatalog`, `config` | Setup |

Everything else (profile, appliances, outages, logs, catalog reads, config reads) is **direct Firestore access from the app**, protected by security rules.

---

## 4. Firestore Data Layout

```
users/{uid}
  ├─ profile fields: name, language ('en' | 'ur_Latn'), city, lat, lon, createdAt, demoMode
  ├─ systems/{systemId}                 // MVP: one system with id "main"
  │    ├─ fields: inverter{}, battery{}, solar{}?, hasSolar, updatedAt
  │    ├─ appliances/{applianceId}
  │    ├─ outages/{outageId}            // "Light gayi / aa gayi" events + SoC
  │    ├─ schedule/{slotId}             // user-entered area schedule
  │    ├─ solarLogs/{yyyy-MM-dd}        // actual vs expected kWh
  │    ├─ healthSnapshots/{snapshotId}
  │    └─ weatherCache/{yyyy-MM-dd}     // trimmed Open-Meteo hourly data
  └─ chats/{chatId}/messages/{msgId}    // optional, P1

batteryCatalog/{productId}              // read-only for clients
config/pricing_pk                       // panel/inverter/battery prices, tariff, lastUpdated
config/app                              // feature flags, minimum app version, AI enabled
```

Static, rarely changing reference data ships **inside the app** as assets: `assets/data/appliances_pk.json`, `assets/data/cities_psh.json`, `assets/data/equipment_pk.json` (setup's one-tap battery, inverter and panel sizes), plus the first copy of `pricing_pk.json` as an offline fallback.

### 4.1 Security rules (summary — full file in `firestore.rules`)

- `users/{uid}/**`: read/write only if `request.auth.uid == uid`.
- `batteryCatalog/**`, `config/**`: read for any signed-in user; **no client writes** (admin SDK / seed only).
- Validate types and required fields on writes for `systems`, `appliances`, `outages`.
- Deny everything else by default.

---

## 5. Root Structure

```
backup-brain/
├── CLAUDE.md                    # agent entry point: doc map + golden rules
├── ARCHITECTURE.md              # product spec (what & why)
├── TECH_STACK.md                # this file (how & where)
├── DESIGN.md                    # visual system: palette, fonts, icons, components, screens
├── README.md                    # overview + setup + run commands
├── tool/
│   └── check_design_tokens.sh   # CI guard: fails on raw colors / font sizes outside bb_ui
├── firebase.json                # Firebase CLI config (functions, firestore, emulators)
├── .firebaserc                  # project aliases: dev, prod
├── firestore.rules
├── firestore.indexes.json
├── firestore-tests/             # rules tests in the emulator: `pnpm install && pnpm test`
│
├── app/                         # Flutter application
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   ├── l10n.yaml
│   ├── assets/
│   │   ├── data/                # appliances_pk.json, cities_psh.json, pricing_pk.json (fallback)
│   │   ├── images/
│   │   └── icons/
│   ├── lib/
│   │   ├── main.dart            # calls bootstrap()
│   │   ├── bootstrap.dart       # Firebase init, emulator switch, Crashlytics, ProviderScope
│   │   ├── app/
│   │   │   ├── app.dart         # MaterialApp.router
│   │   │   ├── router.dart      # go_router routes
│   │   │   ├── theme_mode/      # ThemeModeController (system/light/dark), persisted locally
│   │   │   └── l10n/            # app_en.arb, app_ur_Latn.arb (Roman Urdu)
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   ├── overlays/        # single OverlayHost at app root: sheets, dialogs, toasts
│   │   │   ├── errors/          # Failure types, error mapping
│   │   │   ├── firebase/        # firestore paths, converters, providers for instances
│   │   │   ├── services/        # connectivity, notifications, location, clock
│   │   │   ├── utils/           # formatters (hours, PKR, kWh)
│   │   │   └── widgets/         # app-aware wrappers only (e.g. ConnectedOfflineBanner reading
│   │   │                        #   connectivity); pure visual components live in bb_ui
│   │   └── features/
│   │       ├── onboarding/      # setup flow
│   │       ├── dashboard/       # home screen, advice cards
│   │       ├── backup/          # F1 countdown
│   │       ├── loads/           # F2 appliances + switch-off planner
│   │       ├── solar/           # F3 forecast, F4 performance
│   │       ├── estimator/       # F5 solar cost & sizing
│   │       ├── battery/         # F6 health, F7 diagnose/recommend/shops
│   │       ├── outages/         # F8 logging, schedule, readiness, local alerts
│   │       ├── assistant/       # F9 chat
│   │       └── settings/        # language, demo mode, account
│   └── test/                    # mirrors lib/ structure
│
├── packages/
│   ├── bb_ui/                # DESIGN SYSTEM — Flutter only; no Riverpod, Firebase, l10n
│   │   ├── pubspec.yaml         # declares bundled fonts
│   │   ├── assets/fonts/        # Geist (see DESIGN.md §3); Urdu-script font later
│   │   ├── lib/
│   │   │   ├── bb_ui.dart                    # public exports only (no primitives exported)
│   │   │   └── src/
│   │   │       ├── foundations/
│   │   │       │   ├── primitives/              # LAYER 1 — raw values, package-private
│   │   │       │   │   ├── color_primitives.dart    # tonal scales: canvas, navy, yellow, status
│   │   │       │   │   └── font_primitives.dart     # families, weights
│   │   │       │   ├── icons.dart               # BbIcons — semantic Phosphor registry
│   │   │       │   ├── tokens/                  # scales used everywhere
│   │   │       │   │   ├── spacing.dart             # 4-pt grid
│   │   │       │   │   ├── radius.dart
│   │   │       │   │   ├── elevation.dart
│   │   │       │   │   ├── motion.dart              # durations + curves
│   │   │       │   │   ├── sizes.dart               # icon sizes, touch targets
│   │   │       │   │   ├── opacity.dart
│   │   │       │   │   └── breakpoints.dart
│   │   │       │   └── semantic/                # LAYER 2 — meaning, per theme
│   │   │       │       ├── app_colors.dart          # ThemeExtension: surfaces, text, status
│   │   │       │       ├── energy_colors.dart       # ThemeExtension: solar/grid/battery/load
│   │   │       │       ├── palettes_light.dart      # light values for both extensions
│   │   │       │       ├── palettes_dark.dart       # dark values for both extensions
│   │   │       │       └── app_typography.dart      # text roles + metric (tabular) styles
│   │   │       ├── theme/
│   │   │       │   ├── app_theme.dart           # AppTheme.light() / AppTheme.dark() → ThemeData
│   │   │       │   ├── color_scheme_builder.dart # maps AppColors → Material ColorScheme
│   │   │       │   ├── component_themes.dart    # buttons, cards, inputs, chips, nav bar, dialogs
│   │   │       │   └── context_extensions.dart  # context.colors / .energy / .text / .space
│   │   │       ├── components/                  # LAYER 3 — reusable widgets, prefix "Bb"
│   │   │       │   ├── buttons/                 # BbButton (primary/secondary/ghost/danger), BbIconButton
│   │   │       │   ├── inputs/                  # BbTextField, BbNumberField (unit suffix), BbSwitch,
│   │   │       │   │                            #   BbSegmentedControl, BbSlider, BbDropdown
│   │   │       │   ├── surfaces/                # BbCard, BbSection, BbBottomSheet, BbDialog
│   │   │       │   ├── feedback/                # BbBanner (info/success/warning/danger),
│   │   │       │   │                            #   BbOfflineBanner, BbEmptyState, BbErrorState,
│   │   │       │   │                            #   BbSkeleton, BbSpinner, BbToast,
│   │   │       │   │                            #   BbTypingIndicator
│   │   │       │   ├── data_display/            # BbStatTile, BbMetric, BbBadge, BbChip,
│   │   │       │   │                            #   BbListTile, BbProgressBar
│   │   │       │   ├── navigation/              # BbScaffold, BbAppBar, BbNavBar, BbTabs
│   │   │       │   ├── layout/                  # BbGap, BbResponsive, BbPagePadding
│   │   │       │   └── energy/                  # domain visuals (still dumb):
│   │   │       │                                #   BbBatteryGauge, BbCountdownRing,
│   │   │       │                                #   BbPowerFlow, BbGridStatusPill,
│   │   │       │                                #   BbLoadToggleTile, BbPriorityBadge,
│   │   │       │                                #   BbSolarForecastStrip, BbHealthIndicator
│   │   │       └── utils/
│   │   │           └── contrast.dart            # contrastRatio(a, b) used by tests
│   │   ├── test/
│   │   │   ├── contrast_test.dart               # every text/bg pair, light + dark
│   │   │   ├── theme_parity_test.dart           # light & dark define the same tokens
│   │   │   └── goldens/                         # each component × light/dark × text scale
│   │   └── example/                             # Component Gallery app with theme toggle
│   │
│   └── energy_engine/           # PURE DART — no Flutter, no Firebase imports
│       ├── pubspec.yaml
│       ├── lib/
│       │   ├── energy_engine.dart          # public exports only
│       │   └── src/
│       │       ├── models/                 # BatterySpec, ApplianceLoad, SolarSpec, HourlyWeather...
│       │       ├── backup_calculator.dart  # F1
│       │       ├── load_planner.dart       # F2
│       │       ├── solar_model.dart        # F3 + F4
│       │       ├── solar_sizing.dart       # F5
│       │       ├── battery_health.dart     # F6
│       │       ├── battery_diagnosis.dart  # F7 repair-vs-replace rules
│       │       ├── outage_pattern.dart     # F8
│       │       └── defaults.dart           # chemistry limits, efficiencies, PR
│       └── test/                           # one test file per calculator
│
├── functions/                   # Cloud Functions (TypeScript)
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       ├── index.ts             # exports only — no logic here
│       ├── assistant/           # assistantChat, prompt builder, snapshot schema
│       ├── places/              # findNearbyShops, Places client, response mapper
│       ├── admin/               # seedCatalog and other admin-only jobs
│       └── shared/              # auth guard, zod schemas, error helpers, config
│
├── seed/                        # data loaded into Firestore by seedCatalog
│   ├── battery_catalog_pk.json
│   └── pricing_pk.json
│
└── docs/
    ├── decisions/               # short ADRs: 0001-firebase-only.md, ...
    └── demo-script.md
```

### 5.1 Inside every feature folder

```
features/<feature>/
├── data/
│   ├── models/          # Firestore/JSON DTOs (freezed + json_serializable)
│   ├── sources/         # raw access: Firestore refs, dio calls, callable functions
│   └── <feature>_repository_impl.dart
├── domain/
│   ├── entities/        # app-level objects used by UI (may reuse energy_engine models)
│   └── <feature>_repository.dart     # abstract interface
└── presentation/
    ├── controllers/     # Riverpod notifiers / providers
    ├── screens/         # one file per route
    └── widgets/         # widgets used only by this feature
```

A small feature may skip `domain/entities/` if the engine models are enough. It may **not** skip the repository interface.

---

## 6. Design System (`packages/bb_ui`)

The design system is a separate package (`bb_ui`; `Bb` = Backup Brain) so that every screen is built from the same tokens and components, light and dark mode work everywhere automatically, and `DESIGN.md` can change the look by editing **values in one place** without touching feature code.

### 6.1 Relationship with DESIGN.md

| This file (TECH_STACK.md) owns | DESIGN.md owns |
|---|---|
| Token **names**, layers, file locations | Final token **values** (hex, sizes, fonts) |
| Theme mechanics (ThemeData, extensions, light/dark switch) | Screen layouts, illustrations, icon style |
| Component list, APIs and rules | Component visual details (shape, density) |
| — | Palette, fonts, icon set, loading/empty states |

**Contract:** DESIGN.md may change any value, but may not rename or remove a token without updating this section. Adding a token always means adding **both** a light and a dark value and a contrast-test entry.

### 6.2 Three token layers

```
LAYER 1  primitives   yellow500 = #FFC21A        ← raw values, NEVER used by widgets
            │
LAYER 2  semantic     colors.primary, energy.solar, colors.textMuted
            │          (different value in light vs dark)
            │
LAYER 3  components   BbButton, BbCard, BbBatteryGauge  ← read semantic tokens only
            │
         features     screens compose Bb components; no raw styling
```

Why: to change "the brand yellow" or "how dark mode looks", you edit layer 1 or 2 only. Nothing in `app/` changes.

### 6.3 Theme mechanics (Flutter)

- `AppTheme.light()` and `AppTheme.dark()` return complete `ThemeData` with `useMaterial3: true`.
- Material's `ColorScheme` is **built from our semantic `AppColors`** (`color_scheme_builder.dart`), so stock Material widgets (dialogs, date pickers, snackbars) also match our theme.
- Domain colors that Material has no slot for live in **`ThemeExtension`s**: `AppColors` (status, surfaces, text levels) and `EnergyColors` (solar, grid, battery states, load, chart series). Both implement `copyWith` and `lerp` so theme switching animates smoothly.
- Typography lives in `AppTypography` (also a `ThemeExtension`) plus Material `TextTheme`.
- Access from widgets only through context extensions:
  ```dart
  context.colors.textPrimary     // AppColors
  context.energy.solar           // EnergyColors
  context.text.metricLarge       // AppTypography
  AppSpacing.lg                  // static tokens (theme-independent)
  ```
- **Theme mode:** `ThemeModeController` in `app/lib/app/theme_mode/` holds `ThemeMode.system | light | dark`, default `system`, saved in `shared_preferences` (local, so the correct theme shows on the very first frame, even offline). The toggle is in Settings, with a quick toggle on the Dashboard app bar.
- `MaterialApp.router(theme: AppTheme.light(), darkTheme: AppTheme.dark(), themeMode: ...)`.

### 6.4 Colors

All color meaning, palette values, semantic tokens (`AppColors`, `EnergyColors`), the Material `ColorScheme` mapping and the contrast audit live in **`DESIGN.md` §2**. Summary: Canvas neutrals (60%) · Ink Navy (30%, text, structure, grid) · Spark Yellow (10%, the one CTA, solar). Green/orange/red are for battery and safety status only, and never appear without an icon + text.

### 6.5 Other tokens

| Token file | Values (full spec: `DESIGN.md` §4–§7) | Rule |
|---|---|---|
| `spacing.dart` | `xxs 2 · xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32 · xxxl 48 · xxxxl 64` | 4-pt grid; screen side padding = `lg` |
| `radius.dart` | `xs 4 · sm 8 · md 12 · lg 16 · xl 24 · pill 999` | Cards `lg`, buttons/inputs `md`, chips `pill` |
| `elevation.dart` | `level0..level3` | Light: soft navy shadows; dark: lighter surface instead of shadow. Containers are separated by surface color + shadow, never borders |
| `motion.dart` | `fast 150ms · normal 250ms · slow 400ms · skeletonPulse 1200ms`, curve `easeOutCubic` | Respect `MediaQuery.disableAnimations` |
| `sizes.dart` | icons `16 · 20 · 24 · 32 · 48`; `minTouchTarget 48` | Every tappable ≥ 48×48 dp |
| `opacity.dart` | `disabled 0.38 · pressed 0.12 · hover 0.08` | Same as Material states |
| `breakpoints.dart` | `compact < 600 · medium 600–840 · expanded > 840` | Phone first; tablets get 2 columns |

### 6.6 Typography

- **Fonts:** Geist for all text and numbers (live numbers use tabular figures), bundled in `bb_ui/assets/fonts/` so they work offline. Never `google_fonts`. Full type scale and weights: **`DESIGN.md` §3**.
- **Roles:** Material `TextTheme` roles plus our metric styles (`metricHero`, `metricLarge`, `metricMedium`, `metricSmall`, `metricCaption`) in `AppTypography`.
- **Tabular figures** (`FontFeature.tabularFigures()`) on all live numbers so the countdown doesn't jitter as digits change.
- Layouts must work at system text scale **1.0 and 1.5** without overflow (older users enlarge text).

### 6.7 Component rules

1. **Prefix `Bb`** for every design-system widget (avoids clashes with Material names).
2. **Dumb components:** no Riverpod, no Firebase, no `go_router`, no l10n inside `bb_ui`. Text, values and callbacks come in as parameters.
3. **Variants, not colors:** components accept `variant` enums (`BbButtonVariant.primary`, `BbBannerTone.warning`), never a raw `Color` parameter. Exception: chart widgets may accept a series token from `EnergyColors`.
4. **States built in:** each interactive component handles enabled, disabled, pressed, focused and loading itself.
5. **Accessibility built in:** semantic labels, ≥ 48 dp targets, works with screen readers and large text.
6. **Rule of two:** a widget starts in `features/<x>/presentation/widgets/`. When a second feature needs it, it moves to `bb_ui` (and becomes dumb if it wasn't).
7. **Every new component** gets: a Gallery entry in `example/`, golden tests in light + dark at text scale 1.0 and 1.5, and a short doc comment with a usage example.
8. Feature code may **compose** components but must not restyle them with `copyWith` on colors or text styles. If a style is missing, add a variant to the component.

### 6.8 Guardrails (keep the system reliable)

- `tool/check_design_tokens.sh` runs in CI and fails if any file **outside** `packages/bb_ui/lib/src/foundations/` and `packages/bb_ui/lib/src/theme/` contains `Color(0x`, `Colors.`, `fontSize:` or `TextStyle(` constructors (plus the icon/spinner/font checks in `DESIGN.md` §14.3). `theme/` is exempt because the `ColorScheme` mapping needs `Colors.transparent` (DESIGN §2.6). Match whole identifiers (`\bColors\.`, `\bIcons\.`) so `AppColors.`, `EnergyColors.` and `BbIcons.` don't trip the check.
- `theme_parity_test.dart` fails if light and dark palettes don't define the same set of tokens.
- `contrast_test.dart` checks every text/background pair in both themes against the WCAG thresholds in `DESIGN.md` §2.8.
- Golden tests catch accidental visual changes; update goldens only on purpose.
- The Gallery app (`packages/bb_ui/example`) is the single place to review components in both themes before using them in screens.

---

## 7. Structure Rules

### 7.1 Dependency direction (strict)

```
presentation ──► controllers ──► repository (interface) ──► repository_impl ──► sources
     │                │
     │                └────────► energy_engine   (pure Dart)
     │
     └─────────────────────────► bb_ui        (tokens, themes, Bb components)

bb_ui and energy_engine never import each other or anything from app/.
```

1. **Screens and widgets never touch Firestore, dio, or Cloud Functions.** They only read providers.
2. **Controllers** combine repository data with engine calculations. Business decisions live here or in the engine, never in widgets.
3. **Repositories** are the only place that knows Firestore paths, JSON shapes, or API URLs.
4. **`energy_engine` imports nothing from the app**, nothing from Flutter, nothing from Firebase. Input: plain Dart objects. Output: plain Dart objects. No `DateTime.now()` inside — the current time is passed in.
5. **Features don't import each other's `data/` or `presentation/`.** If two features need the same thing, move it to `core/` or expose it through a provider in the owning feature's `domain/`.
6. **Screens are built from `bb_ui` components** and read styling only through `context.colors`, `context.energy`, `context.text` and `AppSpacing`/`AppRadius` tokens (Section 6).
7. `functions/src/index.ts` only re-exports. Each function lives in its own folder with its own input schema.
8. **Overlays** (bottom sheets, dialogs, toasts) open only through the single `OverlayHost` in `core/overlays/`, mounted at the app root. Screens never keep their own open/close state. Every modal traps focus, closes on Escape / back / scrim tap, and has an accessible title.

### 7.2 Offline rules

1. F1, F2, F5 and the F3 model **must work in airplane mode** after onboarding. Test this before every demo.
2. Read with listeners (`snapshots()`) so cached data shows instantly; show an `OfflineBanner` from `connectivity_plus`, never a blocking spinner.
3. **No Firestore transactions in offline paths** — transactions require a server round-trip. Use plain `set`/`update` and let Firestore queue them.
4. Don't `await` writes in the UI when offline; write and continue (the local cache updates immediately).
5. Weather: fetch Open-Meteo when online, save a trimmed copy to `weatherCache`, and use the latest cache when offline. Show the forecast's age ("updated 3 h ago").
6. Pricing: use `config/pricing_pk` from Firestore when available, otherwise the bundled `assets/data/pricing_pk.json`.
7. Outage alerts from the user's schedule and learned pattern are **local notifications scheduled on the device**, so they fire without internet. FCM is only for server-originated messages.
8. Features that truly need the network (F9 assistant, F7 shops) show a clear "needs internet" state, never a crash.

### 7.3 Data & Firestore rules

1. All Firestore paths come from one file: `core/firebase/firestore_paths.dart`. No string paths anywhere else.
2. Use `withConverter` with freezed models for every collection.
3. Field names are `camelCase`; document IDs for dated logs are `yyyy-MM-dd`.
4. Every document has `createdAt` / `updatedAt` (server timestamps).
5. Never store derived values that the engine can recompute (e.g. backup hours). Store inputs and events; compute outputs.
6. Queries on growing collections (`outages`, `solarLogs`, `healthSnapshots`) always use `orderBy` + `limit`.
7. Any new query that needs an index → add it to `firestore.indexes.json` in the same PR.

### 7.4 Security & secrets

1. The app contains **no secret keys**. Only the public Firebase config generated by FlutterFire.
2. Claude and Places API keys live in Secret Manager and are read with `defineSecret` in Functions.
3. Every callable function checks `request.auth` and validates input with `zod`. Reject unauthenticated calls.
4. Rate-limit `assistantChat` per user (e.g. a counter document per day) to protect the AI budget.
5. Firestore rules are deny-by-default and tested in the emulator before deploy.

### 7.5 Engine rules

1. One calculator per file, one test file per calculator.
2. Every public function has tests for: normal case, zero load, SoC at/below minimum, lead-acid vs. LiFePO4, and an invalid input.
3. Default constants (efficiencies, minimum SoC, performance ratio) live only in `defaults.dart` and can be overridden by inputs.
4. Return ranges or a confidence value for forecasts and cost estimates (per ARCHITECTURE.md principle "Honest uncertainty").

### 7.6 AI rules

1. The model only explains numbers given to it in the snapshot or tool results. The system prompt states this explicitly.
2. Language follows the user setting (`en` or Roman Urdu `ur_Latn`).
3. Safety text is fixed, not generated: battery swelling, burning smell or heat → disconnect and call a technician.
4. If the AI call fails, the app shows template text built from the snapshot. The dashboard never depends on the AI being up.

### 7.7 Naming & code style

| Thing | Convention | Example |
|---|---|---|
| Dart files | `snake_case.dart` | `backup_calculator.dart` |
| Classes | `PascalCase` | `BackupCalculator` |
| Providers | `camelCase` + `Provider` | `backupEstimateProvider` |
| Screens | `<Name>Screen` | `LoadPlannerScreen` |
| Firestore collections | `camelCase` plural | `solarLogs` |
| Functions (TS) | `camelCase` verbs | `findNearbyShops` |
| Branches | `feat/<feature>-<short>`, `fix/...` | `feat/backup-countdown` |

- No hardcoded user-facing strings — everything goes through ARB files.
- No hardcoded colors, font sizes, spacing or radii in widgets — use `bb_ui` tokens (enforced by `tool/check_design_tokens.sh`).
- Design-system widgets use the `Bb` prefix (`BbButton`, `BbBatteryGauge`).
- Generated files (`*.g.dart`, `*.freezed.dart`) are committed so teammates can run without `build_runner` (team may change this; decide once).

### 7.8 Environments

| Environment | Firebase project alias | Used for |
|---|---|---|
| Local | Emulator Suite | Daily development; `bootstrap.dart` switches to emulators when `USE_EMULATORS=true` (`--dart-define`) |
| dev | `backup-brain-dev` | Team testing on devices |
| prod | `backup-brain-prod` | Demo build |

**Region:** Firestore lives in `asia-south1` (Mumbai, closest to Pakistan) in every project. Deploy Cloud Functions to the same region. A Firestore location can never be changed, so pick it when creating the database.

Demo Mode (from ARCHITECTURE.md) is a **user setting**, not an environment: it swaps the data source to `SimulatedSource` so the demo never depends on live hardware or real outages.

### 7.9 Definition of done (every feature)

- [ ] Engine logic has passing tests
- [ ] Works in airplane mode (or shows a clear "needs internet" state if it's F7/F9)
- [ ] English and Roman Urdu strings added
- [ ] Firestore rules and indexes updated if new data was added
- [ ] No secrets, no hardcoded strings/paths/colors
- [ ] Screens use only `bb_ui` components/tokens; token check passes
- [ ] Checked in **light and dark** mode and at text scale 1.5
- [ ] Any new component has Gallery entry + goldens (light/dark)
- [ ] Tested on a real Android device

---

## 8. Setup Commands (summary — keep README.md as the full version)

```bash
# one-time (pnpm only — never npm/npx/yarn)
pnpm add -g firebase-tools
dart pub global activate flutterfire_cli
firebase login

# app
cd app
flutterfire configure            # generates firebase_options.dart
flutter pub get
dart run build_runner build -d
flutter run --dart-define=USE_EMULATORS=true

# engine tests
cd packages/energy_engine && dart test

# design system: tests, goldens, gallery
cd packages/bb_ui && flutter test
cd packages/bb_ui/example && flutter run
bash tool/check_design_tokens.sh

# functions
cd functions && pnpm install && pnpm run build
firebase emulators:start         # from repo root
firebase deploy --only functions,firestore:rules,firestore:indexes
```

---

## 9. Build Order (maps to ARCHITECTURE.md §11)

1. Repo skeleton, Firebase projects (Blaze + budget alert), emulators, `bootstrap.dart`, anonymous auth.
2. `bb_ui` foundations: primitives, semantic light/dark palettes, `AppTheme`, context extensions, contrast + parity tests, Gallery app, theme-mode toggle. Then the first components: `BbScaffold`, `BbButton`, `BbCard`, `BbStatTile`, `BbBanner`, `BbCountdownRing`.
3. `energy_engine`: `backup_calculator` + `load_planner` with tests.
4. Onboarding → Firestore `systems/main` + `appliances`.
5. Dashboard countdown (F1) + Load Planner (F2). **Verify airplane mode.**
6. Open-Meteo source + `solar_model` + Solar screen (F3).
7. `solar_sizing` + Estimator screen (F5) with bundled pricing fallback.
8. `assistantChat` function (snapshot mode) + chat screen (F9).
9. Outage logging + local notifications + `outage_pattern` (F8), `battery_health` (F6).
10. `seedCatalog`, battery recommendations, `findNearbyShops` (F7), F4 performance.
11. Roman Urdu pass, Demo Mode data, Crashlytics check, demo rehearsal on a real device.
