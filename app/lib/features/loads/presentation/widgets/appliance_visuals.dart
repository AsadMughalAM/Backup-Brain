import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/widgets.dart';

import '../../../../app/l10n/app_localizations.dart';

/// Appliance preset key → glyph. Anything without a preset gets a plug.
IconData applianceIcon(String key) => switch (key) {
  'fan' => BbIcons.fan,
  'light' => BbIcons.light,
  'tv' => BbIcons.tv,
  'router' => BbIcons.router,
  'water' => BbIcons.water,
  'iron' => BbIcons.iron,
  _ => BbIcons.plug,
};

BbPriority bbPriority(AppliancePriority p) => switch (p) {
  AppliancePriority.essential => BbPriority.essential,
  AppliancePriority.comfort => BbPriority.comfort,
  AppliancePriority.avoidOnBackup => BbPriority.avoidOnBackup,
};

String priorityLabel(AppLocalizations l10n, AppliancePriority p) => switch (p) {
  AppliancePriority.essential => l10n.priorityEssential,
  AppliancePriority.comfort => l10n.priorityComfort,
  AppliancePriority.avoidOnBackup => l10n.priorityAvoid,
};
