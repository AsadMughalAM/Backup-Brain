import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../outages/domain/outage_repository.dart';
import '../controllers/reading_controller.dart';

/// "What % did the battery show when the power came back?" for one outage.
/// A full screen, not a dialog: no OverlayHost yet (TECH_STACK §7.1 rule 8).
class BatteryReadingScreen extends ConsumerStatefulWidget {
  const BatteryReadingScreen({super.key, required this.outageId});

  final String outageId;

  @override
  ConsumerState<BatteryReadingScreen> createState() =>
      _BatteryReadingScreenState();
}

class _BatteryReadingScreenState extends ConsumerState<BatteryReadingScreen> {
  /// Percent, in the 5% steps inverter displays show.
  int? _percent;

  static const _step = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final outage = (ref.watch(recentOutagesProvider).value ?? const [])
        .where((o) => o.id == widget.outageId)
        .firstOrNull;
    if (outage == null || outage.endedAt == null) {
      return BbScaffold(
        title: l10n.readingTitle,
        body: const SizedBox.shrink(),
      );
    }
    // Start from the estimate, so a quick check is one tap.
    final percent =
        _percent ?? ((outage.endSoc ?? 0.5) * 100 / _step).round() * _step;
    final start = outage.startedAt.toLocal();
    final end = outage.endedAt!.toLocal();

    return BbScaffold(
      title: l10n.readingTitle,
      bottomAction: BbButton(
        label: l10n.scheduleSave,
        size: BbButtonSize.lg,
        expand: true,
        onPressed: () {
          ref.read(readingControllerProvider).save(outage.id, percent / 100);
          context.pop();
        },
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          Text(
            l10n.readingQuestion(
              l10n.weekdayAt(
                '${start.weekday}',
                '${Formatters.localClock(start)}–${Formatters.localClock(end)}',
              ),
            ),
            style: context.textTheme.titleMedium,
          ),
          const BbGap.xs(),
          Text(
            l10n.readingHint,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          const BbGap.xl(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BbIconButton(
                icon: BbIcons.remove,
                tooltip: l10n.readingLess,
                variant: BbIconButtonVariant.tonal,
                onPressed: percent <= 0
                    ? null
                    : () => setState(() => _percent = percent - _step),
              ),
              const BbGap.lg(),
              Semantics(
                label: l10n.readingValue('$percent%'),
                liveRegion: true,
                excludeSemantics: true,
                child: Text(
                  '$percent%',
                  style: context.text.metricLarge.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              const BbGap.lg(),
              BbIconButton(
                icon: BbIcons.add,
                tooltip: l10n.readingMore,
                variant: BbIconButtonVariant.tonal,
                onPressed: percent >= 100
                    ? null
                    : () => setState(() => _percent = percent + _step),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
