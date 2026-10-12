import { continueRender, delayRender, staticFile } from 'remotion';

/** Manrope, from the same TTF files bb_ui ships. */
const WEIGHTS = ['500', '600', '700', '800'] as const;

let requested = false;

/** Holds the first frame until every face is ready, so nothing renders in a fallback font. */
export function loadFonts(): void {
  if (requested) return;
  requested = true;
  const handle = delayRender('Loading Manrope');
  Promise.all(
    WEIGHTS.map(async (weight) => {
      const face = new FontFace('Manrope', `url(${staticFile(`fonts/Manrope-${weight}.ttf`)}) format('truetype')`, {
        weight,
      });
      await face.load();
      document.fonts.add(face);
    }),
  )
    .then(() => continueRender(handle))
    .catch((error: unknown) => {
      console.error('Manrope failed to load', error);
      continueRender(handle);
    });
}
