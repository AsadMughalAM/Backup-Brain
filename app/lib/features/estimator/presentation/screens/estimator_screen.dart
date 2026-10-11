import 'dart:math' as math;

import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../controllers/estimator_controller.dart';

/// F5 — "Agar mein solar lagwana chahun to kitna kharcha aayega?" One live
/// form: the three packages update as the answers change (DESIGN §11
/// Estimator).
class EstimatorScreen extends ConsumerStatefulWidget {
  const EstimatorScreen({super.key});

  @override
  ConsumerState<EstimatorScreen> createState() => _EstimatorScreenState();
}

class _EstimatorScreenState extends ConsumerState<EstimatorScreen> {
  late final _amount = TextEditingController(
    text: _initial(ref.read(estimatorControllerProvider).amount),
  );
  late final _nightLoad = TextEditingController(
    text: _initial(ref.read(estimatorControllerProvider).nightLoadW),
  );

  static String _initial(double? v) => v == null ? '' : '${v.round()}';

  @override
  void initState() {
    super.initState();
    final form = ref.read(estimatorControllerProvider.notifier);
    _amount.addListener(() => form.setAmount(_parse(_amount.text)));
    _nightLoad.addListener(() => form.setNightLoad(_parse(_nightLoad.text)));
  }

  static double? _parse(String text) =>
      double.tryParse(text.replaceAll(',', '').trim());

  @override
  void dispose() {
    _amount.dispose();
    _nightLoad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final form = ref.watch(estimatorControllerProvider);
    final controller = ref.read(estimatorControllerProvider.notifier);
    final result = ref.watch(estimatorResultProvider);
    final presets = ref.watch(estimatorCitiesProvider);
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: context.colors.textMuted,
    );

    return BbScaffold(
      title: l10n.estimatorTitle,
      body: result == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              children: [
                Text(l10n.estimatorIntro, style: muted),
                const BbGap.xl(),
                _Heading(l10n.estimatorUsage),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    BbChip(
                      label: l10n.estimatorUnits,
                      selected: form.unit == UsageUnit.units,
                      onSelected: () => controller.setUnit(UsageUnit.units),
                    ),
                    BbChip(
                      label: l10n.estimatorBill,
                      selected: form.unit == UsageUnit.bill,
                      onSelected: () => controller.setUnit(UsageUnit.bill),
                    ),
                  ],
                ),
                const BbGap.md(),
                BbTextField(
                  label: form.unit == UsageUnit.units
                      ? l10n.estimatorUnitsLabel
                      : l10n.estimatorBillLabel,
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  helper: form.unit == UsageUnit.bill
                      ? l10n.estimatorTariffNote(
                          Formatters.number(result.sheet.pricing.tariffPerUnit),
                        )
                      : null,
                ),
                const BbGap.xl(),
                _Heading(l10n.estimatorCity),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final city in presets)
                      BbChip(
                        label: city.name,
                        selected: city.id == result.city.id,
                        onSelected: () => controller.setCity(city.id),
                      ),
                  ],
                ),
                const BbGap.xl(),
                _Heading(l10n.estimatorGoal),
                for (final (goal, icon, title, hint) in [
                  (
                    SolarGoal.reduceBill,
                    BbIcons.money,
                    l10n.goalBill,
                    l10n.goalBillHint,
                  ),
                  (
                    SolarGoal.both,
                    BbIcons.solarPanel,
                    l10n.goalBoth,
                    l10n.goalBothHint,
                  ),
                  (
                    SolarGoal.backup,
                    BbIcons.batteryFull,
                    l10n.goalBackup,
                    l10n.goalBackupHint,
                  ),
                ]) ...[
                  BbChoiceCard(
                    icon: icon,
                    title: title,
                    subtitle: hint,
                    selected: form.goal == goal,
                    onSelected: () => controller.setGoal(goal),
                  ),
                  const BbGap.sm(),
                ],
                const BbGap.lg(),
                BbQuantityStepper(
                  label: l10n.estimatorBackupHours,
                  value: form.backupHours,
                  min: 1,
                  max: 12,
                  decreaseLabel: l10n.estimatorHoursLess,
                  increaseLabel: l10n.estimatorHoursMore,
                  onChanged: controller.setBackupHours,
                ),
                const BbGap.lg(),
                BbTextField(
                  label: l10n.estimatorNightLoad,
                  controller: _nightLoad,
                  keyboardType: TextInputType.number,
                  hint: Formatters.number(result.nightLoadW),
                  helper: l10n.estimatorNightLoadHint,
                ),
                const BbGap.xl(),
                if (result.packages case final packages?) ...[
                  for (final p in packages) ...[
                    _PackageCard(
                      package: p,
                      backupHours: switch (p.kind) {
                        PackageKind.basic => 0,
                        PackageKind.hybrid => form.backupHours.toDouble(),
                        PackageKind.fullBackup => math.max(
                          form.backupHours.toDouble(),
                          EngineDefaults.fullBackupHours,
                        ),
                      },
                      nightLoadW: result.nightLoadW,
                    ),
                    const BbGap.md(),
                  ],
                  const BbGap.md(),
                  const _InstallerChecklist(),
                ] else
                  BbEmptyState(
                    icon: BbIcons.estimator,
                    title: l10n.estimatorEmptyTitle,
                    message: l10n.estimatorEnterUsage,
                  ),
                const BbGap.lg(),
                Text(
                  [
                    l10n.estimatorDisclaimer(result.sheet.lastUpdated),
                    if (!result.sheet.verified) l10n.estimatorPricesUnverified,
                  ].join(' '),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
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
    child: Text(text, style: context.textTheme.titleMedium),
  );
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.backupHours,
    required this.nightLoadW,
  });

  final SolarPackage package;
  final double backupHours;
  final double nightLoadW;

  /// Quotes vary by thousands; finer digits would claim false precision.
  static String _rupees(double v) =>
      Formatters.number(((v / 1000).round() * 1000).toDouble());

  static String _years(double v) => v.isInfinite ? '–' : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = package;
    final (title, subtitle) = switch (p.kind) {
      PackageKind.basic => (l10n.packageBasic, l10n.packageBasicSub),
      PackageKind.hybrid => (l10n.packageHybrid, l10n.packageHybridSub),
      PackageKind.fullBackup => (l10n.packageFull, l10n.packageFullSub),
    };
    final inverter = p.inverterCount > 1
        ? '${p.inverterCount} × ${Formatters.number(p.inverterKw)} kW'
        : '${Formatters.number(p.inverterKw)} kW';
    final muted = context.textTheme.bodySmall?.copyWith(
      color: p.recommended ? null : context.colors.textMuted,
    );

    return BbCard(
      variant: p.recommended ? BbCardVariant.highlight : BbCardVariant.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: context.textTheme.titleMedium),
              ),
              if (p.recommended) _RecommendedBadge(l10n.packageRecommended),
            ],
          ),
          Text(subtitle, style: muted),
          const BbGap.md(),
          Text(
            l10n.packageCost(_rupees(p.cost.min), _rupees(p.cost.max)),
            style: context.text.metricMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const BbGap.md(),
          for (final line in [
            l10n.packagePanels(
              '${p.panelCount}',
              Formatters.number(p.panelW),
              Formatters.kiloWatts(p.kWp),
            ),
            p.hasBattery
                ? l10n.packageInverterHybrid(inverter)
                : l10n.packageInverterOngrid(inverter),
            p.hasBattery
                ? l10n.packageBattery(
                    p.batteryKWh.toStringAsFixed(1),
                    Formatters.duration(l10n, backupHours),
                    Formatters.watts(nightLoadW),
                  )
                : l10n.packageNoBattery,
            l10n.packageProduction(Formatters.number(p.monthlyKWh)),
            l10n.packageSavings(_rupees(p.monthlySavings)),
            l10n.packagePayback(
              _years(p.paybackYears.min),
              _years(p.paybackYears.max),
            ),
          ]) ...[
            Text(line, style: context.textTheme.bodyMedium),
            const BbGap.xs(),
          ],
        ],
      ),
    );
  }
}

class _RecommendedBadge extends StatelessWidget {
  const _RecommendedBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(BbIcons.check, size: AppSizes.iconXs, color: c.textOnPrimary),
          const BbGap.xs(),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: c.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstallerChecklist extends StatelessWidget {
  const _InstallerChecklist();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.installerTitle, style: context.textTheme.titleMedium),
          const BbGap.md(),
          for (final q in [
            l10n.installerQ1,
            l10n.installerQ2,
            l10n.installerQ3,
            l10n.installerQ4,
            l10n.installerQ5,
          ]) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  BbIcons.check,
                  size: AppSizes.iconSm,
                  color: context.colors.textPrimary,
                ),
                const BbGap.sm(),
                Expanded(child: Text(q, style: context.textTheme.bodyMedium)),
              ],
            ),
            const BbGap.sm(),
          ],
        ],
      ),
    );
  }
}
