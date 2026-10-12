import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../foundations/tokens/opacity.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../_internal/tappable.dart';

/// A field that opens a picker instead of a keyboard (DESIGN.md §10.2):
/// the same label, 52 px height and outline as `BbTextField`, the chosen
/// value (or a muted [placeholder]) and a caret. The picker, usually a
/// searchable sheet, is the caller's: [onTap] opens it through the
/// OverlayHost.
///
/// ```dart
/// BbDropdown(label: l10n.cityLabel, value: city?.name,
///   placeholder: l10n.cityPick, icon: BbIcons.location, onTap: openPicker)
/// ```
class BbDropdown extends StatelessWidget {
  const BbDropdown({
    super.key,
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.value,
    this.icon,
  });

  final String label;

  /// Null shows [placeholder].
  final String? value;
  final String placeholder;
  final IconData? icon;
  final VoidCallback onTap;

  static const _height = 52.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.textTheme;
    final value = this.value;
    final icon = this.icon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: t.labelLarge?.copyWith(color: c.textPrimary)),
        const SizedBox(height: AppSpacing.xs),
        Tappable(
          onTap: onTap,
          semanticLabel: '$label, ${value ?? placeholder}',
          builder: (context, state) {
            final fill = state.pressed || state.hovered
                ? Color.alphaBlend(
                    c.textPrimary.withValues(
                      alpha: state.pressed
                          ? AppOpacity.pressed
                          : AppOpacity.hover,
                    ),
                    c.surface,
                  )
                : c.surface;
            return FocusRing(
              visible: state.focused,
              radius: AppRadius.md,
              child: Container(
                height: _height,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  // An input's outline: the one place a boundary is allowed.
                  border: Border.all(color: c.outlineVariant),
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: AppSizes.iconSm, color: c.textMuted),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    Expanded(
                      child: Text(
                        value ?? placeholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodyLarge?.copyWith(
                          color: value == null ? c.textMuted : c.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      BbIcons.expand,
                      size: AppSizes.iconSm,
                      color: c.textMuted,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
