import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../backup/domain/system_repository.dart';
import '../../../outages/domain/outage_repository.dart';
import '../../domain/battery_health.dart';

/// F6 — "Is my battery becoming unhealthy?" The verdict first, then what
/// to do, then the readings it needs.
class BatteryScreen extends ConsumerWidget {
  const BatteryScreen({
    super.key,
    required this.readingLocation,
    this.shopsLocation,
  });

  /// Where "Enter %" for one outage goes; passed in so this feature doesn't
  /// import the app router.
  final String Function(String outageId) readingLocation;

  /// F7 battery shops and repair; null hides the button.
  final String? shopsLocation;

  /// Asking about older outages gets guesses, not readings.
  static const _askAbout = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final system = ref.watch(householdSystemProvider).value;
    final health = ref.watch(batteryHealthProvider);
    final readings = ref.watch(healthReadingsProvider);
    final awaiting = ref.watch(outagesAwaitingReadingProvider);
    final shops = shopsLocation;

    return BbScaffold(
      title: l10n.tabBattery,
      body: system == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              children: [
                health == null
                    ? _NoVerdict(readings: readings)
                    : _Verdict(health: health),
                if (health != null)
                  for (final w in health.warnings) ...[
                    const BbGap.md(),
                    BbBanner(
                      tone: BbBannerTone.warning,
                      title: switch (w) {
                        HealthWarning.capacityLoss => l10n.healthLossTitle,
                        HealthWarning.deepDischarge => l10n.healthDeepTitle,
                      },
                      message: switch (w) {
                        HealthWarning.capacityLoss => l10n.healthLossBody(
                          Formatters.percent(health.capacityLoss),
                        ),
                        HealthWarning.deepDischarge => l10n.healthDeepBody(
                          Formatters.percent(system.battery.cutoffSoc),
                        ),
                      },
                    ),
                  ],
                if (awaiting.isNotEmpty) ...[
                  const BbGap.xl(),
                  Text(
                    l10n.readingsTitle,
                    style: context.textTheme.titleMedium,
                  ),
                  const BbGap.xs(),
                  Text(
                    l10n.readingsBody,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                  const BbGap.md(),
                  BbCard.list(
                    children: [
                      for (final o in awaiting.take(_askAbout))
                        _AwaitingRow(
                          outage: o,
                          onEnter: () => context.push(readingLocation(o.id)),
                        ),
                    ],
                  ),
                ],
                const BbGap.xl(),
                _Details(system.battery),
                const BbGap.lg(),
                // Golden rule 8: fixed safety text, never generated.
                BbBanner(
                  tone: BbBannerTone.danger,
                  title: l10n.assistantSafetyTitle,
                  message: l10n.assistantSafetyBody,
                ),
                if (shops != null) ...[
                  const BbGap.lg(),
                  BbButton.secondary(
                    label: l10n.batteryKharab,
                    icon: BbIcons.repair,
                    expand: true,
                    onPressed: () => context.push(shops),
                  ),
                ],
              ],
            ),
    );
  }
}

class _Verdict extends StatelessWidget {
  const _Verdict({required this.health});

  final BatteryHealth health;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final h = health.healthFactor;
    final (tone, icon, label) = h >= 0.8
        ? (BbTone.success, BbIcons.batteryFull, l10n.healthGood)
        : h >= 0.6
        ? (BbTone.warning, BbIcons.batteryMedium, l10n.healthWearing)
        : (BbTone.danger, BbIcons.batteryLow, l10n.healthWeak);
    return BbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BbStatTile(
            icon: icon,
            tone: tone,
            label: l10n.healthLabel,
            value: Formatters.number(h * 100),
            unit: '%',
          ),
          const BbGap.md(),
          Text(label, style: context.textTheme.titleMedium),
          const BbGap.xs(),
          Text(
            l10n.healthHolds(
              (health.capacityWh / 1000).toStringAsFixed(1),
              (health.nominalWh / 1000).toStringAsFixed(1),
            ),
            style: context.textTheme.bodyMedium,
          ),
          const BbGap.xs(),
          Text(
            l10n.healthBasis('${health.sessionsUsed}'),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoVerdict extends StatelessWidget {
  const _NoVerdict({required this.readings});

  final int readings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BbCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            BbIcons.batteryHigh,
            size: AppSizes.iconMd,
            color: context.colors.textPrimary,
          ),
          const BbGap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.healthNoneTitle,
                  style: context.textTheme.titleMedium,
                ),
                const BbGap.xs(),
                Text(l10n.healthNoneBody, style: context.textTheme.bodyMedium),
                const BbGap.xs(),
                Text(
                  l10n.healthProgress(
                    '$readings',
                    '${EngineDefaults.healthMinSessions}',
                  ),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AwaitingRow extends StatelessWidget {
  const _AwaitingRow({required this.outage, required this.onEnter});

  final OutageEvent outage;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final start = outage.startedAt.toLocal();
    final end = outage.endedAt!.toLocal();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.weekdayAt(
                '${start.weekday}',
                '${Formatters.localClock(start)}–${Formatters.localClock(end)}',
              ),
              style: context.textTheme.bodyMedium,
            ),
          ),
          BbButton.secondary(
            label: l10n.readingsEnter,
            size: BbButtonSize.sm,
            onPressed: onEnter,
          ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details(this.battery);

  final BatterySpec battery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chemistry = switch (battery.chemistry) {
      BatteryChemistry.leadAcid => l10n.chemLeadAcid,
      BatteryChemistry.tubular => l10n.chemTubular,
      BatteryChemistry.lifepo4 => l10n.chemLithium,
    };
    return BbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.batteryDetails, style: context.textTheme.titleMedium),
          const BbGap.sm(),
          Text(chemistry, style: context.textTheme.bodyMedium),
          Text(
            l10n.batterySize(
              Formatters.volts(battery.voltage),
              Formatters.ampHours(battery.ampHours),
              '${battery.count}',
              (battery.nominalWh / 1000).toStringAsFixed(1),
            ),
            style: context.textTheme.bodyMedium,
          ),
          Text(
            l10n.batteryCutoff(Formatters.percent(battery.cutoffSoc)),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
