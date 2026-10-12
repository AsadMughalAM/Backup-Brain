import { BatteryHigh, Bell, ChatCircleDots, House, Plugs, Sun } from '@phosphor-icons/react';
import { staticFile } from 'remotion';
import { t } from '../copy';
import { color, radius, shadow, type } from '../theme';

/** The one-color brand PNGs, tinted with the ink color the way BrandLogo does. */
export function BrandImage({ file, height, tint = color.ink }: { file: string; height: number; tint?: string }) {
  const ratio = file === 'mark' ? 399 / 384 : 888 / 144;
  return (
    <div
      style={{
        height,
        width: height * ratio,
        background: tint,
        WebkitMaskImage: `url(${staticFile(`brand/${file}.png`)})`,
        WebkitMaskSize: 'contain',
        WebkitMaskRepeat: 'no-repeat',
        WebkitMaskPosition: 'center',
      }}
    />
  );
}

/** Home app bar: mark + wordmark, bell with a coral count badge. */
export function HomeAppBar({ badge }: { badge?: number }): React.JSX.Element {
  return (
    <div style={{ height: 56, padding: '0 16px', display: 'flex', alignItems: 'center', gap: 8 }}>
      <BrandImage file="mark" height={28} />
      <BrandImage file="wordmark" height={17} />
      <div style={{ flex: 1 }} />
      <div style={{ position: 'relative', width: 40, height: 40, display: 'grid', placeItems: 'center' }}>
        <Bell size={24} />
        {badge ? (
          <div
            style={{
              position: 'absolute',
              top: 4,
              right: 3,
              minWidth: 18,
              height: 18,
              borderRadius: 9,
              background: color.coral,
              color: color.inkDeep,
              fontSize: 11,
              fontWeight: 800,
              display: 'grid',
              placeItems: 'center',
            }}
          >
            {badge}
          </div>
        ) : null}
      </div>
    </div>
  );
}

/** A screen title app bar (Load planner, Solar…). */
export function TitleAppBar({ title }: { title: string }): React.JSX.Element {
  return (
    <div style={{ height: 56, padding: '0 20px', display: 'flex', alignItems: 'center', ...type.titleLarge }}>
      {title}
    </div>
  );
}

const TABS = [
  { key: 'tabHome', Icon: House },
  { key: 'tabLoads', Icon: Plugs },
  { key: 'tabSolar', Icon: Sun },
  { key: 'tabBattery', Icon: BatteryHigh },
  { key: 'tabAssistant', Icon: ChatCircleDots },
] as const;

export type TabKey = (typeof TABS)[number]['key'];

/** Floating nav bar: 74 tall, radius 32, sliding indigo pill behind the active icon. */
export function NavBar({ active }: { active: TabKey }): React.JSX.Element {
  return (
    <div
      style={{
        position: 'absolute',
        left: 12,
        right: 12,
        bottom: 12,
        height: 74,
        borderRadius: radius.xl,
        background: color.surface,
        boxShadow: shadow.level2,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-around',
        zIndex: 20,
      }}
    >
      {TABS.map(({ key, Icon }) => {
        const selected = key === active;
        return (
          <div key={key} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, width: 64 }}>
            <div
              style={{
                width: 56,
                height: 32,
                borderRadius: radius.pill,
                background: selected ? color.ink : 'transparent',
                color: selected ? '#fff' : color.muted,
                display: 'grid',
                placeItems: 'center',
              }}
            >
              <Icon size={22} weight={selected ? 'fill' : 'regular'} />
            </div>
            <div style={{ fontSize: 11, fontWeight: selected ? 800 : 600, color: selected ? color.ink : color.muted }}>
              {t(key)}
            </div>
          </div>
        );
      })}
    </div>
  );
}
