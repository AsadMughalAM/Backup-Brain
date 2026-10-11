# 0002 — Gemini key in the app for the MVP

**Date:** 2026-10-11 · **Status:** Accepted for the MVP only; replace before a public release

## Context

Golden rule 9 (CLAUDE.md) says no secrets in the app: the F9 assistant should call Gemini through the `assistantChat` Cloud Function, with the key in Secret Manager. That function is built and tested (`functions/`), but deploying it needs the Blaze plan. The team decided not to take Blaze for the MVP. Firebase AI Logic (free) was tried first; it rejects requests without App Check, which a shared APK can't pass without hand-registered debug tokens.

## Decision

For the MVP the app calls the Gemini API directly (`GeminiDirectAssistantRepository`, plain REST through `dio`) with a key passed at build time:

```bash
flutter run --dart-define-from-file=env.json   # env.json: {"GEMINI_API_KEY": "..."}
```

`env.json` is git-ignored; `env.example.json` shows the shape. Without a key the app uses the Cloud Function path, so nothing else changes when we move to Blaze.

## Risks and how they are contained

- **The key is inside every build** (APK or web page) and can be extracted. It is not a secret, only kept out of git.
- Use a key from a Google project **without billing** and **restrict it to the Generative Language API** in Google Cloud console → APIs & Services → Credentials. Then a leaked key can't cost money or reach other APIs; the worst case is someone using up the free quota, which stops the assistant (the app then shows its template answer from the engine numbers).
- Each phone is limited to 50 assistant messages a day (local, soft limit).
- Rotate the key if it leaks.

## Revisit when

Before any public or store release, or if the quota is abused: take Blaze, set `GEMINI_API_KEY` as a Functions secret, deploy `assistantChat`, and stop passing the key to `flutter run`.
