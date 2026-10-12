import { CloudSlash, Translate } from '@phosphor-icons/react';
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from 'remotion';
import { BrandImage } from '../app/chrome';
import { EASE_OUT, pop, progress, tween } from '../lib/motion';
import { color, font, radius } from '../theme';
import { spokenAt } from '../timeline';
import { Headline } from '../ui/Headline';
import { Narration } from '../ui/Narration';
import { Sfx } from '../ui/Sfx';

const MARK = 240;

/**
 * The splash, scaled up: a coral dot swells, the house mark lands in it and
 * the wordmark rises from 0.4 of its height (splash_screen.dart timing).
 */
export function OutroScene(): React.JSX.Element {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const tagAt = spokenAt('outro', 'Know how long');
  const mark = pop(frame, 20, fps);
  const word = progress(frame, 30, 16, EASE_OUT);
  const chips = progress(frame, tagAt + 30, 14);

  return (
    <AbsoluteFill style={{ background: color.bg, fontFamily: font.sans }}>
      <div
        style={{
          position: 'absolute',
          left: 540,
          top: 760,
          width: 0,
          height: 0,
        }}
      >
        <div
          style={{
            position: 'absolute',
            width: 400,
            height: 400,
            left: -200,
            top: -200,
            borderRadius: '50%',
            background: color.coral,
            transform: `scale(${tween(frame, [2, 10, 26], [0, 0.2, 1])})`,
            opacity: 1 - progress(frame, 24, 14),
          }}
        />
        <div
          style={{
            position: 'absolute',
            left: (-MARK * 399) / 384 / 2,
            top: -MARK / 2,
            transform: `scale(${0.6 + mark * 0.4})`,
            opacity: Math.min(1, mark),
          }}
        >
          <BrandImage file="mark" height={MARK} />
        </div>
      </div>
      <div
        style={{
          position: 'absolute',
          top: 930,
          left: 0,
          right: 0,
          display: 'flex',
          justifyContent: 'center',
          opacity: word,
          transform: `translateY(${(1 - word) * 0.4 * 96}px)`,
        }}
      >
        <BrandImage file="wordmark" height={96} />
      </div>
      <Headline
        words={[
          { text: 'Know' },
          { text: 'your' },
          { text: 'backup' },
          { text: 'before' },
          { text: 'the' },
          { text: 'light goes.', mark: true },
        ]}
        at={tagAt}
        top={1150}
        size={84}
      />
      <div
        style={{
          position: 'absolute',
          top: 1500,
          left: 0,
          right: 0,
          display: 'flex',
          justifyContent: 'center',
          gap: 20,
          opacity: chips,
          transform: `translateY(${(1 - chips) * 20}px)`,
        }}
      >
        {[
          { Icon: CloudSlash, label: 'Works offline' },
          { Icon: Translate, label: 'English · Roman Urdu' },
        ].map(({ Icon, label }) => (
          <div
            key={label}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 12,
              height: 72,
              padding: '0 30px',
              borderRadius: radius.pill,
              background: color.surface,
              color: color.ink,
              fontSize: 30,
              fontWeight: 700,
            }}
          >
            <Icon size={32} />
            {label}
          </div>
        ))}
      </div>
      <Narration id="outro" captions={false} />
      <Sfx name="pop" at={2} />
      <Sfx name="shutter-modern" at={20} />
      <Sfx name="whip" at={tagAt} />
    </AbsoluteFill>
  );
}
