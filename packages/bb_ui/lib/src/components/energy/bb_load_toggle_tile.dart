import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../foundations/tokens/opacity.dart';
import '../../foundations/tokens/radius.dart';
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
    this.onEditWatts,
    this.editWattsLabel,
  }) : assert(
         onEditWatts == null || editWattsLabel != null,
         'An edit control needs its screen-reader label',
       );

  final IconData icon;
  final String name;

  /// Formatted effective load, e.g. "150 W".
  final String watts;
  final BbPriority priority;
  final String priorityLabel;
  final bool value;
  final ValueChanged<bool>? onChanged;

  /// When set, the watts become their own button (pencil icon) that opens
  /// the wattage choice; the rest of the row still toggles.
  final VoidCallback? onEditWatts;

  /// e.g. "Change watts: Ceiling fan, 150 W".
  final String? editWattsLabel;

  static const _minHeight = 72.0;
  static const _discSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final toggle = onChanged == null ? null : () => onChanged(!value);
    final onEditWatts = this.onEditWatts;
    if (onEditWatts == null) {
      return Tappable(
        onTap: toggle,
        builder: (context, s) => FocusRing(
          visible: s.focused,
          radius: 0,
          child: Semantics(
            toggled: value,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _minHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(child: _identity(context)),
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
        ),
      );
    }
    // Three targets side by side: name (toggles), watts (edits), switch
    // (toggles). The switch repeats the name's action, so screen readers
    // hear it once.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minHeight),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Tappable(
                onTap: toggle,
                builder: (context, s) => FocusRing(
                  visible: s.focused,
                  radius: 0,
                  child: Semantics(
                    toggled: value,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: AppSpacing.lg,
                        top: AppSpacing.md,
                        bottom: AppSpacing.md,
                      ),
                      child: _identity(context),
                    ),
                  ),
                ),
              ),
            ),
            _WattsButton(
              watts: watts,
              label: editWattsLabel!,
              onTap: onEditWatts,
            ),
            ExcludeSemantics(
              child: Tappable(
                onTap: toggle,
                builder: (context, s) => Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.xs,
                    end: AppSpacing.lg,
                  ),
                  child: BbSwitch(value: value, onChanged: onChanged),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _identity(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          width: _discSize,
          height: _discSize,
          decoration: BoxDecoration(
            color: c.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: AppSizes.iconSm, color: c.textPrimary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
      ],
    );
  }
}

/// The tappable watts: a muted pill with the value and a pencil, so it
/// reads as "change this" without a border.
class _WattsButton extends StatelessWidget {
  const _WattsButton({
    required this.watts,
    required this.label,
    required this.onTap,
  });

  final String watts;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, s) {
        final fill = s.pressed || s.hovered
            ? Color.alphaBlend(
                c.textPrimary.withValues(
                  alpha: s.pressed ? AppOpacity.pressed : AppOpacity.hover,
                ),
                c.surfaceMuted,
              )
            : c.surfaceMuted;
        return FocusRing(
          visible: s.focused,
          radius: AppRadius.pill,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BbMetric(value: watts, size: BbMetricSize.small),
                const SizedBox(width: AppSpacing.xs),
                Icon(BbIcons.edit, size: AppSizes.iconXs, color: c.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }
}
