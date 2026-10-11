import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/overlays/overlay_host.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/outage_outlook.dart';
import '../controllers/reminder_controller.dart';

/// "Light hai / Light gayi" with one tap to log, and — during a cut — when
/// it started with a way to correct it. Used on Home and Outages.
class GridStatus extends ConsumerWidget {
  const GridStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final outlook = ref.watch(outageOutlookProvider);
    final ongoing = outlook?.ongoing;
    final logger = ref.read(outageLoggerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BbGridStatusPill(
          gridOn: ongoing == null,
          label: ongoing == null ? l10n.gridOn : l10n.gridOff,
          duration: ongoing == null
              ? null
              : Formatters.duration(l10n, ongoing.hours),
          actionLabel: ongoing == null ? l10n.logPowerCut : l10n.logPowerBack,
          onTap: outlook == null
              ? null
              : () {
                  logger.toggle();
                  // The first logged cut is when reminders make sense.
                  ref.read(reminderControllerProvider).askPermissionOnce();
                },
        ),
        if (ongoing != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.outageSince(
                  Formatters.localClock(ongoing.event.startedAt.toLocal()),
                ),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              Semantics(
                label: l10n.outageChangeStartLabel,
                excludeSemantics: true,
                button: true,
                child: BbButton.ghost(
                  label: l10n.outageChangeStart,
                  size: BbButtonSize.sm,
                  onPressed: () => _changeStart(context, ref),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _changeStart(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref
        .read(overlayHostProvider)
        .showSheet<void>(
          title: l10n.outageStartTitle,
          builder: (_) => const _StartChoices(),
        );
  }
}

/// "Just now / 15 / 30 min / 1 h ago" — no typing, in the dark — and the
/// undo for a mistaken tap.
class _StartChoices extends ConsumerWidget {
  const _StartChoices();

  static const _minutesAgo = [0, 15, 30, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final logger = ref.read(outageLoggerProvider);
    final overlays = ref.read(overlayHostProvider);
    final now = ref.watch(nowProvider).value ?? DateTime.now().toUtc();

    String label(int minutes) => switch (minutes) {
      0 => l10n.outageStartJustNow,
      60 => l10n.outageStartHourAgo,
      _ => l10n.outageStartMinutesAgo(minutes),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final minutes in _minutesAgo)
              BbChip(
                label: label(minutes),
                selected: false,
                onSelected: () {
                  logger.moveStart(now.subtract(Duration(minutes: minutes)));
                  overlays.close();
                },
              ),
          ],
        ),
        const BbGap.lg(),
        BbButton.ghost(
          label: l10n.outageUndo,
          icon: BbIcons.delete,
          onPressed: () {
            logger.undo();
            overlays.close();
          },
        ),
      ],
    );
  }
}
