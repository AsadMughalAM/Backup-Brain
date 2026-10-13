import { AbsoluteFill, useCurrentFrame } from 'remotion';
import { AssistantScreen } from '../app/AssistantScreen';
import { CHAT } from '../mock-data';
import { progress, tween } from '../lib/motion';
import { color } from '../theme';
import { Camera, WIDE } from '../ui/Camera';
import { Headline } from '../ui/Headline';
import { Narration } from '../ui/Narration';
import { Phone, onCanvas } from '../ui/Phone';
import { Sfx } from '../ui/Sfx';
import { Tap } from '../ui/Tap';

const TYPE_FROM = 8;
const CHARS_PER_FRAME = 1.5;
const SEND = { x: 348, y: 720 };

/** F9: a Roman Urdu question answered with the app's own numbers. */
export function AskScene(): React.JSX.Element {
  const frame = useCurrentFrame();
  const sendAt = TYPE_FROM + Math.ceil(CHAT.question.length / CHARS_PER_FRAME) + 4;
  const answerFrom = sendAt + 26;
  const chat = onCanvas(195, 380);

  return (
    <AbsoluteFill style={{ background: color.bg }}>
      <Camera
        keys={[
          { at: 0, ...WIDE },
          { at: sendAt, ...WIDE },
          { at: sendAt + 24, x: chat.x, y: chat.y, scale: 1.2 },
        ]}
      >
        <Phone>
          <AssistantScreen
            typedChars={Math.max(0, Math.floor((frame - TYPE_FROM) * CHARS_PER_FRAME))}
            sent={progress(frame, sendAt, 8)}
            typing={progress(frame, sendAt + 8, 6)}
            dotsPhase={frame * 0.35}
            answerChars={Math.max(0, Math.floor((frame - answerFrom) * 2.6))}
            sendPress={tween(frame, [sendAt, sendAt + 4, sendAt + 8], [0, 1, 0])}
          />
          <Tap at={sendAt} x={SEND.x} y={SEND.y} />
        </Phone>
      </Camera>
      <Headline
        words={[{ text: 'Poochein' }, { text: 'Roman Urdu', mark: true }, { text: 'mein.' }]}
        at={6}
        top={150}
      />
      <Narration id="ask" />
      <Sfx name="whoosh" at={2} />
      <Sfx name="mouse-click" at={sendAt} />
      <Sfx name="pop" at={sendAt + 2} />
      <Sfx name="pop" at={answerFrom} />
    </AbsoluteFill>
  );
}
