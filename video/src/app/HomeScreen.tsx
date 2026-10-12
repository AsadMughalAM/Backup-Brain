import { BatteryHigh, Lightning, LightningSlash, Plugs, Sparkle } from '@phosphor-icons/react';
import { t } from '../copy';
import { BATTERY_PERCENT, duration, watts } from '../mock-data';
import { color, font, type } from '../theme';
import { Card } from './Card';
import { HomeAppBar, NavBar } from './chrome';
import { Button, IconDisc } from './controls';
import { BackupGauge } from './gauges';
import { appear } from './reveal';

export interface HomeState {
  reveal: number;
  /** 0 → battery fraction, swept like BbBackupGauge's entry. */
  gauge: number;
  minutes: number;
  loadW: number;
  /** Highlight on the hero number (0→1), for the camera push. */
  pulse?: number;
}

/** F1 Home during a power cut: grid pill, backup hero, stat tiles, AI tip. */
export function HomeScreen({ reveal, gauge, minutes, loadW, pulse = 0 }: HomeState): React.JSX.Element {
  const section = (i: number) => appear(reveal, i, 4);
  return (
    <div>
      <HomeAppBar badge={2} />
      <div style={{ padding: '4px 16px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div
          style={{
            ...section(0),
            alignSelf: 'flex-start',
            height: 40,
            padding: '0 16px',
            borderRadius: 999,
            background: color.surface,
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            ...type.labelLarge,
          }}
        >
          <LightningSlash size={18} weight="fill" />
          {t('gridOff')}
          <span style={{ color: color.muted }}>· {t('outageSince', { time: '6:10 PM' })}</span>
        </div>

        <Card style={{ ...section(1), padding: 24, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <BackupGauge fill={gauge}>
            <div
              style={{
                ...type.metricHero,
                ...font.tabular,
                transform: `scale(${1 + pulse * 0.06})`,
              }}
            >
              {duration(minutes)}
            </div>
            <div style={{ ...type.bodyMedium, color: color.muted }}>{t('backupLeftAt', { load: watts(loadW) })}</div>
          </BackupGauge>
          <div style={{ ...type.bodySmall, color: color.muted, textAlign: 'center' }}>
            {t('stopsProtectingAt', { percent: '15%' })}
          </div>
          <Button variant="secondary" full>
            <Plugs size={20} />
            {t('whatToTurnOff')}
          </Button>
        </Card>

        <div style={{ ...section(2), display: 'flex', gap: 12 }}>
          <Card style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
            <IconDisc bg={color.successContainer} fg={color.success} size={36}>
              <BatteryHigh size={20} weight="fill" />
            </IconDisc>
            <div style={{ ...type.labelMedium, color: color.muted }}>{t('statBattery')}</div>
            <div style={{ ...type.metricLarge, ...font.tabular }}>{BATTERY_PERCENT}%</div>
            <div style={{ ...type.bodySmall, color: color.muted }}>
              {t('chargeCheckedAgo', { age: t('ageMinutes', { minutes: 5 }) })}
            </div>
          </Card>
          <Card style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
            <IconDisc bg={color.indigoContainer} fg={color.info} size={36}>
              <Lightning size={20} weight="fill" />
            </IconDisc>
            <div style={{ ...type.labelMedium, color: color.muted }}>{t('statLoad')}</div>
            <div style={{ ...type.metricLarge, ...font.tabular }}>{watts(loadW)}</div>
          </Card>
        </div>

        <Card tone="highlight" style={{ ...section(3), display: 'flex', gap: 12, alignItems: 'center' }}>
          <Sparkle size={22} weight="fill" color={color.coral} />
          <div style={type.bodyMedium}>{t('adviceTurnOff', { name: 'LED TV', time: '56m' })}</div>
        </Card>
      </div>
      <NavBar active="tabHome" />
    </div>
  );
}
