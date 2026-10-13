import {
  Drop,
  Fan,
  Laptop,
  Lightbulb,
  TShirt,
  Television,
  ThermometerCold,
  WifiHigh,
  type Icon,
} from '@phosphor-icons/react';

/** BbIcons' appliance glyphs (DESIGN.md icon table), keyed by demo_household icon names. */
export const APPLIANCE_ICONS: Record<string, Icon> = {
  fan: Fan,
  fridge: ThermometerCold,
  tv: Television,
  laptop: Laptop,
  router: WifiHigh,
  light: Lightbulb,
  iron: TShirt,
  water: Drop,
};
