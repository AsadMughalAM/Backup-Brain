import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../foundations/tokens/motion.dart';
import '../../foundations/tokens/opacity.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../_internal/tappable.dart';

/// Selectable pill (DESIGN.md §10.4), e.g. a Today / Tomorrow switch.
/// Unselected = muted fill; selected = navy fill plus a check icon, so the
/// state never rests on color alone. 32 px tall inside a 48 dp hit area.
///
/// ```dart
/// BbChip(label: l10n.today, selected: day == Day.today, onSelected: () => pick(Day.today))
/// ```
class BbChip extends StatelessWidget {
  const BbChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;

  /// Null disables the chip.
  final VoidCallback? onSelected;

  static const _verticalPadding = 6.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      onTap: onSelected,
      builder: (context, state) {
        final fg = selected ? c.onSecondary : c.textPrimary;
        final base = selected ? c.secondary : c.surfaceMuted;
        // Interaction shows as a background shift, never a border.
        final fill = state.pressed || state.hovered
            ? Color.alphaBlend(
                fg.withValues(
                  alpha: state.pressed ? AppOpacity.pressed : AppOpacity.hover,
                ),
                base,
              )
            : base;
        final pill = FocusRing(
          visible: state.focused,
          radius: AppRadius.pill,
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.fast),
            // 20 px label line + 2 × 6 = the 32 px pill; grows with text
            // scale instead of clipping.
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: _verticalPadding,
            ),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Icon(BbIcons.check, size: AppSizes.iconXs, color: fg),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: context.textTheme.labelLarge?.copyWith(color: fg),
                ),
              ],
            ),
          ),
        );
        // Inside the Tappable so it merges into the one button node.
        return Semantics(
          selected: selected,
          child: state.enabled
              ? pill
              : Opacity(opacity: AppOpacity.disabled, child: pill),
        );
      },
    );
  }
}
