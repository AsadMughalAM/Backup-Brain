import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/overlays/overlay_host.dart';
import '../../../../core/utils/formatters.dart';
import '../../../backup/domain/charge_recorder.dart';
import '../../../setup/domain/setup_presets_repository.dart';
import '../controllers/battery_check_controller.dart';

/// "What does your UPS screen show?" as one tap: the setup answers
/// (100 / 75 / 50 / 25%), each with a battery-bars glyph like the display.
/// The choice closest to the app's estimate is pre-selected.
class BatteryChoices extends ConsumerWidget {
  const BatteryChoices({
    super.key,
    required this.estimate,
    required this.onPicked,
  });

  final double estimate;
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choices = ref.watch(setupPresetsProvider).value?.socChoices;
    if (choices == null) return const SizedBox.shrink();
    final closest = choices.reduce(
      (a, b) => (a - estimate).abs() <= (b - estimate).abs() ? a : b,
    );
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final soc in choices)
          BbChip(
            label: Formatters.percent(soc),
            icon: _bars(soc),
            selected: soc == closest,
            onSelected: () {
              ref.read(chargeRecorderProvider).confirm(soc);
              onPicked();
            },
          ),
      ],
    );
  }

  static IconData _bars(double soc) => soc >= 1
      ? BbIcons.batteryFull
      : soc >= 0.75
      ? BbIcons.batteryHigh
      : soc >= 0.5
      ? BbIcons.batteryMedium
      : BbIcons.batteryLow;
}

/// Asked once at the start of a power cut when the user's last reading is
/// old: the moment the number matters. "Not now" puts it off for this cut.
class BatteryCheckCard extends ConsumerWidget {
  const BatteryCheckCard({
    super.key,
    required this.outageId,
    required this.estimate,
  });

  final String outageId;
  final double estimate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return BbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.batteryCheckTitle, style: context.textTheme.titleMedium),
          const BbGap.xs(),
          Text(
            l10n.batteryCheckHint,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          const BbGap.md(),
          BatteryChoices(estimate: estimate, onPicked: () {}),
          const BbGap.sm(),
          BbButton.ghost(
            label: l10n.notNow,
            onPressed: () => ref
                .read(batteryCheckDismissalProvider.notifier)
                .dismiss(outageId),
          ),
        ],
      ),
    );
  }
}

/// The same question on demand, from the Battery tile.
void showBatteryCheck(WidgetRef ref, AppLocalizations l10n, double estimate) {
  final overlays = ref.read(overlayHostProvider);
  overlays.showSheet<void>(
    title: l10n.batteryCheckTitle,
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.batteryCheckHint,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.textMuted,
          ),
        ),
        const BbGap.md(),
        BatteryChoices(estimate: estimate, onPicked: overlays.close),
      ],
    ),
  );
}
