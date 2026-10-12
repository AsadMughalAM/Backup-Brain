import { AbsoluteFill, useCurrentFrame, useVideoConfig } from 'remotion';
import { OutageNotification } from '../app/Notification';
import { SolarScreen } from '../app/SolarScreen';
import { SOLAR } from '../mock-data';
import { pop, progress, tween } from '../lib/motion';
import { color } from '../theme';
import { spokenAt } from '../timeline';
import { Camera, WIDE } from '../ui/Camera';
import { Headline } from '../ui/Headline';
import { Narration } from '../ui/Narration';
import { Phone, onCanvas } from '../ui/Phone';
import { Sfx } from '../ui/Sfx';
import { Tap } from '../ui/Tap';

const TOMORROW_CHIP = { x: 140, y: 118 };
const TOMORROW_RING = 0.73;

/** Solution: tomorrow's sun and the next cut, with a heads-up before it. */
export function ReadyScene(): React.JSX.Element {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const tomorrowAt = spokenAt('ready', "tomorrow's sun");
  const alertAt = spokenAt('ready', 'and warns you') - 4;
  const tomorrow = frame >= tomorrowAt + 2;
  const today = SOLAR.reachesPercent / 100;
  const ring = tomorrow
    ? tween(frame, [tomorrowAt + 2, tomorrowAt + 16], [0, TOMORROW_RING])
    : tween(frame, [10, 40], [0, today]);
  const drop = pop(frame, alertAt, fps);
  const hero = onCanvas(195, 300);

  return (
    <AbsoluteFill style={{ background: color.bg }}>
      <Camera
        keys={[
          { at: 0, ...WIDE },
          { at: 20, ...WIDE },
          { at: tomorrowAt + 10, x: hero.x, y: hero.y, scale: 1.18 },
          { at: alertAt, x: hero.x, y: hero.y, scale: 1.18 },
          { at: alertAt + 20, ...WIDE },
        ]}
      >
        <Phone>
          <SolarScreen
            reveal={progress(frame, 4, 26)}
            ring={ring}
            tomorrow={tomorrow}
            stripGrow={tomorrow ? 1 : progress(frame, 14, 36)}
          />
          <Tap at={tomorrowAt} x={TOMORROW_CHIP.x} y={TOMORROW_CHIP.y} />
        </Phone>
        <AbsoluteFill style={{ background: color.night, opacity: drop * 0.35 }} />
      </Camera>
      <Headline
        words={[{ text: 'Ready' }, { text: 'before' }, { text: 'the' }, { text: 'next cut.', mark: true }]}
        at={6}
        out={alertAt - 6}
        top={150}
      />
      <div
        style={{
          position: 'absolute',
          left: 90,
          top: 160,
          opacity: Math.min(1, drop),
          transform: `translateY(${(1 - drop) * -420}px) scale(${0.92 + drop * 0.08})`,
        }}
      >
        <OutageNotification />
      </div>
      <Narration id="ready" />
      <Sfx name="whoosh" at={2} />
      <Sfx name="mouse-click" at={tomorrowAt} />
      <Sfx name="ding" at={alertAt + 2} />
    </AbsoluteFill>
  );
}
