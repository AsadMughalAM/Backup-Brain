import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../backup/domain/system_repository.dart';
import '../../domain/weather_repository.dart';
import '../controllers/forecast_refresh_controller.dart';
import '../../domain/solar_outlook.dart';
import '../widgets/solar_day_hero.dart';
import '../widgets/sun_forecast_card.dart';

/// F3 — "Will solar charge my battery?" answered with zero taps: the
/// verdict, the sun behind it, and one thing to do (DESIGN.md §11 Solar).
/// Tomorrow is one tap away and is picked automatically after sunset.
class SolarScreen extends ConsumerStatefulWidget {
  const SolarScreen({super.key, this.editHomeLocation});

  /// Where "Add my panels" goes; passed in so this feature doesn't import
  /// the app router. Null hides the button.
  final String? editHomeLocation;

  @override
  ConsumerState<SolarScreen> createState() => _SolarScreenState();
}

class _SolarScreenState extends ConsumerState<SolarScreen> {
  /// Null until the user picks a day; until then the screen picks for them.
  bool? _pickedToday;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(forecastRefreshProvider.notifier).refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final system = ref.watch(householdSystemProvider).value;
    final outlook = ref.watch(solarOutlookProvider);
    final refresh = ref.watch(forecastRefreshProvider);
    final fetching = refresh == ForecastRefresh.fetching;
    void forceRefresh() =>
        ref.read(forecastRefreshProvider.notifier).refresh(force: true);

    final Widget body;
    if (system == null) {
      body = const SizedBox.shrink();
    } else if (!system.hasSolar || system.location == null) {
      body = Center(
        child: BbEmptyState(
          icon: BbIcons.solarPanel,
          title: l10n.solarNoPanelsTitle,
          message: l10n.solarNoPanelsBody,
          action: switch (widget.editHomeLocation) {
            final location? => BbButton.secondary(
              label: l10n.solarAddPanels,
              icon: BbIcons.solarPanel,
              onPressed: () => context.push(location),
            ),
            null => null,
          },
        ),
      );
    } else if (outlook == null ||
        (outlook.today == null && outlook.tomorrow == null)) {
      // Still reading the offline cache: show nothing rather than flash
      // the "needs internet" state.
      body = ref.watch(latestForecastProvider).isLoading
          ? const SizedBox.shrink()
          : Center(
              child: BbEmptyState(
                icon: BbIcons.offline,
                title: l10n.solarNeedsInternetTitle,
                message: l10n.solarNeedsInternetBody,
                action: BbButton.secondary(
                  label: l10n.tryAgain,
                  loading: fetching,
                  loadingLabel: l10n.solarFetching,
                  onPressed: forceRefresh,
                ),
              ),
            );
    } else {
      body = _OutlookBody(
        outlook: outlook,
        showToday: _showToday(outlook),
        onPickDay: (today) => setState(() => _pickedToday = today),
        refresh: refresh,
        onRetry: forceRefresh,
      );
    }

    return BbScaffold(
      title: l10n.tabSolar,
      actions: [
        if (system?.location != null)
          BbIconButton(
            icon: BbIcons.refresh,
            tooltip: l10n.refreshForecast,
            onPressed: fetching ? null : forceRefresh,
          ),
      ],
      body: body,
    );
  }

  bool _showToday(SolarOutlook outlook) {
    final today = outlook.today, tomorrow = outlook.tomorrow;
    if (today == null) return false;
    if (tomorrow == null) return true;
    // After sunset, "today" has nothing left to tell.
    return _pickedToday ?? !today.sunIsOver;
  }
}

class _OutlookBody extends ConsumerWidget {
  const _OutlookBody({
    required this.outlook,
    required this.showToday,
    required this.onPickDay,
    required this.refresh,
    required this.onRetry,
  });

  final SolarOutlook outlook;
  final bool showToday;
  final ValueChanged<bool> onPickDay;
  final ForecastRefresh refresh;
  final VoidCallback onRetry;

  /// Below this share of a clear day's sun, and with the battery not
  /// filling, the advice switches from "use the sun" to "save the battery".
  static const _weakSunShare = 0.30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final day = (showToday ? outlook.today : outlook.tomorrow)!;
    final advice = _advice(l10n, day);
    final now = ref.watch(nowProvider).value ?? outlook.fetchedAt;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            BbChip(
              label: l10n.solarToday,
              selected: showToday,
              onSelected: outlook.today == null ? null : () => onPickDay(true),
            ),
            BbChip(
              label: l10n.solarTomorrow,
              selected: !showToday,
              onSelected: outlook.tomorrow == null
                  ? null
                  : () => onPickDay(false),
            ),
          ],
        ),
        const BbGap.md(),
        SolarDayHero(
          day: day,
          isToday: showToday,
          utcOffset: outlook.utcOffset,
          loadW: outlook.loadW,
        ),
        if (advice != null) ...[
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
                Expanded(child: Text(advice)),
              ],
            ),
          ),
        ],
        const BbGap.lg(),
        SunForecastCard(
          day: day,
          isToday: showToday,
          utcOffset: outlook.utcOffset,
        ),
        const BbGap.lg(),
        _Freshness(
          label: l10n.solarUpdated(
            outlook.city,
            Formatters.age(l10n, now.difference(outlook.fetchedAt)),
          ),
          refresh: refresh,
          onRetry: onRetry,
        ),
      ],
    );
  }

  String? _advice(AppLocalizations l10n, SolarDayForecast day) {
    if (day.sunIsOver) return null;
    if (day.socAtSunset < 1 && day.belowClearSky >= _weakSunShare) {
      return l10n.solarAdviceWeak(
        Formatters.percent(day.socAtSunset),
        Formatters.clock(day.sunset, outlook.utcOffset),
      );
    }
    final peak = day.peakWindow;
    if (peak == null) return null;
    return l10n.solarAdvicePeak(
      Formatters.clock(peak.start, outlook.utcOffset),
      Formatters.clock(peak.end, outlook.utcOffset),
    );
  }
}

/// "Lahore · updated 20 min ago", a small spinner while refreshing, and a
/// friendly retry when the update failed (DESIGN.md §8.5–8.6).
class _Freshness extends StatelessWidget {
  const _Freshness({
    required this.label,
    required this.refresh,
    required this.onRetry,
  });

  final String label;
  final ForecastRefresh refresh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = context.colors.textMuted;
    final caption = context.text.metricCaption.copyWith(color: muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(BbIcons.countdown, size: AppSizes.iconXs, color: muted),
            const BbGap.xs(),
            Flexible(child: Text(label, style: caption)),
            if (refresh == ForecastRefresh.fetching) ...[
              const BbGap.sm(),
              IconTheme.merge(
                data: IconThemeData(color: muted),
                child: const BbSpinner(size: BbSpinnerSize.xs),
              ),
            ],
          ],
        ),
        if (refresh == ForecastRefresh.failed) ...[
          const BbGap.xs(),
          Text(
            l10n.solarUpdateFailed,
            style: context.textTheme.bodySmall?.copyWith(color: muted),
          ),
          BbButton.ghost(label: l10n.tryAgain, onPressed: onRetry),
        ],
      ],
    );
  }
}
