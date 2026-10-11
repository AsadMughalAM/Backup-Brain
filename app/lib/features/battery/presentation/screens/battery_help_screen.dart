import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/services/external_links.dart';
import '../../../../core/utils/fire_and_forget.dart';
import '../../../../core/utils/formatters.dart';
import '../../../backup/domain/system_repository.dart';
import '../../domain/battery_catalog_repository.dart';
import '../../domain/battery_health.dart';

/// F7 — "Meri battery kharab ho gayi: kaunsi nayi lun, ya repair ho sakti
/// hai?" Diagnose first, then compare what to buy, then find a shop.
class BatteryHelpScreen extends ConsumerStatefulWidget {
  const BatteryHelpScreen({super.key});

  @override
  ConsumerState<BatteryHelpScreen> createState() => _BatteryHelpScreenState();
}

class _BatteryHelpScreenState extends ConsumerState<BatteryHelpScreen> {
  final _symptoms = <BatterySymptom>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final system = ref.watch(householdSystemProvider).value;
    final catalog = ref.watch(batteryCatalogProvider).value;
    if (system == null) {
      return BbScaffold(title: l10n.helpTitle, body: const SizedBox.shrink());
    }
    final chemistry = system.battery.chemistry;
    final verdict = const BatteryDiagnosis().diagnose(
      _symptoms,
      chemistry,
      healthFactor: ref.watch(batteryHealthProvider)?.healthFactor,
    );
    final city = system.location?.city;
    void search(String what) => fireAndForget(
      ref
          .read(externalLinksProvider)
          .openMapsSearch(city == null ? what : '$what $city'),
      'maps search',
    );

    return BbScaffold(
      title: l10n.helpTitle,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          Text(l10n.helpSymptoms, style: context.textTheme.titleMedium),
          const BbGap.md(),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (symptom, label) in [
                (BatterySymptom.shortBackup, l10n.symptomShortBackup),
                (BatterySymptom.wontCharge, l10n.symptomWontCharge),
                if (chemistry == BatteryChemistry.tubular)
                  (BatterySymptom.lowWater, l10n.symptomLowWater),
                (BatterySymptom.swollen, l10n.symptomSwollen),
                (BatterySymptom.smellOrHeat, l10n.symptomSmellOrHeat),
              ])
                BbChip(
                  label: label,
                  selected: _symptoms.contains(symptom),
                  onSelected: () => setState(
                    () => _symptoms.contains(symptom)
                        ? _symptoms.remove(symptom)
                        : _symptoms.add(symptom),
                  ),
                ),
            ],
          ),
          const BbGap.lg(),
          _VerdictCard(verdict),
          if (catalog != null) ...[
            const BbGap.xl(),
            Text(l10n.buyTitle, style: context.textTheme.titleMedium),
            const BbGap.xs(),
            Text(
              l10n.buyIntro(
                (system.battery.nominalWh / 1000).toStringAsFixed(1),
              ),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.textMuted,
              ),
            ),
            const BbGap.md(),
            for (final (i, ranked)
                in const BatteryRanking()
                    .rank(catalog.options, system.battery.nominalWh)
                    .indexed) ...[
              _OptionCard(ranked, bestValue: i == 0),
              const BbGap.md(),
            ],
            Text(
              [
                l10n.buyDisclaimer(catalog.lastUpdated),
                if (!catalog.verified) l10n.estimatorPricesUnverified,
              ].join(' '),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ],
          const BbGap.xl(),
          Text(l10n.nearbyTitle, style: context.textTheme.titleMedium),
          const BbGap.xs(),
          Text(
            city == null ? l10n.nearbyBodyNoCity : l10n.nearbyBody(city),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          const BbGap.md(),
          for (final (label, query) in [
            (l10n.nearbyBatteryShops, l10n.queryBatteryShop),
            (l10n.nearbyUpsRepair, l10n.queryUpsRepair),
            (l10n.nearbySolarInstallers, l10n.querySolarInstaller),
          ]) ...[
            BbButton.secondary(
              label: label,
              icon: BbIcons.location,
              expand: true,
              onPressed: () => search(query),
            ),
            const BbGap.sm(),
          ],
        ],
      ),
    );
  }
}

class _VerdictCard extends StatelessWidget {
  const _VerdictCard(this.verdict);

  final BatteryVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Golden rule 8: swelling, smell or heat get the fixed text only.
    if (verdict == BatteryVerdict.unsafe) {
      return BbBanner(
        tone: BbBannerTone.danger,
        title: l10n.assistantSafetyTitle,
        message: l10n.assistantSafetyBody,
      );
    }
    final (icon, title, body) = switch (verdict) {
      BatteryVerdict.tryMaintenance => (
        BbIcons.repair,
        l10n.verdictMaintenanceTitle,
        l10n.verdictMaintenanceBody,
      ),
      BatteryVerdict.repairPossible => (
        BbIcons.repair,
        l10n.verdictRepairTitle,
        l10n.verdictRepairBody,
      ),
      BatteryVerdict.replace => (
        BbIcons.batteryWarning,
        l10n.verdictReplaceTitle,
        l10n.verdictReplaceBody,
      ),
      _ => (BbIcons.info, l10n.verdictNoneTitle, l10n.verdictNoneBody),
    };
    return BbCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSizes.iconMd, color: context.colors.textPrimary),
          const BbGap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.titleMedium),
                const BbGap.xs(),
                Text(body, style: context.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard(this.ranked, {required this.bestValue});

  final RankedOption ranked;
  final bool bestValue;

  static String _rupees(double v) =>
      Formatters.number(((v / 1000).round() * 1000).toDouble());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = ranked.option;
    final name = switch (o.chemistry) {
      BatteryChemistry.leadAcid => l10n.chemLeadAcid,
      BatteryChemistry.tubular => l10n.chemTubular,
      BatteryChemistry.lifepo4 => l10n.chemLithium,
    };
    return BbCard(
      variant: bestValue ? BbCardVariant.highlight : BbCardVariant.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: context.textTheme.titleMedium),
          if (bestValue) ...[
            const BbGap.xs(),
            Row(
              children: [
                Icon(
                  BbIcons.check,
                  size: AppSizes.iconXs,
                  color: context.colors.textPrimary,
                ),
                const BbGap.xs(),
                Flexible(
                  child: Text(
                    l10n.buyBestValue,
                    style: context.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ],
          const BbGap.sm(),
          Text(
            l10n.packageCost(
              _rupees(ranked.price.min),
              _rupees(ranked.price.max),
            ),
            style: context.text.metricMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const BbGap.xs(),
          Text(
            l10n.buyLife(
              ranked.lifeYears.toStringAsFixed(1),
              Formatters.number(o.cycleLife.toDouble()),
              '${o.warrantyMonths}',
            ),
            style: context.textTheme.bodyMedium,
          ),
          Text(
            l10n.buyPerKWhYear(
              Formatters.number(
                ((ranked.costPerUsableKWhYear / 100).round() * 100).toDouble(),
              ),
            ),
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
