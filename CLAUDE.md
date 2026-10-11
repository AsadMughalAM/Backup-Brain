# CLAUDE.md — Backup Brain

AI home energy manager for Pakistani households facing load-shedding. Flutter app (Android first) + Firebase. Hackathon build: **early build** (Firebase `backup-brain-dev` connected; demo household; F1 countdown, F2 load planner, F3 solar forecast and F9 assistant working; F5–F8 next). The three spec docs below are the source of truth, so read the relevant section before writing code.

## Doc map: which file owns what

| File | Owns | Wins on |
|---|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Problems, personas, features F1–F10, formulas, data model, screens, demo script | Product behaviour and formulas |
| [TECH_STACK.md](TECH_STACK.md) | Packages, Firestore layout, Cloud Functions, folder tree, coding rules, build order | Technology, structure, rules |
| [DESIGN.md](DESIGN.md) | Colors, typography, spacing, icons, motion, loading states, component visuals, screen anatomy | Every visual value |

If two docs disagree, the "Wins on" column decides. If a doc change affects another doc, update both in the same change.

## Where to look, by task

| Task | Read |
|---|---|
| Any engine calculation (F1–F8) | ARCHITECTURE §5 (the feature's formula) · TECH_STACK §7.5 (engine rules) |
| New screen | ARCHITECTURE §10 · DESIGN §11 (anatomy) + §10 (components) · TECH_STACK §5.1 (feature folder) |
| Firestore data / rules / indexes | TECH_STACK §4 + §7.3 · ARCHITECTURE §8 (entities) |
| Cloud Function (AI, Places) | TECH_STACK §3.1–§3.2 + §7.4 + §7.6 |
| `bb_ui` token or component | TECH_STACK §6 (names, mechanics) · DESIGN §2–§10 (values, visuals) · DESIGN §14 (checklist) |
| Offline behaviour | TECH_STACK §7.2 · DESIGN §8 |
| What to build next | TECH_STACK §9 (technical order) · ARCHITECTURE §11 (phases) |
| Demo prep | ARCHITECTURE §12 |

## Names

- Product: **Backup Brain**. Repo root folder: `backup-brain/`.
- Design-system package: `packages/bb_ui`. Widget prefix `Bb` (= Backup Brain), CSS prefix `--bb-`.
- Engine package: `packages/energy_engine` (pure Dart).
- Firebase aliases: `backup-brain-dev`, `backup-brain-prod`.
- Brand colors: Canvas (60%) · Ink Navy (30%) · Spark Yellow (10%).
- Locales: `en` and Roman Urdu `ur_Latn`.

## Golden rules (never break)

1. **The engine computes, the AI explains.** Every number comes from the pure Dart `energy_engine`. The LLM never invents or calculates numbers. The engine is never re-implemented in TypeScript.
2. **Offline first.** F1, F2, F3 model and F5 work in airplane mode. Show cached data with its age; never block with a full-screen spinner.
3. **Config over code.** Prices, tariffs, PSH and wattages come from Firestore `config/` or bundled JSON, never hardcoded. Always show "last updated" and ranges.
4. **Layering:** screens → controllers (Riverpod) → repository interface → impl → sources. Widgets never touch Firestore, dio or Functions. Features never import each other.
5. **One source per value:** Firestore paths only in `core/firebase/firestore_paths.dart`; strings only in ARB files; colors, sizes and icons only via `bb_ui` tokens and `BbIcons`.
6. **Design:** containers are separated by surface color + shadow, never borders, and elevated surfaces are never nested. Never use color alone (always add an icon and text). Focus is always visible. Touch targets are at least 48 dp.
7. **Overlays** go through the single `OverlayHost` at the app root. Modals trap focus, close on Escape, back or scrim tap, and have an accessible title.
8. **Safety:** never switch appliances automatically without confirmation. Battery swelling, smell or heat → fixed "disconnect and call a technician" text.
9. **No secrets in the app.** API keys live in Secret Manager and are read only from Cloud Functions; the Gemini key is held by Firebase AI Logic.

## Tooling

- Node tooling: **pnpm only** (never npm, npx, yarn or bun). Dart and Flutter use their own CLIs.
- Simplicity first (KISS, YAGNI, DRY). Comments explain *why*, not *what*.
- Verify before calling work done (do not run a production build for this):
  - Flutter / Dart: `flutter analyze` and `dart test` / `flutter test` in the touched package
  - Functions: `pnpm run typecheck`, or `pnpm exec tsc --noEmit` if that script doesn't exist
  - Design tokens: `bash tool/check_design_tokens.sh`
- Definition of done per feature: TECH_STACK §7.9.
