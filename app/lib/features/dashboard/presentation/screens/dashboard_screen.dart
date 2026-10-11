import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/theme_mode/theme_mode_controller.dart';
import '../../../../core/utils/formatters.dart';
import '../../../backup/domain/entities/household_system.dart';
import '../../../backup/domain/system_repository.dart';
import '../../../loads/domain/appliance_repository.dart';

/// Home (DESIGN.md §11 Dashboard): countdown hero with the one yellow CTA,
/// stat tiles, and at least one actionable recommendation (ARCHITECTURE.md
/// §15) built from engine numbers — no AI needed.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plan = ref.watch(loadPlanProvider);
    final system = ref.watch(householdSystemProvider).value;
    final brightness = Theme.of(context).brightness;

    return BbScaffold(
      title: l10n.greeting,
      actions: [
        BbIconButton(
          icon: brightness == Brightness.dark
              ? BbIcons.themeLight
              : BbIcons.themeDark,
          tooltip: l10n.switchTheme,
          onPressed: () =>
              ref.read(themeModeProvider.notifier).toggle(brightness),
        ),
        BbIconButton(
          icon: BbIcons.settings,
          tooltip: l10n.settings,
          onPressed: () => context.push(Routes.settings),
        ),
      ],
      body: plan == null || system == null
          ? const SizedBox.shrink()
          : _DashboardBody(plan: plan, system: system),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.plan, required this.system});

  final LoadPlan plan;
  final HouseholdSystem system;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = plan.current;
    final time = Formatters.duration(l10n, current.hours);
    final load = Formatters.watts(current.loadW);
    final soc = Formatters.percent(system.soc);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      children: [
        if (current.isOverloaded) ...[
          BbBanner(
            tone: BbBannerTone.danger,
            title: l10n.overloadTitle,
            message: l10n.overloadBody(
              load,
              Formatters.watts(system.inverter.ratedW),
            ),
          ),
          const BbGap.lg(),
        ],
        BbCard(
          variant: BbCardVariant.hero,
          child: Column(
            children: [
              BbCountdownRing(
                soc: system.soc,
                timeLabel: time,
                caption: l10n.backupLeftAt(load),
                footnote: l10n.stopsProtectingAt(
                  Formatters.percent(current.minSoc),
                ),
                isOverloaded: current.isOverloaded,
                semanticLabel: l10n.backupSemantics(time, load, soc),
              ),
              const BbGap.lg(),
              BbButton(
                label: l10n.whatToTurnOff,
                icon: BbIcons.loads,
                expand: true,
                onPressed: () => context.go(Routes.loads),
              ),
            ],
          ),
        ),
        const BbGap.lg(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BbStatTile(
                icon: _batteryIcon(system.soc),
                tone: _batteryTone(system.soc),
                label: l10n.statBattery,
                value: Formatters.number(system.soc * 100),
                unit: '%',
              ),
            ),
            const BbGap.md(),
            Expanded(
              child: BbStatTile(
                icon: BbIcons.loads,
                tone: BbTone.load,
                label: l10n.statLoad,
                value: Formatters.number(current.loadW),
                unit: 'W',
              ),
            ),
          ],
        ),
        const BbGap.lg(),
        BbCard(
          variant: BbCardVariant.highlight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                BbIcons.loads,
                size: AppSizes.iconSm,
                color: context.colors.textMuted,
              ),
              const BbGap.md(),
              Expanded(child: Text(_advice(l10n))),
            ],
          ),
        ),
      ],
    );
  }

  String _advice(AppLocalizations l10n) {
    final best = plan.suggestions.firstOrNull;
    if (best == null) return l10n.adviceOnlyEssentials;
    return l10n.adviceTurnOff(
      best.appliance.name,
      Formatters.duration(l10n, best.hoursGained),
    );
  }

  static IconData _batteryIcon(double soc) => soc > 0.75
      ? BbIcons.batteryFull
      : soc > 0.5
      ? BbIcons.batteryHigh
      : soc >= 0.2
      ? BbIcons.batteryMedium
      : BbIcons.batteryLow;

  // Same thresholds as EnergyColors.battery (DESIGN.md §2.5).
  static BbTone _batteryTone(double soc) => soc > 0.5
      ? BbTone.success
      : soc >= 0.2
      ? BbTone.warning
      : BbTone.danger;
}
