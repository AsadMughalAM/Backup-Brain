import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/fire_and_forget.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/solar_log_repository.dart';

/// F4 — "Is my solar system underperforming?" The user types what the
/// inverter says the panels made; the model says what that day's weather
/// should have given.
class SolarCheckScreen extends ConsumerStatefulWidget {
  const SolarCheckScreen({super.key});

  @override
  ConsumerState<SolarCheckScreen> createState() => _SolarCheckScreenState();
}

class _SolarCheckScreenState extends ConsumerState<SolarCheckScreen> {
  final _actual = TextEditingController();

  /// Yesterday by default: today's total isn't known until sunset.
  int _dayOffset = -1;
  bool _triedSave = false;

  /// Days the user can log; older ones have left the weather cache.
  static const _offsets = [0, -1, -2, -3];

  /// The trend shows two weeks.
  static const _trendDays = 14;

  @override
  void dispose() {
    _actual.dispose();
    super.dispose();
  }

  void _save(DayExpectation expected) {
    final actual = double.tryParse(_actual.text.replaceAll(',', '').trim());
    if (actual == null || actual < 0) {
      setState(() => _triedSave = true);
      return;
    }
    fireAndForget(
      ref
          .read(solarLogRepositoryProvider)
          .save(
            SolarLog(
              day: expected.day,
              actualKWh: actual,
              expectedKWh: expected.expectedKWh,
              clearShare: expected.clearShare,
            ),
          ),
      'solar log',
    );
    _actual.clear();
    setState(() => _triedSave = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(solarPerformanceProvider);
    final logs = ref.watch(solarLogsProvider).value ?? const [];
    final expected = ref.watch(dayExpectationProvider(_dayOffset));
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: context.colors.textMuted,
    );

    return BbScaffold(
      title: l10n.checkTitle,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          _StatusCard(status),
          const BbGap.xl(),
          Text(l10n.checkEnterTitle, style: context.textTheme.titleMedium),
          const BbGap.md(),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final offset in _offsets)
                if (ref.watch(dayExpectationProvider(offset)) != null)
                  BbChip(
                    label: switch (offset) {
                      0 => l10n.checkToday,
                      -1 => l10n.checkYesterday,
                      _ => l10n.checkDaysAgo('${-offset}'),
                    },
                    selected: offset == _dayOffset,
                    onSelected: () => setState(() => _dayOffset = offset),
                  ),
            ],
          ),
          const BbGap.md(),
          if (expected == null)
            Text(l10n.checkNoWeather, style: muted)
          else ...[
            Text(
              l10n.checkExpected(expected.expectedKWh.toStringAsFixed(1)),
              style: context.textTheme.bodyMedium,
            ),
            if (_dayOffset == 0) Text(l10n.checkTodayHint, style: muted),
            const BbGap.md(),
            BbTextField(
              label: l10n.checkActualLabel,
              controller: _actual,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              errorText: _triedSave ? l10n.checkActualError : null,
            ),
            const BbGap.md(),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: BbButton.secondary(
                label: l10n.scheduleSave,
                onPressed: () => _save(expected),
              ),
            ),
          ],
          if (logs.isNotEmpty) ...[
            const BbGap.xl(),
            Text(l10n.checkTrendTitle, style: context.textTheme.titleMedium),
            const BbGap.md(),
            BbCard(
              child: BbSolarForecastStrip(
                bars: [
                  for (final log in logs.take(_trendDays).toList().reversed)
                    BbSolarBar(
                      value: log.actualKWh,
                      potential: log.expectedKWh,
                      label: '${log.day.day}',
                    ),
                ],
                forecastLabel: l10n.checkMade,
                potentialLabel: l10n.checkShouldMake,
                semanticLabel: l10n.checkTrendSemantics('${logs.length}'),
              ),
            ),
            const BbGap.md(),
            for (final log in logs.take(_trendDays)) _LogRow(log),
          ],
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard(this.status);

  final PerformanceStatus? status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final (icon, color, title, body) = switch (status) {
      null => (
        BbIcons.solarPanel,
        c.textPrimary,
        l10n.checkNoneTitle,
        l10n.checkNoneBody,
      ),
      PerformanceStatus.healthy => (
        BbIcons.success,
        c.success,
        l10n.checkHealthyTitle,
        l10n.checkHealthyBody,
      ),
      PerformanceStatus.slightlyLow => (
        BbIcons.warning,
        c.warning,
        l10n.checkSlightTitle,
        l10n.checkSlightBody,
      ),
      PerformanceStatus.significantlyLow => (
        BbIcons.danger,
        c.danger,
        l10n.checkLowTitle,
        l10n.checkLowBody,
      ),
    };
    return BbCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSizes.iconMd, color: color),
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

class _LogRow extends StatelessWidget {
  const _LogRow(this.log);

  final SolarLog log;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = log.performance;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.checkLogRow(
                l10n.weekdayShort('${log.day.weekday}'),
                '${log.day.day}',
                log.actualKWh.toStringAsFixed(1),
                log.expectedKWh.toStringAsFixed(1),
              ),
              style: context.textTheme.bodyMedium,
            ),
          ),
          Text(
            Formatters.percent(p.index),
            style: context.text.metricSmall.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
