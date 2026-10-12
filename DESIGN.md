# DESIGN.md — Backup Brain Design System

> **Status:** v3 "Quiet Home" (2026-10-12): cool mist background, white cards with large radii and soft indigo-tinted shadows, deep indigo ink, one coral accent, Manrope. The single source of truth for every visual value (colors, fonts, spacing, icons, component visuals). `TECH_STACK.md` §6 only defines token *names* and theme mechanics.
> **Read together with:** `TECH_STACK.md` §6 (token *names*, layers, theme mechanics) and `ARCHITECTURE.md` §10 (screens). Start at `CLAUDE.md` for the doc map.
> **Contract (from TECH_STACK §6.1):** this file owns token **values**, icon style, component visuals and screen layouts. It does **not** rename or remove any token. New tokens are marked **`NEW`** and each has a light value, a dark value and a contrast-test entry.
> **Scope:** the Flutter app (`packages/bb_ui`) **and** any future website / landing page. Section 13 gives the same tokens as CSS variables so the web stays identical.

---

## Table of Contents

1. [Design Principles](#1-design-principles)
2. [Color System — Mist · Indigo · Coral, 60 · 30 · 10](#2-color-system--mist--indigo--coral-60--30--10)
3. [Typography — Manrope](#3-typography--manrope)
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

Brand direction: **Quiet Home** — a cool mist background, white cards with large radii and soft indigo-tinted shadows, deep indigo ink and **one** coral accent.

| # | Principle | What it means on screen |
|---|---|---|
| 1 | **Calm in a crisis** | Users open the app *during* a power cut, often in a dark room at night. Quiet mist background, white cards, one loud thing (the number they need), no clutter. |
| 2 | **The number is the hero** | Every screen leads with one big metric (backup time, kWh, PKR). Labels are small and muted; numbers are large, Manrope ExtraBold with tabular figures. |
| 3 | **One color = one meaning** | Coral = the screen's main action and active marks. Indigo = ink, structure, selected states & grid. Amber = solar only. Green/amber/red = battery status only. Nothing is colored "for decoration". |
| 4 | **Minimal, not empty** | Containers separated by surface color and soft shadow — never borders. Generous whitespace. Density comes from good alignment, not boxes. |
| 5 | **Honest & offline-first** | Show cached data instantly with its age ("updated 3 h ago"). Never block the screen with a spinner. Never fake precision — show ranges. |
| 6 | **Readable in Lahore sunlight, gentle at 2 AM** | Light theme is high-contrast for strong sun; dark theme is a designed deep indigo night (not inverted) for night outages. |

---

## 2. Color System — Mist · Indigo · Coral, 60 · 30 · 10

### 2.1 The three brand colors

The app uses **exactly three brand color families**. Everything else is a tint/shade of these three, plus *functional* colors (§2.3) that only ever communicate solar energy (amber) or battery/safety state (green/amber/red).

| Role | Name | Core value | Share of screen | Used for |
|---|---|---|---|---|
| **Primary — 60%** | **Mist** (cool neutral, hue ≈ 225°) | Light page `#EEF1F6` with white `#FFFFFF` cards · Dark `#0E1024` | ~60% | Backgrounds, surfaces, cards, sheets, dividers, muted text. The quiet base that lets numbers breathe. |
| **Secondary — 30%** | **Indigo** | `#1B1F3B` (indigo900, the text ink); `#414BA4` (indigo600) for links, info and grid | ~30% | All primary text and icons, the indigo hero card, secondary buttons, selected states (nav pill, chips, switches), links, info banners, **grid power** in charts. |
| **Accent — 10%** | **Coral** | Light `#FF6B4A` · Dark `#FF876B` | ~10% | The one primary CTA per screen and active marks (count badge, recommended badge), the highlight card tint, the dark-theme focus ring. |

**Why this palette**

- **Mist** neutrals are cool (hue ≈ 225°), the same family as the indigo ink, so base and ink read as one calm palette. White cards float on the mist page, separated by large radii and soft indigo-tinted shadows instead of lines.
- **Indigo** is used deep (`indigo900`) as near-black ink and for structure; lighter indigo (`indigo600` light / `indigo300` dark) carries links, info and grid power.
- **Coral** is the one warm accent in the interface (amber appears only as solar data). Against cool mist and indigo it is the one thing that stands out, so it is reserved for the 10% that must be noticed: the screen's main action and active marks.
- **Amber** is kept for solar only, so the sun has its own color and never reads as a button.
- **Dark theme** is a deep indigo night: mist 950/900/850 surfaces, coral 400 as primary and `CoralP.night` (`#34213A`, a coral glow on indigo) for highlight cards.

> **Naming note for developers.** In the 60-30-10 rule "primary" means the *dominant* (mist) color. In Material 3 / our `AppColors`, `primary` means the *main action* color. So in code: **`colors.primary` = Coral (accent)**, `colors.secondary` = Indigo, `colors.surface/background` = Mist. The mapping table in §2.4 is the source of truth.

### 2.2 Primitives (LAYER 1 — `color_primitives.dart`, package-private)

Widgets never use these directly. They exist only so semantic tokens (§2.4) can reference them.

**`MistP` — cool neutral (Primary, 60%)**

| Step | 0 | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 850 | 900 | 950 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Hex | `#FFFFFF` | `#F6F7FB` | `#EEF1F6` | `#E3E7F0` | `#CDD3E1` | `#A3AAC2` | `#7C84A3` | `#555D80` | `#3F4668` | `#282D4C` | `#1F2340` | `#181B33` | `#0E1024` |

`MistP.black` `#000000` exists only for the dark-theme scrim; never text or surfaces.

**`IndigoP` — ink (Secondary, 30%)**

| Step | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | 950 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Hex | `#F0F1FA` | `#E3E6F7` | `#C7CCEE` | `#A6AEE6` | `#7F89D6` | `#5965C2` | `#414BA4` | `#313884` | `#262B66` | `#1B1F3B` | `#12152A` |

**`CoralP` — accent (10%)**

| Step | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | 950 | night |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Hex | `#FFF4F1` | `#FFE4DD` | `#FFC7B9` | `#FF9F88` | `#FF876B` | `#FF6B4A` | `#E5502F` | `#B83C20` | `#8A2D18` | `#4D190D` | `#2E1008` | `#34213A` |

`CoralP.night` is the coral glow on the indigo night: the dark-theme `primaryContainer` (highlight cards).

### 2.3 Functional colors (not brand colors)

These are **not** part of the 3-color palette and never appear decoratively.

**`AmberP` — solar only, never actions**

| Step | 100 | 300 | 400 | 500 | 700 | 800 |
|---|---|---|---|---|---|---|
| Hex | `#FFF1D6` | `#FFCF73` | `#FFC04D` | `#F5A623` | `#A86A00` | `#7F5000` |

**`StatusP` — battery level, success/warning/danger feedback, overload, destructive actions**

| Scale | 100 | 300 | 600 | 900 |
|---|---|---|---|---|
| success (green) | `#DDF4EA` | `#52D29D` | `#137A54` | `#0B3A28` |
| warning (amber-orange — kept redder than solar amber) | `#FFEBD3` | `#FFB25C` | `#9E4A00` | `#4A2600` |
| danger (red) | `#FDE2E5` | `#FF7D8C` | `#C4283C` | `#4F0F18` |

> **Never color alone:** every status = color **+** Phosphor icon **+** text/number. Example: battery low = red + `batteryLow` icon + "12%".

### 2.4 Semantic tokens (LAYER 2 — `palettes_light.dart` / `palettes_dark.dart`)

Token names follow `TECH_STACK.md` §6; tokens marked **NEW** were added here.

**AppColors**

| Token | Light | Dark | Notes |
|---|---|---|---|
| `background` | mist100 `#EEF1F6` | mist950 `#0E1024` | Scaffold. Maps to M3 `surface` (see §2.6). |
| `surface` | mist0 `#FFFFFF` | mist900 `#181B33` | Cards, sheets, nav bar. |
| `surfaceRaised` | mist0 `#FFFFFF` + `elevation.level2` shadow | mist850 `#1F2340` | Menus, bottom sheets, dialogs. Dark mode uses a lighter surface, not a shadow. |
| `surfaceMuted` | mist100 `#EEF1F6` | mist800 `#282D4C` | Input fills, tonal buttons, segmented track, icon discs, gauge track. |
| `hero` **NEW** | indigo900 `#1B1F3B` | indigo800 `#262B66` | Hero cards (Solar). Its content is drawn with the **dark** palette (§10.3), so it needs no on-hero tokens. |
| `textPrimary` | indigo900 `#1B1F3B` | mist100 `#EEF1F6` | Body, titles, numbers. Off-white in dark, never `#FFFFFF`. |
| `textMuted` | mist600 `#555D80` | mist400 `#A3AAC2` | Labels, captions, units, placeholders, timestamps. |
| `textOnPrimary` | indigo950 `#12152A` | indigo950 `#12152A` | Indigo ink on coral, in both themes. |
| `outline` | mist500 `#7C84A3` | mist500 `#7C84A3` | Input borders, focus-less boundaries (≥ 3:1). |
| `outlineVariant` | mist200 `#E3E7F0` | mist800 `#282D4C` | Hairline list dividers, chart gridlines. Never a container border. |
| `primary` | coral500 `#FF6B4A` | coral400 `#FF876B` | **Fill only.** Primary CTA, active marks. Never text/icon on light surfaces. |
| `primaryContainer` | coral100 `#FFE4DD` | `CoralP.night` `#34213A` | Highlight card (AI advice), "recommended" tags. |
| `onPrimaryContainer` **NEW** | coral900 `#4D190D` | coral200 `#FFC7B9` | Text/icons on `primaryContainer`. |
| `secondary` **NEW** | indigo900 `#1B1F3B` | indigo300 `#A6AEE6` | Secondary buttons, selected chip/segment/switch, nav pill. |
| `onSecondary` **NEW** | mist0 `#FFFFFF` | indigo950 `#12152A` | Text/icons on `secondary`. |
| `secondaryContainer` **NEW** | indigo100 `#E3E6F7` | indigo800 `#262B66` | Info banner, selected list row, "Keep" badge, grid icon disc. |
| `onSecondaryContainer` **NEW** | indigo900 `#1B1F3B` | indigo100 `#E3E6F7` | Text on `secondaryContainer`. |
| `link` **NEW** | indigo600 `#414BA4` | indigo300 `#A6AEE6` | Inline links & text buttons (underlined on press). |
| `focusRing` **NEW** | indigo600 `#414BA4` | coral400 `#FF876B` | 2 px focus outline, offset 2 px. |
| `success` / `successContainer` | success600 / success100 | success300 / success900 | |
| `warning` / `warningContainer` | warning600 / warning100 | warning300 / warning900 | |
| `danger` / `dangerContainer` | danger600 / danger100 | danger300 / danger900 | |
| `onDanger` **NEW** | mist0 `#FFFFFF` | indigo950 `#12152A` | Text/icons on a `danger` fill (`BbButton.danger`). Same values as M3 `onError` (§2.6). |
| `info` | indigo600 `#414BA4` | indigo300 `#A6AEE6` | Info = secondary family (no 4th hue). |
| `skeleton` **NEW** | mist200 `#E3E7F0` | mist800 `#282D4C` | Skeleton blocks (§8). |
| `scrim` **NEW** | indigo950 `#12152A` @ 40% | `#000000` @ 60% | Behind sheets/dialogs. |

### 2.5 Energy colors (`EnergyColors` ThemeExtension)

Energy meanings use indigo, mist, amber (solar) and the status colors — no extra hues. Coral never means energy.

| Token | Light | Dark | Meaning / rule |
|---|---|---|---|
| `energy.solar` (fill) | amber500 `#F5A623` | amber400 `#FFC04D` | Large fills only (area charts, bars). In light mode always paired with a `solarStroke` edge. |
| `energy.solarStroke` **NEW** | amber700 `#A86A00` | amber400 `#FFC04D` | Lines, thin marks, small icons on light (≥ 3:1). |
| `energy.solarText` | amber800 `#7F5000` | amber300 `#FFCF73` | Any solar text such as "4.2 kWh". |
| `energy.grid` | indigo600 `#414BA4` | indigo300 `#A6AEE6` | WAPDA/DISCO grid. |
| `energy.load` | mist700 `#3F4668` | mist300 `#CDD3E1` | Household consumption. In charts drawn as **dashed** line to separate from grid. |
| `energy.batteryHigh` (> 50%) | success600 | success300 | Always + icon + %. |
| `energy.batteryMid` (20–50%) | warning600 | warning300 | |
| `energy.batteryLow` (< 20%) | danger600 | danger300 | |
| `energy.offline` / grid down | mist500 `#7C84A3` | mist500 `#7C84A3` | With `lightningSlash` icon. |

`EnergyColors.battery(soc)` picks the status color: > 50% high, ≥ 20% mid, else low. `BbBackupGauge` and `BbCountdownRing` both draw their arc with it.

**Chart series order** (`EnergyColors.chartSeries`): solar → grid → load (dashed) → battery (status color for current level) → "other" mist400. Chart gridlines = `outlineVariant`, axis labels = `textMuted` in `metricCaption`.

### 2.6 Material 3 `ColorScheme` mapping (`color_scheme_builder.dart`)

Flutter's M3 `ColorScheme` deprecated `background`, `onBackground` and `surfaceVariant` in favour of `surface`, `onSurface` and the tone-based `surfaceContainer*` roles. Our `AppColors.background` stays as a token but feeds the M3 surface roles like this:

| M3 role | Light | Dark |
|---|---|---|
| `primary` / `onPrimary` | coral500 / indigo950 | coral400 / indigo950 |
| `primaryContainer` / `onPrimaryContainer` | coral100 / coral900 | `CoralP.night` / coral200 |
| `secondary` / `onSecondary` | indigo900 / mist0 | indigo300 / indigo950 |
| `secondaryContainer` / `onSecondaryContainer` | indigo100 / indigo900 | indigo800 / indigo100 |
| `tertiary` (+ container) | = secondary values | = secondary values (we deliberately have no 4th hue) |
| `error` / `onError` / `errorContainer` / `onErrorContainer` | danger600 / mist0 / danger100 / indigo950 | danger300 / indigo950 / danger900 / mist100 |
| `surface` / `onSurface` | mist100 / indigo900 | mist950 / mist100 |
| `surfaceContainerLowest` | mist0 | mist950 |
| `surfaceContainerLow` | mist0 | mist900 |
| `surfaceContainer` | mist0 | mist900 |
| `surfaceContainerHigh` | mist50 | mist850 |
| `surfaceContainerHighest` | mist200 | mist800 |
| `onSurfaceVariant` | mist600 | mist400 |
| `outline` / `outlineVariant` | mist500 / mist200 | mist500 / mist800 |
| `inverseSurface` / `onInverseSurface` | indigo900 / mist100 | mist100 / indigo900 |
| `inversePrimary` | coral400 | coral500 |
| `surfaceTint` | `Colors.transparent` (we do not tint elevated surfaces) | same |
| `scrim` / `shadow` | indigo950 / indigo950 | black / black |

Never use `ColorScheme.fromSeed` — it would generate hues outside our families.

### 2.7 Color usage rules

1. **60-30-10 budget per screen.** Mist fills the screen; indigo carries text, icons, structure and selected states; coral appears in at most **one CTA + one highlight** per viewport. The nav pill is indigo, not coral. If a screen has two coral buttons, one of them is wrong.
2. **Coral is a fill, never text on light.** Coral500 on white is 2.8:1. Use `textOnPrimary` ink *on* coral.
3. **Indigo ink on coral, always.** Coral buttons/pills carry `textOnPrimary` (6.4:1 light, 7.7:1 dark). Never white on coral (2.8:1).
4. **Amber is for solar only**, never for actions. **Status colors are for status.** Green ≠ "nice", red ≠ "brand". A green button does not exist; a red button only exists as `BbButton.danger` for destructive actions.
5. **No gradients**, except the 2-stop solar area fill in charts (`energy.solar` 32% → 0% alpha) and the **auth "sky"** on Sign up / Login: `secondary` → `secondaryContainer` → `background` (dark: `secondaryContainer` → `surface` → `background`) with a solid `primary` sun disc in the corner. Never through grey; titles on it use `onSecondary` (dark: `onSecondaryContainer`).
6. **No pure black or pure white text** in dark mode. Mist950 is the darkest pixel; mist100 is the brightest text.
7. **Opacity, not new colors,** for states: pressed overlay = `textPrimary` @ 12%, hover @ 8%, disabled content @ 38% (TECH_STACK `opacity.dart`).

### 2.8 Contrast audit (WCAG 2.x, computed)

The pairs below are checked in `contrast_test.dart` (plus `textPrimary` on each container and `info` on `secondaryContainer`). Ratios are computed from the hex values above. All pass.

| Foreground | Background | Light | Dark | Min |
|---|---|---|---|---|
| `textPrimary` | `surface` | 16.1:1 | 14.9:1 | 4.5:1 |
| `textPrimary` | `background` | 14.2:1 | 16.6:1 | 4.5:1 |
| `textPrimary` | `surfaceMuted` | 14.2:1 | 11.8:1 | 4.5:1 |
| `textMuted` | `surface` | 6.4:1 | 7.3:1 | 4.5:1 |
| `textMuted` | `surfaceMuted` | 5.7:1 | 5.8:1 | 4.5:1 |
| `textOnPrimary` | `primary` | 6.4:1 | 7.7:1 | 4.5:1 |
| `onSecondary` | `secondary` | 16.1:1 | 8.4:1 | 4.5:1 |
| `onSecondaryContainer` | `secondaryContainer` | 13.0:1 | 10.5:1 | 4.5:1 |
| `onPrimaryContainer` | `primaryContainer` | 11.9:1 | 9.9:1 | 4.5:1 |
| `textPrimary` | `primaryContainer` | 13.3:1 | 13.0:1 | 4.5:1 |
| `onDanger` | `danger` | 5.7:1 | 7.3:1 | 4.5:1 |
| `link` | `surface` | 7.6:1 | 7.9:1 | 4.5:1 |
| `outline` | `surface` | 3.7:1 | 4.6:1 | 3.0:1 |
| `outline` | `background` | 3.3:1 | 5.1:1 | 3.0:1 |
| `success` | `surface` | 5.3:1 | 8.9:1 | 4.5:1 |
| `success` | `successContainer` | 4.6:1 | 6.7:1 | 4.5:1 |
| `warning` | `surface` | 6.1:1 | 9.5:1 | 4.5:1 |
| `warning` | `warningContainer` | 5.3:1 | 7.5:1 | 4.5:1 |
| `danger` | `surface` | 5.7:1 | 6.9:1 | 4.5:1 |
| `danger` | `dangerContainer` | 4.6:1 | 6.1:1 | 4.5:1 |
| `energy.solarText` | `surface` | 6.9:1 | 11.6:1 | 4.5:1 |
| `energy.solarStroke` | `surface` | 4.4:1 | 10.4:1 | 3.0:1 |
| `energy.grid` | `surface` | 7.6:1 | 7.9:1 | 3.0:1 |
| `energy.load` | `surface` | 9.2:1 | 11.3:1 | 3.0:1 |
| `energy.offline` | `surface` | 3.7:1 | 4.6:1 | 3.0:1 |

**Hero island** (dark-palette tokens on `hero`; light hero indigo900 / dark hero indigo800): `textPrimary` 14.2 / 11.5:1 · `textMuted` 7.0 / 5.6:1 · `primary` 6.8 / 5.5:1 · `warning` 9.0 / 7.3:1 · `danger` 6.6 / 5.3:1 · `focusRing` 6.8 / 5.5:1.

**Known exception (documented):** `energy.solar` fill on light `surface` is 2.0:1. It is therefore only used for large areas and always has a `solarStroke` edge or an adjacent label — the meaning never depends on the fill alone.

---

## 3. Typography — Manrope

### 3.1 Families (max 2)

| # | Family | Role | Status |
|---|---|---|---|
| 1 | **Manrope** (Sans) | All text **and all numbers** | Active |
| 2 | *Noto Nastaliq Urdu* | Fallback family for Urdu script (future stretch goal) | Reserved — not bundled yet |

Roman Urdu uses Manrope (Latin). No other fonts are allowed in the app or on the website.

**Numbers use Manrope with tabular figures, not a monospace.** `FontFeature.tabularFigures()` gives every digit the same width, so "3h 20m → 3h 19m" never jitters and columns line up, without making numbers look like code. Every metric style uses Manrope + tabular figures.

**The one rule to remember:** *if a number can change while you look at it, it uses a `metric*` style.* Static numbers inside sentences ("Turn off 2 fans") stay in the body style.

### 3.2 Bundling (offline requirement)

- Static TTFs live in `packages/bb_ui/assets/fonts/` (`Manrope-400.ttf` … `Manrope-800.ttf`) with `OFL.txt` (SIL Open Font License 1.1, The Manrope Project Authors, github.com/googlefonts/manrope).
- Fonts are declared in `bb_ui`'s pubspec, so every style names the package (`FontP.package = 'bb_ui'`).
- **Do not use the `google_fonts` package**: it fetches at runtime and breaks offline.

```yaml
# packages/bb_ui/pubspec.yaml
flutter:
  fonts:
    - family: Manrope
      fonts:
        - asset: assets/fonts/Manrope-400.ttf
          weight: 400
        - asset: assets/fonts/Manrope-500.ttf
          weight: 500
        - asset: assets/fonts/Manrope-600.ttf
          weight: 600
        - asset: assets/fonts/Manrope-700.ttf
          weight: 700
        - asset: assets/fonts/Manrope-800.ttf
          weight: 800
```

### 3.3 Weights

| Weight | Name (`FontP`) | Use |
|---|---|---|
| 400 | Regular (`regular`) | Bundled; no type role uses it today |
| 500 | Medium (`medium`) | Body text (`body*`) |
| 600 | SemiBold (`semibold`) | Labels, buttons, `metricSmall`, `metricCaption`, unselected nav label |
| 700 | Bold (`bold`) | `headlineSmall`, `title*`, `metricMedium` |
| 800 | ExtraBold (`extrabold`) | `displaySmall`, `headlineMedium`, `metricHero`, `metricLarge`, selected nav label |

No Light/Thin. Big numbers are the heaviest thing on screen; everything else steps down by size, weight and color.

### 3.4 Type scale (`AppTypography` + Material `TextTheme`)

Sizes in logical px (sp). Line heights on a 4-pt rhythm (except `metricLarge`). Negative tracking on large sizes; big numbers get the tightest tracking.

| Role | Family | Size / Line | Weight | Tracking | Use |
|---|---|---|---|---|---|
| `displaySmall` | Manrope | 32 / 40 | 800 | −1.0 | Onboarding hero, estimator result headline |
| `headlineMedium` | Manrope | 28 / 36 | 800 | −0.8 | Screen title (large app bar) |
| `headlineSmall` | Manrope | 24 / 32 | 700 | −0.5 | Sheet / dialog titles |
| `titleLarge` | Manrope | 20 / 28 | 700 | −0.3 | Section titles |
| `titleMedium` | Manrope | 16 / 24 | 700 | −0.1 | Card titles, list primary text (emphasised) |
| `titleSmall` | Manrope | 14 / 20 | 700 | 0 | Small card headers, list row titles |
| `bodyLarge` | Manrope | 16 / 24 | 500 | 0 | Main reading text, chat messages |
| `bodyMedium` | Manrope | 14 / 20 | 500 | 0 | Default body, list secondary text |
| `bodySmall` | Manrope | 12 / 16 | 500 | +0.1 | Captions, helper text, disclaimers |
| `labelLarge` | Manrope | 14 / 20 | 600 | +0.1 | Buttons, tabs, segmented control |
| `labelMedium` | Manrope | 12 / 16 | 600 | +0.2 | Chips, badges, nav labels |
| `labelSmall` | Manrope | 11 / 16 | 600 | +0.4 | Overlines (UPPERCASE allowed only here) |
| `metricHero` | Manrope `tnum` | 56 / 60 | 800 | −2.4 | Backup time "3h 20m" |
| `metricLarge` | Manrope `tnum` | 32 / 38 | 800 | −1.2 | Stat tiles (kWh, %, PKR) |
| `metricMedium` | Manrope `tnum` | 20 / 24 | 700 | −0.4 | Package prices, secondary stats, units of `metricLarge` |
| `metricSmall` | Manrope `tnum` | 16 / 20 | 600 | −0.1 | Inline numbers in lists ("+2h 10m", "750 W") |
| `metricCaption` | Manrope `tnum` | 12 / 16 | 600 | 0 | Chart axes, timestamps, "updated 3 h ago" times |

Default text color = `textPrimary`; secondary text = `textMuted`. Feature code never sets color/size on text — it picks a role.

### 3.5 Typography rules

1. **Value + unit pattern:** the value uses a metric style; the unit uses the same family one step smaller in `textMuted`, **baseline-aligned** (`Row` with `CrossAxisAlignment.baseline`). E.g. **`3h 20m`** `left` · **`420`** `W` · `PKR` **`1,85,000`**.
2. **Currency:** PKR with South-Asian grouping when `ur_Latn` / `en_PK` locale is active (`1,85,000`), formatted only via `core/utils` formatters.
3. **Line length:** body text max ~60 characters per line on tablets/web (`maxWidth: 560`).
4. **Text scale:** every screen must work at system text scale **1.0 and 1.5** (TECH_STACK §6.6). `metricHero` may clamp at 1.3× to keep the ring readable; nothing else clamps.
5. **Truncation:** titles 1 line + ellipsis; list secondary text max 2 lines; never truncate numbers (they scale down to fit instead).
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
| Card (`BbCard`) | 16 all sides (24 for hero card) | 12 between rows |
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
| `md` | 14 | Inputs, segmented control |
| `lg` | 24 | Cards, stat tiles, banners, dialogs |
| `xl` | 32 | Bottom sheets (top corners), hero card, floating nav bar |
| `pill` | 999 | **Buttons**, chips, nav indicator, grid status pill, switches |

Nested radius rule: inner radius = outer radius − padding (e.g. 24-px card with 8-px inset → 16-px inner element).

Large, soft corners and pill buttons are part of the Quiet Home look: a pill reads as "tappable" at a glance.

### 5.2 Borders

- **Containers never have borders.** Cards, sheets, nav bar, app bar and chat bubbles are separated from the page by surface color contrast plus elevation (§5.3): light = white `surface` on mist `background` + `level1` shadow; dark = `surface` on `background` (lighter surface, no shadow).
- **Never nest elevated surfaces.** A card does not contain another shadowed card; inner groups use `surfaceMuted` fill instead.
- **Interactive states change background, not borders** (pressed/hover overlays, selected fills).
- **Exceptions (accessibility):** inputs keep a 1 px `outline` boundary (WCAG 1.4.11, ≥ 3:1). Focus is a separate 2 px `focusRing` outline offset 2 px, always visible. Input error = `dangerContainer` fill + `danger` helper text + `warning` icon, not a border change.
- Dividers: 1 px `outlineVariant`, inset 16 from the leading edge, only *between rows inside* one list group.

### 5.3 Elevation (`elevation.dart`)

| Level | Light (y offset · blur · alpha of indigo950 `#12152A`) | Dark | Used by |
|---|---|---|---|
| `level0` | No shadow | `background` | Flat page content, inner groups (`surfaceMuted` fill) |
| `level1` | `0 1 2 rgba(18,21,42,.05)` + `0 10 30 rgba(18,21,42,.07)` | `surface` | Cards, list groups, sticky bottom CTA bar (cast upward) |
| `level2` | `0 2 4 rgba(18,21,42,.06)` + `0 14 36 rgba(18,21,42,.10)` | `surfaceRaised` | Floating nav bar, menus, dropdowns, toasts |
| `level3` | `0 4 8 rgba(18,21,42,.08)` + `0 24 56 rgba(18,21,42,.16)` | `surfaceRaised` | Bottom sheets, dialogs |

Shadows have two layers (a tight contact shadow plus a wide ambient one), are tinted with indigo950 (never pure black), and are very soft. In dark mode `shadows()` returns none: elevation = lighter surface.

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
| **Fill** | Selected nav tab, active toggle states, status icons inside banners/badges, icon inside a coral/indigo filled button. |
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

Icon color always comes from a token: `textPrimary` (default), `textMuted` (secondary), `secondary` (selected), status/energy tokens for meaning. Icons on coral use `textOnPrimary`.

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
| `remove` · `delete` | `minus` · `trash` | Step a value down · delete a row (e.g. a schedule time) |
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
| `fast` | 150 ms | `easeOutCubic` (`enter`) | Press states, toggles, chip select, icon swap, nav label weight |
| `normal` | 250 ms | `easeOutCubic` (enter) / `easeInCubic` (exit) | Cards, banners, rolling numbers, nav pill slide, theme cross-fade |
| `slow` | 400 ms | `easeInOutCubic` (`emphasized`) | Countdown ring value change, bottom sheet, chart reveal, `BbAppear` entrance |
| `skeletonPulse` **NEW** | 1200 ms loop | `easeInOut` (`pulse`) | Skeleton opacity pulse (§8.2) |

**Where motion is used**

| Motion | Spec |
|---|---|
| **Press** | Every control built on `Tappable` scales to **0.97** while pressed (`fast`, `easeOutCubic`); scale never moves the layout around it. `BbButton` also scales its own body to 0.98 inside that. |
| **Rolling numbers** | `BbMetric`: when the value changes, the new value fades in rising from 35% of its height below while the old one fades out upward (`normal`, enter/exit curves). |
| **Entrance (`BbAppear`)** | Content fades in while rising **16 px** (`slow`, `easeOutCubic`). Each `index` starts **45 ms** after the previous (capped at 8 steps). Plays once on first build; kept alive so a section scrolled off and back does not replay. `BbScaffold` wraps every screen body in `BbAppear`; Home also staggers its sections (§11). |
| **Nav bar** | The indigo pill slides to the selected tab (`normal`, `easeInOutCubic`); the selected icon pops to 1.08 with `Curves.easeOutBack` (`normal`); the label weight changes 600 → 800 (`fast`). |
| **Gauge sweep** | `BbBackupGauge` fills from empty to the charge over 800 ms (`slow` × 2, `easeOutCubic`) when it appears, and glides when the charge changes. |
| **Countdown ring** | Arc tweens to the new charge (`slow`, `easeInOutCubic`); overload → one 4% pulse (`normal`). |
| **Page transitions** | `FadeForwardsPageTransitionsBuilder` on every platform: pages fade and slide forward together. |

Rules:
- Motion explains change (a number rolling to its new value, an arc growing, a screen assembling top to bottom) — never decoration, no parallax. The only overshoot is the nav icon's small `easeOutBack` pop.
- **Reduced motion:** components read durations through `AppMotion.of`, which returns zero when `MediaQuery.disableAnimations` is set. Press scale, rolling numbers, nav slide/pop, gauge sweep and ring tweens become instant; `BbAppear` shows content static; the skeleton pulse becomes static.

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
- **Color:** `colors.skeleton` (mist200 light / mist800 dark).
- **Animation:** **soft opacity pulse**, 1.0 → 0.55 → 1.0 over `skeletonPulse` (1200 ms). Chosen over shimmer because it is calmer, cheaper to render, and gentler on battery during outages. All skeletons on a screen pulse **in sync** (one shared `AnimationController` via `BbSkeletonScope`).
- **Shapes:** text line height = 60% of the text style's line height, radius `xs`; last line of a multi-line block = 60% width; max 3 lines per block. Circles for avatars/icons; rect radius matches the real component (`lg` for cards).
- **Timing:** show only if loading takes > **200 ms** (avoids flash); once shown, keep at least **400 ms**; cross-fade to content with `normal` (250 ms).
- **Accessibility:** wrap region in `Semantics(label: 'Loading')`, `liveRegion` once; individual blocks excluded from semantics.

### 8.3 Inline spinner spec (`BbSpinner`) **NEW**

- Circular, **2-px stroke**, round cap, 270° arc rotating at 900 ms/turn.
- Sizes: `xs` 12, `sm` 16, `md` 20. No larger spinner exists.
- Color = the content color it replaces (`textOnPrimary` in coral buttons, `onSecondary` in indigo buttons, `textMuted` inline).
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
| Background | Mist `#EEF1F6` | Deep indigo night `#0E1024` (not `#000`) |
| Cards | White `#FFFFFF` + soft `level1` shadow | `#181B33` on `#0E1024`, no shadow (raised `#1F2340`) |
| Text | Indigo ink `#1B1F3B` | Off-white mist `#EEF1F6` |
| Primary CTA | Coral `#FF6B4A` + indigo ink label | Coral `#FF876B` + indigo ink label |
| Highlight card | Coral100 `#FFE4DD` | `CoralP.night` `#34213A` |
| Selected states / nav pill | Indigo `#1B1F3B` | Light indigo `#A6AEE6` |
| Hero card | `hero` indigo `#1B1F3B`, dark-palette content | `hero` indigo `#262B66`, dark-palette content |
| Elevation | Soft indigo-tinted shadows | Lighter surfaces, no shadows |
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
| `primary` | `primary` (coral) | `textOnPrimary` (indigo ink) | — | **One per screen.** The main task ("Calculate", "Light gayi") |
| `secondary` | `secondary` (indigo) | `onSecondary` | — | Strong secondary actions |
| `tonal` **NEW** | `surfaceMuted` | `textPrimary` | — | Neutral actions ("Edit", "Add appliance") |
| `ghost` | transparent | `link` | — | Low-emphasis / inline ("See all", "Skip") |
| `danger` | `danger` | `onDanger` | — | Destructive only ("Delete appliance") |

- Shape: **pill** (`radius.pill`) at every size.
- Sizes: `sm` 40 h, `md` 48 h (default), `lg` 56 h (sticky bottom CTA, full width). Label `labelLarge`; icon 20, leading only.
- States: pressed = 12% `textPrimary` overlay + scale 0.98 (`fast`), inside the shared 0.97 press scale (§7); disabled = 38% opacity, no overlay; focused = 2-px `focusRing` offset 2; loading = §8.3.
- `BbIconButton`: 48 × 48 hit area, 24 icon, circular; variants `standard` (no fill), `tonal` (`surfaceMuted` circle 40).
- `BbGoogleButton` **NEW**: outlined pill (`surface` fill, 1 px `outlineVariant`), Google's four-color G (SVG asset, as Google's branding requires), `labelLarge` label.

### 10.2 Inputs

- **`BbTextField` / `BbNumberField`:** height 52, radius `md`, fill `surface`, border 1 px `outline`; label above (`labelLarge`, `textPrimary`); helper/error below (`bodySmall`). Number field: value in `metricSmall`, **unit suffix** in `textMuted` ("Ah", "W", "kWp"), numeric keyboard, right-aligned value.
- **`BbSwitch`:** track 52 × 32 pill; on = `secondary` track + `onSecondary` thumb; off = `surfaceMuted` track + `outline` border + `textMuted` thumb.
- **`BbSegmentedControl`:** track `surfaceMuted`, radius `md`, 4 px inset; selected segment = `surface` + level1 (light) / `surfaceRaised` (dark), label `textPrimary` 600; unselected `textMuted`.
- **`BbSlider`:** track 4 px `surfaceMuted`, active `secondary`, thumb 20 px `secondary` with value label in `metricSmall` while dragging.
- **`BbTextField(pill: true)`** **NEW**: sign-in style — pill radius, leading icon, label shown inside as the placeholder (still the accessible name), 1 px `outlineVariant`.
- **`BbDropdown`:** looks like `BbTextField` (label above, 52 px, radius `md`, 1 px `outlineVariant`) with an optional leading 20-px icon and a `caretDown`; the value in `bodyLarge` `textPrimary`, or a `textMuted` placeholder. Tapping opens the caller's picker through `OverlayHost`; for long lists (cities) that is a sheet with a pill search field on top and rows that show the pick with a `check` icon and `titleSmall`, not color alone. Pressed/hover tint the fill; focus ring at radius `md`.
- **`BbTextField` unit suffix:** `suffixText` ("W", "Ah") in `bodyLarge` `textMuted` after the value, for typed sizes ("Other…" on a size-chip row, an added appliance's watts).
- **`BbChoiceCard`** **NEW**: one answer to a single-choice question. Full width, radius `lg`, padding 16: 40-px icon disc, `titleSmall` title, optional `bodySmall` muted hint (a recognition cue, e.g. "Tall battery you top up with water"), radio mark on the right. Unselected = `surface` + level1; selected = `secondaryContainer`, no shadow, Fill `checkCircle` in `secondary`. No borders.
- **`BbQuantityStepper`** **NEW**: tonal − / + icon buttons (48 dp) around the value in `metricSmall` (`textMuted` at 0). One adjustable node for screen readers (swipe to change).

### 10.3 Surfaces

- **`BbCard`:** `surface`, radius `lg` (24), `level1`, no border, padding 16. Variants:
  - `standard`. Home's backup hero is a standard (white) card.
  - `hero`: `hero` indigo fill, radius `xl` (32), padding 24, no shadow. Its content is wrapped in the **dark theme** (`Theme` + default text and icon color), so every component inside uses the dark tokens automatically: off-white text, 300-tone status colors, coral focus ring. One hero per screen.
  - `highlight`: `primaryContainer` fill (coral100 light / `CoralP.night` dark), no shadow, no stripe. The top AI advice card, with a `BbIcons.ai` icon in `onPrimaryContainer`.
- **`BbSection`:** `titleLarge` header + optional `ghost` action on the right ("See all"), `md` gap to content.
- **`BbBottomSheet`:** `surfaceRaised`, top radius `xl`, drag handle 32 × 4 `outline` pill, level3, scrim. Title `titleLarge` (a header, and the sheet's route name for screen readers); tall content scrolls inside. Opened only through `OverlayHost.showSheet` (modal route: focus trap, Escape / back / scrim tap close it).
- **`BbDialog`:** radius `lg`, max width 400, padding 24, title `headlineSmall`, actions right-aligned (ghost + primary/danger).

### 10.4 Data display

- **`BbStatTile`:** `BbCard` with: 40-px icon disc (`BbTone.containerColor`, e.g. `successContainer`) holding a 20-px icon in the tone color → `md` gap → `labelMedium` label in `textMuted` → `metricLarge` value + unit → optional `bodySmall` delta ("−18% vs Mar"). Min height 112; the tile fills its column (Home's two tiles are equal height). Optional tap (`onTap` + `tapLabel` read as the hint): pressed/hover tint the card, focus ring at radius `lg`.
- **`BbMetric`:** standalone value+unit pair (§3.5), sizes hero/large/medium/small. A changed value rolls into place (§7). Scales down to fit, never truncates; only `hero` clamps text scale at 1.3×.
- **`BbBadge`:** pill, height 24, `labelMedium`, container color + on-container text, optional 16-px Fill icon.
- **`BbCountBadge`:** a count on the corner of an icon button (the notification bell): pill, min 18 × 18, `primary` fill, `labelSmall` in `textOnPrimary`, "9+" above 9, hidden at 0. A number rather than a dot, so it never rests on color alone; the button's label repeats it ("Notifications, 3 new").
- **`BbChip`:** pill height 32, unselected = `surfaceMuted` fill + `textPrimary`; selected = `secondary` fill + `onSecondary` + leading `check` icon. Optional leading 16-px icon (e.g. battery bars beside "75%") that the check replaces when selected.
- **`BbListTile`:** 56/72 min height, leading 20-px icon in a 40-px `surfaceMuted` circle (or energy-tinted container), title `bodyLarge`, subtitle `bodyMedium` muted, trailing value in `metricSmall` right-aligned or `caretRight` 16.
- **`BbProgressBar`:** §8.4.

### 10.5 Navigation

- **`BbNavBar`** (bottom, 5 tabs: Home · Loads · Solar · Battery · Assistant): a **floating rounded bar**, height 74, inset `md` (12) from the sides and at least `md` above the bottom safe area; `surface`, radius `xl` (32), `level2` shadow (light; lighter surface in dark), no border. Selected tab = **indigo pill** 56 × 32 (`secondary`, radius `pill`, 10 from the top) that **slides** between tabs, behind a **Fill** icon in `onSecondary` that pops to 1.08 (`easeOutBack`); label `labelMedium` 6 below, `textPrimary` weight 800. Unselected = Regular icon + label in `textMuted`, weight 600. Indigo, not coral, so the screen's coral goes to its one action.
- **`BbAppBar`:** `background` color (blends with page), title `titleLarge` (or large `headlineMedium` variant on top-level tabs that collapses on scroll), actions = `BbIconButton`s; gains `level1` (and `surface` fill) when content scrolls under it.
- **`BbStepIndicator`** **NEW**: short stepped flows (setup). Per step a 28-px circle + `labelMedium` label below, joined by 2-px lines. Done = `successContainer` + `check` in `success` (line `success`); current = `secondary` + number in `onSecondary`; upcoming = `surfaceMuted` + number in `textMuted` (line `outlineVariant`). One semantics label: "Step 2 of 3: Battery".
- **`BbTabs`:** text tabs, `labelLarge`; selected = `textPrimary` + 2-px `secondary` underline (full label width); unselected `textMuted`.

### 10.6 Energy components (domain visuals, still dumb)

| Component | Visual spec |
|---|---|
| **`BbBackupGauge`** **NEW** | Home's hero gauge. Half ring 280 × 160, 18-px stroke, round caps. Track = `outlineVariant` (visible on a card and on the page); fill = the battery's charge in its status color (`EnergyColors.battery`: green > 50%, amber ≥ 20%, red below). The fill sweeps up from empty on arrival (800 ms, `easeOutCubic`) and glides when the charge changes. The caller's content (time + caption) sits in the bowl of the arc. One semantics label carries the whole answer; the arc itself is excluded. |
| **`BbCountdownRing`** | Sits on a hero card (Solar). 240-px ring (200 on small phones), 14-px stroke, round caps. Track = `textPrimary` @ 12%; arc = **always the battery status color** (`batteryHigh` > 50%, `batteryMid` ≥ 20%, `batteryLow` below — coral is for actions), animated `slow`. The battery stat tile always shows icon + % beside it, so color is never the only signal. Center: `metricHero` "3h 20m" + `bodySmall` muted "left at 420 W". Below ring: `labelMedium` "Stops protecting battery at 50%". Overload → ring pulses once (`normal`) and a `danger` banner appears. |
| **`BbGridStatusPill`** | Pill 40 h (48 dp hit area). Grid on: `secondaryContainer` + Fill `lightning` in `energy.grid` + "Light hai". Grid off: `surfaceMuted` + Fill `lightningSlash` in `energy.offline` + "Light gayi · 1h 12m" (duration in `metricSmall`). Trailing action label in `secondary`, underlined ("Light gayi?" / "Light aa gayi?") says what a tap logs. Tapping logs the event (with haptic). |
| **`BbBatteryGauge`** | Horizontal battery glyph 64 × 28, 2-px `outline` body, fill in status token, % in `metricSmall` beside it. Always icon + number. |
| **`BbPowerFlow`** | Three nodes (Solar · Grid · Battery) flowing to Home, 48-px circles with Regular icons; connecting lines 2 px in each source's energy color, **dashed** when inactive; small moving dots (`slow`, disabled with reduced motion) show direction. |
| **`BbLoadToggleTile`** | `BbListTile` + appliance icon + name + `metricSmall` watts + `BbSwitch`. Shows `BbPriorityBadge`. When toggled, the countdown updates live. With `onEditWatts`, the watts become their own target: a `surfaceMuted` pill with the value and a 16-px `edit` (pencil) icon, labelled "Change watts: Ceiling fan, 150 W"; name and switch still toggle. |
| **`BbPriorityBadge`** | `essential` = `secondaryContainer` "Keep"; `comfort` = `surfaceMuted` "Use carefully"; `avoid_on_backup` = `warningContainer` + `warning` icon "Avoid on backup". |
| **`BbSolarForecastStrip`** | Horizontal row of hourly bars (sunrise → sunset), bar = `energy.solar` fill with `solarStroke` top edge, hour labels every 3 h in `metricCaption`. Behind each bar a faint "clear day" bar (`textPrimary` @ 8%) shows what clouds take away; a legend names both. Bars grow in with `slow`. The header ("Sun today · 3.3–4.5 kWh · 49% less sun than a clear day") is composed by the screen above the strip. |
| **`BbHealthIndicator`** | Small semicircle gauge (health factor) in status token + `metricMedium` "82%" + `bodySmall` explanation. |

---

## 11. Screen Anatomy

All screens: `BbScaffold` → `BbAppBar` → optional `BbOfflineBanner` → content with `BbPagePadding` → optional sticky bottom CTA → `BbNavBar` (top-level tabs only).

**Splash (app start)**
```
[Android launch screen]  page `background` + the brand mark (112 dp wide) centered
[Flutter splash]         same mark, same place → wordmark "Backup Brain" fades up below (`enter`)
```
The native screen and the Flutter splash draw the mark at the same size and position, so the hand-over doesn't jump. Mark and wordmark are one-color artwork tinted `textPrimary` (indigo ink in light, off-white in dark). The splash stays until the session is restored and the 900 ms intro has played (zero with reduced motion), then goes Home; the router redirect takes over from there. Native colors live in `android/.../values*/colors.xml` (mirroring `background`) and `drawable-*xxxhdpi/splash_mark.png` (288 dp canvas, mark inside Android 12's 192 dp safe circle).

**Dashboard (Home)**
```
[App bar]  brand mark + wordmark (logo)  ·  bell · theme toggle · settings
[Grid status pill]                         ← tap = Light gayi / aa gayi
  "Since 7:02 PM · Change"                  ← during a cut; Change = sheet: Just now / 15 / 30 min / 1 h ago, "The power didn't go"
[Battery check card]                       ← only at the start of a cut, when the last reading is ≥ 6 h old:
  "What does your UPS screen show?" · chips 100 / 75 / 50 / 25% with bars icons · ghost "Not now"
[Overload banner]                          ← `danger`, only when the load is over the inverter's rating
[Backup hero: white `BbCard` (standard)]
     ( BbBackupGauge half ring, battery status color, sweeps up on arrival )
          3h 20m                           ← `BbMetric` hero in the bowl of the arc, `danger` tone when overloaded
          "left at 420 W"                  ← bodyMedium muted
     "Stops protecting battery at 50%"     ← labelMedium muted
     [What should I turn off?]             ← primary (coral) CTA, `lg`, full width, `loads` icon
[Stat tiles 1×2, equal height, icon discs]  Battery 60% "Estimate · you checked 2 h ago" (status tone; tap = same question as a sheet) · Load now 420 W (neutral)
[Tip card: `highlight` variant (coral tint), sparkle icon in `onPrimaryContainer`]
[Today card: `BbCard.list`, rows = 40-px `surfaceMuted` icon disc + title + muted line + › ]
  schedule / warning / lightning-slash · "Next outage likely 7:00 PM" · "Battery 96% by then · lasts 6h 14m" · › to Outages
  sun · "Sun today · 3.3–4.5 kWh" · "Lahore · updated 20 min ago" · › to Solar
[Nav bar]                                  ← floating rounded bar, sliding indigo pill (§10.5)
```
An estimated countdown shows to 10 minutes and the estimated % rounds down to 5%, with the source and age under the Battery tile; a fresh reading shows as given.
Sections arrive top to bottom with `BbAppear` (grid pill → hero → stat tiles → tip card → today card, 45 ms apart, §7); the battery check card and overload banner appear without a stagger. Calm by design: no indigo hero card on Home, icons are ink on `surfaceMuted` unless they carry a status (battery tone, `warning` when the battery won't cover the next cut). Coral budget: the CTA + the tip card tint.

**Outages (F8, from the Dashboard outage card):** grid status pill → answer card (cut in progress with battery estimate / next outage + battery by then + "enough for the usual 1h 30m" or a `warning`-icon line to avoid heavy loads / how to get a prediction) with muted basis lines → "Your area's schedule" list rows with a `delete` icon button + secondary "Add time" → "Recent outages" list (`gridOn`/`gridOff` icon, times, duration in `metricSmall`). **Add time** is a full screen (no overlay yet): weekday `BbChip`s, From/To half-hour steppers (`remove`/`add` tonal icon buttons, time in `metricMedium`), sticky coral Save. **Settings** has an "Outage alerts" row (title + muted one-line explanation + `BbSwitch`, one merged semantics node), Android only.

**Battery (F6):** verdict card (`BbStatTile` health % with battery icon and status tone: ≥ 80% success "Healthy", ≥ 60% warning "Wearing out", else danger "Weak"; capacity line; muted basis) or, before 3 readings, a how-to card with "n of 3 readings" → warning `BbBanner`s for capacity loss / deep discharge → "Enter the battery %" list of recent outages with a small secondary "Enter %" button → battery details card → the fixed danger safety banner → secondary "My battery is kharab" (F7). **Battery reading** is a full screen: question with the outage's time, 5% stepper (tonal `remove`/`add`, value in `metricLarge`, starting at the app's estimate), sticky Save.

**Battery problem (F7):** symptom `BbChip`s (multi-select; "water low" only for tubular) → verdict card (icon + title + what to do) or, for swelling / smell / heat, only the fixed danger safety banner → "Which battery to buy" cards ranked by cost over life (best one = `highlight` + `check` "Cheapest over its life"; PKR range in `metricMedium`; life, cycles, warranty; Rs per usable kWh per year) with the prices' date → "Find help nearby": three expanded secondary buttons with the `location` icon that open Google Maps searches.

**Panel check (F4, from a secondary button at the end of Solar):** status card (icon + colored icon + title + what to do: `success` healthy, `warning` a little low, `danger` well below) → day `BbChip`s (Today / Yesterday / n days ago, only days with recorded weather) → "should make about X kWh" line → kWh field + secondary Save → "Last two weeks" `BbSolarForecastStrip` (made vs should make, day-of-month labels) and a per-day list with the index in `metricSmall`.

**Price search card (F5, F7):** `BbCard` "Check today's prices online" + muted line that these are sellers' asking prices → product `BbChip`s when there are several → "Search: …" line → small secondary buttons Google · Daraz · OLX with the `shop` icon.

**Load Planner:** live `BbMetric` hero at top (sticky, updates on toggle) → "Battery now" slider (a reading) → "Turn off first" ranked list (`BbListTile` with `+2h 10m` in `success` `metricSmall`) → appliance toggles grouped by priority, watts editable → target-hours `BbNumberField`. **Watts sheet** ("Which Ceiling fan?"): muted hint (the sticker on the back) → the kinds as `BbChip`s ("Inverter / DC fan · 35 W", current one selected; one tap saves and closes) → "Exact watts, each" ±5 W tonal steppers with the value in `metricMedium` → primary "Done".

**Solar:** answer first, zero taps.
```
[App bar]  "Solar"  ·  refresh
[BbChip Today | Tomorrow]                 ← auto-picks Tomorrow after sunset
[Hero card] "Battery full by 1:15 PM" / "Battery reaches 79% by sunset"
            "Starting from 60% now"  (assumption, muted)
            gridOff icon + "Counts the power cut from 2:00 PM"  (only when a cut overlaps the sun left)
            ( ring = SoC at sunset, "at sunset, 5:30 PM" )
            "Lasts until about 10:25 PM at 420 W"
[Advice card: highlight]  "Most sun 12–3 PM. Run the iron or water motor then." / "Weak sun… avoid heavy loads after 5:30 PM"
[Card] "Sun today" · 3.3–4.5 kWh (solarText) · cloud icon + "49% less sun than a clear day" · BbSolarForecastStrip
[Footer] timer icon · "Lahore · updated 20 min ago" · xs spinner while refreshing · retry on failure
[Panels] solarPanel icon · "Panels cleaned 3 d ago" / "Panels: last cleaning unknown" · ghost "Cleaned today"
```
The forecast refreshes from the app root (start, return to the app, location first known), not the tab. No forecast yet → `BbEmptyState` "Needs internet once" with a loading `BbButton.secondary`. No panels → `BbEmptyState`. Performance check (F4) goes under the sun card later.

**Setup (first run):** `BbStepIndicator` (Home · Battery · Appliances) → one question block per topic (`titleMedium` question + muted hint saying where to find the answer) → answers as `BbChip`s, `BbChoiceCard`s and `BbQuantityStepper`s; follow-up questions appear only once they apply → sticky bottom bar: live backup time (from step 2) above a tonal Back icon button and the full-width primary Next / "Show my backup time". Next stays disabled until the step's required answers are in. Questions about numbers printed on a sticker carry a ghost "Where is this written?" (info icon) that expands, in place, a `surfaceMuted` drawing of the sticker: lines in `metricCaption` `textMuted`, the line to read on a `primaryContainer` marker in `metricSmall` with an arrow beside it (shape + color). The same screen, titled "Edit my home" with "Save changes", edits a saved home from Settings → My home (summary line + tonal "Edit my home" button).

**Estimator:** one live form instead of steps (usage as Units / Bill chips + number field, city chips prefilled from the home, goal as `BbChoiceCard`s, backup hours `BbQuantityStepper`, night load field); the packages update as answers change. Entry: Solar app bar `estimator` icon. → 3 package cards (`BbCard`, recommended one = `highlight` variant + a `primary` pill badge with `check` icon and "Recommended" in `textOnPrimary`) with PKR range in `metricMedium` → payback → installer checklist → disclaimer `bodySmall` muted + "prices last updated".

**Battery:** `BbHealthIndicator` → trend chart → warnings (`BbBanner`) → "My battery is kharab" (`secondary` button) → help screen: symptom chips → verdict → **nearby shops** (kind `BbChip`s, `BbCard.list` rows: name, muted "850 m · address", small secondary **Directions** button; inline spinner "Finding shops…"; `BbEmptyState` offline + Try again; ghost "More on Google Maps") → recommendations → price search.

**Assistant:** chat bubbles (`BbChatBubble`) — user = `secondary` fill + `onSecondary`, radius `lg` with 4-px tail corner; assistant = `surfaceMuted` fill; suggested prompts as `BbChip`s; numbers inside replies rendered in `metricSmall`; `BbTypingIndicator` while waiting.

---

## 12. Flutter Implementation Snippets

```dart
// packages/bb_ui/lib/src/foundations/primitives/color_primitives.dart (excerpt)
// LAYER 1 — package-private. Never exported, never used by widgets.
abstract final class MistP {
  static const c0 = Color(0xFFFFFFFF), c50 = Color(0xFFF6F7FB), c100 = Color(0xFFEEF1F6),
      c200 = Color(0xFFE3E7F0), /* … */ c900 = Color(0xFF181B33), c950 = Color(0xFF0E1024);
  static const black = Color(0xFF000000); // dark-theme scrim only
}

abstract final class IndigoP {
  static const c50 = Color(0xFFF0F1FA), /* … */ c600 = Color(0xFF414BA4),
      c800 = Color(0xFF262B66), c900 = Color(0xFF1B1F3B), c950 = Color(0xFF12152A);
}

abstract final class CoralP {
  static const c50 = Color(0xFFFFF4F1), /* … */ c400 = Color(0xFFFF876B),
      c500 = Color(0xFFFF6B4A), /* … */ c950 = Color(0xFF2E1008);
  static const night = Color(0xFF34213A); // dark-theme highlight cards
}

abstract final class AmberP { /* 100 · 300 · 400 · 500 · 700 · 800 — solar only */ }
abstract final class StatusP { /* success / warning / danger × 100 · 300 · 600 · 900 */ }
```

```dart
// packages/bb_ui/lib/src/foundations/primitives/font_primitives.dart
abstract final class FontP {
  static const package = 'bb_ui';
  static const sans = 'Manrope';
  static const regular = FontWeight.w400, medium = FontWeight.w500,
      semibold = FontWeight.w600, bold = FontWeight.w700, extrabold = FontWeight.w800;
}

// app_typography.dart (excerpt)
metricHero: _metric(56, 60, FontP.extrabold, -2.4), // Manrope + tabularFigures
```

```dart
// Staggered entrance (DESIGN.md §7)
ListView(children: [
  BbAppear(index: 0, child: gridStatus),
  BbAppear(index: 1, child: backupHero),
  BbAppear(index: 2, child: statTiles),
])
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

For the landing page / web dashboard, use exactly the same values. Font: self-host the same Manrope files (400–800, full features incl. `tnum`); icons via `@phosphor-icons/react` or `@phosphor-icons/web`.

```css
:root {
  /* Brand — Mist 60 / Indigo 30 / Coral 10 */
  --bb-background: #EEF1F6;  --bb-surface: #FFFFFF;  --bb-surface-raised: #FFFFFF;
  --bb-surface-muted: #EEF1F6;  --bb-hero: #1B1F3B;
  --bb-text: #1B1F3B;  --bb-text-muted: #555D80;  --bb-text-on-primary: #12152A;
  --bb-outline: #7C84A3;  --bb-outline-variant: #E3E7F0;
  --bb-primary: #FF6B4A;  --bb-primary-container: #FFE4DD;  --bb-on-primary-container: #4D190D;
  --bb-secondary: #1B1F3B;  --bb-on-secondary: #FFFFFF;
  --bb-secondary-container: #E3E6F7;  --bb-on-secondary-container: #1B1F3B;
  --bb-link: #414BA4;  --bb-focus: #414BA4;  --bb-skeleton: #E3E7F0;
  /* Status */
  --bb-success: #137A54; --bb-success-container: #DDF4EA;
  --bb-warning: #9E4A00; --bb-warning-container: #FFEBD3;
  --bb-danger:  #C4283C; --bb-danger-container:  #FDE2E5; --bb-on-danger: #FFFFFF;
  /* Energy */
  --bb-solar: #F5A623; --bb-solar-stroke: #A86A00; --bb-solar-text: #7F5000;
  --bb-grid: #414BA4;  --bb-load: #3F4668;  --bb-offline: #7C84A3;
  /* Type */
  --bb-font-sans: "Manrope", system-ui, sans-serif;
  /* Space (4-pt) */
  --bb-space-xxs: 2px; --bb-space-xs: 4px; --bb-space-sm: 8px; --bb-space-md: 12px;
  --bb-space-lg: 16px; --bb-space-xl: 24px; --bb-space-xxl: 32px; --bb-space-xxxl: 48px;
  --bb-space-xxxxl: 64px;
  /* Radius */
  --bb-radius-xs: 4px; --bb-radius-sm: 8px; --bb-radius-md: 14px;
  --bb-radius-lg: 24px; --bb-radius-xl: 32px; --bb-radius-pill: 999px;
  /* Elevation (light only) */
  --bb-shadow-1: 0 1px 2px rgba(18,21,42,.05), 0 10px 30px rgba(18,21,42,.07);
  --bb-shadow-2: 0 2px 4px rgba(18,21,42,.06), 0 14px 36px rgba(18,21,42,.10);
  --bb-shadow-3: 0 4px 8px rgba(18,21,42,.08), 0 24px 56px rgba(18,21,42,.16);
  /* Motion */
  --bb-fast: 150ms; --bb-normal: 250ms; --bb-slow: 400ms;
  --bb-ease: cubic-bezier(0.33, 1, 0.68, 1); /* easeOutCubic */
}

[data-theme="dark"] {
  --bb-background: #0E1024;  --bb-surface: #181B33;  --bb-surface-raised: #1F2340;
  --bb-surface-muted: #282D4C;  --bb-hero: #262B66;
  --bb-text: #EEF1F6;  --bb-text-muted: #A3AAC2;  --bb-text-on-primary: #12152A;
  --bb-outline: #7C84A3;  --bb-outline-variant: #282D4C;
  --bb-primary: #FF876B;  --bb-primary-container: #34213A;  --bb-on-primary-container: #FFC7B9;
  --bb-secondary: #A6AEE6;  --bb-on-secondary: #12152A;
  --bb-secondary-container: #262B66;  --bb-on-secondary-container: #E3E6F7;
  --bb-link: #A6AEE6;  --bb-focus: #FF876B;  --bb-skeleton: #282D4C;
  --bb-success: #52D29D; --bb-success-container: #0B3A28;
  --bb-warning: #FFB25C; --bb-warning-container: #4A2600;
  --bb-danger:  #FF7D8C; --bb-danger-container:  #4F0F18; --bb-on-danger: #12152A;
  --bb-solar: #FFC04D; --bb-solar-stroke: #FFC04D; --bb-solar-text: #FFCF73;
  --bb-grid: #A6AEE6;  --bb-load: #CDD3E1;  --bb-offline: #7C84A3;
  --bb-shadow-1: none; --bb-shadow-2: none; --bb-shadow-3: none;
}

/* System default when no explicit choice is stored */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) { /* copy the [data-theme="dark"] block */ }
}

body { background: var(--bb-background); color: var(--bb-text); font-family: var(--bb-font-sans); }
.bb-metric { font-variant-numeric: tabular-nums; }
/* .bb-hero: background var(--bb-hero), with the [data-theme="dark"] variables applied inside it. */
@media (prefers-reduced-motion: reduce) { * { transition: none !important; animation: none !important; } }
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
- [ ] Only mist / indigo / coral + amber (solar only) + status colors used; **≤ 1 coral CTA** and ≤ 1 other coral highlight per viewport; ≤ 1 indigo hero per screen
- [ ] No coral text or coral icons on light surfaces
- [ ] Every status shown with color **+** icon **+** text/number
- [ ] Only Manrope; every live number uses a `metric*` style (tabular figures); weights from the §3.4 roles only (500–800)
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
| Manrope (github.com/googlefonts/manrope, SIL OFL 1.1) | One sans for text and numbers, tabular figures, weights 400–800 bundled for offline |
| Team-shared Dribbble references (2026-10): insurance app (warm gradient hero, charcoal pill CTAs), mental-health app (dark emphasis card beside white cards, tinted nav pill), calorie tracker (warm beige canvas, one orange accent, large sans numbers) | v2 (superseded by v3 Quiet Home): warm neutral canvas, one dark hero mass, a single saturated accent, big **sans** numbers, generous radii, pill buttons, two-layer soft shadows |
| Phosphor Icons (phosphoricons.com, `phosphor_icons` on pub.dev) | One consistent icon family with Regular/Fill/Duotone weights |
| WCAG 2.2 AA | 4.5:1 text, 3:1 large text & UI boundaries — verified in §2.8 |

---

*Owner: design-system maintainers of `packages/bb_ui`. Any change to values here must land together with the matching Dart and CSS changes.*
