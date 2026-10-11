import 'package:flutter/material.dart';

import '../../foundations/semantic/app_colors.dart';
import '../../foundations/tokens/elevation.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/context_extensions.dart';

enum BbCardVariant {
  /// `surface` + soft shadow (light) / lighter surface (dark).
  standard,

  /// Dashboard hero: midnight `hero` fill, larger radius and padding. Its
  /// content is drawn with the dark palette in both themes.
  hero,

  /// Soft yellow `primaryContainer` tint, no shadow — the top AI advice card.
  highlight,
}

/// Content container (DESIGN.md §10.3). Separated from the page by surface
/// color and shadow, never a border. Never put a card inside a card; use a
/// `surfaceMuted` group instead.
///
/// ```dart
/// BbCard(child: Text(advice))
/// BbCard(variant: BbCardVariant.hero, child: BbCountdownRing(...))
/// BbCard.list(children: [for (final a in appliances) BbLoadToggleTile(...)])
/// ```
class BbCard extends StatelessWidget {
  const BbCard({
    super.key,
    required Widget this.child,
    this.variant = BbCardVariant.standard,
  }) : children = null;

  /// A list group (DESIGN.md §5.2): rows sit flush to the card and bring
  /// their own 16 px padding; hairline dividers inset 16 go between them.
  const BbCard.list({super.key, required List<Widget> this.children})
    : child = null,
      variant = BbCardVariant.standard;

  final Widget? child;
  final List<Widget>? children;
  final BbCardVariant variant;

  // Built once: the hero's content always uses the dark palette, so yellow,
  // status colors and text are the tones designed for a dark surface.
  static final _heroTheme = AppTheme.dark();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hero = variant == BbCardVariant.hero;
    final radius = BorderRadius.circular(hero ? AppRadius.xl : AppRadius.lg);
    final rows = children;

    Widget content = rows != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, row) in rows.indexed) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: AppSpacing.lg,
                    color: colors.outlineVariant,
                  ),
                row,
              ],
            ],
          )
        : Padding(
            padding: EdgeInsets.all(hero ? AppSpacing.xl : AppSpacing.lg),
            child: child,
          );
    if (hero) {
      final dark = _heroTheme.extension<AppColors>()!;
      content = Theme(
        data: _heroTheme,
        child: DefaultTextStyle.merge(
          style: _heroTheme.textTheme.bodyMedium,
          child: IconTheme.merge(
            data: IconThemeData(color: dark.textPrimary),
            child: content,
          ),
        ),
      );
    }

    final (fill, shadows) = switch (variant) {
      BbCardVariant.standard => (
        colors.surface,
        AppElevation.level1.shadows(Theme.of(context).brightness),
      ),
      BbCardVariant.hero => (colors.hero, <BoxShadow>[]),
      BbCardVariant.highlight => (colors.primaryContainer, <BoxShadow>[]),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        boxShadow: shadows,
      ),
      child: ClipRRect(borderRadius: radius, child: content),
    );
  }
}
