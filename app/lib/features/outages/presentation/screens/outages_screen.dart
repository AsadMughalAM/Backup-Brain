import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/outage_outlook.dart';
import '../../domain/outage_repository.dart';
import '../controllers/schedule_controller.dart';
import '../widgets/grid_status.dart';
import '../widgets/outlook_card.dart';

/// F8 — "Will my battery be ready before the next outage?": the answer
/// first, then the two things it is built from — the area schedule and the
/// household's own log.
class OutagesScreen extends ConsumerWidget {
  const OutagesScreen({super.key, required this.addTimeLocation});

  /// Where "Add time" goes; passed in so this feature doesn't import the
  /// app router.
  final String addTimeLocation;

  /// The log shows the latest few; the pattern uses all of them.
  static const _logRows = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final outlook = ref.watch(outageOutlookProvider);
    final now = ref.watch(nowProvider).value ?? DateTime.now().toUtc();
    final schedule = ref.watch(scheduleProvider).value ?? const [];
    final outages = ref.watch(recentOutagesProvider).value ?? const [];

    return BbScaffold(
      title: l10n.outagesTitle,
      body: outlook == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              children: [
                const GridStatus(),
                const BbGap.lg(),
                OutlookCard(outlook: outlook, now: now),
                const BbGap.xl(),
                Text(l10n.scheduleTitle, style: context.textTheme.titleMedium),
                const BbGap.md(),
                if (schedule.isEmpty)
                  Text(
                    l10n.scheduleEmpty,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.textMuted,
                    ),
                  )
                else
                  BbCard.list(
                    children: [
                      for (final entry in schedule)
                        _ScheduleRow(
                          label: _slotLabel(l10n, entry),
                          onRemove: () => ref
                              .read(scheduleControllerProvider)
                              .remove(entry.id),
                        ),
                    ],
                  ),
                const BbGap.md(),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: BbButton.secondary(
                    label: l10n.scheduleAdd,
                    icon: BbIcons.add,
                    onPressed: () => context.push(addTimeLocation),
                  ),
                ),
                const BbGap.xl(),
                Text(
                  l10n.recentOutagesTitle,
                  style: context.textTheme.titleMedium,
                ),
                const BbGap.md(),
                if (outages.isEmpty)
                  Text(
                    l10n.recentOutagesEmpty,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.textMuted,
                    ),
                  )
                else
                  BbCard.list(
                    children: [
                      for (final o in outages.take(_logRows))
                        _LogRow(event: o, now: now),
                    ],
                  ),
              ],
            ),
    );
  }

  static String _slotLabel(AppLocalizations l10n, ScheduleEntry entry) =>
      l10n.scheduleSlot(
        l10n.weekdayShort('${entry.slot.weekday}'),
        Formatters.minuteOfDay(entry.slot.startMinute),
        Formatters.minuteOfDay(entry.slot.endMinute),
      );
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.textTheme.bodyLarge)),
          BbIconButton(
            icon: BbIcons.delete,
            tooltip: l10n.scheduleRemove(label),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.event, required this.now});

  final OutageEvent event;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final start = event.startedAt.toLocal();
    final end = event.endedAt?.toLocal();
    final hours = (end ?? now.toLocal()).difference(start).inMinutes / 60;
    final when = l10n.weekdayAt(
      '${start.weekday}',
      end == null
          ? Formatters.localClock(start)
          : '${Formatters.localClock(start)}–${Formatters.localClock(end)}',
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(
            end == null ? BbIcons.gridOff : BbIcons.gridOn,
            size: AppSizes.iconSm,
            color: end == null ? context.energy.offline : context.energy.grid,
          ),
          const BbGap.md(),
          Expanded(child: Text(when, style: context.textTheme.bodyMedium)),
          Text(
            end == null
                ? '${Formatters.duration(l10n, hours)} · ${l10n.outageStillOut}'
                : Formatters.duration(l10n, hours),
            style: context.text.metricSmall.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
