import { Audio } from '@remotion/media';
import { AbsoluteFill, Sequence, staticFile, useCurrentFrame } from 'remotion';
import { progress } from '../lib/motion';
import { font } from '../theme';
import { audioFrames, lead } from '../timeline';
import { VOICE_LINES, type VoiceLineId } from '../voiceover/lines';

/** Sentence-sized caption chunks. */
function chunks(text: string): string[] {
  return text.match(/[^.?!]+[.?!]+/g)?.map((s) => s.trim()) ?? [text];
}

/** One caption at a time, each held for its share of the spoken clip. */
function Caption({ text, frames }: { text: string; frames: number }): React.JSX.Element | null {
  const frame = useCurrentFrame();
  const parts = chunks(text);
  const total = parts.reduce((s, p) => s + p.length, 0);
  let start = 0;
  for (const part of parts) {
    const length = (part.length / total) * frames;
    const isLast = part === parts[parts.length - 1];
    if (frame < start + length || isLast) {
      const fadeIn = progress(frame, start, 5);
      const fadeOut = 1 - progress(frame, frames + 2, 6);
      const opacity = Math.min(fadeIn, fadeOut);
      if (opacity <= 0) return null;
      return (
        <AbsoluteFill style={{ justifyContent: 'flex-end', alignItems: 'center', paddingBottom: 128 }}>
          <div
            style={{
              maxWidth: 900,
              padding: '14px 28px',
              borderRadius: 24,
              background: 'rgba(14, 16, 36, 0.86)',
              color: '#fff',
              fontFamily: font.sans,
              fontSize: 38,
              fontWeight: 700,
              lineHeight: 1.3,
              textAlign: 'center',
              letterSpacing: -0.5,
              opacity,
              transform: `translateY(${(1 - fadeIn) * 10}px)`,
            }}
          >
            {part}
          </div>
        </AbsoluteFill>
      );
    }
    start += length;
  }
  return null;
}

/** The scene's voice line and its captions, starting after the scene's lead-in. */
export function Narration({ id, captions = true }: { id: VoiceLineId; captions?: boolean }): React.JSX.Element {
  const line = VOICE_LINES.find((l) => l.id === id);
  if (!line) throw new Error(`No voice line "${id}"`);
  return (
    <Sequence from={lead(id)} name={`vo:${id}`} layout="none">
      <Audio src={staticFile(`voiceover/${id}.wav`)} />
      {captions ? <Caption text={line.text} frames={audioFrames(id)} /> : null}
    </Sequence>
  );
}
