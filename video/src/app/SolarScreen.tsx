import { CloudSun } from '@phosphor-icons/react';
import { t } from '../copy';
import { SOLAR, watts } from '../mock-data';
import { color, font, type } from '../theme';
import { Card } from './Card';
import { NavBar, TitleAppBar } from './chrome';
import { Chip } from './controls';
import { CountdownRing, ForecastStrip } from './gauges';
import { appear } from './reveal';

export interface SolarState {
  reveal: number;
  /** Ring fill as a fraction (0.79 today, 0.73 tomorrow). */
  ring: number;
  tomorrow: boolean;
  stripGrow: number;
}

/** Tomorrow's fixture value (solar_model_test); the rest of tomorrow's card is not shown. */
const TOMORROW_PERCENT = 73;

/** F3 Solar: Today/Tomorrow chips, indigo hero with the sunset ring, sun forecast strip. */
export function SolarScreen({ reveal, ring, tomorrow, stripGrow }: SolarState): React.JSX.Element {
  const section = (i: number) => appear(reveal, i, 3);
  const percent = tomorrow ? TOMORROW_PERCENT : SOLAR.reachesPercent;
  return (
    <div style={{ position: 'absolute', inset: 0, top: 44 }}>
      <TitleAppBar title={t('tabSolar')} />
      <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div style={{ ...section(0), display: 'flex', gap: 8 }}>
          <Chip selected={!tomorrow}>{t('solarToday')}</Chip>
          <Chip selected={tomorrow}>{t('solarTomorrow')}</Chip>
        </div>

        <Card tone="hero" style={{ ...section(1), display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 14 }}>
          <div style={{ alignSelf: 'stretch' }}>
            <div style={type.headlineSmall}>{t('solarReaches', { percent: `${percent}%` })}</div>
            {tomorrow ? null : (
              <div style={{ ...type.bodyMedium, color: color.nightMuted }}>
                {t('solarStartNow', { percent: `${SOLAR.startPercent}%` })}
              </div>
            )}
          </div>
          <CountdownRing fill={ring}>
            <div style={{ ...type.metricLarge, ...font.tabular }}>{Math.round(ring * 100)}%</div>
            <div style={{ ...type.labelMedium, color: color.nightMuted }}>
              {t('solarAtSunset', { time: SOLAR.sunset })}
            </div>
          </CountdownRing>
          {tomorrow ? null : (
            <div style={{ ...type.bodyMedium, color: color.nightMuted }}>
              {t('solarNightUntil', { time: SOLAR.lastsUntil, load: watts(420) })}
            </div>
          )}
        </Card>

        <Card style={{ ...section(2), display: 'flex', flexDirection: 'column', gap: 10 }}>
          <div style={{ ...type.labelLarge, color: color.muted }}>
            {t(tomorrow ? 'solarSunTomorrow' : 'solarSunToday')}
          </div>
          {tomorrow ? null : (
            <>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 6 }}>
                <span style={{ ...type.metricLarge, ...font.tabular, color: color.solarText }}>{SOLAR.rangeKWh}</span>
                <span style={{ ...type.metricSmall, color: color.muted }}>kWh</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, ...type.bodyMedium, color: color.muted }}>
                <CloudSun size={18} />
                {t('solarBelowClear', { percent: `${SOLAR.lessSunPercent}%` })}
              </div>
            </>
          )}
          <ForecastStrip hours={SOLAR.hours} grow={stripGrow} />
        </Card>
      </div>
      <NavBar active="tabSolar" />
    </div>
  );
}
