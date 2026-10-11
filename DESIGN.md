# DESIGN.md — Backup Brain Design System

> **Status:** v2 (2026-10-11): warm canvas, midnight hero, Geist-only numbers, softer shape. The single source of truth for every visual value (colors, fonts, spacing, icons, component visuals). `TECH_STACK.md` §6 only defines token *names* and theme mechanics.
> **Read together with:** `TECH_STACK.md` §6 (token *names*, layers, theme mechanics) and `ARCHITECTURE.md` §10 (screens). Start at `CLAUDE.md` for the doc map.
> **Contract (from TECH_STACK §6.1):** this file owns token **values**, icon style, component visuals and screen layouts. It does **not** rename or remove any token. New tokens are marked **`NEW`** and each has a light value, a dark value and a contrast-test entry.
> **Scope:** the Flutter app (`packages/bb_ui`) **and** any future website / landing page. Section 13 gives the same tokens as CSS variables so the web stays identical.

---

## Table of Contents

1. [Design Principles](#1-design-principles)
2. [Color System — 3 colors, 60 · 30 · 10](#2-color-system--3-colors-60--30--10)
3. [Typography — Geist](#3-typography--geist)
4. [Spacing, Layout Grid & Alignment](#4-spacing-layout-grid--alignment)
5. [Shape, Borders & Elevation](#5-shape-borders--elevation)
6. [Iconography — Phosphor](#6-iconography--phosphor)
7. [Motion](#7-motion)
8. [Loading, Empty, Error & Offline States](#8-loading-empty-error--offline-states)
9. [Light & Dark Themes](#9-light--dark-themes)
10. [Component Visual Specs](#10-component-visual-specs)
11. [Screen Anatomy](#11-screen-anatomy)
12. [Flutter Implementation Snippets](#12-flutter-implementation-snippets)
13. [Web Tokens (CSS variables)](#13-web-tokens-css-variables)
14. [Governance & Review Checklist](#14-governance--review-checklist)
15. [References & Inspiration](#15-references--inspiration)

---

## 1. Design Principles

| # | Principle | What it means on screen |
|---|---|---|
| 1 | **Calm in a crisis** | Users open the app *during* a power cut, often in a dark room at night. Quiet canvas, one loud thing (the number they need), no clutter. |
| 2 | **The number is the hero** | Every screen leads with one big metric (backup time, kWh, PKR). Labels are small and muted; numbers are large, Geist SemiBold with tabular figures. |
| 3 | **One color = one meaning** | Yellow = energy & action. Navy = structure & grid. Green/orange/red = battery status only. Nothing is colored "for decoration". |
| 4 | **Minimal, not empty** | Containers separated by surface color and soft shadow — never borders. Generous whitespace. Density comes from good alignment, not boxes. |
| 5 | **Honest & offline-first** | Show cached data instantly with its age ("updated 3 h ago"). Never block the screen with a spinner. Never fake precision — show ranges. |
| 6 | **Readable in Lahore sunlight, gentle at 2 AM** | Light theme is high-contrast for strong sun; dark theme is designed (not inverted) for night outages and OLED battery saving. |

---

## 2. Color System — 3 colors, 60 · 30 · 10

### 2.1 The three brand colors

The app uses **exactly three brand color families**. Everything else is a tint/shade of these three, plus a tiny set of *functional* status colors (§2.3) that only ever communicate battery/safety state.

| Role | Name | Core value | Share of screen | Used for |
|---|---|---|---|---|
| **Primary — 60%** | **Canvas** (warm stone neutral) | Light `#F6F4F0` · Dark `#121110` | ~60% | Backgrounds, surfaces, cards, sheets, dividers, muted text. The quiet base that lets numbers breathe. |
| **Secondary — 30%** | **Ink Navy** | `#1F2F57` (deepest step `#0E1424` is the text ink) | ~30% | All primary text and icons, the **midnight hero card**, secondary buttons, selected states (segmented, chips, switches, nav pill), links, info banners, **grid power** in charts. |
| **Accent — 10%** | **Spark Yellow** | Light `#FFC21A` · Dark `#FFC93D` | ~10% | The one primary CTA per screen, the countdown ring arc, the AI advice tint, focus ring (dark), **solar** in charts. Yellow = electricity, sunlight and "do this". |

**Why this palette**

- **Spark Yellow** is the universal color of electricity and sunlight in Pakistan (lightning sign, solar). It is the brightest, most "clickable" color on both themes, so it is reserved for the 10% that must be noticed.
- **Ink Navy** is calm and trustworthy (fintech / utility feel), reads as near-black for body text, and owns "grid / structure" meaning without competing with yellow. Navy + yellow is a complementary pair (blue ↔ yellow-orange on the color wheel), which gives maximum distinction with only two hues.
- **Canvas** neutrals are **warm** (hue ≈ 40°, very low chroma), the same temperature as yellow. Warm paper next to amber reads as one palette; the v1 cool greys made the yellow look pasted on.
- **Navy is used deep, not pastel.** v1 filled the hero with a pale periwinkle (`navy100`) that competed with three other saturations (cool grey, saturated yellow, forest green), so no color led. v2 uses navy at its darkest (`navy900`, "midnight") for the hero. That gives each screen one strong dark anchor, and yellow sits on it at 10:1.

**Harmony model (v2).** A warm neutral base, one deep cool anchor and one warm accent: blue and amber are complementary, and the warm neutral bridges them. Each screen has one dark mass (the hero) with one bright accent inside it, and everything else stays quiet. The reference apps in §15 follow the same pattern: a neutral canvas, a dark emphasis card and a single saturated accent.

> **Naming note for developers.** In the 60-30-10 rule "primary" means the *dominant* (canvas) color. In Material 3 / our `AppColors`, `primary` means the *main action* color. So in code: **`colors.primary` = Spark Yellow (accent)**, `colors.secondary` = Ink Navy, `colors.surface/background` = Canvas. The mapping table in §2.4 is the source of truth.

### 2.2 Primitives (LAYER 1 — `color_primitives.dart`, package-private)

Widgets never use these directly. They exist only so semantic tokens (§2.4) can reference them.

**Canvas — neutral (Primary, 60%)**

| Step | 0 | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 850 | 900 | 950 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Hex | `#FFFFFF` | `#F6F4F0` | `#EDEAE4` | `#E2DED6` | `#CBC6BC` | `#A39D92` | `#857F74` | `#5E594F` | `#423E37` | `#2A2824` | `#211F1C` | `#1A1917` | `#121110` |

**Ink Navy — secondary (30%)**

| Step | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | 950 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Hex | `#F1F3F8` | `#E3E7F0` | `#C6CEDF` | `#A3B2D1` | `#7C90BE` | `#5670A6` | `#3F5891` | `#2E4378` | `#1F2F57` | `#16213D` | `#0E1424` |

**Spark Yellow — accent (10%)**

| Step | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | 950 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Hex | `#FFFBEB` | `#FFF3CC` | `#FFE7A3` | `#FFD666` | `#FFC93D` | `#FFC21A` | `#E6A800` | `#B38300` | `#8A6200` | `#4D3800` | `#2E2100` |

### 2.3 Functional status colors (not brand colors)

These are **not** part of the 3-color palette. They are safety signals and are only allowed for: battery level, success/warning/danger feedback, overload, destructive actions. They count inside the 10% budget and never appear decoratively.

| Scale | 100 | 300 | 600 | 900 |
|---|---|---|---|---|
| success (green) | `#DDF3E4` | `#5CCB82` | `#1E7A3D` | `#0E3A1E` |
| warning (orange — kept clearly redder than Spark Yellow) | `#FFE6D2` | `#FF9F5A` | `#A34706` | `#4A2004` |
| danger (red) | `#FDE1DF` | `#FF7A70` | `#C42B22` | `#4F1210` |

> **Never color alone:** every status = color **+** Phosphor icon **+** text/number. Example: battery low = red + `batteryLow` icon + "12%".

### 2.4 Semantic tokens (LAYER 2 — `palettes_light.dart` / `palettes_dark.dart`)

Token names follow `TECH_STACK.md` §6; tokens marked **NEW** were added here.

**AppColors**

| Token | Light | Dark | Notes |
|---|---|---|---|
| `background` | canvas50 `#F6F4F0` | canvas950 `#121110` | Scaffold. Maps to M3 `surface` (see §2.6). |
| `surface` | canvas0 `#FFFFFF` | canvas900 `#1A1917` | Cards, sheets, nav bar. |
| `surfaceRaised` | canvas0 + `elevation.level2` shadow | canvas850 `#211F1C` | Menus, bottom sheets, dialogs. Dark mode uses a lighter surface, not a shadow. |
| `surfaceMuted` | canvas100 `#EDEAE4` | canvas800 `#2A2824` | Input fills, tonal buttons, segmented track, skeleton base. |
| `hero` **NEW** | navy900 `#16213D` | navy900 `#16213D` | Dashboard hero card, both themes. Its content is drawn with the **dark** palette (§10.3), so it needs no on-hero tokens. |
| `textPrimary` | navy950 `#0E1424` | canvas100 `#EDEAE4` | Body, titles, numbers. Off-white in dark, never `#FFFFFF`. |
| `textMuted` | canvas600 `#5E594F` | canvas400 `#A39D92` | Labels, captions, units, placeholders, timestamps. |
| `textOnPrimary` | navy950 `#0E1424` | navy950 `#0E1424` | Ink on yellow, in both themes. |
| `outline` | canvas500 `#857F74` | canvas500 `#857F74` | Input borders, focus-less boundaries (≥ 3:1). |
| `outlineVariant` | canvas200 `#E2DED6` | canvas800 `#2A2824` | Hairline list dividers, chart gridlines, ring track. Never a container border. |
| `primary` | yellow500 `#FFC21A` | yellow400 `#FFC93D` | **Fill only.** Primary CTA, active nav pill, FAB. Never text/icon on light surfaces. |
| `primaryContainer` | yellow100 `#FFF3CC` | yellow950 `#2E2100` | Highlight chips, "recommended" tags, the AI advice card fill. |
| `onPrimaryContainer` **NEW** | yellow900 `#4D3800` | yellow200 `#FFE7A3` | Text/icons on `primaryContainer`. |
| `secondary` **NEW** | navy800 `#1F2F57` | navy300 `#A3B2D1` | Secondary buttons, selected chip/segment/switch, nav selected label. |
| `onSecondary` **NEW** | canvas0 `#FFFFFF` | navy950 `#0E1424` | Text/icons on `secondary`. |
| `secondaryContainer` **NEW** | navy100 `#E3E7F0` | navy900 `#16213D` | Info banner, selected list row, "Keep" badge, grid icon disc. |
| `onSecondaryContainer` **NEW** | navy900 `#16213D` | navy100 `#E3E7F0` | Text on `secondaryContainer`. |
| `link` **NEW** | navy700 `#2E4378` | navy300 `#A3B2D1` | Inline links & text buttons (underlined on press). |
| `focusRing` **NEW** | navy600 `#3F5891` | yellow400 `#FFC93D` | 2 px focus outline, offset 2 px. |
| `success` / `successContainer` | success600 / success100 | success300 / success900 | |
| `warning` / `warningContainer` | warning600 / warning100 | warning300 / warning900 | |
| `danger` / `dangerContainer` | danger600 / danger100 | danger300 / danger900 | |
| `onDanger` **NEW** | canvas0 `#FFFFFF` | navy950 `#0E1424` | Text/icons on a `danger` fill (`BbButton.danger`). Same values as M3 `onError` (§2.6). |
| `info` | navy600 `#3F5891` | navy300 `#A3B2D1` | Info = secondary family (no 4th hue). |
| `skeleton` **NEW** | canvas100 `#EDEAE4` | canvas800 `#2A2824` | Skeleton blocks (§8). On `surfaceMuted` backgrounds use canvas200 / canvas850. |
| `scrim` **NEW** | `#0E1424` @ 40% | `#000000` @ 60% | Behind sheets/dialogs. |

### 2.5 Energy colors (`EnergyColors` ThemeExtension)

Energy meanings are mapped onto the **same three families + status colors** — no extra hues.

| Token | Light | Dark | Meaning / rule |
|---|---|---|---|
| `energy.solar` (fill) | yellow500 `#FFC21A` | yellow400 `#FFC93D` | Large fills only (ring arcs ≥ 8 px, area charts, bars). In light mode always paired with `solarStroke` edge. |
| `energy.solarStroke` **NEW** | yellow700 `#B38300` | yellow400 `#FFC93D` | Lines, thin marks, small icons on light (≥ 3:1). |
| `energy.solarText` | yellow800 `#8A6200` | yellow400 `#FFC93D` | Any solar text such as "4.2 kWh". |
| `energy.grid` | navy600 `#3F5891` | navy400 `#7C90BE` | WAPDA/DISCO grid. |
| `energy.load` | canvas700 `#423E37` | canvas300 `#CBC6BC` | Household consumption. In charts drawn as **dashed** line to separate from grid. |
| `energy.batteryHigh` (> 50%) | success600 | success300 | Always + icon + %. |
| `energy.batteryMid` (20–50%) | warning600 | warning300 | |
| `energy.batteryLow` (< 20%) | danger600 | danger300 | |
| `energy.offline` / grid down | canvas500 `#857F74` | canvas500 `#857F74` | With `lightningSlash` icon. |

**Chart series order** (`EnergyColors.chartSeries`): solar → grid → load (dashed) → battery (status color for current level) → "other" canvas400. Chart gridlines = `outlineVariant`, axis labels = `textMuted` in `metricCaption`.

### 2.6 Material 3 `ColorScheme` mapping (`color_scheme_builder.dart`)

Flutter's M3 `ColorScheme` deprecated `background`, `onBackground` and `surfaceVariant` in favour of `surface`, `onSurface` and the tone-based `surfaceContainer*` roles. Our `AppColors.background` stays as a token but feeds the M3 surface roles like this:

| M3 role | Light | Dark |
|---|---|---|
| `primary` / `onPrimary` | yellow500 / navy950 | yellow400 / navy950 |
| `primaryContainer` / `onPrimaryContainer` | yellow100 / yellow900 | yellow950 / yellow200 |
| `secondary` / `onSecondary` | navy800 / canvas0 | navy300 / navy950 |
| `secondaryContainer` / `onSecondaryContainer` | navy100 / navy900 | navy900 / navy100 |
| `tertiary` (+ container) | = secondary values | = secondary values (we deliberately have no 4th hue) |
| `error` / `onError` / `errorContainer` | danger600 / canvas0 / danger100 | danger300 / navy950 / danger900 |
| `surface` / `onSurface` | canvas50 / navy950 | canvas950 / canvas100 |
| `surfaceContainerLowest` | canvas0 | canvas950 |
| `surfaceContainerLow` | canvas0 | canvas900 |
| `surfaceContainer` | canvas0 | canvas900 |
| `surfaceContainerHigh` | canvas100 | canvas850 |
| `surfaceContainerHighest` | canvas200 | canvas800 |
| `onSurfaceVariant` | canvas600 | canvas400 |
| `outline` / `outlineVariant` | canvas500 / canvas200 | canvas500 / canvas800 |
| `inverseSurface` / `onInverseSurface` | navy950 / canvas100 | canvas100 / navy950 |
| `surfaceTint` | `Colors.transparent` (we do not tint elevated surfaces) | same |
| `scrim` / `shadow` | navy950 / navy950 | black / black |

Never use `ColorScheme.fromSeed` — it would generate hues outside our three families.

### 2.7 Color usage rules

1. **60-30-10 budget per screen.** Canvas fills the screen; navy carries text, icons, structure and the one dark hero; yellow appears in at most **one CTA + one highlight** per viewport (the ring arc is data, not a highlight). The nav indicator is navy, not yellow. If a screen has two yellow buttons, one of them is wrong.
2. **Yellow is a fill, never text on light.** On light surfaces yellow text/icons fail contrast (1.6:1). Use `textOnPrimary` ink *on* yellow, or `energy.solarText` for solar numbers.
3. **Ink on yellow, always.** Yellow buttons/pills carry `textOnPrimary` (11:1+). Never white on yellow.
4. **Status colors are for status.** Green ≠ "nice", red ≠ "brand". A green button does not exist; a red button only exists as `BbButton.danger` for destructive actions.
5. **No gradients**, except the 2-stop solar area fill in charts (`energy.solar` 32% → 0% alpha) and the **auth "sky"** on Sign up / Login: `secondary` → `secondaryContainer` → `background` (dark: `secondaryContainer` → `surface` → `background`) with a solid `primary` sun disc in the corner. Never through grey; titles on it use `onSecondary` (dark: `onSecondaryContainer`).
6. **No pure black or pure white text** in dark mode. Canvas950 is the darkest pixel; canvas100 is the brightest text.
7. **Opacity, not new colors,** for states: pressed overlay = `textPrimary` @ 12%, hover @ 8%, disabled content @ 38% (TECH_STACK `opacity.dart`).

### 2.8 Contrast audit (WCAG 2.x, computed)

These pairs go into `contrast_test.dart`. All pass.

| Foreground | Background | Light | Dark | Min |
|---|---|---|---|---|
| `textPrimary` | `surface` | 18.4:1 | 14.6:1 | 4.5:1 |
| `textPrimary` | `background` | 16.7:1 | 15.7:1 | 4.5:1 |
| `textPrimary` | `surfaceMuted` | 15.3:1 | 12.3:1 | 4.5:1 |
| `textMuted` | `surface` | 7.0:1 | 6.5:1 | 4.5:1 |
| `textMuted` | `surfaceMuted` | 5.8:1 | 5.5:1 | 4.5:1 |
| `textOnPrimary` | `primary` | 11.3:1 | 12.0:1 | 4.5:1 |
| `onSecondary` | `secondary` | 13.1:1 | 8.6:1 | 4.5:1 |
| `onSecondaryContainer` | `secondaryContainer` | 12.9:1 | 12.9:1 | 4.5:1 |
| `onPrimaryContainer` | `primaryContainer` | 10.1:1 | 12.9:1 | 4.5:1 |
| `textPrimary` | `primaryContainer` | 16.6:1 | 13.1:1 | 4.5:1 |
| `onDanger` | `danger` | 5.7:1 | 7.2:1 | 4.5:1 |
| `link` | `surface` | 9.6:1 | 8.2:1 | 4.5:1 |
| `outline` | `surface` | 4.0:1 | 4.4:1 | 3.0:1 |
| `outline` | `background` | 3.6:1 | 4.7:1 | 3.0:1 |
| `success` | `surface` | 5.4:1 | 8.6:1 | 4.5:1 |
| `success` | `successContainer` | 4.6:1 | 6.3:1 | 4.5:1 |
| `warning` | `surface` | 6.1:1 | 8.7:1 | 4.5:1 |
| `warning` | `warningContainer` | 5.1:1 | 6.9:1 | 4.5:1 |
| `danger` | `surface` | 5.7:1 | 6.9:1 | 4.5:1 |
| `danger` | `dangerContainer` | 4.6:1 | 5.8:1 | 4.5:1 |
| `energy.solarText` | `surface` | 5.5:1 | 11.4:1 | 4.5:1 |
| `energy.solarStroke` | `surface` | 3.4:1 | 11.4:1 | 3.0:1 |
| `energy.grid` | `surface` | 7.0:1 | 5.5:1 | 3.0:1 |
| `energy.load` | `surface` | 10.6:1 | 10.3:1 | 3.0:1 |
| `energy.offline` | `surface` | 4.0:1 | 4.4:1 | 3.0:1 |

**Hero island** (dark-palette tokens on `hero`, same in both themes): `textPrimary` 13.3:1 · `textMuted` 5.9:1 · `primary` (ring arc) 10.4:1 · `warning` 7.9:1 · `danger` 6.3:1 · `focusRing` 10.4:1.

**Known exception (documented):** `energy.solar` fill on light `surface` is 1.6:1. It is therefore only used for large areas and always has a `solarStroke` edge or an adjacent label — the meaning never depends on the fill alone.

---

## 3. Typography — Geist

### 3.1 Families (max 2)

| # | Family | Role | Status |
|---|---|---|---|
| 1 | **Geist** (Sans) | All text **and all numbers** | Active |
| 2 | *Noto Nastaliq Urdu* | Fallback family for Urdu script (future stretch goal) | Reserved — not bundled yet |

Roman Urdu uses Geist (Latin). No other fonts are allowed in the app or on the website.

**Why no Geist Mono (changed in v2).** v1 set every live number in Geist Mono. Monospace digits with a slashed zero made the hero countdown and stat tiles look like terminal output. Geist itself ships **tabular figures** (`tnum`), which give us the one thing we needed from mono: every digit has the same width, so "3h 20m → 3h 19m" never jitters and columns line up. Every metric style therefore uses Geist + `FontFeature.tabularFigures()`.

**The one rule to remember:** *if a number can change while you look at it, it uses a `metric*` style.* Static numbers inside sentences ("Turn off 2 fans") stay in the body style.

### 3.2 Bundling (offline requirement)

- Download the official release (otf / variable) from **vercel.com/font** or `github.com/vercel/geist-font` (SIL Open Font License — free for commercial use; keep `OFL.txt` in `assets/fonts/`).
- **Do not use the Google Fonts build or the `google_fonts` package**: it is fetched at runtime (breaks offline) and Vercel notes the Google Fonts build lacks the full glyph set and `font-feature-settings` support (we rely on `tnum`).
- Bundle static weights only (smaller APK than variable): **Geist 400, 500, 600**. No other weights.

```yaml
# packages/bb_ui/pubspec.yaml
flutter:
  fonts:
    - family: Geist
      fonts:
        - asset: assets/fonts/Geist-Regular.otf
          weight: 400
        - asset: assets/fonts/Geist-Medium.otf
          weight: 500
        - asset: assets/fonts/Geist-SemiBold.otf
          weight: 600
```

### 3.3 Weights

| Weight | Name | Use |
|---|---|---|
| 400 | Regular | Body, captions |
| 500 | Medium | Labels, buttons, small metrics |
| 600 | SemiBold | Titles, headlines and large metrics |

No Bold (700+) and no Light/Thin. Hierarchy comes from **size and color**, not heavy weights — that is what keeps the look minimal.

### 3.4 Type scale (`AppTypography` + Material `TextTheme`)

Sizes in logical px (sp). Line heights on a 4-pt rhythm. Negative tracking on large sizes is what makes Geist look crisp; big numbers get the tightest tracking.

| Role | Family | Size / Line | Weight | Tracking | Use |
|---|---|---|---|---|---|
| `displaySmall` | Geist | 32 / 40 | 600 | −0.8 | Onboarding hero, estimator result headline |
| `headlineMedium` | Geist | 28 / 36 | 600 | −0.6 | Screen title (large app bar) |
| `headlineSmall` | Geist | 24 / 32 | 600 | −0.4 | Sheet / dialog titles |
| `titleLarge` | Geist | 20 / 28 | 600 | −0.3 | Section titles |
| `titleMedium` | Geist | 16 / 24 | 600 | −0.1 | Card titles, list primary text (emphasised) |
| `titleSmall` | Geist | 14 / 20 | 600 | 0 | Small card headers |
| `bodyLarge` | Geist | 16 / 24 | 400 | 0 | Main reading text, chat messages |
| `bodyMedium` | Geist | 14 / 20 | 400 | 0 | Default body, list secondary text |
| `bodySmall` | Geist | 12 / 16 | 400 | +0.1 | Captions, helper text, disclaimers |
| `labelLarge` | Geist | 14 / 20 | 500 | +0.1 | Buttons, tabs, segmented control |
| `labelMedium` | Geist | 12 / 16 | 500 | +0.2 | Chips, badges, nav labels |
| `labelSmall` | Geist | 11 / 16 | 500 | +0.5 | Overlines (UPPERCASE allowed only here) |
| `metricHero` | Geist `tnum` | 60 / 64 | 600 | −2.4 | Backup countdown "3h 20m" |
| `metricLarge` | Geist `tnum` | 34 / 40 | 600 | −1.2 | Stat tiles (kWh, %, PKR) |
| `metricMedium` | Geist `tnum` | 20 / 24 | 600 | −0.4 | Package prices, secondary stats, units of `metricLarge` |
| `metricSmall` | Geist `tnum` | 16 / 20 | 500 | −0.1 | Inline numbers in lists ("+2h 10m", "750 W") |
| `metricCaption` | Geist `tnum` | 12 / 16 | 500 | 0 | Chart axes, timestamps, "updated 3 h ago" times |

Default text color = `textPrimary`; secondary text = `textMuted`. Feature code never sets color/size on text — it picks a role.

### 3.5 Typography rules

1. **Value + unit pattern:** the value uses a metric style; the unit uses the same family one step smaller in `textMuted`, **baseline-aligned** (`Row` with `CrossAxisAlignment.baseline`). E.g. **`3h 20m`** `left` · **`420`** `W` · `PKR` **`1,85,000`**.
2. **Currency:** PKR with South-Asian grouping when `ur_Latn` / `en_PK` locale is active (`1,85,000`), formatted only via `core/utils` formatters.
3. **Line length:** body text max ~60 characters per line on tablets/web (`maxWidth: 560`).
4. **Text scale:** every screen must work at system text scale **1.0 and 1.5** (TECH_STACK §6.6). `metricHero` may clamp at 1.3× to keep the ring readable; nothing else clamps.
5. **Truncation:** titles 1 line + ellipsis; list secondary text max 2 lines; never truncate numbers.
6. **Sentence case** everywhere ("Turn off first", not "Turn Off First"). UPPERCASE only for `labelSmall` overlines.

---

## 4. Spacing, Layout Grid & Alignment

### 4.1 Spacing scale (`spacing.dart`, 4-pt grid)

| Token | Value | Typical use |
|---|---|---|
| `xxs` | 2 | Icon ↔ badge nudge, value ↔ unit gap |
| `xs` | 4 | Label ↔ helper text, chip icon ↔ label |
| `sm` | 8 | Icon ↔ text in a row, between chips, tight stacks |
| `md` | 12 | Grid gutter (compact), list item vertical padding, stat tiles gap |
| `lg` | 16 | **Screen side margin (compact)**, card padding, between cards |
| `xl` | 24 | Between sections, sheet padding, gutter (expanded) |
| `xxl` | 32 | Top of screen to first section, before primary CTA block |
| `xxxl` | 48 | Empty-state vertical padding, onboarding hero spacing |
| `xxxxl` **NEW** | 64 | Web hero sections, large empty states |

Only these values. No `EdgeInsets.all(10)`, no `SizedBox(height: 18)`. Gaps between widgets use `BbGap.md()` etc.

### 4.2 Layout grid, margins & gutters (`breakpoints.dart`)

| Window class | Width | Columns | Side margin | Gutter | Max content width |
|---|---|---|---|---|---|
| **Compact** (phones) | < 600 | 4 | 16 (`lg`) | 12 (`md`) | full width |
| **Medium** (large phones landscape, small tablets) | 600 – 840 | 8 | 24 (`xl`) | 16 (`lg`) | 720 |
| **Expanded** (tablets, web) | > 840 | 12 | 32 (`xxl`) | 24 (`xl`) | 1080 (content centered) |

- `BbPagePadding` applies the side margin + safe-area insets automatically. Screens never hard-code horizontal padding.
- **Stat tiles grid:** 2 columns on compact (each tile = 2 of 4 columns), 4 columns on medium/expanded.
- **Cards:** full bleed to margins on compact; on expanded, the dashboard uses a 2-column layout (hero 7 cols + side 5 cols).
- Bottom content padding = nav bar height + `lg` so the last card is never hidden.

### 4.3 Vertical rhythm

```
App bar ──────────────── 56 (large title variant 112)
  ↓ xxl 32 (first section)  — or lg 16 under a large title
Section title (titleLarge)
  ↓ md 12
Card / list
  ↓ lg 16 between cards
  ↓ xl 24 between sections
Primary CTA block (sticky bottom: lg 16 padding + safe area)
```

### 4.4 Component internal spacing

| Component | Padding | Internal gap |
|---|---|---|
| Card (`BbCard`) | 16 all sides (20 for hero card) | 12 between rows |
| List tile | 16 horizontal · 12 vertical (min height 56; 72 with 2 lines) | 12 leading icon ↔ text |
| Button (md) | 20 horizontal | 8 icon ↔ label |
| Input | 16 horizontal · 14 vertical (height 52) | 4 label ↔ field, 4 field ↔ helper |
| Chip | 12 horizontal · 6 vertical (height 32) | 4 icon ↔ label |
| Bottom sheet | 24 sides · 8 top (drag handle) · 24 + safe area bottom | 16 |
| Banner | 12 vertical · 16 horizontal | 12 icon ↔ text |

### 4.5 Alignment rules

1. **Left-align everything** by default (text, titles, form labels). One strong left edge = the minimal look.
2. **Center only:** hero countdown ring, empty/error states, onboarding illustrations, dialog icon.
3. **Numbers right-aligned** in lists and tables (`textAlign: end`; tabular figures make columns line up).
4. **Leading icons align to the first line of text**, not the vertical center of a multi-line block.
5. **Value + unit** baseline-aligned (§3.5).
6. **One alignment edge per card:** content inside a card shares the card's 16-px inner edge; do not indent sub-rows.
7. **Touch targets ≥ 48 × 48** even when the visible glyph is 20–24 px (expand hit area with padding, not size).
8. **RTL-ready:** use `EdgeInsetsDirectional` / `AlignmentDirectional` everywhere so future Urdu script flips correctly.

---

## 5. Shape, Borders & Elevation

### 5.1 Radius (`radius.dart`)

| Token | Value | Use |
|---|---|---|
| `xs` **NEW** | 4 | Skeleton text lines, progress bars, small tags |
| `sm` | 8 | Badges, tooltips, chart bars (top corners) |
| `md` | 12 | Inputs, segmented control |
| `lg` | 20 | Cards, banners, dialogs |
| `xl` | 28 | Bottom sheets (top corners), hero card |
| `pill` | 999 | **Buttons**, chips, nav indicator, grid status pill, switches |

Nested radius rule: inner radius = outer radius − padding (e.g. 20-px card with 8-px inset → 12-px inner element).

v2 moved to larger radii and pill buttons: the reference apps (§15) all use soft, generous corners, and a pill reads as "tappable" at a glance.

### 5.2 Borders

- **Containers never have borders.** Cards, sheets, nav bar, app bar and chat bubbles are separated from the page by surface color contrast plus elevation (§5.3): light = `surface` on `background` + `level1` shadow; dark = `surface` on `background` (lighter surface, no shadow).
- **Never nest elevated surfaces.** A card does not contain another shadowed card; inner groups use `surfaceMuted` fill instead.
- **Interactive states change background, not borders** (pressed/hover overlays, selected fills).
- **Exceptions (accessibility):** inputs keep a 1 px `outline` boundary (WCAG 1.4.11, ≥ 3:1). Focus is a separate 2 px `focusRing` outline offset 2 px, always visible. Input error = `dangerContainer` fill + `danger` helper text + `warning` icon, not a border change.
- Dividers: 1 px `outlineVariant`, inset 16 from the leading edge, only *between rows inside* one list group.

### 5.3 Elevation (`elevation.dart`)

| Level | Light | Dark | Used by |
|---|---|---|---|
| `level0` | No shadow | `background` | Flat page content, inner groups (`surfaceMuted` fill) |
| `level1` | `0 1 2 rgba(18,17,16,.04)` + `0 8 24 rgba(18,17,16,.06)` | `surface` | Cards, list groups, nav bar, sticky bottom CTA bar, app bar when scrolled |
| `level2` | `0 2 4 rgba(18,17,16,.05)` + `0 12 32 rgba(18,17,16,.08)` | `surfaceRaised` | Menus, dropdowns, toasts |
| `level3` | `0 4 8 rgba(18,17,16,.06)` + `0 24 56 rgba(18,17,16,.14)` | `surfaceRaised` | Bottom sheets, dialogs |

Shadows have two layers (a tight contact shadow plus a wide ambient one), are tinted with warm ink canvas950 (never pure black), and are very soft. In dark mode elevation = lighter surface, not a shadow.

---

## 6. Iconography — Phosphor

### 6.1 Library

- **Phosphor Icons only.** No Lucide, no Material Icons, no Cupertino icons, no mixed sets.
- Flutter package: **`phosphor_icons`** (^3.0.1 at time of writing). It is a maintained fork of the original `phosphor-icons/flutter` package, created to keep working on Flutter 3.43+ where `IconData` is `final`, and it adds `PhosphorDuotoneTheme`. Verify the latest stable version at setup and record it in `pubspec.lock`.
- Use the **style classes** (`PhosphorIconsRegular.x`, `PhosphorIconsFill.x`) — not `PhosphorIcons.x(style)` — so unused glyphs are tree-shaken.
- Web: `@phosphor-icons/react` (or `@phosphor-icons/web`) — same glyph names.

### 6.2 Style policy

| Style | When |
|---|---|
| **Regular** (default) | Every icon in normal state: list leading icons, app bar actions, inputs, nav (unselected). |
| **Fill** | Selected nav tab, active toggle states, status icons inside banners/badges, icon inside a yellow/navy filled button. |
| **Duotone** | Only for large illustrative icons (48 – 64 px) in empty states and onboarding. Secondary layer = same color @ 20%. |
| Thin / Light / Bold | **Not used.** |

### 6.3 Sizes (`sizes.dart`)

| Token | Size | Use |
|---|---|---|
| `iconXs` | 16 | Inline with `bodySmall`/`labelMedium`, inside chips & badges |
| `iconSm` | 20 | List leading icons, inputs, buttons |
| `iconMd` | 24 | App bar actions, nav bar, default |
| `iconLg` | 32 | Stat tile icons, banner (prominent) |
| `iconXl` **NEW** | 48 | Empty / error states (Duotone) |

Icon color always comes from a token: `textPrimary` (default), `textMuted` (secondary), `secondary` (selected), status/energy tokens for meaning. Icons on yellow use `textOnPrimary`.

### 6.4 `BbIcons` — semantic icon registry

Features never import Phosphor directly. They use `BbIcons.<meaning>`, defined once in `bb_ui/src/foundations/icons.dart` (**NEW** file). Swapping a glyph later = one-line change.

| `BbIcons.` | Phosphor glyph (Regular / Fill) | Meaning |
|---|---|---|
| `home` | `house` | Dashboard tab |
| `loads` | `plugs` | Load planner tab |
| `solar` | `sun` | Solar tab, solar series |
| `battery` | `batteryHigh` | Battery tab |
| `assistant` | `chatCircleDots` | AI chat tab |
| `ai` | `sparkle` | AI-generated advice marker |
| `gridOn` | `lightning` | Grid power present ("Light aa gayi") |
| `gridOff` | `lightningSlash` | Outage ("Light gayi") |
| `batteryFull / High / Medium / Low / Empty` | `batteryFull` … `batteryEmpty` | Battery level (paired with % text) |
| `batteryCharging` | `batteryCharging` | Charging from grid/solar |
| `batteryWarning` | `batteryWarning` | Health / overload warning |
| `solarPanel` | `solarPanel` | Panel system, estimator |
| `cloudy` | `cloudSun` | Reduced solar forecast |
| `countdown` | `timer` | Backup time |
| `schedule` | `calendarDots` | Outage schedule |
| `estimator` | `calculator` | Solar cost estimator |
| `money` | `coins` | PKR savings / cost |
| `shop` | `storefront` | Battery dealer |
| `repair` | `wrench` | Repair shop |
| `location` | `mapPin` | Nearby search |
| `fan` · `light` · `tv` · `router` · `water` · `iron` | `fan` · `lightbulb` · `television` · `wifiHigh` · `drop` · `tShirt` | Appliance presets (fallback for anything missing: `plug`) |
| `offline` | `wifiSlash` | Offline banner |
| `success` · `warning` · `danger` · `info` | `checkCircle` · `warning` · `warningOctagon` · `info` | Status (Fill inside banners) |
| `themeLight` · `themeDark` · `themeSystem` | `sun` · `moon` · `circleHalf` | Theme toggle |
| `settings` | `gearSix` | Settings |
| `account` · `email` · `google` · `signOut` | `userCircle` · `envelope` · `googleLogo` · `signOut` | Account & sign-in |
| `showPassword` · `hidePassword` | `eye` · `eyeSlash` | Password visibility toggle in `BbTextField` |
| `back` · `next` · `close` · `add` · `more` | `arrowLeft` · `caretRight` · `x` · `plus` · `dotsThree` | Navigation & actions |
| `send` | `paperPlaneRight` (Fill) | Send a chat message |
| `expand` · `check` | `caretDown` · `check` | `BbDropdown` caret, selected `BbChip` |
| `refresh` | `arrowClockwise` | Refresh forecast |
| `add` · `remove` | `plus` · `minus` | `BbQuantityStepper` |
| `radioOff` · `radioOn` | `circle` · Fill `checkCircle` | `BbChoiceCard` mark |
| `fridge` · `ac` · `cooler` · `laptop` · `desktop` · `charger` · `washer` · `microwave` | `thermometerCold` · `snowflake` · `wind` · `laptop` · `desktop` · `deviceMobile` · `washingMachine` · `oven` | Appliance presets |
| `homeActive` · `loadsActive` · `solarActive` · `batteryActive` · `assistantActive` | Fill of the tab glyph | Selected nav tab (§6.2) |

> Glyph names follow Phosphor's catalog (phosphoricons.com). Confirm each exists in the installed package version during setup; if one is missing, choose the closest Phosphor glyph and update only this table + `icons.dart`.

---

## 7. Motion (`motion.dart`)

| Token | Duration | Curve | Use |
|---|---|---|---|
| `fast` | 150 ms | `easeOutCubic` | Press states, toggles, chip select, icon swap |
| `normal` | 250 ms | `easeOutCubic` (enter) / `easeInCubic` (exit) | Cards, banners, page transitions, theme cross-fade |
| `slow` | 400 ms | `easeInOutCubic` | Countdown ring value change, bottom sheet, chart reveal |
| `skeletonPulse` **NEW** | 1200 ms loop | `easeInOut` | Skeleton opacity pulse (§8.2) |

Rules:
- Motion explains change (a number rolling to its new value, a ring arc growing) — never decoration, no bouncy springs, no parallax.
- Live numbers animate with a 250-ms count tween; the ring arc animates with `slow`.
- Page transitions: shared-axis horizontal (fade + 24-px slide) for push; fade-through for tab switches.
- Respect `MediaQuery.disableAnimations`: all durations become 0, skeleton pulse becomes static.

---

## 8. Loading, Empty, Error & Offline States

Offline-first means **most screens never load from scratch** — Firestore cache and engine results render on the first frame. Loading UI is only for genuinely missing data. Every loading pattern in the app is one of the five below; nothing else is allowed.

### 8.1 Decision table — which loader?

| Situation | Pattern | Component |
|---|---|---|
| First load of a region whose **shape is known** (dashboard cards, lists, charts, package cards) and **no cached data** | **Skeleton** | `BbSkeleton` |
| A **button** triggered an action (save, find shops, send) | **Inline spinner inside the button** | `BbButton(loading: true)` |
| **Refreshing** data that is already on screen (weather update, pull-to-refresh) | Keep content visible + **2-px linear progress** under the app bar, or inline 12-px spinner next to "updated …" | `BbProgressBar.indeterminate` / `BbSpinner.xs` |
| **AI assistant** is composing a reply | **Typing indicator** (3 dots) in a chat bubble | `BbTypingIndicator` |
| A **known-length** task (seeding, uploading, onboarding steps) | **Determinate progress bar** | `BbProgressBar` |

**Banned:** full-screen blocking spinners, spinners in the middle of empty cards, centered `CircularProgressIndicator` on a blank screen, shimmer on already-loaded content, and loaders with only a color and no shape.

### 8.2 Skeleton spec (`BbSkeleton`)

- **Variants:** `BbSkeleton.text(lines: 1–3)`, `.circle(size)`, `.rect(height, radius)`, `.metric()` (block sized to the metric style), and composed `.card()` / `.listTile()` / `.statTile()` that mirror the real component's layout **exactly** (same padding, same heights) so nothing jumps when data arrives.
- **Color:** `colors.skeleton` (canvas100 light / canvas800 dark).
- **Animation:** **soft opacity pulse**, 1.0 → 0.55 → 1.0 over `skeletonPulse` (1200 ms). Chosen over shimmer because it is calmer, cheaper to render, and gentler on battery during outages. All skeletons on a screen pulse **in sync** (one shared `AnimationController` via `BbSkeletonScope`).
- **Shapes:** text line height = 60% of the text style's line height, radius `xs`; last line of a multi-line block = 60% width; max 3 lines per block. Circles for avatars/icons; rect radius matches the real component (`lg` for cards).
- **Timing:** show only if loading takes > **200 ms** (avoids flash); once shown, keep at least **400 ms**; cross-fade to content with `normal` (250 ms).
- **Accessibility:** wrap region in `Semantics(label: 'Loading')`, `liveRegion` once; individual blocks excluded from semantics.

### 8.3 Inline spinner spec (`BbSpinner`) **NEW**

- Circular, **2-px stroke**, round cap, 270° arc rotating at 900 ms/turn.
- Sizes: `xs` 12, `sm` 16, `md` 20. No larger spinner exists.
- Color = the content color it replaces (`textOnPrimary` in yellow buttons, `onSecondary` in navy buttons, `textMuted` inline).
- **In buttons:** the spinner replaces the leading icon (or sits before the label if no icon); the label stays; the button keeps its exact width; taps are ignored; label switches to the progressive form ("Finding shops…").

### 8.4 Progress bar (`BbProgressBar`)

- Height 4 (determinate) / 2 (indeterminate under app bar), radius `xs`.
- Track `surfaceMuted`, indicator `secondary`. Battery-level bars use the battery status token instead.

### 8.5 Stale & offline data

- Data older than the freshness window shows `metricCaption` text "updated 3 h ago" in `textMuted` with `BbIcons.countdown` 12 px. Never hide stale data.
- `BbOfflineBanner`: slim (40 px) bar under the app bar, `surfaceMuted` background, `BbIcons.offline` + "You're offline — showing saved data". Slides in/out with `normal`. Never blocks interaction.
- Network-only features (F7 shops, F9 chat) show an **inline "Needs internet"** empty state (§8.6), not an error.

### 8.6 Empty & error states (`BbEmptyState`, `BbErrorState`)

Centered column, `xxxl` vertical padding:
1. Phosphor **Duotone** icon 48 px in `textMuted` (secondary layer @ 20%).
2. `titleMedium` headline (one line, sentence case).
3. `bodyMedium` `textMuted` explanation (max 2 lines).
4. One action: `BbButton.secondary` (or `.primary` if it is the screen's main task).

Errors are friendly and actionable ("Couldn't reach the weather service. Showing yesterday's forecast." + "Try again"), never raw exception text.

### 8.7 Toasts & banners

- `BbToast`: bottom, above nav bar, `inverseSurface` background, `bodyMedium`, auto-dismiss 4 s, max 1 action (`link`-style). One at a time.
- `BbBanner(tone: info | success | warning | danger)`: container color + Fill icon in the status color + `textPrimary` body; radius `lg`; optional dismiss. Safety banners (battery swelling/heat, overload) are `danger` and **not dismissible**.

---

## 9. Light & Dark Themes

### 9.1 Mechanics (unchanged from TECH_STACK §6.3)

`AppTheme.light()` / `AppTheme.dark()` → `ThemeData(useMaterial3: true)`; `ThemeModeController` with `system | light | dark`, default **system**, persisted in `shared_preferences` so the right theme paints on the first frame offline. `AppColors`, `EnergyColors` and `AppTypography` implement `lerp`, so switching cross-fades over `normal` (250 ms).

### 9.2 Side-by-side

| Element | Light | Dark |
|---|---|---|
| Background | `#F6F4F0` cool paper | `#121110` near-black navy (not `#000`) |
| Cards | White + soft `level1` shadow | `#1A1917` on `#121110`, no shadow |
| Text | Ink navy `#0E1424` | Off-white `#EDEAE4` |
| Primary CTA | Yellow `#FFC21A` + ink label | Yellow `#FFC93D` + ink label |
| Selected states / nav pill | Navy `#1F2F57` | Light navy `#A3B2D1` |
| Hero card | `hero` midnight `#16213D`, dark-palette content | same |
| Elevation | Soft navy shadows | Lighter surfaces, no shadows |
| Status / energy | 600-tones | 300-tones |

### 9.3 Dark theme rules

1. **Designed, not inverted:** every token has a hand-picked dark value (theme parity test enforces both exist).
2. Use 300-tones for colors on dark; never the light 600-tones (they vibrate/vanish on dark).
3. Max 3 surface levels visible at once (background → surface → surfaceRaised).
4. Reduce large white areas: images/illustrations get a dark variant or 90% opacity.
5. Status bar & navigation bar icons follow the theme (`SystemUiOverlayStyle`), nav bar color = `surface`.

### 9.4 Theme toggle UI

- **Settings:** `BbSegmentedControl` with three segments — System / Light / Dark (icons `circleHalf` / `sun` / `moon`, Regular; selected = Fill).
- **Dashboard app bar:** one `BbIconButton` that cycles light ↔ dark (shows `moon` in light, `sun` in dark), tooltip "Switch theme".

---

## 10. Component Visual Specs

All components live in `bb_ui` with the `Bb` prefix, accept **variants not colors**, handle all states, and appear in the Gallery app in both themes (TECH_STACK §6.7).

### 10.1 Buttons (`BbButton`, `BbIconButton`)

| Variant | Fill | Label / icon | Border | Use |
|---|---|---|---|---|
| `primary` | `primary` (yellow) | `textOnPrimary` | — | **One per screen.** The main task ("Calculate", "Light gayi") |
| `secondary` | `secondary` (navy) | `onSecondary` | — | Strong secondary actions |
| `tonal` **NEW** | `surfaceMuted` | `textPrimary` | — | Neutral actions ("Edit", "Add appliance") |
| `ghost` | transparent | `link` | — | Low-emphasis / inline ("See all", "Skip") |
| `danger` | `danger` | `onDanger` | — | Destructive only ("Delete appliance") |

- Shape: **pill** (`radius.pill`) at every size.
- Sizes: `sm` 40 h, `md` 48 h (default), `lg` 56 h (sticky bottom CTA, full width). Label `labelLarge`; icon 20, leading only.
- States: pressed = 12% `textPrimary` overlay + scale 0.98 (`fast`); disabled = 38% opacity, no overlay; focused = 2-px `focusRing` offset 2; loading = §8.3.
- `BbIconButton`: 48 × 48 hit area, 24 icon, circular; variants `standard` (no fill), `tonal` (`surfaceMuted` circle 40).
- `BbGoogleButton` **NEW**: outlined pill (`surface` fill, 1 px `outlineVariant`), Google's four-color G (SVG asset, as Google's branding requires), `labelLarge` label.

### 10.2 Inputs

- **`BbTextField` / `BbNumberField`:** height 52, radius `md`, fill `surface`, border 1 px `outline`; label above (`labelLarge`, `textPrimary`); helper/error below (`bodySmall`). Number field: value in `metricSmall`, **unit suffix** in `textMuted` ("Ah", "W", "kWp"), numeric keyboard, right-aligned value.
- **`BbSwitch`:** track 52 × 32 pill; on = `secondary` track + `onSecondary` thumb; off = `surfaceMuted` track + `outline` border + `textMuted` thumb.
- **`BbSegmentedControl`:** track `surfaceMuted`, radius `md`, 4 px inset; selected segment = `surface` + level1 (light) / `surfaceRaised` (dark), label `textPrimary` 600; unselected `textMuted`.
- **`BbSlider`:** track 4 px `surfaceMuted`, active `secondary`, thumb 20 px `secondary` with value label in `metricSmall` while dragging.
- **`BbTextField(pill: true)`** **NEW**: sign-in style — pill radius, leading icon, label shown inside as the placeholder (still the accessible name), 1 px `outlineVariant`.
- **`BbDropdown`:** looks like `BbTextField` + `caretDown` icon; menu = level2 surface.
- **`BbChoiceCard`** **NEW**: one answer to a single-choice question. Full width, radius `lg`, padding 16: 40-px icon disc, `titleSmall` title, optional `bodySmall` muted hint (a recognition cue, e.g. "Tall battery you top up with water"), radio mark on the right. Unselected = `surface` + level1; selected = `secondaryContainer`, no shadow, Fill `checkCircle` in `secondary`. No borders.
- **`BbQuantityStepper`** **NEW**: tonal − / + icon buttons (48 dp) around the value in `metricSmall` (`textMuted` at 0). One adjustable node for screen readers (swipe to change).

### 10.3 Surfaces

- **`BbCard`:** `surface`, radius `lg`, `level1`, no border, padding 16. Variants:
  - `standard`.
  - `hero`: `hero` midnight fill, radius `xl`, padding 24, no shadow. Its content is wrapped in the **dark theme** (`Theme` + default text and icon color), so every component inside uses the dark tokens automatically: off-white text, 300-tone status colors, yellow focus ring. One hero per screen.
  - `highlight`: `primaryContainer` fill, no shadow, no stripe. The top AI advice card, with a `BbIcons.ai` icon in `onPrimaryContainer`.
- **`BbSection`:** `titleLarge` header + optional `ghost` action on the right ("See all"), `md` gap to content.
- **`BbBottomSheet`:** `surfaceRaised`, top radius `xl`, drag handle 32 × 4 `outline` pill, level3, scrim.
- **`BbDialog`:** radius `lg`, max width 400, padding 24, title `headlineSmall`, actions right-aligned (ghost + primary/danger).

### 10.4 Data display

- **`BbStatTile`:** `BbCard` with: 40-px icon disc (`BbTone.containerColor`, e.g. `successContainer`) holding a 20-px icon in the tone color → `md` gap → `labelMedium` label in `textMuted` → `metricLarge` value + unit → optional `bodySmall` delta ("−18% vs Mar"). Min height 112.
- **`BbMetric`:** standalone value+unit pair (§3.5), sizes hero/large/medium/small.
- **`BbBadge`:** pill, height 24, `labelMedium`, container color + on-container text, optional 16-px Fill icon.
- **`BbChip`:** pill height 32, unselected = `surfaceMuted` fill + `textPrimary`; selected = `secondary` fill + `onSecondary` + leading `check` icon.
- **`BbListTile`:** 56/72 min height, leading 20-px icon in a 40-px `surfaceMuted` circle (or energy-tinted container), title `bodyLarge`, subtitle `bodyMedium` muted, trailing value in `metricSmall` right-aligned or `caretRight` 16.
- **`BbProgressBar`:** §8.4.

### 10.5 Navigation

- **`BbNavBar`** (bottom, 5 tabs: Home · Loads · Solar · Battery · Assistant): height 64 + safe area, `surface` + `level1` (shadow cast upward in light; lighter surface in dark), no border. Selected tab = **navy pill indicator** 56 × 32 (`secondary`) behind a **Fill** icon in `onSecondary`, label `labelMedium` `textPrimary` 600; unselected = Regular icon + label in `textMuted`. Navy since v2, so the yellow budget goes to the screen's CTA.
- **`BbAppBar`:** `background` color (blends with page), title `titleLarge` (or large `headlineMedium` variant on top-level tabs that collapses on scroll), actions = `BbIconButton`s; gains `level1` (and `surface` fill) when content scrolls under it.
- **`BbStepIndicator`** **NEW**: short stepped flows (setup). Per step a 28-px circle + `labelMedium` label below, joined by 2-px lines. Done = `successContainer` + `check` in `success` (line `success`); current = `secondary` + number in `onSecondary`; upcoming = `surfaceMuted` + number in `textMuted` (line `outlineVariant`). One semantics label: "Step 2 of 3: Battery".
- **`BbTabs`:** text tabs, `labelLarge`; selected = `textPrimary` + 2-px `secondary` underline (full label width); unselected `textMuted`.

### 10.6 Energy components (domain visuals, still dumb)

| Component | Visual spec |
|---|---|
| **`BbCountdownRing`** | Sits on the hero card. 240-px ring (200 on small phones), 14-px stroke, round caps. Track = `textPrimary` @ 12%; arc = `primary` (Spark Yellow) while SoC > 50%, then the `batteryMid` / `batteryLow` status color, animated `slow`. The battery stat tile always shows icon + % beside it, so color is never the only signal. Center: `metricHero` "3h 20m" + `bodySmall` muted "left at 420 W". Below ring: `labelMedium` "Stops protecting battery at 50%". Overload → ring pulses once (`normal`) and a `danger` banner appears. |
| **`BbGridStatusPill`** | Pill 40 h. Grid on: `secondaryContainer` + Fill `lightning` in `energy.grid` + "Light hai". Grid off: `surfaceMuted` + Fill `lightningSlash` in `energy.offline` + "Light gayi · 1h 12m" (duration in `metricSmall`). Tapping logs the event (with haptic). |
| **`BbBatteryGauge`** | Horizontal battery glyph 64 × 28, 2-px `outline` body, fill in status token, % in `metricSmall` beside it. Always icon + number. |
| **`BbPowerFlow`** | Three nodes (Solar · Grid · Battery) flowing to Home, 48-px circles with Regular icons; connecting lines 2 px in each source's energy color, **dashed** when inactive; small moving dots (`slow`, disabled with reduced motion) show direction. |
| **`BbLoadToggleTile`** | `BbListTile` + appliance icon + name + `metricSmall` watts + `BbSwitch`. Shows `BbPriorityBadge`. When toggled, the countdown updates live. |
| **`BbPriorityBadge`** | `essential` = `secondaryContainer` "Keep"; `comfort` = `surfaceMuted` "Use carefully"; `avoid_on_backup` = `warningContainer` + `warning` icon "Avoid on backup". |
| **`BbSolarForecastStrip`** | Horizontal row of hourly bars (sunrise → sunset), bar = `energy.solar` fill with `solarStroke` top edge, hour labels every 3 h in `metricCaption`. Behind each bar a faint "clear day" bar (`textPrimary` @ 8%) shows what clouds take away; a legend names both. Bars grow in with `slow`. The header ("Sun today · 3.3–4.5 kWh · 49% less sun than a clear day") is composed by the screen above the strip. |
| **`BbHealthIndicator`** | Small semicircle gauge (health factor) in status token + `metricMedium` "82%" + `bodySmall` explanation. |

---

## 11. Screen Anatomy

All screens: `BbScaffold` → `BbAppBar` → optional `BbOfflineBanner` → content with `BbPagePadding` → optional sticky bottom CTA → `BbNavBar` (top-level tabs only).

**Dashboard (Home)**
```
[App bar]  "Assalam-o-alaikum"  ·  theme toggle · settings
[Grid status pill]                         ← tap = Light gayi / aa gayi
[Hero card: midnight `hero`, radius xl, dark-palette content]
     ( Countdown ring, yellow arc  3h 20m )
     "left at 420 W"  ·  [What should I turn off?]  ← primary (yellow) CTA
[Stat tiles 2×2, icon discs]  Battery 62% · Load 420 W · Solar today 3.8 kWh · Next outage 7:00 PM
[AI advice card: highlight variant (soft yellow), sparkle icon]
[Solar forecast strip]
[Nav bar]
```
Yellow budget: the CTA (inside the hero) + the advice tint. The ring arc and solar marks are data. The nav indicator is navy.

**Load Planner:** live `BbMetric` hero at top (sticky, updates on toggle) → "Turn off first" ranked list (`BbListTile` with `+2h 10m` in `success` `metricSmall`) → appliance toggles grouped by priority → target-hours `BbNumberField`.

**Solar:** answer first, zero taps.
```
[App bar]  "Solar"  ·  refresh
[BbChip Today | Tomorrow]                 ← auto-picks Tomorrow after sunset
[Hero card] "Battery full by 1:15 PM" / "Battery reaches 79% by sunset"
            "Starting from 60% now"  (assumption, muted)
            ( ring = SoC at sunset, "at sunset, 5:30 PM" )
            "Lasts until about 10:25 PM at 420 W"
[Advice card: highlight]  "Most sun 12–3 PM. Run the iron or water motor then." / "Weak sun… avoid heavy loads after 5:30 PM"
[Card] "Sun today" · 3.3–4.5 kWh (solarText) · cloud icon + "49% less sun than a clear day" · BbSolarForecastStrip
[Footer] timer icon · "Lahore · updated 20 min ago" · xs spinner while refreshing · retry on failure
```
No forecast yet → `BbEmptyState` "Needs internet once" with a loading `BbButton.secondary`. No panels → `BbEmptyState`. Performance check (F4) goes under the sun card later.

**Setup (first run):** `BbStepIndicator` (Home · Battery · Appliances) → one question block per topic (`titleMedium` question + muted hint saying where to find the answer) → answers as `BbChip`s, `BbChoiceCard`s and `BbQuantityStepper`s; follow-up questions appear only once they apply → sticky bottom bar: live backup time (from step 2) above a tonal Back icon button and the full-width primary Next / "Show my backup time". Next stays disabled until the step's required answers are in. Questions about numbers printed on a sticker carry a ghost "Where is this written?" (info icon) that expands, in place, a `surfaceMuted` drawing of the sticker: lines in `metricCaption` `textMuted`, the line to read on a `primaryContainer` marker in `metricSmall` with an arrow beside it (shape + color). The same screen, titled "Edit my home" with "Save changes", edits a saved home from Settings → My home (summary line + tonal "Edit my home" button).

**Estimator:** stepped form (`BbProgressBar` determinate, 3 steps) → 3 package cards (`BbCard`, recommended one = `highlight` variant + `primaryContainer` badge "Recommended") with PKR range in `metricMedium` → payback → installer checklist → disclaimer `bodySmall` muted + "prices last updated".

**Battery:** `BbHealthIndicator` → trend chart → warnings (`BbBanner`) → "My battery is kharab" (`secondary` button) → diagnosis sheet → recommendations → shops list (needs internet state).

**Assistant:** chat bubbles (`BbChatBubble`) — user = `secondary` fill + `onSecondary`, radius `lg` with 4-px tail corner; assistant = `surfaceMuted` fill; suggested prompts as `BbChip`s; numbers inside replies rendered in `metricSmall`; `BbTypingIndicator` while waiting.

---

## 12. Flutter Implementation Snippets

```dart
// packages/bb_ui/lib/src/foundations/primitives/color_primitives.dart
// LAYER 1 — package-private. Never exported, never used by widgets.
abstract final class CanvasP {
  static const c0 = Color(0xFFFFFFFF), c50 = Color(0xFFF6F4F0), c100 = Color(0xFFEDEAE4),
      c200 = Color(0xFFE2DED6), c300 = Color(0xFFCBC6BC), c400 = Color(0xFFA39D92),
      c500 = Color(0xFF857F74), c600 = Color(0xFF5E594F), c700 = Color(0xFF423E37),
      c800 = Color(0xFF2A2824), c850 = Color(0xFF211F1C), c900 = Color(0xFF1A1917),
      c950 = Color(0xFF121110);
}

abstract final class NavyP {
  static const c50 = Color(0xFFF1F3F8), c100 = Color(0xFFE3E7F0), c200 = Color(0xFFC6CEDF),
      c300 = Color(0xFFA3B2D1), c400 = Color(0xFF7C90BE), c500 = Color(0xFF5670A6),
      c600 = Color(0xFF3F5891), c700 = Color(0xFF2E4378), c800 = Color(0xFF1F2F57),
      c900 = Color(0xFF16213D), c950 = Color(0xFF0E1424);
}

abstract final class YellowP {
  static const c50 = Color(0xFFFFFBEB), c100 = Color(0xFFFFF3CC), c200 = Color(0xFFFFE7A3),
      c300 = Color(0xFFFFD666), c400 = Color(0xFFFFC93D), c500 = Color(0xFFFFC21A),
      c600 = Color(0xFFE6A800), c700 = Color(0xFFB38300), c800 = Color(0xFF8A6200),
      c900 = Color(0xFF4D3800), c950 = Color(0xFF2E2100);
}

abstract final class StatusP {
  static const success100 = Color(0xFFDDF3E4), success300 = Color(0xFF5CCB82),
      success600 = Color(0xFF1E7A3D), success900 = Color(0xFF0E3A1E);
  static const warning100 = Color(0xFFFFE6D2), warning300 = Color(0xFFFF9F5A),
      warning600 = Color(0xFFA34706), warning900 = Color(0xFF4A2004);
  static const danger100 = Color(0xFFFDE1DF), danger300 = Color(0xFFFF7A70),
      danger600 = Color(0xFFC42B22), danger900 = Color(0xFF4F1210);
}
```

```dart
// packages/bb_ui/lib/src/foundations/primitives/font_primitives.dart
abstract final class FontP {
  static const sans = 'Geist';
  static const regular = FontWeight.w400, medium = FontWeight.w500, semibold = FontWeight.w600;
}

// app_typography.dart (excerpt)
TextStyle get metricHero => const TextStyle(
      fontFamily: FontP.sans, fontSize: 60, height: 64 / 60,
      fontWeight: FontP.semibold, letterSpacing: -2.4,
      fontFeatures: [FontFeature.tabularFigures()],
    );
```

```dart
// packages/bb_ui/lib/src/foundations/icons.dart  (NEW)
import 'package:phosphor_icons/phosphor_icons.dart';

abstract final class BbIcons {
  static const home = PhosphorIconsRegular.house;
  static const homeActive = PhosphorIconsFill.house;
  static const gridOn = PhosphorIconsFill.lightning;
  static const gridOff = PhosphorIconsFill.lightningSlash;
  static const countdown = PhosphorIconsRegular.timer;
  // … one entry per row of the §6.4 table
}
```

---

## 13. Web Tokens (CSS variables)

For the landing page / web dashboard, use exactly the same values. Font via the `geist` npm package (self-hosted, full features incl. `tnum`); icons via `@phosphor-icons/react` or `@phosphor-icons/web`.

```css
:root {
  /* Brand — 60 / 30 / 10 */
  --bb-background: #F6F4F0;  --bb-surface: #FFFFFF;  --bb-surface-raised: #FFFFFF;
  --bb-surface-muted: #EDEAE4;  --bb-hero: #16213D;
  --bb-text: #0E1424;  --bb-text-muted: #5E594F;  --bb-text-on-primary: #0E1424;
  --bb-outline: #857F74;  --bb-outline-variant: #E2DED6;
  --bb-primary: #FFC21A;  --bb-primary-container: #FFF3CC;  --bb-on-primary-container: #4D3800;
  --bb-secondary: #1F2F57;  --bb-on-secondary: #FFFFFF;
  --bb-secondary-container: #E3E7F0;  --bb-on-secondary-container: #16213D;
  --bb-link: #2E4378;  --bb-focus: #3F5891;  --bb-skeleton: #EDEAE4;
  /* Status */
  --bb-success: #1E7A3D; --bb-success-container: #DDF3E4;
  --bb-warning: #A34706; --bb-warning-container: #FFE6D2;
  --bb-danger:  #C42B22; --bb-danger-container:  #FDE1DF; --bb-on-danger: #FFFFFF;
  /* Energy */
  --bb-solar: #FFC21A; --bb-solar-stroke: #B38300; --bb-solar-text: #8A6200;
  --bb-grid: #3F5891;  --bb-load: #423E37;  --bb-offline: #857F74;
  /* Type */
  --bb-font-sans: "Geist", system-ui, sans-serif;
  /* Space (4-pt) */
  --bb-space-xxs: 2px; --bb-space-xs: 4px; --bb-space-sm: 8px; --bb-space-md: 12px;
  --bb-space-lg: 16px; --bb-space-xl: 24px; --bb-space-xxl: 32px; --bb-space-xxxl: 48px;
  --bb-space-xxxxl: 64px;
  /* Radius */
  --bb-radius-xs: 4px; --bb-radius-sm: 8px; --bb-radius-md: 12px;
  --bb-radius-lg: 20px; --bb-radius-xl: 28px; --bb-radius-pill: 999px;
  /* Motion */
  --bb-fast: 150ms; --bb-normal: 250ms; --bb-slow: 400ms;
  --bb-ease: cubic-bezier(0.33, 1, 0.68, 1); /* easeOutCubic */
}

[data-theme="dark"] {
  --bb-background: #121110;  --bb-surface: #1A1917;  --bb-surface-raised: #211F1C;
  --bb-surface-muted: #2A2824;  --bb-hero: #16213D;
  --bb-text: #EDEAE4;  --bb-text-muted: #A39D92;  --bb-text-on-primary: #0E1424;
  --bb-outline: #857F74;  --bb-outline-variant: #2A2824;
  --bb-primary: #FFC93D;  --bb-primary-container: #2E2100;  --bb-on-primary-container: #FFE7A3;
  --bb-secondary: #A3B2D1;  --bb-on-secondary: #0E1424;
  --bb-secondary-container: #16213D;  --bb-on-secondary-container: #E3E7F0;
  --bb-link: #A3B2D1;  --bb-focus: #FFC93D;  --bb-skeleton: #2A2824;
  --bb-success: #5CCB82; --bb-success-container: #0E3A1E;
  --bb-warning: #FF9F5A; --bb-warning-container: #4A2004;
  --bb-danger:  #FF7A70; --bb-danger-container:  #4F1210; --bb-on-danger: #0E1424;
  --bb-solar: #FFC93D; --bb-solar-stroke: #FFC93D; --bb-solar-text: #FFC93D;
  --bb-grid: #7C90BE;  --bb-load: #CBC6BC;  --bb-offline: #857F74;
}

/* System default when no explicit choice is stored */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) { /* copy the [data-theme="dark"] block */ }
}

body { background: var(--bb-background); color: var(--bb-text); font-family: var(--bb-font-sans); }
.bb-metric { font-variant-numeric: tabular-nums; font-weight: 600; }
/* .bb-hero: background var(--bb-hero), with the [data-theme="dark"] variables applied inside it. */
```

Web layout follows §4.2 (expanded: 12 columns, 32-px margins, 24-px gutters, 1080-px max width). Web breakpoints: `< 600`, `600–840`, `> 840` — identical to the app.

---

## 14. Governance & Review Checklist

### 14.1 Changing the design system

1. Change values only in `primitives/` or `semantic/` (or this file + CSS block). Never in features.
2. New token → light value + dark value + `contrast_test.dart` entry + update this file + TECH_STACK §6 if it's a name change.
3. New component → Gallery entry + goldens (light/dark × text scale 1.0/1.5) + section in §10.
4. Update the CSS variables in §13 in the same PR so web and app never drift.

### 14.2 Screen review checklist (add to PR template)

- [ ] No borders on containers (cards, sheets, bars, bubbles); separation by surface color + elevation only
- [ ] Only canvas / navy / yellow + status colors used; **≤ 1 yellow CTA** and ≤ 1 other yellow highlight per viewport; ≤ 1 midnight hero per screen
- [ ] No yellow text or yellow icons on light surfaces
- [ ] Every status shown with color **+** icon **+** text/number
- [ ] Only Geist; every live number uses a `metric*` style (tabular figures); weights 400/500/600 only
- [ ] All spacing from the 4-pt tokens; side margins from `BbPagePadding`
- [ ] Left-aligned content, numbers right-aligned in lists, value+unit baseline-aligned
- [ ] Only Phosphor via `BbIcons`; Regular default, Fill for selected/status, Duotone only in empty states
- [ ] Loading uses one of the 5 patterns in §8.1; no full-screen spinner; skeleton mirrors final layout
- [ ] Offline banner & stale timestamps work in airplane mode
- [ ] Checked in light **and** dark, at text scale 1.0 **and** 1.5
- [ ] Touch targets ≥ 48 × 48; semantic labels on icon-only buttons
- [ ] `tool/check_design_tokens.sh` passes

### 14.3 Additions to `tool/check_design_tokens.sh`

Also fail the build if any file outside `bb_ui/lib/src/foundations/` and `bb_ui/lib/src/theme/` contains (whole-identifier matches, so `BbIcons.` is allowed):
- `lucide`, `Icons.` (Material icons), `CupertinoIcons.`, `PhosphorIcons` (must go through `BbIcons`)
- `CircularProgressIndicator(` or `LinearProgressIndicator(` (must use `BbSpinner` / `BbProgressBar`)
- `fontFamily:` or `google_fonts`

---

## 15. References & Inspiration

| Source | What we took from it |
|---|---|
| Material Design 3 — color roles & tone-based surfaces (m3.material.io; Flutter "new ColorScheme roles" migration guide) | Role-based color tokens, `surfaceContainer*` hierarchy, replacing deprecated `background`/`surfaceVariant`, state-layer opacities, window size classes (compact/medium/expanded) |
| Mobbin — iOS / Android energy, fintech & utility apps | Patterns: single hero metric per screen, bottom nav with 4–5 tabs, pill indicators, stat-tile grids, skeletons that mirror layout |
| Dribbble / Contra energy & solar monitoring concepts (2025–2026) | Dark-first dashboards with one bright accent on near-black, purpose-coded energy colors, tabular numerals for live data |
| Vercel Geist (vercel.com/font) | Geist with tabular figures, Swiss-minimal tone, self-hosted for full OpenType features |
| Team-shared Dribbble references (2026-10): insurance app (warm gradient hero, charcoal pill CTAs), mental-health app (dark emphasis card beside white cards, tinted nav pill), calorie tracker (warm beige canvas, one orange accent, large sans numbers) | v2: warm neutral canvas, one dark hero mass, a single saturated accent, big **sans** numbers, generous radii, pill buttons, two-layer soft shadows |
| Phosphor Icons (phosphoricons.com, `phosphor_icons` on pub.dev) | One consistent icon family with Regular/Fill/Duotone weights |
| WCAG 2.2 AA | 4.5:1 text, 3:1 large text & UI boundaries — verified in §2.8 |

---

*Owner: design-system maintainers of `packages/bb_ui`. Any change to values here must land together with the matching Dart and CSS changes.*
