import 'package:flutter/material.dart';

import '../../foundations/tokens/motion.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';

/// Page position for short intro carousels: the current dot is a wider
/// navy pill, the rest small muted dots — shape changes too, not just color.
///
/// ```dart
/// BbPageDots(count: 3, current: page, semanticLabel: l10n.pageOf(page + 1, 3))
/// ```
class BbPageDots extends StatelessWidget {
  const BbPageDots({
    super.key,
    required this.count,
    required this.current,
    required this.semanticLabel,
  });

  final int count;
  final int current;

  /// e.g. "Page 2 of 3".
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppMotion.of(context, AppMotion.normal),
              curve: AppMotion.enter,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              width: i == current ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == current ? c.secondary : c.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
        ],
      ),
    );
  }
}
