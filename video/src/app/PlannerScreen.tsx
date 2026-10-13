import { PencilSimple, Warning } from '@phosphor-icons/react';
import { t } from '../copy';
import { BATTERY_PERCENT, INVERTER_W, TURN_OFF_FIRST, appliance, duration, watts, type ApplianceId } from '../mock-data';
import { color, font, radius, type } from '../theme';
import { APPLIANCE_ICONS } from './applianceIcons';
import { Card } from './Card';
import { NavBar, TitleAppBar } from './chrome';
import { Button, IconDisc, Switch } from './controls';

/** Appliances section, in the planner's priority order (essentials first). */
const APPLIANCE_ORDER: ApplianceId[] = [
  'router',
  'led',
  'fan-bedroom',
  'fan-lounge',
  'fridge',
  'tv',
  'laptop',
  'iron',
  'motor',
];

const PRIORITY_LABEL: Record<string, string> = {
  essential: 'priorityEssential',
  comfort: 'priorityComfort',
  avoid_on_backup: 'priorityAvoid',
};

export interface PlannerState {
  /** dp the list has scrolled under the sticky hero. */
  scroll: number;
  minutes: number;
  loadW: number;
  /** 0→1 switch positions for the heavy loads. */
  ironOn: number;
  motorOn: number;
  /** 0→1 height of the overload banner. */
  overload: number;
  /** 0→1 collapse of rows that were just turned off. */
  gone: Partial<Record<ApplianceId, number>>;
  /** Which gain column to show: 0 at 420 W, 1 after TV off, 2 after fridge off. */
  step: 0 | 1 | 2;
  press?: Partial<Record<ApplianceId, number>>;
}

function SectionTitle({ children }: { children: string }) {
  return <div style={{ ...type.titleMedium, margin: '8px 4px 0' }}>{children}</div>;
}

function TurnOffRow({ id, gain, gone, press }: { id: ApplianceId; gain: number; gone: number; press: number }) {
  const a = appliance(id);
  const Icon = APPLIANCE_ICONS[a.icon];
  return (
    <div style={{ height: 64 * (1 - gone), opacity: 1 - gone, overflow: 'hidden' }}>
      <div style={{ height: 64, display: 'flex', alignItems: 'center', gap: 12 }}>
        <IconDisc bg={color.surfaceMuted} fg={color.ink}>
          <Icon size={22} />
        </IconDisc>
        <div style={{ flex: 1, ...type.titleSmall }}>{a.name}</div>
        <div style={{ ...type.metricSmall, ...font.tabular, color: color.success }}>
          {t('gainedTime', { time: duration(gain) })}
        </div>
        <Button variant="ghost" press={press}>
          {t('turnOff')}
        </Button>
      </div>
    </div>
  );
}

function ApplianceTile({ id, on }: { id: ApplianceId; on: number }) {
  const a = appliance(id);
  const Icon = APPLIANCE_ICONS[a.icon];
  const avoid = a.priority === 'avoid_on_backup';
  return (
    <Card style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px' }}>
      <IconDisc bg={on > 0.5 ? color.indigoContainer : color.surfaceMuted} fg={color.ink}>
        <Icon size={22} weight={on > 0.5 ? 'fill' : 'regular'} />
      </IconDisc>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 4 }}>
        <div style={type.titleSmall}>{a.name}</div>
        <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
          <span
            style={{
              ...type.labelMedium,
              ...font.tabular,
              background: color.surfaceMuted,
              borderRadius: radius.pill,
              padding: '2px 8px',
              display: 'flex',
              gap: 4,
              alignItems: 'center',
            }}
          >
            {watts(a.watts * a.quantity)}
            <PencilSimple size={11} />
          </span>
          <span
            style={{
              ...type.labelMedium,
              borderRadius: radius.pill,
              padding: '2px 8px',
              background: avoid ? color.warningContainer : 'transparent',
              color: avoid ? color.warning : color.muted,
            }}
          >
            {t(PRIORITY_LABEL[a.priority])}
          </span>
        </div>
      </div>
      <Switch on={on} />
    </Card>
  );
}

/** F2 Load planner: sticky backup hero, overload banner, Turn off first, appliance switches. */
export function PlannerScreen(s: PlannerState): React.JSX.Element {
  const over = s.overload > 0.5;
  const switchOf = (id: ApplianceId): number => {
    if (id === 'iron') return s.ironOn;
    if (id === 'motor') return s.motorOn;
    return appliance(id).isOn ? 1 - (s.gone[id] ?? 0) : 0;
  };
  return (
    <div style={{ position: 'absolute', inset: 0, top: 44 }}>
      <TitleAppBar title={t('loadsTitle')} />
      <div
        style={{
          position: 'relative',
          zIndex: 10,
          background: color.bg,
          padding: '4px 20px 14px',
          display: 'flex',
          alignItems: 'baseline',
          gap: 10,
        }}
      >
        <div style={{ ...type.metricHero, ...font.tabular, color: over ? color.danger : color.ink }}>
          {duration(s.minutes)}
        </div>
        <div style={{ ...type.bodyLarge, color: over ? color.danger : color.muted }}>
          {t('backupLeftAt', { load: watts(s.loadW) })}
        </div>
      </div>
      <div style={{ position: 'absolute', top: 134, left: 0, right: 0, bottom: 0, overflow: 'hidden' }}>
        <div
          style={{
            transform: `translateY(${-s.scroll}px)`,
            padding: '0 16px 120px',
            display: 'flex',
            flexDirection: 'column',
            gap: 12,
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '0 4px' }}>
            <div style={type.labelLarge}>{t('batteryNow')}</div>
            <div style={{ flex: 1, height: 6, borderRadius: 3, background: color.divider, position: 'relative' }}>
              <div style={{ width: `${BATTERY_PERCENT}%`, height: 6, borderRadius: 3, background: color.ink }} />
              <div
                style={{
                  position: 'absolute',
                  left: `calc(${BATTERY_PERCENT}% - 10px)`,
                  top: -7,
                  width: 20,
                  height: 20,
                  borderRadius: '50%',
                  background: color.ink,
                }}
              />
            </div>
            <div style={{ ...type.metricSmall, ...font.tabular }}>{BATTERY_PERCENT}%</div>
          </div>

          <div style={{ height: 112 * s.overload, opacity: s.overload, overflow: 'hidden' }}>
            <div
              style={{
                background: color.dangerContainer,
                color: color.danger,
                borderRadius: radius.lg,
                padding: 16,
                display: 'flex',
                gap: 12,
                transform: `scale(${0.9 + s.overload * 0.1})`,
              }}
            >
              <Warning size={24} weight="fill" style={{ flexShrink: 0 }} />
              <div>
                <div style={type.titleSmall}>{t('overloadTitle')}</div>
                <div style={{ ...type.bodyMedium, color: color.ink }}>
                  {t('overloadBody', { load: watts(s.loadW), rated: watts(INVERTER_W) })}
                </div>
              </div>
            </div>
          </div>

          <SectionTitle>{t('turnOffFirst')}</SectionTitle>
          <Card style={{ padding: '4px 16px' }}>
            {TURN_OFF_FIRST.map((row) => (
              <TurnOffRow
                key={row.id}
                id={row.id}
                gain={row.gain[s.step]}
                gone={s.gone[row.id] ?? 0}
                press={s.press?.[row.id] ?? 0}
              />
            ))}
          </Card>

          <SectionTitle>{t('appliancesSection')}</SectionTitle>
          {APPLIANCE_ORDER.map((id) => (
            <ApplianceTile key={id} id={id} on={switchOf(id)} />
          ))}
        </div>
      </div>
      <NavBar active="tabLoads" />
    </div>
  );
}
