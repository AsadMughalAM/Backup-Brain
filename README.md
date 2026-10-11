# Backup Brain

An AI home energy manager for Pakistani households living with load-shedding. It tells you how long your backup will last, what to switch off first, whether solar will recharge the battery, what solar would cost you, and where to buy or repair a battery when it fails.

**Stack:** Flutter (Android first) · Firebase (Auth, Firestore, Cloud Functions) · Open-Meteo · Gemini API

**Status:** Hackathon build. Working: sign-in (email + Google), the calculation engine, the `bb_ui` design system, and Dashboard (F1), Load Planner (F2), Solar forecast (F3), outage logging, schedule, readiness and alerts (F8) and the AI assistant (F9, Gemini through the `assistantChat` Cloud Function) on the demo household (ARCHITECTURE §12), backed by Firebase `backup-brain-dev` (Firestore in `asia-south1`, rules deployed). Next: the estimator (F5) and full onboarding.

## Docs

| File | Read it for |
|---|---|
| [CLAUDE.md](CLAUDE.md) | Start here: doc map, golden rules, conventions |
| [ARCHITECTURE.md](ARCHITECTURE.md) | What we build and why: problems, features F1–F10, formulas, data model, screens, demo script |
| [TECH_STACK.md](TECH_STACK.md) | How and where: packages, Firestore layout, folder structure, coding rules, build order |
| [DESIGN.md](DESIGN.md) | How it looks: colors, typography, icons, components, screen layouts |

## Setup

Use **pnpm** for every Node tool, never npm, npx or yarn.

**Prerequisites:** Flutter stable (3.47+, Dart 3.13), Android Studio (for the Android SDK and its bundled JDK), Node 22+, pnpm. On Windows, install pnpm with `winget install pnpm.pnpm`, because the corepack bundled with Node 22.13 fails with a signing-key error. The first Android build downloads Gradle and the NDK (about 1.5 GB) and is slow; later builds are fast.

```bash
# one-time
pnpm add -g firebase-tools
dart pub global activate flutterfire_cli
firebase login

# app
cd app
flutterfire configure
flutter pub get
dart run build_runner build -d
flutter run --dart-define=USE_EMULATORS=true
flutter run -d chrome            # quick dev preview without a phone (Android is the real target)

# tests
cd packages/energy_engine && dart test
cd packages/bb_ui && flutter test

# cloud functions + emulators
cd functions && pnpm install && pnpm run build
firebase emulators:start
```

**AI assistant (F9):** works against the deployed `assistantChat` function; no per-machine setup. The Gemini key is set once per Firebase project with `firebase functions:secrets:set GEMINI_API_KEY` and lives only in Secret Manager. Deploy with `firebase deploy --only functions` (needs the Blaze plan).

For the full command list and environments, see [TECH_STACK.md §7.8 and §8](TECH_STACK.md).
