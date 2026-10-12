import { AbsoluteFill, useCurrentFrame } from 'remotion';
import { PlannerScreen } from '../app/PlannerScreen';
import { BACKUP_MINUTES, LOADS } from '../mock-data';
import { progress, tween } from '../lib/motion';
import { color } from '../theme';
import { spokenAt } from '../timeline';
import { Camera, WIDE } from '../ui/Camera';
import { Headline } from '../ui/Headline';
import { Narration } from '../ui/Narration';
import { Phone, onCanvas } from '../ui/Phone';
import { Sfx } from '../ui/Sfx';
import { Tap } from '../ui/Tap';

/** The top row's Turn off button; after a row collapses the next one slides into the same spot. */
const TURN_OFF = { x: 318, y: 302 };

/** Solution: a ranked list of what to switch off, and the countdown climbing. */
export function PlannerScene(): React.JSX.Element {
  const frame = useCurrentFrame();
  const ranks = spokenAt('planner', 'It ranks');
  const tvAt = spokenAt('planner', 'Two taps') + 4;
  const fridgeAt = tvAt + 22;
  const tvGone = progress(frame, tvAt + 4, 12);
  const fridgeGone = progress(frame, fridgeAt + 4, 12);
  const step = fridgeGone > 0.5 ? 2 : tvGone > 0.5 ? 1 : 0;
  const minutes = tween(
    frame,
    [tvAt, tvAt + 12, fridgeAt, fridgeAt + 12],
    [BACKUP_MINUTES.at420, BACKUP_MINUTES.at330, BACKUP_MINUTES.at330, BACKUP_MINUTES.at250],
  );
  const loadW = frame < tvAt ? LOADS.normal : frame < fridgeAt ? LOADS.tvOff : LOADS.twoOff;
  const list = onCanvas(195, 360);
  const press = (at: number) => tween(frame, [at, at + 4, at + 8], [0, 1, 0]);

  return (
    <AbsoluteFill style={{ background: color.bg }}>
      <Camera
        keys={[
          { at: 0, ...WIDE },
          { at: ranks - 4, ...WIDE },
          { at: ranks + 14, x: list.x, y: list.y, scale: 1.22 },
        ]}
      >
        <Phone>
          <PlannerScreen
            scroll={0}
            minutes={minutes}
            loadW={loadW}
            ironOn={0}
            motorOn={0}
            overload={0}
            gone={{ tv: tvGone, fridge: fridgeGone }}
            step={step}
            press={{ tv: press(tvAt), fridge: press(fridgeAt) }}
          />
          <Tap at={tvAt} x={TURN_OFF.x} y={TURN_OFF.y} />
          <Tap at={fridgeAt} x={TURN_OFF.x} y={TURN_OFF.y} />
        </Phone>
      </Camera>
      <Headline
        words={[{ text: 'Know' }, { text: 'what' }, { text: 'to' }, { text: 'turn' }, { text: 'off' }, { text: 'first.', mark: true }]}
        at={6}
        top={150}
      />
      <Narration id="planner" />
      <Sfx name="whoosh" at={2} />
      <Sfx name="mouse-click" at={tvAt} />
      <Sfx name="mouse-click" at={fridgeAt} />
      <Sfx name="ding" at={fridgeAt + 12} />
    </AbsoluteFill>
  );
}
