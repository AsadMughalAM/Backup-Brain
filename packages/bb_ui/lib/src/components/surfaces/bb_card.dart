import 'package:flutter/material.dart';

import '../../foundations/tokens/elevation.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';

enum BbCardVariant {
  /// `surface` + soft shadow (light) / lighter surface (dark).
  standard,

  /// Dashboard hero: `secondaryContainer`, larger radius and padding.
  hero,

  /// `surface` with a yellow leading stripe — the top AI advice card.
  highlight,
}

/// Content container (DESIGN.md §10.3). Separated from the page by surface
/// color and shadow, never a border. Never put a card inside a card; use a
/// `surfaceMuted` group instead.
///
/// ```dart
/// BbCard(child: Text(advice))
/// BbCard(variant: BbCardVariant.hero, child: BbCountdownRing(...))
/// ```
class BbCard extends StatelessWidget {
  const BbCard({
    super.key,
    required this.child,
    this.variant = BbCardVariant.standard,
  });

  final Widget child;
  final BbCardVariant variant;

  static const _stripeWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hero = variant == BbCardVariant.hero;
    final radius = BorderRadius.circular(hero ? AppRadius.xl : AppRadius.lg);
    final padding = EdgeInsets.all(hero ? 20 : AppSpacing.lg);

    Widget content = Padding(padding: padding, child: child);
    if (variant == BbCardVariant.highlight) {
      content = Stack(
        children: [
          content,
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: _stripeWidth,
            child: ColoredBox(color: colors.primary),
          ),
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: hero ? colors.secondaryContainer : colors.surface,
        borderRadius: radius,
        boxShadow: hero
            ? null
            : AppElevation.level1.shadows(Theme.of(context).brightness),
      ),
      child: ClipRRect(borderRadius: radius, child: content),
    );
  }
}
