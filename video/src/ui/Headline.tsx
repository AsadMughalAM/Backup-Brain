import { useCurrentFrame } from 'remotion';
import { EASE_OUT, progress } from '../lib/motion';
import { color, font } from '../theme';

export interface Word {
  text: string;
  /** Coral highlighter swipes in behind this word once it has landed. */
  mark?: boolean;
}

const STAGGER = 3;
const LAND = 12;

/**
 * Kinetic headline: words land one after another (rise, unblur), then a
 * coral highlighter sweeps behind the marked ones. `out` fades it away.
 */
export function Headline({
  words,
  at,
  out,
  top = 170,
  size = 96,
  ink = color.ink,
}: {
  words: Word[];
  at: number;
  out?: number;
  top?: number;
  size?: number;
  ink?: string;
}): React.JSX.Element {
  const frame = useCurrentFrame();
  const gone = out === undefined ? 0 : progress(frame, out, 10);
  return (
    <div
      style={{
        position: 'absolute',
        left: 60,
        right: 60,
        top,
        display: 'flex',
        flexWrap: 'wrap',
        justifyContent: 'center',
        columnGap: size * 0.26,
        rowGap: size * 0.06,
        fontFamily: font.sans,
        fontSize: size,
        fontWeight: 800,
        letterSpacing: -size * 0.04,
        lineHeight: 1.08,
        opacity: 1 - gone,
        transform: `translateY(${-gone * 30}px)`,
      }}
    >
      {words.map((word, i) => {
        const start = at + i * STAGGER;
        const land = progress(frame, start, LAND, EASE_OUT);
        const sweep = word.mark ? progress(frame, start + LAND - 2, 10, EASE_OUT) : 0;
        return (
          <span
            key={`${word.text}-${i}`}
            style={{
              position: 'relative',
              display: 'inline-block',
              isolation: 'isolate',
              color: word.mark && sweep > 0.5 ? color.inkDeep : ink,
              opacity: land,
              filter: `blur(${(1 - land) * 10}px)`,
              transform: `translateY(${(1 - land) * size * 0.55}px) rotate(${(1 - land) * 4}deg)`,
              padding: word.mark ? `0 ${size * 0.12}px` : 0,
            }}
          >
            {word.mark ? (
              <span
                style={{
                  position: 'absolute',
                  inset: `${size * 0.1}px 0 ${size * 0.02}px 0`,
                  background: color.coral,
                  borderRadius: size * 0.16,
                  transform: `scaleX(${sweep}) rotate(-1.5deg)`,
                  transformOrigin: 'left center',
                  zIndex: -1,
                }}
              />
            ) : null}
            {word.text}
          </span>
        );
      })}
    </div>
  );
}
