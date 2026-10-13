# Backup Brain ad (Remotion)

A 9:16, roughly 55 second ad for Reels, TikTok, Shorts and WhatsApp status. It opens on a power cut and then shows the app's answer to each problem: the countdown, the overload warning, Turn off first, solar and outage alerts, cost, health and shops, and the Roman Urdu assistant.

This folder has its own pnpm root (`pnpm-workspace.yaml`), so installing here never touches the app or `functions/`.

## Commands

```bash
pnpm install
pnpm voiceover            # Kokoro TTS (free, local) → public/voiceover/*.wav + durations.json
pnpm voiceover planner    # regenerate a single line after you edit it
pnpm audio                # synthesises the music bed and the custom SFX
pnpm studio               # preview
pnpm stills 280 610 1340  # check chosen frames at half scale (out/stills/)
pnpm render               # out/backup-brain-ad.mp4 (AAC, -14 LUFS) + -preview.mp4 (MP3, for VS Code)
pnpm typecheck
```

## How it stays true to the app

- All app labels come from `app/lib/app/l10n/app_en.arb`, read through `t()` in `src/copy.ts`. The webpack config loads `.arb` as JSON.
- Appliance names and watts come from `app/assets/data/demo_household.json`.
- The numbers in `src/mock-data.ts` are the ones the energy_engine tests lock: 3h 28m at 420 W, overload at 2170 W, 5h 49m with two loads off, and the 79% / 73% sunset values.
- The colors, Manrope font, radii, shadows and Phosphor icons follow DESIGN.md ("Quiet Home": Mist, Indigo, Coral).

## Retiming

1. Edit a line in `src/voiceover/lines.ts`. `text` is used for the captions; `spoken` is what the voice says.
2. Run `pnpm voiceover <id>`. Each scene's length follows its clip (`src/timeline.ts`).
3. Visual beats hang off `spokenAt(id, phrase)`, so they move with the voice.

## Sound

- Voice: Kokoro-82M `af_heart` (Apache 2.0).
- SFX: whoosh, whip, click, ding, switch and shutter come from remotion.media. The power-down, fan wind-down, impact, pop and riser are synthesised by `scripts/generate-audio.ts`.
- The music bed is also synthesised by that script: a 96 BPM pulse over Am F C G that comes in with the app and swells into the logo.
