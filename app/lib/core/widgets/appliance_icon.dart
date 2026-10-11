import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/widgets.dart';

/// Appliance preset key (`icon` in the appliance JSON) → glyph. Anything
/// without a preset gets a plug.
IconData applianceIcon(String key) => switch (key) {
  'fan' => BbIcons.fan,
  'light' => BbIcons.light,
  'tv' => BbIcons.tv,
  'router' => BbIcons.router,
  'water' => BbIcons.water,
  'iron' => BbIcons.iron,
  'fridge' => BbIcons.fridge,
  'ac' => BbIcons.ac,
  'cooler' => BbIcons.cooler,
  'laptop' => BbIcons.laptop,
  'desktop' => BbIcons.desktop,
  'charger' => BbIcons.charger,
  'washer' => BbIcons.washer,
  'microwave' => BbIcons.microwave,
  _ => BbIcons.plug,
};
