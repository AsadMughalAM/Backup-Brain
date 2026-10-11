import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';

/// Placeholder for a tab whose feature isn't built yet, shaped like the
/// empty state in DESIGN.md §8.6.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BbScaffold(
      title: title,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: AppSizes.iconXl,
                color: context.colors.textMuted,
              ),
              const BbGap.lg(),
              Text(l10n.comingSoonTitle, style: context.textTheme.titleMedium),
              const BbGap.xs(),
              Text(
                description,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
