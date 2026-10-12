import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../services/notification_inbox.dart';

/// The app bar's bell, with how many notifications came since the list
/// was last opened. The count is in the label too, for screen readers.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final unread = ref.watch(unreadNotificationsProvider);
    return BbCountBadge(
      count: unread,
      child: BbIconButton(
        icon: BbIcons.notifications,
        tooltip: unread == 0
            ? l10n.notificationsTitle
            : l10n.notificationsUnread(unread),
        onPressed: onPressed,
      ),
    );
  }
}
