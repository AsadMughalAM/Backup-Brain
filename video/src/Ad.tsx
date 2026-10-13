import { Audio } from '@remotion/media';
import { AbsoluteFill, Sequence, interpolate, staticFile } from 'remotion';
import { loadFonts } from './fonts';
import { AskScene } from './scenes/AskScene';
import { CountdownScene } from './scenes/CountdownScene';
import { HookScene } from './scenes/HookScene';
import { MoreScene } from './scenes/MoreScene';
import { OutroScene } from './scenes/OutroScene';
import { OverloadScene } from './scenes/OverloadScene';
import { PlannerScene } from './scenes/PlannerScene';
import { ReadyScene } from './scenes/ReadyScene';
import { color, font } from './theme';
import { SCENE_IDS, TOTAL_FRAMES, sceneLength, sceneStart } from './timeline';
import type { VoiceLineId } from './voiceover/lines';
import { Sfx } from './ui/Sfx';
import { Wipe } from './ui/Wipe';

loadFonts();

const SCENES: Record<VoiceLineId, () => React.JSX.Element> = {
  hook: HookScene,
  countdown: CountdownScene,
  overload: OverloadScene,
  planner: PlannerScene,
  ready: ReadyScene,
  more: MoreScene,
  ask: AskScene,
  outro: OutroScene,
};

const MUSIC_VOLUME = 0.13;

/** The music bed comes in with the app and swells into the logo. */
function Music(): React.JSX.Element {
  const from = sceneStart('countdown');
  const outro = sceneStart('outro') - from;
  const end = TOTAL_FRAMES - from;
  return (
    <Sequence from={from} name="music" layout="none">
      <Audio
        src={staticFile('music/bed.wav')}
        volume={(f) =>
          interpolate(f, [0, 20, outro, outro + 20, end - 30, end], [0, MUSIC_VOLUME, MUSIC_VOLUME, 0.2, 0.2, 0], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          })
        }
      />
    </Sequence>
  );
}

/** Backup Brain, 9:16 ad: the blackout problem, then each feature's answer. */
export function Ad(): React.JSX.Element {
  return (
    <AbsoluteFill style={{ background: color.bg, fontFamily: font.sans }}>
      {SCENE_IDS.map((id) => {
        const Scene = SCENES[id];
        return (
          <Sequence key={id} from={sceneStart(id)} durationInFrames={sceneLength(id)} name={id}>
            <Scene />
          </Sequence>
        );
      })}
      {SCENE_IDS.slice(1).map((id) => (
        <Wipe key={id} at={sceneStart(id)} />
      ))}
      {SCENE_IDS.slice(1).map((id) => (
        <Sfx key={id} name="whoosh" at={sceneStart(id) - 9} />
      ))}
      <Sfx name="riser" at={sceneStart('outro') - 30} />
      <Music />
    </AbsoluteFill>
  );
}
