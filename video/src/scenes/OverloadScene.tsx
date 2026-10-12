import { AbsoluteFill, useCurrentFrame, useVideoConfig } from 'remotion';
import { PlannerScreen } from '../app/PlannerScreen';
import { BACKUP_MINUTES, LOADS } from '../mock-data';
import { pop, progress, tween } from '../lib/motion';
import { color } from '../theme';
import { spokenAt } from '../timeline';
import { Camera, WIDE } from '../ui/Camera';
import { Headline } from '../ui/Headline';
import { Narration } from '../ui/Narration';
import { Phone, onCanvas } from '../ui/Phone';
import { Sfx } from '../ui/Sfx';
import { Tap } from '../ui/Tap';

/** Scrolled so the iron and water motor switches sit in view (calibrated from stills). */
const LIST_SCROLL = 660;
const SWITCH_X = 332;
const IRON_Y = 614;
const MOTOR_Y = 698;

/** Problem → solution: heavy loads tip the inverter over, and the app says so first. */
export function OverloadScene(): React.JSX.Element {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const ironAt = spokenAt('overload', 'iron') + 2;
  const motorAt = spokenAt('overload', 'water motor') + 2;
  const warnAt = spokenAt('overload', 'warns you');
  const scroll = tween(frame, [4, 24, warnAt - 10, warnAt], [0, LIST_SCROLL, LIST_SCROLL, 0]);
  const overload = pop(frame, warnAt, fps);
  const loadW = frame < ironAt ? LOADS.normal : frame < motorAt ? LOADS.iron : LOADS.overload;
  const minutes = tween(
    frame,
    [ironAt, ironAt + 10, motorAt, motorAt + 10],
    [BACKUP_MINUTES.at420, BACKUP_MINUTES.at1420, BACKUP_MINUTES.at1420, BACKUP_MINUTES.at2170],
  );
  const banner = onCanvas(195, 260);

  return (
    <AbsoluteFill style={{ background: color.bg }}>
      <Camera
        keys={[
          { at: 0, ...WIDE },
          { at: warnAt - 4, ...WIDE },
          { at: warnAt + 10, x: banner.x, y: banner.y, scale: 1.3, shake: 14 },
        ]}
      >
        <Phone>
          <PlannerScreen
            scroll={scroll}
            minutes={minutes}
            loadW={loadW}
            ironOn={progress(frame, ironAt, 6)}
            motorOn={progress(frame, motorAt, 6)}
            overload={Math.min(1, overload)}
            gone={{}}
            step={0}
          />
          <Tap at={ironAt} x={SWITCH_X} y={IRON_Y} />
          <Tap at={motorAt} x={SWITCH_X} y={MOTOR_Y} />
        </Phone>
      </Camera>
      <Headline
        words={[{ text: 'Warns' }, { text: 'you' }, { text: 'before', mark: true }, { text: 'it' }, { text: 'trips.' }]}
        at={6}
        top={150}
      />
      <Narration id="overload" />
      <Sfx name="whoosh" at={2} />
      <Sfx name="switch" at={ironAt} />
      <Sfx name="switch" at={motorAt} />
      <Sfx name="impact" at={warnAt} />
    </AbsoluteFill>
  );
}
