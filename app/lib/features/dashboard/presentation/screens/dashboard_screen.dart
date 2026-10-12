import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../app/session/household_setup.dart';
import '../../../../app/theme_mode/theme_mode_controller.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/notification_bell.dart';
import '../../../backup/domain/battery_estimate.dart';
import '../../../backup/domain/entities/household_system.dart';
import '../../../backup/domain/system_repository.dart';
import '../../../loads/domain/load_plan.dart';
import '../../../outages/domain/outage_outlook.dart';
import '../../../outages/presentation/widgets/grid_status.dart';
import '../../../solar/domain/solar_outlook.dart';
import '../controllers/battery_check_controller.dart';
import '../widgets/backup_hero.dart';
import '../widgets/battery_check.dart';

/// Home (DESIGN.md §11 Dashboard): the backup time over the house with the
/// one yellow CTA, two stat tiles, and at least one actionable
/// recommendation (ARCHITECTURE.md §15) built from engine numbers — no AI
/// needed.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plan = ref.watch(loadPlanProvider);
    final charge = ref.watch(batteryEstimateProvider);
    final systemState = ref.watch(householdSystemProvider);
    final system = systemState.value;
    final brightness = Theme.of(context).brightness;
    // Loaded, but this account has no household yet (just signed up).
    final noHousehold = systemState.hasValue && system == null;

    return BbScaffold(
      titleWidget: const BrandLogo(),
      actions: [
        NotificationBell(onPressed: () => context.push(Routes.notifications)),
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
      body: noHousehold
          ? const _SettingUpHome()
          : plan == null || system == null || charge == null
          ? const SizedBox.shrink()
          : _DashboardBody(plan: plan, system: system, charge: charge),
    );
  }
}

/// Shown for the moment between sign-up and the demo household arriving,
/// or if that couldn't happen (offline) — with a way to retry.
class _SettingUpHome extends ConsumerWidget {
  const _SettingUpHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      children: [
        BbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingUpHomeTitle,
                style: context.textTheme.titleMedium,
              ),
              const BbGap.xs(),
              Text(
                l10n.settingUpHomeBody,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              const BbGap.lg(),
              BbButton(
                label: l10n.setUpMyHome,
                expand: true,
                onPressed: () => context.go(Routes.setup),
              ),
              const BbGap.sm(),
              BbButton.ghost(
                label: l10n.useDemoHousehold,
                expand: true,
                onPressed: () =>
                    ref.read(householdSetupProvider.notifier).useDemo(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({
    required this.plan,
    required this.system,
    required this.charge,
  });

  final LoadPlan plan;
  final HouseholdSystem system;
  final BatteryEstimate charge;

  /// An estimated countdown is shown to 10 minutes, never more precise
  /// than the app can know.
  static const _estimateStepMinutes = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = plan.current;
    final outlook = ref.watch(outageOutlookProvider);
    final ongoing = outlook?.ongoing;
    final dismissed = ref.watch(batteryCheckDismissalProvider);
    final now = ref.watch(nowProvider).value ?? DateTime.now().toUtc();
    final time = Formatters.duration(
      l10n,
      current.hours,
      stepMinutes: charge.isEstimate ? _estimateStepMinutes : 1,
    );
    final load = Formatters.watts(current.loadW);
    final soc = Formatters.charge(charge.soc, estimate: charge.isEstimate);
    final askCharge =
        ongoing != null && charge.needsCheck && dismissed != ongoing.event.id;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      children: [
        const GridStatus(),
        const BbGap.lg(),
        if (askCharge) ...[
          BatteryCheckCard(outageId: ongoing.event.id, estimate: charge.soc),
          const BbGap.lg(),
        ],
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
        BackupHero(
          time: time,
          caption: l10n.backupLeftAt(load),
          footnote: l10n.stopsProtectingAt(Formatters.percent(current.minSoc)),
          semanticLabel: l10n.backupSemantics(time, load, soc),
          isOverloaded: current.isOverloaded,
          actionLabel: l10n.whatToTurnOff,
          onAction: () => context.go(Routes.loads),
        ),
        const BbGap.xl(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BbStatTile(
                icon: _batteryIcon(charge.soc),
                tone: _batteryTone(charge.soc),
                label: l10n.statBattery,
                value: Formatters.chargeNumber(
                  charge.soc,
                  estimate: charge.isEstimate,
                ),
                unit: '%',
                delta: _chargeSource(l10n, now),
                onTap: () => showBatteryCheck(ref, l10n, charge.soc),
                tapLabel: l10n.batteryCheckOpen,
              ),
            ),
            const BbGap.md(),
            Expanded(
              child: BbStatTile(
                icon: BbIcons.loads,
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
                BbIcons.ai,
                size: AppSizes.iconSm,
                color: context.colors.onPrimaryContainer,
              ),
              const BbGap.md(),
              Expanded(child: Text(_advice(l10n))),
            ],
          ),
        ),
        _TodayCard(outages: outlook),
      ],
    );
  }

  /// Where the % comes from, with its age: the user's reading, or the
  /// app's estimate since then.
  String _chargeSource(AppLocalizations l10n, DateTime now) {
    final checkedAt = charge.checkedAt;
    if (checkedAt == null) {
      return charge.isEstimate
          ? l10n.chargeEstimateNever
          : l10n.batteryCheckOpen;
    }
    final age = Formatters.age(l10n, now.difference(checkedAt));
    return charge.isEstimate
        ? l10n.chargeEstimateAgo(age)
        : l10n.chargeCheckedAgo(age);
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

/// One card for what's coming today: the outage outlook and the sun, each a
/// row that opens its screen. Hidden when there is neither yet.
class _TodayCard extends ConsumerWidget {
  const _TodayCard({required this.outages});

  final OutageOutlook? outages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outages = this.outages;
    final solar = ref.watch(solarOutlookProvider);
    final sunToday = solar?.today;
    final rows = [
      if (outages != null) _OutageRow(outlook: outages),
      if (solar != null && sunToday != null)
        _SunRow(outlook: solar, today: sunToday),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: BbCard.list(children: rows),
    );
  }
}

/// Today's sun at a glance, with the forecast's age; the details are on
/// the Solar tab.
class _SunRow extends ConsumerWidget {
  const _SunRow({required this.outlook, required this.today});

  final SolarOutlook outlook;
  final SolarDayForecast today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final now = ref.watch(nowProvider).value ?? outlook.fetchedAt;
    return _SummaryRow(
      icon: BbIcons.solar,
      title: l10n.sunTodayLine(
        Formatters.kWhRange(today.lowKWh, today.highKWh),
      ),
      subtitle: l10n.solarUpdated(
        outlook.city,
        Formatters.age(l10n, now.difference(outlook.fetchedAt)),
      ),
      openLabel: l10n.sunTodayOpen,
      onOpen: () => context.go(Routes.solar),
    );
  }
}

/// One glance at F8: the cut in progress, or the next outage and the battery
/// by then. The details live on the Outages screen.
class _OutageRow extends ConsumerWidget {
  const _OutageRow({required this.outlook});

  final OutageOutlook outlook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final now = ref.watch(nowProvider).value ?? DateTime.now().toUtc();
    final ongoing = outlook.ongoing;
    final next = outlook.next;
    final readiness = outlook.readiness;
    final short = readiness?.coversOutage == false;

    final (String title, String? line) = switch ((ongoing, next, readiness)) {
      (final o?, _, _) => (
        l10n.ongoingTitle(Formatters.duration(l10n, o.hours)),
        l10n.ongoingBody(
          Formatters.percent(o.socNow),
          Formatters.duration(l10n, o.backup.hours),
          Formatters.watts(outlook.loadW),
        ),
      ),
      (null, final n?, final r?) => (
        n.source == PredictionSource.schedule
            ? l10n.nextOutageScheduled(
                Formatters.dayTime(l10n, n.start, now.toLocal()),
              )
            : l10n.nextOutageLikely(
                Formatters.dayTime(l10n, n.start, now.toLocal()),
              ),
        l10n.readinessBattery(
          Formatters.percent(r.socAtStart),
          Formatters.duration(l10n, r.backup.hours),
        ),
      ),
      _ => (l10n.noPredictionTitle, null),
    };

    return _SummaryRow(
      icon: ongoing != null
          ? BbIcons.gridOff
          : short
          ? BbIcons.warning
          : BbIcons.schedule,
      tone: short ? BbTone.warning : BbTone.neutral,
      title: title,
      subtitle: line,
      openLabel: l10n.outagesOpen,
      onOpen: () => context.push(Routes.outages),
    );
  }
}

/// A list row (DESIGN.md §10.4 `BbListTile`): icon disc, title, muted
/// line, and a chevron that opens the details.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.openLabel,
    required this.onOpen,
    this.subtitle,
    this.tone = BbTone.neutral,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String openLabel;
  final VoidCallback onOpen;

  /// Colors the icon only; the title says the same in words.
  final BbTone tone;

  static const _discSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.lg,
        end: AppSpacing.xs,
        top: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: _discSize,
            height: _discSize,
            decoration: BoxDecoration(
              color: tone.containerColor(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: AppSizes.iconSm,
              color: tone.iconColor(context),
            ),
          ),
          const BbGap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.titleSmall),
                if (subtitle != null) ...[
                  const BbGap.xxs(),
                  Text(
                    subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          BbIconButton(icon: BbIcons.next, tooltip: openLabel, onPressed: onOpen),
        ],
      ),
    );
  }
}
