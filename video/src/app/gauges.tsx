import type { ReactNode } from 'react';
import { color, type } from '../theme';

/** BbBackupGauge: 280×160 half ring, 18px round-capped stroke, indigo fill = battery %. */
export function BackupGauge({ fill, children }: { fill: number; children: ReactNode }): React.JSX.Element {
  const r = 131;
  const arc = Math.PI * r;
  const path = `M ${140 - r} 149 A ${r} ${r} 0 0 1 ${140 + r} 149`;
  return (
    <div style={{ position: 'relative', width: 280, height: 160, margin: '0 auto' }}>
      <svg width={280} height={160} style={{ position: 'absolute', inset: 0 }}>
        <path d={path} stroke={color.divider} strokeWidth={18} fill="none" strokeLinecap="round" />
        <path
          d={path}
          stroke={color.ink}
          strokeWidth={18}
          fill="none"
          strokeLinecap="round"
          strokeDasharray={`${arc * fill} ${arc}`}
          opacity={fill > 0.001 ? 1 : 0}
        />
      </svg>
      <div
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          bottom: 4,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        {children}
      </div>
    </div>
  );
}

/** BbCountdownRing on the indigo hero card: 14px stroke, arc in the battery status color. */
export function CountdownRing({
  fill,
  size = 200,
  children,
}: {
  fill: number;
  size?: number;
  children: ReactNode;
}): React.JSX.Element {
  const r = (size - 14) / 2;
  const c = 2 * Math.PI * r;
  const tone = fill > 0.5 ? '#52D29D' : fill >= 0.2 ? '#FFB25C' : '#FF7D8C';
  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg width={size} height={size} style={{ position: 'absolute', inset: 0, transform: 'rotate(-90deg)' }}>
        <circle cx={size / 2} cy={size / 2} r={r} stroke="rgba(238,241,246,0.12)" strokeWidth={14} fill="none" />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          stroke={tone}
          strokeWidth={14}
          fill="none"
          strokeLinecap="round"
          strokeDasharray={`${c * fill} ${c}`}
        />
      </svg>
      <div
        style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        {children}
      </div>
    </div>
  );
}

/**
 * BbSolarForecastStrip: hourly amber bars with a darker top edge over faint
 * clear-day ghosts. `grow` (0→1) raises the bars left to right.
 */
export function ForecastStrip({
  hours,
  grow,
}: {
  hours: readonly (readonly [number, number])[];
  grow: number;
}): React.JSX.Element {
  const height = 112;
  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'flex-end', gap: 5, height }}>
        {hours.map(([forecast, clear], i) => {
          const local = Math.max(0, Math.min(1, grow * 1.6 - (i / hours.length) * 0.6));
          return (
            <div key={i} style={{ flex: 1, height: '100%', position: 'relative' }}>
              <div
                style={{
                  position: 'absolute',
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: clear * height,
                  borderRadius: 6,
                  background: 'rgba(27,31,59,0.08)',
                }}
              />
              <div
                style={{
                  position: 'absolute',
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: forecast * height * local,
                  borderRadius: 6,
                  background: color.solar,
                  borderTop: `2px solid ${color.solarStroke}`,
                }}
              />
            </div>
          );
        })}
      </div>
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          marginTop: 6,
          ...type.labelMedium,
          color: color.muted,
        }}
      >
        {['6 AM', '9 AM', '12 PM', '3 PM', '6 PM'].map((label) => (
          <span key={label}>{label}</span>
        ))}
      </div>
    </div>
  );
}
