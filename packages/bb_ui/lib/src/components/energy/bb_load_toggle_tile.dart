import 'package:flutter/material.dart';

import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../_internal/tappable.dart';
import '../data_display/bb_metric.dart';
import '../inputs/bb_switch.dart';
import 'bb_priority_badge.dart';

/// One appliance in the load planner (DESIGN.md §10.6): icon, name, priority
/// badge, watts and an on/off switch. The whole row toggles, so the target
/// is the full tile, not just the switch.
///
/// ```dart
/// BbLoadToggleTile(
///   icon: BbIcons.fan,
///   name: 'Ceiling fan',
///   watts: '75 W',
///   priority: BbPriority.comfort,
///   priorityLabel: l10n.priorityComfort,
///   value: appliance.isOn,
///   onChanged: (on) => controller.setOn(appliance.id, on),
/// )
/// ```
class BbLoadToggleTile extends StatelessWidget {
  const BbLoadToggleTile({
    super.key,
    required this.icon,
    required this.name,
    required this.watts,
    required this.priority,
    required this.priorityLabel,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String name;

  /// Formatted effective load, e.g. "150 W".
  final String watts;
  final BbPriority priority;
  final String priorityLabel;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final onChanged = this.onChanged;
    return Tappable(
      onTap: onChanged == null ? null : () => onChanged(!value),
      builder: (context, s) => Semantics(
        toggled: value,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: AppSizes.iconSm,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      BbPriorityBadge(priority: priority, label: priorityLabel),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                BbMetric(value: watts, size: BbMetricSize.small),
                const SizedBox(width: AppSpacing.sm),
                ExcludeSemantics(
                  child: BbSwitch(value: value, onChanged: onChanged),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
