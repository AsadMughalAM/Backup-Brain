# DESIGN.md — Backup Brain Design System

> **Status:** v1 — the single source of truth for every visual value (colors, fonts, spacing, icons, component visuals). `TECH_STACK.md` §6 only defines token *names* and theme mechanics.
> **Read together with:** `TECH_STACK.md` §6 (token *names*, layers, theme mechanics) and `ARCHITECTURE.md` §10 (screens). Start at `CLAUDE.md` for the doc map.
> **Contract (from TECH_STACK §6.1):** this file owns token **values**, icon style, component visuals and screen layouts. It does **not** rename or remove any token. New tokens are marked **`NEW`** and each has a light value, a dark value and a contrast-test entry.
> **Scope:** the Flutter app (`packages/bb_ui`) **and** any future website / landing page. Section 13 gives the same tokens as CSS variables so the web stays identical.

---

## Table of Contents

1. [Design Principles](#1-design-principles)
2. [Color System — 3 colors, 60 · 30 · 10](#2-color-system--3-colors-60--30--10)
3. [Typography — Geist + Geist Mono](#3-typography--geist--geist-mono)
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
| 2 | **The number is the hero** | Every screen leads with one big metric (backup time, kWh, PKR). Labels are small and muted; numbers are large and in Geist Mono. |
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
| **Primary — 60%** | **Canvas** (cool neutral) | Light `#F7F8FA` · Dark `#0B0D12` | ~60% | Backgrounds, surfaces, cards, sheets, dividers, muted text. The quiet base that lets numbers breathe. |
| **Secondary — 30%** | **Ink Navy** | `#1F3A70` (deepest step `#0E1526` is the text ink) | ~30% | All primary text and icons, secondary buttons, selected states (segmented, chips, switches, nav labels), links, info banners, the dashboard hero card, **grid power** in charts. |
| **Accent — 10%** | **Spark Yellow** | Light `#FFC21A` · Dark `#FFC93D` | ~10% | The one primary CTA per screen, the active nav indicator, the live countdown highlight, focus ring (dark), **solar** in charts. Yellow = electricity, sunlight and "do this". |

**Why this palette**

- **Spark Yellow** is the universal color of electricity and sunlight in Pakistan (lightning sign, solar). It is the brightest, most "clickable" color on both themes, so it is reserved for the 10% that must be noticed.
- **Ink Navy** is calm and trustworthy (fintech / utility feel), reads as near-black for body text, and owns "grid / structure" meaning without competing with yellow. Navy + yellow is a complementary pair (blue ↔ yellow-orange on the color wheel), which gives maximum distinction with only two hues.
- **Canvas** neutrals are slightly cool (hue ≈ 220°) so they sit harmoniously next to navy, and they never compete with status colors.

> **Naming note for developers.** In the 60-30-10 rule "primary" means the *dominant* (canvas) color. In Material 3 / our `AppColors`, `primary` means the *main action* color. So in code: **`colors.primary` = Spark Yellow (accent)**, `colors.secondary` = Ink Navy, `colors.surface/background` = Canvas. The mapping table in §2.4 is the source of truth.

### 2.2 Primitives (LAYER 1 — `color_primitives.dart`, package-private)

Widgets never use these directly. They exist only so semantic tokens (§2.4) can reference them.

**Canvas — neutral (Primary, 60%)**

| Step | 0 | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 850 | 900 | 950 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Hex | `#FFFFFF` | `#F7F8FA` | `#EEF0F3` | `#E1E4E9` | `#C9CED6` | `#9AA2AF` | `#7D8592` | `#5A6270` | `#3E4550` | `#222733` | `#1A1E27` | `#13161D` | `#0B0D12` |

**Ink Navy — secondary (30%)**

| Step | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | 950 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Hex | `#F2F5FB` | `#E4EAF6` | `#C5D3EE` | `#9DB4E8` | `#7E9EE0` | `#4F72C2` | `#3A5FB0` | `#2A4A8E` | `#1F3A70` | `#152851` | `#0E1526` |

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
| `background` | canvas50 `#F7F8FA` | canvas950 `#0B0D12` | Scaffold. Maps to M3 `surface` (see §2.6). |
| `surface` | canvas0 `#FFFFFF` | canvas900 `#13161D` | Cards, sheets, nav bar. |
| `surfaceRaised` | canvas0 + `elevation.level2` shadow | canvas850 `#1A1E27` | Menus, bottom sheets, dialogs. Dark mode uses a lighter surface, not a shadow. |
| `surfaceMuted` | canvas100 `#EEF0F3` | canvas800 `#222733` | Input fills, tonal buttons, segmented track, skeleton base. |
| `textPrimary` | navy950 `#0E1526` | canvas100 `#EEF0F3` | Body, titles, numbers. Off-white in dark, never `#FFFFFF`. |
| `textMuted` | canvas600 `#5A6270` | canvas400 `#9AA2AF` | Labels, captions, units, placeholders, timestamps. |
| `textOnPrimary` | navy950 `#0E1526` | navy950 `#0E1526` | Ink on yellow, in both themes. |
| `outline` | canvas500 `#7D8592` | canvas500 `#7D8592` | Input borders, focus-less boundaries (≥ 3:1). |
| `outlineVariant` | canvas200 `#E1E4E9` | canvas800 `#222733` | Hairline list dividers, chart gridlines, ring track. Never a container border. |
| `primary` | yellow500 `#FFC21A` | yellow400 `#FFC93D` | **Fill only.** Primary CTA, active nav pill, FAB. Never text/icon on light surfaces. |
| `primaryContainer` | yellow100 `#FFF3CC` | yellow950 `#2E2100` | Highlight chips, "recommended" tags, advice-card stripe. |
| `onPrimaryContainer` **NEW** | yellow900 `#4D3800` | yellow200 `#FFE7A3` | Text/icons on `primaryContainer`. |
| `secondary` **NEW** | navy800 `#1F3A70` | navy300 `#9DB4E8` | Secondary buttons, selected chip/segment/switch, nav selected label. |
| `onSecondary` **NEW** | canvas0 `#FFFFFF` | navy950 `#0E1526` | Text/icons on `secondary`. |
| `secondaryContainer` **NEW** | navy100 `#E4EAF6` | navy900 `#152851` | Hero card (light), info banner, selected list row. |
| `onSecondaryContainer` **NEW** | navy900 `#152851` | navy100 `#E4EAF6` | Text on `secondaryContainer`. |
| `link` **NEW** | navy700 `#2A4A8E` | navy300 `#9DB4E8` | Inline links & text buttons (underlined on press). |
| `focusRing` **NEW** | navy600 `#3A5FB0` | yellow400 `#FFC93D` | 2 px focus outline, offset 2 px. |
| `success` / `successContainer` | success600 / success100 | success300 / success900 | |
| `warning` / `warningContainer` | warning600 / warning100 | warning300 / warning900 | |
| `danger` / `dangerContainer` | danger600 / danger100 | danger300 / danger900 | |
| `info` | navy600 `#3A5FB0` | navy300 `#9DB4E8` | Info = secondary family (no 4th hue). |
| `skeleton` **NEW** | canvas100 `#EEF0F3` | canvas800 `#222733` | Skeleton blocks (§8). On `surfaceMuted` backgrounds use canvas200 / canvas850. |
| `scrim` **NEW** | `#0E1526` @ 40% | `#000000` @ 60% | Behind sheets/dialogs. |

### 2.5 Energy colors (`EnergyColors` ThemeExtension)

Energy meanings are mapped onto the **same three families + status colors** — no extra hues.

| Token | Light | Dark | Meaning / rule |
|---|---|---|---|
| `energy.solar` (fill) | yellow500 `#FFC21A` | yellow400 `#FFC93D` | Large fills only (ring arcs ≥ 8 px, area charts, bars). In light mode always paired with `solarStroke` edge. |
| `energy.solarStroke` **NEW** | yellow700 `#B38300` | yellow400 `#FFC93D` | Lines, thin marks, small icons on light (≥ 3:1). |
| `energy.solarText` | yellow800 `#8A6200` | yellow400 `#FFC93D` | Any solar text such as "4.2 kWh". |
| `energy.grid` | navy600 `#3A5FB0` | navy400 `#7E9EE0` | WAPDA/DISCO grid. |
| `energy.load` | canvas700 `#3E4550` | canvas300 `#C9CED6` | Household consumption. In charts drawn as **dashed** line to separate from grid. |
| `energy.batteryHigh` (> 50%) | success600 | success300 | Always + icon + %. |
| `energy.batteryMid` (20–50%) | warning600 | warning300 | |
| `energy.batteryLow` (< 20%) | danger600 | danger300 | |
| `energy.offline` / grid down | canvas500 `#7D8592` | canvas500 `#7D8592` | With `lightningSlash` icon. |

**Chart series order** (`EnergyColors.chartSeries`): solar → grid → load (dashed) → battery (status color for current level) → "other" canvas400. Chart gridlines = `outlineVariant`, axis labels = `textMuted` in Geist Mono 11.

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

1. **60-30-10 budget per screen.** Canvas fills the screen; navy carries text, icons and structure; yellow appears in at most **one CTA + one highlight** per viewport. If a screen has two yellow buttons, one of them is wrong.
2. **Yellow is a fill, never text on light.** On light surfaces yellow text/icons fail contrast (1.6:1). Use `textOnPrimary` ink *on* yellow, or `energy.solarText` for solar numbers.
3. **Ink on yellow, always.** Yellow buttons/pills carry `textOnPrimary` (11:1+). Never white on yellow.
4. **Status colors are for status.** Green ≠ "nice", red ≠ "brand". A green button does not exist; a red button only exists as `BbButton.danger` for destructive actions.
5. **No gradients**, except the 2-stop solar area fill in charts (`energy.solar` 32% → 0% alpha).
6. **No pure black or pure white text** in dark mode. Canvas950 is the darkest pixel; canvas100 is the brightest text.
7. **Opacity, not new colors,** for states: pressed overlay = `textPrimary` @ 12%, hover @ 8%, disabled content @ 38% (TECH_STACK `opacity.dart`).

### 2.8 Contrast audit (WCAG 2.x, computed)

These pairs go into `contrast_test.dart`. All pass.

| Foreground | Background | Light | Dark | Min |
|---|---|---|---|---|
| `textPrimary` | `surface` | 18.2:1 | 15.9:1 | 4.5:1 |
| `textPrimary` | `background` | 17.1:1 | 17.0:1 | 4.5:1 |
| `textPrimary` | `surfaceMuted` | 15.9:1 | 13.1:1 | 4.5:1 |
| `textMuted` | `surface` | 6.1:1 | 7.0:1 | 4.5:1 |
| `textMuted` | `surfaceMuted` | 5.4:1 | 5.8:1 | 4.5:1 |
| `textOnPrimary` | `primary` | 11.3:1 | 11.9:1 | 4.5:1 |
| `onSecondary` | `secondary` | 11.1:1 | 8.8:1 | 4.5:1 |
| `onSecondaryContainer` | `secondaryContainer` | 12.0:1 | 12.0:1 | 4.5:1 |
| `onPrimaryContainer` | `primaryContainer` | 10.1:1 | 12.9:1 | 4.5:1 |
| `link` | `surface` | 8.5:1 | 8.7:1 | 4.5:1 |
| `outline` | `surface` | 3.7:1 | 4.9:1 | 3.0:1 |
| `outline` | `background` | 3.5:1 | 5.2:1 | 3.0:1 |
| `success` | `surface` | 5.4:1 | 8.9:1 | 4.5:1 |
| `success` | `successContainer` | 4.6:1 | 6.3:1 | 4.5:1 |
| `warning` | `surface` | 6.1:1 | 8.9:1 | 4.5:1 |
| `warning` | `warningContainer` | 5.1:1 | 6.9:1 | 4.5:1 |
| `danger` | `surface` | 5.7:1 | 7.1:1 | 4.5:1 |
| `danger` | `dangerContainer` | 4.6:1 | 5.8:1 | 4.5:1 |
| `energy.solarText` | `surface` | 5.5:1 | 11.8:1 | 4.5:1 |
| `energy.solarStroke` | `surface` | 3.4:1 | 11.8:1 | 3.0:1 |
| `energy.grid` | `surface` | 6.1:1 | 6.8:1 | 3.0:1 |
| `energy.load` | `surface` | 9.7:1 | 11.4:1 | 3.0:1 |
| `energy.offline` | `surface` | 3.7:1 | 4.9:1 | 3.0:1 |

**Known exception (documented):** `energy.solar` fill on light `surface` is 1.6:1. It is therefore only used for large areas and always has a `solarStroke` edge or an adjacent label — the meaning never depends on the fill alone.

---

## 3. Typography — Geist + Geist Mono

### 3.1 Families (max 3)

| # | Family | Role | Status |
|---|---|---|---|
| 1 | **Geist** (Sans) | All UI text: titles, body, labels, buttons | Active |
| 2 | **Geist Mono** | Every **live / changing number**: countdown, %, W, kWh, PKR, times, chart axes, timestamps | Active |
| 3 | *Noto Nastaliq Urdu* | Fallback family for Urdu script (future stretch goal) | Reserved — not bundled yet |

Roman Urdu uses Geist (Latin). No other fonts are allowed in the app or on the website.

**The one rule to remember:** *if a number can change while you look at it, it is Geist Mono.* Monospaced digits mean the backup countdown "3h 20m → 3h 19m" never jitters, and columns of numbers align without extra work. Static numbers inside sentences ("Turn off 2 fans") stay in Geist.

### 3.2 Bundling (offline requirement)

- Download the official release (otf / variable) from **vercel.com/font** or `github.com/vercel/geist-font` (SIL Open Font License — free for commercial use; keep `OFL.txt` in `assets/fonts/`).
- **Do not use the Google Fonts build or the `google_fonts` package**: it is fetched at runtime (breaks offline) and Vercel notes the Google Fonts build lacks the full glyph set and `font-feature-settings` support.
- Bundle static weights only (smaller APK than variable): **Geist 400, 500, 600** and **Geist Mono 400, 500**. No other weights.

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
    - family: GeistMono
      fonts:
        - asset: assets/fonts/GeistMono-Regular.otf
          weight: 400
        - asset: assets/fonts/GeistMono-Medium.otf
          weight: 500
```

### 3.3 Weights

| Weight | Name | Use |
|---|---|---|
| 400 | Regular | Body, captions |
| 500 | Medium | Labels, buttons, metric numbers (Mono) |
| 600 | SemiBold | Titles & headlines only |

No Bold (700+) and no Light/Thin. Hierarchy comes from **size and color**, not heavy weights — that is what keeps the look minimal.

### 3.4 Type scale (`AppTypography` + Material `TextTheme`)

Sizes in logical px (sp). Line heights on a 4-pt rhythm. Negative tracking on large sizes is what makes Geist look crisp.

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
| `metricHero` | Geist Mono | 56 / 60 | 500 | −2.0 | Backup countdown "3h 20m" |
| `metricLarge` | Geist Mono | 32 / 36 | 500 | −1.0 | Stat tiles (kWh, %, PKR) |
| `metricMedium` **NEW** | Geist Mono | 20 / 24 | 500 | −0.4 | Package prices, secondary stats |
| `metricSmall` | Geist Mono | 16 / 20 | 500 | 0 | Inline numbers in lists ("+2h 10m", "750 W") |
| `metricCaption` **NEW** | Geist Mono | 11 / 16 | 400 | 0 | Chart axes, timestamps, "updated 3 h ago" times |

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
3. **Numbers right-aligned** in lists and tables (`textAlign: end`, Geist Mono makes columns line up).
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
| `md` | 12 | Buttons, inputs, segmented control, list-group containers |
| `lg` | 16 | Cards, banners, dialogs |
| `xl` | 24 | Bottom sheets (top corners), hero card |
| `pill` | 999 | Chips, nav indicator, grid status pill, switches |

Nested radius rule: inner radius = outer radius − padding (e.g. 16-px card with 8-px inset → 8-px inner element).

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
| `level1` | `0 1 3 rgba(14,21,38,.08)` | `surface` | Cards, list groups, nav bar, sticky bottom CTA bar, app bar when scrolled |
| `level2` | `0 4 12 rgba(14,21,38,.08)` | `surfaceRaised` | Menus, dropdowns, toasts |
| `level3` | `0 12 32 rgba(14,21,38,.12)` | `surfaceRaised` | Bottom sheets, dialogs |

Shadows are navy-tinted (never pure black) and very soft. In dark mode elevation = lighter surface, not a shadow.

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
| `back` · `next` · `close` · `add` · `more` | `arrowLeft` · `caretRight` · `x` · `plus` · `dotsThree` | Navigation & actions |

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
| **AI assistant** is composing a reply | **Typing indicator** (3 dots) in a chat bubble | `BbTypingIndicator` **NEW** |
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
| Background | `#F7F8FA` cool paper | `#0B0D12` near-black navy (not `#000`) |
| Cards | White + soft `level1` shadow | `#13161D` on `#0B0D12`, no shadow |
| Text | Ink navy `#0E1526` | Off-white `#EEF0F3` |
| Primary CTA | Yellow `#FFC21A` + ink label | Yellow `#FFC93D` + ink label |
| Selected states | Navy `#1F3A70` | Light navy `#9DB4E8` |
| Hero card | `secondaryContainer` (soft navy tint) | `secondaryContainer` (deep navy `#152851`) |
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
| `danger` | `danger` | light: `#FFFFFF` · dark: navy950 | — | Destructive only ("Delete appliance") |

- Sizes: `sm` 40 h (radius md), `md` 48 h (default), `lg` 56 h (sticky bottom CTA, full width). Label `labelLarge`; icon 20, leading only.
- States: pressed = 12% `textPrimary` overlay + scale 0.98 (`fast`); disabled = 38% opacity, no overlay; focused = 2-px `focusRing` offset 2; loading = §8.3.
- `BbIconButton`: 48 × 48 hit area, 24 icon, circular; variants `standard` (no fill), `tonal` (`surfaceMuted` circle 40).

### 10.2 Inputs

- **`BbTextField` / `BbNumberField`:** height 52, radius `md`, fill `surface`, border 1 px `outline`; label above (`labelLarge`, `textPrimary`); helper/error below (`bodySmall`). Number field: value in `metricSmall` (Geist Mono), **unit suffix** in `textMuted` ("Ah", "W", "kWp"), numeric keyboard, right-aligned value.
- **`BbSwitch`:** track 52 × 32 pill; on = `secondary` track + `onSecondary` thumb; off = `surfaceMuted` track + `outline` border + `textMuted` thumb.
- **`BbSegmentedControl`:** track `surfaceMuted`, radius `md`, 4 px inset; selected segment = `surface` + level1 (light) / `surfaceRaised` (dark), label `textPrimary` 600; unselected `textMuted`.
- **`BbSlider`:** track 4 px `surfaceMuted`, active `secondary`, thumb 20 px `secondary` with value label in Geist Mono while dragging.
- **`BbDropdown`:** looks like `BbTextField` + `caretDown` icon; menu = level2 surface.

### 10.3 Surfaces

- **`BbCard`:** `surface`, radius `lg`, `level1`, no border, padding 16. Variants: `standard`, `hero` (`secondaryContainer`, radius `xl`, padding 20), `highlight` (`surface` + 3-px leading stripe in `primary` — used for the top AI advice card).
- **`BbSection`:** `titleLarge` header + optional `ghost` action on the right ("See all"), `md` gap to content.
- **`BbBottomSheet`:** `surfaceRaised`, top radius `xl`, drag handle 32 × 4 `outline` pill, level3, scrim.
- **`BbDialog`:** radius `lg`, max width 400, padding 24, title `headlineSmall`, actions right-aligned (ghost + primary/danger).

### 10.4 Data display

- **`BbStatTile`:** `BbCard` with: icon 20 (energy/status color) + `labelMedium` label in `textMuted` → `metricLarge` value + unit → optional `bodySmall` delta ("−18% vs Mar"). Min height 112.
- **`BbMetric`:** standalone value+unit pair (§3.5), sizes hero/large/medium/small.
- **`BbBadge`:** pill, height 24, `labelMedium`, container color + on-container text, optional 16-px Fill icon.
- **`BbChip`:** pill height 32, unselected = `surfaceMuted` fill + `textPrimary`; selected = `secondary` fill + `onSecondary` + leading `check` icon.
- **`BbListTile`:** 56/72 min height, leading 20-px icon in a 40-px `surfaceMuted` circle (or energy-tinted container), title `bodyLarge`, subtitle `bodyMedium` muted, trailing value in `metricSmall` right-aligned or `caretRight` 16.
- **`BbProgressBar`:** §8.4.

### 10.5 Navigation

- **`BbNavBar`** (bottom, 5 tabs: Home · Loads · Solar · Battery · Assistant): height 64 + safe area, `surface` + `level1` (shadow cast upward in light; lighter surface in dark), no border. Selected tab = **yellow pill indicator** 56 × 32 (`primary`) behind a **Fill** icon in `textOnPrimary`, label `labelMedium` `textPrimary` 600; unselected = Regular icon + label in `textMuted`. This is one of the two allowed yellow highlights per viewport.
- **`BbAppBar`:** `background` color (blends with page), title `titleLarge` (or large `headlineMedium` variant on top-level tabs that collapses on scroll), actions = `BbIconButton`s; gains `level1` (and `surface` fill) when content scrolls under it.
- **`BbTabs`:** text tabs, `labelLarge`; selected = `textPrimary` + 2-px `secondary` underline (full label width); unselected `textMuted`.

### 10.6 Energy components (domain visuals, still dumb)

| Component | Visual spec |
|---|---|
| **`BbCountdownRing`** | 240-px ring (200 on small phones), 12-px stroke, round caps. Track `outlineVariant`; arc = current battery status token (`batteryHigh/Mid/Low`), animated `slow`. Center: `metricHero` "3h 20m" + `bodySmall` muted "left at 420 W". Below ring: `labelMedium` "Stops protecting battery at 50%". Overload → ring pulses once (`normal`) and a `danger` banner appears. |
| **`BbGridStatusPill`** | Pill 40 h. Grid on: `secondaryContainer` + Fill `lightning` in `energy.grid` + "Light hai". Grid off: `surfaceMuted` + Fill `lightningSlash` in `energy.offline` + "Light gayi · 1h 12m" (duration in Geist Mono). Tapping logs the event (with haptic). |
| **`BbBatteryGauge`** | Horizontal battery glyph 64 × 28, 2-px `outline` body, fill in status token, % in `metricSmall` beside it. Always icon + number. |
| **`BbPowerFlow`** | Three nodes (Solar · Grid · Battery) flowing to Home, 48-px circles with Regular icons; connecting lines 2 px in each source's energy color, **dashed** when inactive; small moving dots (`slow`, disabled with reduced motion) show direction. |
| **`BbLoadToggleTile`** | `BbListTile` + appliance icon + name + `metricSmall` watts + `BbSwitch`. Shows `BbPriorityBadge`. When toggled, the countdown updates live. |
| **`BbPriorityBadge`** | `essential` = `secondaryContainer` "Keep"; `comfort` = `surfaceMuted` "Use carefully"; `avoid_on_backup` = `warningContainer` + `warning` icon "Avoid on backup". |
| **`BbSolarForecastStrip`** | Horizontal row of hourly bars (sunrise → sunset), bar = `energy.solar` fill with `solarStroke` top edge, hour labels in `metricCaption`; header shows "Today ~3.8 kWh · 35% below normal" with range. |
| **`BbHealthIndicator`** | Small semicircle gauge (health factor) in status token + `metricMedium` "82%" + `bodySmall` explanation. |

---

## 11. Screen Anatomy

All screens: `BbScaffold` → `BbAppBar` → optional `BbOfflineBanner` → content with `BbPagePadding` → optional sticky bottom CTA → `BbNavBar` (top-level tabs only).

**Dashboard (Home)**
```
[App bar]  "Assalam-o-alaikum"  ·  theme toggle · settings
[Grid status pill]                         ← tap = Light gayi / aa gayi
[Hero card: secondaryContainer, radius xl]
     ( Countdown ring  3h 20m )
     "left at 420 W"  ·  [What should I turn off?]  ← primary (yellow) CTA
[Stat tiles 2×2]  Battery 62% · Load 420 W · Solar today 3.8 kWh · Next outage 7:00 PM
[AI advice card: highlight variant, sparkle icon]
[Solar forecast strip]
[Nav bar]
```
Yellow budget: the CTA + the nav indicator. Nothing else on this screen is yellow except solar data marks.

**Load Planner:** live `BbMetric` hero at top (sticky, updates on toggle) → "Turn off first" ranked list (`BbListTile` with `+2h 10m` in `success` Geist Mono) → appliance toggles grouped by priority → target-hours `BbNumberField`.

**Solar:** forecast chart (hourly area, solar yellow) → `BbStatTile`s (expected kWh range, SoC at sunset, night coverage) → performance check card.

**Estimator:** stepped form (`BbProgressBar` determinate, 3 steps) → 3 package cards (`BbCard`, recommended one = `highlight` variant + `primaryContainer` badge "Recommended") with PKR range in `metricMedium` → payback → installer checklist → disclaimer `bodySmall` muted + "prices last updated".

**Battery:** `BbHealthIndicator` → trend chart → warnings (`BbBanner`) → "My battery is kharab" (`secondary` button) → diagnosis sheet → recommendations → shops list (needs internet state).

**Assistant:** chat bubbles — user = `secondary` fill + `onSecondary`, radius `lg` with 4-px tail corner; assistant = `surfaceMuted` fill; suggested prompts as `BbChip`s; numbers inside replies rendered in Geist Mono; `BbTypingIndicator` while waiting.

---

## 12. Flutter Implementation Snippets

```dart
// packages/bb_ui/lib/src/foundations/primitives/color_primitives.dart
// LAYER 1 — package-private. Never exported, never used by widgets.
abstract final class CanvasP {
  static const c0 = Color(0xFFFFFFFF), c50 = Color(0xFFF7F8FA), c100 = Color(0xFFEEF0F3),
      c200 = Color(0xFFE1E4E9), c300 = Color(0xFFC9CED6), c400 = Color(0xFF9AA2AF),
      c500 = Color(0xFF7D8592), c600 = Color(0xFF5A6270), c700 = Color(0xFF3E4550),
      c800 = Color(0xFF222733), c850 = Color(0xFF1A1E27), c900 = Color(0xFF13161D),
      c950 = Color(0xFF0B0D12);
}

abstract final class NavyP {
  static const c50 = Color(0xFFF2F5FB), c100 = Color(0xFFE4EAF6), c200 = Color(0xFFC5D3EE),
      c300 = Color(0xFF9DB4E8), c400 = Color(0xFF7E9EE0), c500 = Color(0xFF4F72C2),
      c600 = Color(0xFF3A5FB0), c700 = Color(0xFF2A4A8E), c800 = Color(0xFF1F3A70),
      c900 = Color(0xFF152851), c950 = Color(0xFF0E1526);
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
  static const mono = 'GeistMono';
  static const regular = FontWeight.w400, medium = FontWeight.w500, semibold = FontWeight.w600;
}

// app_typography.dart (excerpt)
TextStyle get metricHero => const TextStyle(
      fontFamily: FontP.mono, fontSize: 56, height: 60 / 56,
      fontWeight: FontP.medium, letterSpacing: -2.0,
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

For the landing page / web dashboard, use exactly the same values. Fonts via the `geist` npm package (self-hosted, full features); icons via `@phosphor-icons/react` or `@phosphor-icons/web`.

```css
:root {
  /* Brand — 60 / 30 / 10 */
  --bb-background: #F7F8FA;  --bb-surface: #FFFFFF;  --bb-surface-raised: #FFFFFF;
  --bb-surface-muted: #EEF0F3;
  --bb-text: #0E1526;  --bb-text-muted: #5A6270;  --bb-text-on-primary: #0E1526;
  --bb-outline: #7D8592;  --bb-outline-variant: #E1E4E9;
  --bb-primary: #FFC21A;  --bb-primary-container: #FFF3CC;  --bb-on-primary-container: #4D3800;
  --bb-secondary: #1F3A70;  --bb-on-secondary: #FFFFFF;
  --bb-secondary-container: #E4EAF6;  --bb-on-secondary-container: #152851;
  --bb-link: #2A4A8E;  --bb-focus: #3A5FB0;  --bb-skeleton: #EEF0F3;
  /* Status */
  --bb-success: #1E7A3D; --bb-success-container: #DDF3E4;
  --bb-warning: #A34706; --bb-warning-container: #FFE6D2;
  --bb-danger:  #C42B22; --bb-danger-container:  #FDE1DF;
  /* Energy */
  --bb-solar: #FFC21A; --bb-solar-stroke: #B38300; --bb-solar-text: #8A6200;
  --bb-grid: #3A5FB0;  --bb-load: #3E4550;  --bb-offline: #7D8592;
  /* Type */
  --bb-font-sans: "Geist", system-ui, sans-serif;
  --bb-font-mono: "Geist Mono", ui-monospace, monospace;
  /* Space (4-pt) */
  --bb-space-xxs: 2px; --bb-space-xs: 4px; --bb-space-sm: 8px; --bb-space-md: 12px;
  --bb-space-lg: 16px; --bb-space-xl: 24px; --bb-space-xxl: 32px; --bb-space-xxxl: 48px;
  --bb-space-xxxxl: 64px;
  /* Radius */
  --bb-radius-xs: 4px; --bb-radius-sm: 8px; --bb-radius-md: 12px;
  --bb-radius-lg: 16px; --bb-radius-xl: 24px; --bb-radius-pill: 999px;
  /* Motion */
  --bb-fast: 150ms; --bb-normal: 250ms; --bb-slow: 400ms;
  --bb-ease: cubic-bezier(0.33, 1, 0.68, 1); /* easeOutCubic */
}

[data-theme="dark"] {
  --bb-background: #0B0D12;  --bb-surface: #13161D;  --bb-surface-raised: #1A1E27;
  --bb-surface-muted: #222733;
  --bb-text: #EEF0F3;  --bb-text-muted: #9AA2AF;  --bb-text-on-primary: #0E1526;
  --bb-outline: #7D8592;  --bb-outline-variant: #222733;
  --bb-primary: #FFC93D;  --bb-primary-container: #2E2100;  --bb-on-primary-container: #FFE7A3;
  --bb-secondary: #9DB4E8;  --bb-on-secondary: #0E1526;
  --bb-secondary-container: #152851;  --bb-on-secondary-container: #E4EAF6;
  --bb-link: #9DB4E8;  --bb-focus: #FFC93D;  --bb-skeleton: #222733;
  --bb-success: #5CCB82; --bb-success-container: #0E3A1E;
  --bb-warning: #FF9F5A; --bb-warning-container: #4A2004;
  --bb-danger:  #FF7A70; --bb-danger-container:  #4F1210;
  --bb-solar: #FFC93D; --bb-solar-stroke: #FFC93D; --bb-solar-text: #FFC93D;
  --bb-grid: #7E9EE0;  --bb-load: #C9CED6;  --bb-offline: #7D8592;
}

/* System default when no explicit choice is stored */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) { /* copy the [data-theme="dark"] block */ }
}

body { background: var(--bb-background); color: var(--bb-text); font-family: var(--bb-font-sans); }
.bb-metric { font-family: var(--bb-font-mono); font-variant-numeric: tabular-nums; }
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
- [ ] Only canvas / navy / yellow + status colors used; **≤ 1 yellow CTA** and ≤ 1 other yellow highlight per viewport
- [ ] No yellow text or yellow icons on light surfaces
- [ ] Every status shown with color **+** icon **+** text/number
- [ ] Only Geist & Geist Mono; every live number in Geist Mono; weights 400/500/600 only
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
| Vercel Geist (vercel.com/font) | Geist + Geist Mono, Swiss-minimal tone, self-hosted for full OpenType features |
| Phosphor Icons (phosphoricons.com, `phosphor_icons` on pub.dev) | One consistent icon family with Regular/Fill/Duotone weights |
| WCAG 2.2 AA | 4.5:1 text, 3:1 large text & UI boundaries — verified in §2.8 |

---

*Owner: design-system maintainers of `packages/bb_ui`. Any change to values here must land together with the matching Dart and CSS changes.*
