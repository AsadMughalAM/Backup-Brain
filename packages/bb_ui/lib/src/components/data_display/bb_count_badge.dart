import 'package:flutter/material.dart';

import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';

/// A count on the corner of an icon (DESIGN.md §10.4), e.g. new
/// notifications on the bell. A number, not a bare dot, so the state never
/// rests on color alone; over [max] it reads "9+". Hidden at zero. The
/// count is decoration: the wrapped control's label must say it too.
///
/// ```dart
/// BbCountBadge(count: unread, child: BbIconButton(icon: BbIcons.notifications, ...))
/// ```
class BbCountBadge extends StatelessWidget {
  const BbCountBadge({
    super.key,
    required this.count,
    required this.child,
    this.max = 9,
  });

  final int count;
  final Widget child;
  final int max;

  static const _minSize = 18.0;

  /// Pulls the badge onto the icon's corner inside the 48 dp hit area.
  static const _inset = 6.0;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;
    final c = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: _inset,
          right: _inset,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: _minSize,
                  minHeight: _minSize,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  count > max ? '$max+' : '$count',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: c.textOnPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
