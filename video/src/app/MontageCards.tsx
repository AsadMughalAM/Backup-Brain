import { BatteryWarning, Calculator, MapPin, NavigationArrow, Storefront, Warning } from '@phosphor-icons/react';
import { t } from '../copy';
import { ESTIMATE, HEALTH, SHOPS } from '../mock-data';
import { color, font, radius, type } from '../theme';
import { Card } from './Card';
import { Button, Chip, IconDisc } from './controls';

const WIDTH = 360;

function Label({ icon, children }: { icon: React.ReactNode; children: string }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, ...type.labelLarge, color: color.muted }}>
      {icon}
      {children}
    </div>
  );
}

/** F5: the recommended package for 400 units a month in Lahore. */
export function EstimateCard(): React.JSX.Element {
  return (
    <Card style={{ width: WIDTH, display: 'flex', flexDirection: 'column', gap: 10 }}>
      <Label icon={<Calculator size={18} />}>{t('estimatorTitle')}</Label>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <div style={type.titleLarge}>{t('packageHybrid')}</div>
        <div
          style={{
            ...type.labelMedium,
            background: color.coral,
            color: color.inkDeep,
            borderRadius: radius.pill,
            padding: '3px 10px',
          }}
        >
          {t('packageRecommended')}
        </div>
      </div>
      <div style={{ ...type.bodyMedium, color: color.muted }}>{t('packageHybridSub')}</div>
      <div style={{ ...type.metricMedium, ...font.tabular, color: color.success }}>
        {t('packageSavings', { amount: ESTIMATE.savings })}
      </div>
      <div style={{ ...type.bodyMedium, ...font.tabular }}>{t('packageProduction', { units: ESTIMATE.units })}</div>
    </Card>
  );
}

/** F6: a battery that holds less than its label. */
export function HealthCard(): React.JSX.Element {
  return (
    <Card style={{ width: WIDTH, display: 'flex', flexDirection: 'column', gap: 10 }}>
      <Label icon={<BatteryWarning size={18} />}>{t('healthLabel')}</Label>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, color: color.warning }}>
        <Warning size={22} weight="fill" />
        <div style={type.titleLarge}>{t('healthWearing')}</div>
      </div>
      <div style={{ ...type.bodyMedium, ...font.tabular }}>
        {t('healthHolds', { now: HEALTH.now, label: HEALTH.label })}
      </div>
      <div style={{ background: color.warningContainer, borderRadius: radius.md, padding: 12 }}>
        <div style={{ ...type.titleSmall, color: color.warning }}>{t('healthLossTitle')}</div>
        <div style={{ ...type.bodySmall, color: color.ink }}>{t('healthLossBody', { loss: HEALTH.loss })}</div>
      </div>
    </Card>
  );
}

/** F7: real shops near you, nearest first (names here are fictional). */
export function ShopsCard(): React.JSX.Element {
  return (
    <Card style={{ width: WIDTH, display: 'flex', flexDirection: 'column', gap: 10 }}>
      <Label icon={<MapPin size={18} />}>{t('nearbyTitle')}</Label>
      <div style={{ display: 'flex', gap: 6 }}>
        <Chip selected>{t('nearbyBatteryShops')}</Chip>
        <Chip selected={false}>{t('nearbyUpsRepair')}</Chip>
      </div>
      {SHOPS.map((shop) => (
        <div key={shop.name} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <IconDisc bg={color.indigoContainer} fg={color.info} size={38}>
            <Storefront size={20} />
          </IconDisc>
          <div style={{ flex: 1 }}>
            <div style={type.titleSmall}>{shop.name}</div>
            <div style={{ ...type.bodySmall, color: color.muted }}>
              {shop.distance} · {shop.area}
            </div>
          </div>
          <Button variant="tonal">
            <NavigationArrow size={16} />
            {t('nearbyDirections')}
          </Button>
        </div>
      ))}
    </Card>
  );
}
