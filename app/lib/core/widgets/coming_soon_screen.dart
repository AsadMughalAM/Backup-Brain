import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';

/// Placeholder for a tab whose feature isn't built yet.
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
        child: BbEmptyState(
          icon: icon,
          title: l10n.comingSoonTitle,
          message: description,
        ),
      ),
    );
  }
}
