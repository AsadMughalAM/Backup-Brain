import 'package:flutter/material.dart';

import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';

/// Nothing to show yet, or a friendly error (DESIGN.md §8.6): a large muted
/// icon, a one-line headline, a short explanation and at most one action.
///
/// ```dart
/// BbEmptyState(
///   icon: BbIcons.offline,
///   title: l10n.needsInternet,
///   message: l10n.forecastNeedsInternet,
///   action: BbButton.secondary(label: l10n.tryAgain, onPressed: retry),
/// )
/// ```
class BbEmptyState extends StatelessWidget {
  const BbEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Usually a `BbButton.secondary`.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Icon(
              icon,
              size: AppSizes.iconXl,
              color: context.colors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xl),
            action,
          ],
        ],
      ),
    );
  }
}
