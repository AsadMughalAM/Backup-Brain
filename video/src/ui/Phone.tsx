import type { ReactNode } from 'react';
import { BatteryFull, CellSignalFull, WifiHigh } from '@phosphor-icons/react';
import { color, font } from '../theme';

/** The app is drawn at its real dp size and scaled up into the frame. */
export const SCREEN = { width: 390, height: 844 } as const;
export const DP = 1.6;
const BEZEL = 16;
export const PHONE = {
  width: SCREEN.width * DP + BEZEL * 2,
  height: SCREEN.height * DP + BEZEL * 2,
  left: (1080 - (SCREEN.width * DP + BEZEL * 2)) / 2,
  top: 500,
} as const;

/** Where a dp point inside the screen lands in the 1080×1920 frame. */
export function onCanvas(x: number, y: number): { x: number; y: number } {
  return { x: PHONE.left + BEZEL + x * DP, y: PHONE.top + BEZEL + y * DP };
}

function StatusBar({ time }: { time: string }): React.JSX.Element {
  return (
    <div
      style={{
        height: 44,
        padding: '0 26px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        fontSize: 15,
        fontWeight: 700,
        color: color.ink,
      }}
    >
      <span style={{ fontVariantNumeric: 'tabular-nums' }}>{time}</span>
      <span style={{ display: 'flex', gap: 5 }}>
        <CellSignalFull size={17} weight="fill" />
        <WifiHigh size={17} weight="bold" />
        <BatteryFull size={20} weight="fill" />
      </span>
    </div>
  );
}

/**
 * A phone frame. `rise` (0→1) brings it up from below the frame; `tilt` leans
 * it back in 3D for the hero moments.
 */
export function Phone({
  children,
  rise = 1,
  tilt = 0,
  time = '6:12',
}: {
  children: ReactNode;
  rise?: number;
  tilt?: number;
  time?: string;
}): React.JSX.Element {
  return (
    <div
      style={{
        position: 'absolute',
        left: PHONE.left,
        top: PHONE.top,
        width: PHONE.width,
        height: PHONE.height,
        borderRadius: 78,
        background: '#0B0D1A',
        padding: BEZEL,
        boxShadow: '0 30px 60px rgba(18,21,42,0.25), 0 80px 160px rgba(18,21,42,0.22)',
        transform: `perspective(2400px) translateY(${(1 - rise) * 1500}px) rotateX(${tilt * 14}deg) rotateZ(${tilt * -3}deg)`,
        transformOrigin: '50% 100%',
      }}
    >
      <div
        style={{
          width: SCREEN.width * DP,
          height: SCREEN.height * DP,
          borderRadius: 62,
          overflow: 'hidden',
          position: 'relative',
          background: color.bg,
        }}
      >
        <div
          style={{
            width: SCREEN.width,
            height: SCREEN.height,
            transform: `scale(${DP})`,
            transformOrigin: '0 0',
            fontFamily: font.sans,
            color: color.ink,
            position: 'relative',
          }}
        >
          <StatusBar time={time} />
          {children}
          <div
            style={{
              position: 'absolute',
              top: 11,
              left: SCREEN.width / 2 - 58,
              width: 116,
              height: 32,
              borderRadius: 999,
              background: '#0B0D1A',
            }}
          />
        </div>
      </div>
    </div>
  );
}
