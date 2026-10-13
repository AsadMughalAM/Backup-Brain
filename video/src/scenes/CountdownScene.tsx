import { AbsoluteFill, useCurrentFrame, useVideoConfig } from 'remotion';
import { HomeScreen } from '../app/HomeScreen';
import { BACKUP_MINUTES, BATTERY_PERCENT, LOADS } from '../mock-data';
import { pop, progress, tween } from '../lib/motion';
import { pulse } from '../lib/pulse';
import { color } from '../theme';
import { spokenAt } from '../timeline';
import { Camera, WIDE } from '../ui/Camera';
import { Headline } from '../ui/Headline';
import { Narration } from '../ui/Narration';
import { Phone, onCanvas } from '../ui/Phone';
import { Sfx } from '../ui/Sfx';

/** Solution: the percent becomes a countdown on Home. */
export function CountdownScene(): React.JSX.Element {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const land = spokenAt('countdown', '3 hours') + 8;
  const gauge = onCanvas(195, 250);
  const rise = pop(frame, 0, fps);

  return (
    <AbsoluteFill style={{ background: color.bg }}>
      <Camera
        keys={[
          { at: 0, ...WIDE },
          { at: 34, ...WIDE },
          { at: land, x: gauge.x, y: gauge.y, scale: 1.32 },
        ]}
      >
        <Phone rise={rise}>
          <HomeScreen
            reveal={progress(frame, 8, 30)}
            gauge={tween(frame, [22, 46], [0, BATTERY_PERCENT / 100])}
            minutes={tween(frame, [22, land], [0, BACKUP_MINUTES.at420])}
            loadW={LOADS.normal}
            pulse={pulse(frame, land)}
          />
        </Phone>
      </Camera>
      <Headline
        words={[{ text: 'Your' }, { text: '60%,' }, { text: 'in' }, { text: 'hours.', mark: true }]}
        at={10}
        top={150}
      />
      <Narration id="countdown" />
      <Sfx name="whoosh" at={2} />
      <Sfx name="ding" at={land} />
    </AbsoluteFill>
  );
}
