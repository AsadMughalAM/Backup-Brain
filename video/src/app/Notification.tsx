import { t } from '../copy';
import { ALERT } from '../mock-data';
import { color, shadow } from '../theme';
import { BrandImage } from './chrome';

/**
 * The F8 heads-up, 30 minutes before a scheduled cut the battery won't cover
 * (outage_alerts.dart: alertTitleScheduled + alertBodyShort). Drawn in frame
 * pixels: it breaks out of the phone toward the camera.
 */
export function OutageNotification(): React.JSX.Element {
  return (
    <div
      style={{
        width: 900,
        borderRadius: 44,
        background: color.surface,
        boxShadow: shadow.float,
        padding: '30px 36px',
        display: 'flex',
        gap: 24,
      }}
    >
      <div
        style={{
          width: 76,
          height: 76,
          borderRadius: 22,
          background: color.bg,
          display: 'grid',
          placeItems: 'center',
          flexShrink: 0,
        }}
      >
        <BrandImage file="mark" height={46} />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
        <div style={{ fontSize: 24, fontWeight: 600, color: color.muted }}>{t('appTitle')} · now</div>
        <div style={{ fontSize: 34, fontWeight: 800, letterSpacing: -0.6 }}>
          {t('alertTitleScheduled', { time: ALERT.time })}
        </div>
        <div style={{ fontSize: 28, fontWeight: 500, lineHeight: 1.35, color: color.muted }}>
          {t('alertBodyShort', { soc: ALERT.soc, backup: ALERT.backup, outage: ALERT.outage })}
        </div>
      </div>
    </div>
  );
}
