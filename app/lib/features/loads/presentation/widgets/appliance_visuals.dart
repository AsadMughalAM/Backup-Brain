import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';

import '../../../../app/l10n/app_localizations.dart';

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
