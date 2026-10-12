import type { ReactNode } from 'react';
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from 'remotion';
import { EstimateCard, HealthCard, ShopsCard } from '../app/MontageCards';
import { pop } from '../lib/motion';
import { color, radius } from '../theme';
import { spokenAt } from '../timeline';
import { Headline } from '../ui/Headline';
import { Narration } from '../ui/Narration';
import { Sfx } from '../ui/Sfx';

const SCALE = 2.25;
const CARD_WIDTH = 360 * SCALE;

/**
 * One card in the deck. It flies in from the right, then each newer card
 * pushes it up and back, so the latest always sits front and centre.
 */
function DeckCard({ enter, pushes, tilt, children }: { enter: number; pushes: number; tilt: number; children: ReactNode }) {
  return (
    <div
      style={{
        position: 'absolute',
        left: (1080 - CARD_WIDTH) / 2,
        top: 880,
        width: CARD_WIDTH,
        opacity: Math.min(1, enter),
        transform: [
          `translateX(${(1 - enter) * 900}px)`,
          `translateY(${-pushes * 170}px)`,
          `rotate(${(1 - enter) * 14 + tilt * (1 - pushes * 0.5)}deg)`,
          `scale(${SCALE * (1 - pushes * 0.1)})`,
        ].join(' '),
        transformOrigin: '0 0',
        zIndex: 10 - Math.round(pushes * 2),
      }}
    >
      <div style={{ width: 360, position: 'relative' }}>
        {children}
        {/* Cards behind sink into the page instead of turning see-through. */}
        <div
          style={{
            position: 'absolute',
            inset: 0,
            borderRadius: radius.lg,
            background: color.bg,
            opacity: Math.min(0.7, pushes * 0.45),
          }}
        />
      </div>
    </div>
  );
}

/** Solar cost, battery health and shops nearby, as a fast deck. */
export function MoreScene(): React.JSX.Element {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const solarAt = spokenAt('more', 'Thinking about solar');
  const batteryAt = spokenAt('more', 'Battery wearing out');
  const shopsAt = spokenAt('more', 'and shops');
  const enter = (at: number) => pop(frame, at, fps);
  const pushes = (...ats: number[]) => ats.reduce((sum, at) => sum + Math.min(1, pop(frame, at, fps)), 0);

  return (
    <AbsoluteFill style={{ background: color.bg, overflow: 'hidden' }}>
      <Headline words={[{ text: 'Solar' }, { text: 'ka' }, { text: 'kharcha?', mark: true }]} at={solarAt} out={batteryAt - 8} top={190} size={120} />
      <Headline words={[{ text: 'Battery' }, { text: 'kharab?', mark: true }]} at={batteryAt} top={190} size={120} />
      <DeckCard enter={enter(solarAt)} pushes={pushes(batteryAt, shopsAt)} tilt={-2}>
        <EstimateCard />
      </DeckCard>
      <DeckCard enter={enter(batteryAt)} pushes={pushes(shopsAt)} tilt={2}>
        <HealthCard />
      </DeckCard>
      <DeckCard enter={enter(shopsAt)} pushes={0} tilt={-1}>
        <ShopsCard />
      </DeckCard>
      <Narration id="more" />
      <Sfx name="whip" at={solarAt} />
      <Sfx name="whip" at={batteryAt} />
      <Sfx name="whip" at={shopsAt} />
    </AbsoluteFill>
  );
}
