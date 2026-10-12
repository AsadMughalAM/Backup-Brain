import { Composition } from 'remotion';
import { Ad } from './Ad';
import { VIDEO } from './theme';
import { TOTAL_FRAMES } from './timeline';

export function RemotionRoot(): React.JSX.Element {
  return (
    <Composition
      id="BackupBrainAd"
      component={Ad}
      durationInFrames={TOTAL_FRAMES}
      fps={VIDEO.fps}
      width={VIDEO.width}
      height={VIDEO.height}
    />
  );
}
