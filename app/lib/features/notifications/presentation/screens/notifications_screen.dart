import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/services/notification_inbox.dart';
import '../../../../core/utils/formatters.dart';

/// The bell's list: what the phone has shown (newest first, the unread
/// ones marked "New") and what it will show next, so a swiped-away
/// heads-up is never lost and people can see alerts are set up. Opening it
/// clears the bell's count. Every row leads to the Outages screen, where
/// each one can be acted on.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key, required this.outagesLocation});

  final String outagesLocation;

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  /// When the list was last opened before now: what came after is "New"
  /// for this visit, though the bell is cleared at once.
  late final DateTime? _seenBefore = ref.read(notificationInboxProvider).seenAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(notificationInboxProvider.notifier)
          .markSeen(ref.read(nowProvider).value ?? DateTime.now().toUtc());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shown = ref.watch(shownNotificationsProvider);
    final upcoming = ref.watch(upcomingNotificationsProvider);
    final now = ref.watch(nowProvider).value ?? DateTime.now().toUtc();
    void open() => context.push(widget.outagesLocation);

    return BbScaffold(
      title: l10n.notificationsTitle,
      body: shown.isEmpty && upcoming.isEmpty
          ? Center(
              child: BbEmptyState(
                icon: BbIcons.notifications,
                title: l10n.notificationsEmptyTitle,
                message: l10n.notificationsEmptyBody,
                action: BbButton.secondary(
                  label: l10n.notificationsAddSchedule,
                  icon: BbIcons.schedule,
                  onPressed: open,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              children: [
                if (upcoming.isNotEmpty) ...[
                  _Heading(l10n.notificationsUpcoming),
                  BbCard.list(
                    children: [
                      for (final e in upcoming)
                        _Row(
                          entry: e,
                          when: l10n.notificationsAt(
                            Formatters.dayTime(
                              l10n,
                              e.at.toLocal(),
                              now.toLocal(),
                            ),
                          ),
                          onTap: open,
                        ),
                    ],
                  ),
                  const BbGap.xl(),
                ],
                _Heading(l10n.notificationsEarlier),
                if (shown.isEmpty)
                  Text(
                    l10n.notificationsNoneYet,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.textMuted,
                    ),
                  )
                else
                  BbCard.list(
                    children: [
                      for (final e in shown)
                        _Row(
                          entry: e,
                          when: Formatters.age(l10n, now.difference(e.at)),
                          isNew:
                              _seenBefore == null || e.at.isAfter(_seenBefore),
                          onTap: open,
                        ),
                    ],
                  ),
              ],
            ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Semantics(
      header: true,
      child: Text(text, style: context.textTheme.titleMedium),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.entry,
    required this.when,
    required this.onTap,
    this.isNew = false,
  });

  final InboxEntry entry;
  final String when;
  final VoidCallback onTap;

  /// Marked with a "New" tag, not color alone.
  final bool isNew;

  static const _disc = 40.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _disc,
                height: _disc,
                decoration: BoxDecoration(
                  color: isNew ? c.primaryContainer : c.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  switch (entry.kind) {
                    InboxKind.outageAlert => BbIcons.schedule,
                    InboxKind.cutCheck => BbIcons.gridOff,
                    InboxKind.backCheck => BbIcons.gridOn,
                  },
                  size: AppSizes.iconSm,
                  color: isNew ? c.onPrimaryContainer : c.textPrimary,
                ),
              ),
              const BbGap.md(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: context.textTheme.titleSmall,
                          ),
                        ),
                        if (isNew) ...[
                          const BbGap.sm(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: c.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              l10n.notificationsNew,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: c.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const BbGap.xxs(),
                    Text(
                      entry.body,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                    const BbGap.xs(),
                    Text(
                      when,
                      style: context.text.metricCaption.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
