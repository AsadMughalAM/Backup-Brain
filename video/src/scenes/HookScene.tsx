import { BatteryMedium, Fan } from '@phosphor-icons/react';
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from 'remotion';
import { pop, progress } from '../lib/motion';
import { color, font } from '../theme';
import { spokenAt } from '../timeline';
import { Headline } from '../ui/Headline';
import { Narration } from '../ui/Narration';
import { Sfx } from '../ui/Sfx';

const CUT = 24;
const FLICKER = [27, 29, 31, 33];

/** Fan angle: full speed until the cut, then winding down to a stop. */
function fanAngle(frame: number): number {
  if (frame < CUT) return frame * 32;
  return CUT * 32 + 32 * 18 * (1 - Math.exp(-(frame - CUT) / 18));
}

function lightsOn(frame: number): number {
  if (frame < CUT) return 1;
  const flicks = FLICKER.filter((f) => frame >= f).length;
  return flicks % 2 === 1 && frame < FLICKER[FLICKER.length - 1] ? 0.55 : 0;
}

/** Problem: the power cuts, and the UPS only says "60%". */
export function HookScene(): React.JSX.Element {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const ups = spokenAt('hook', 'The UPS');
  const howLong = spokenAt('hook', 'But how long');
  const light = lightsOn(frame);
  const upsIn = pop(frame, ups - 4, fps);
  const fanFade = 1 - progress(frame, howLong - 6, 14);

  return (
    <AbsoluteFill style={{ background: color.night, fontFamily: font.sans, overflow: 'hidden' }}>
      <AbsoluteFill
        style={{
          background: 'radial-gradient(circle at 50% 30%, rgba(255,226,180,0.55), rgba(255,226,180,0) 60%)',
          opacity: light,
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: 540 - 200,
          top: 300,
          opacity: (0.35 + light * 0.65) * fanFade,
          transform: `rotate(${fanAngle(frame)}deg) scale(${1 - (1 - fanFade) * 0.2})`,
          color: light > 0 ? color.ink : color.nightMuted,
        }}
      >
        <Fan size={400} weight="duotone" />
      </div>

      <Headline words={[{ text: 'Light' }, { text: 'gayi.', mark: true }]} at={CUT + 12} out={howLong - 6} top={830} size={130} ink={color.nightText} />
      <Headline
        words={[{ text: 'How' }, { text: 'long' }, { text: 'is' }, { text: '60%?', mark: true }]}
        at={howLong}
        top={380}
        size={130}
        ink={color.nightText}
      />

      <div
        style={{
          position: 'absolute',
          left: 540 - 260,
          top: 1120 - (frame >= howLong ? progress(frame, howLong, 14) * 260 : 0),
          width: 520,
          padding: 28,
          borderRadius: 40,
          background: color.nightSurface,
          boxShadow: '0 30px 80px rgba(0,0,0,0.5)',
          opacity: upsIn,
          transform: `translateY(${(1 - upsIn) * 120}px) scale(${0.9 + upsIn * 0.1})`,
        }}
      >
        <div style={{ fontSize: 26, fontWeight: 700, color: color.nightMuted, letterSpacing: 4, marginBottom: 14 }}>UPS</div>
        <div
          style={{
            borderRadius: 20,
            background: color.successContainer,
            color: color.success,
            padding: '18px 26px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <BatteryMedium size={110} weight="fill" />
          <div style={{ fontSize: 120, fontWeight: 800, letterSpacing: -4, fontVariantNumeric: 'tabular-nums' }}>60%</div>
        </div>
      </div>

      <Narration id="hook" />
      <Sfx name="power-down" at={CUT - 2} />
      <Sfx name="fan-down" at={CUT} />
      <Sfx name="whip" at={CUT + 10} />
      <Sfx name="pop" at={ups - 4} />
      <Sfx name="whip" at={howLong - 2} />
    </AbsoluteFill>
  );
}
