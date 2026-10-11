import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';

/// Appliance priority tiers (ARCHITECTURE.md F2). Mirrors the engine's enum
/// without importing it — bb_ui and energy_engine never depend on each other.
enum BbPriority { essential, comfort, avoidOnBackup }

/// Priority pill (DESIGN.md §10.6). The label comes from the app's
/// localizations ("Keep" / "Use carefully" / "Avoid on backup").
///
/// ```dart
/// BbPriorityBadge(priority: BbPriority.avoidOnBackup, label: l10n.priorityAvoid)
/// ```
class BbPriorityBadge extends StatelessWidget {
  const BbPriorityBadge({
    super.key,
    required this.priority,
    required this.label,
  });

  final BbPriority priority;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (fill, text) = switch (priority) {
      BbPriority.essential => (c.secondaryContainer, c.onSecondaryContainer),
      BbPriority.comfort => (c.surfaceMuted, c.textPrimary),
      BbPriority.avoidOnBackup => (c.warningContainer, c.textPrimary),
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (priority == BbPriority.avoidOnBackup) ...[
            Icon(BbIcons.warning, size: AppSizes.iconXs, color: c.warning),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelMedium?.copyWith(color: text),
            ),
          ),
        ],
      ),
    );
  }
}
