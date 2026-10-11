import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';

/// How much sun the day brings: the kWh range, how far below a clear day it
/// is, and the hourly bars against the clear-day bars.
class SunForecastCard extends StatelessWidget {
  const SunForecastCard({
    super.key,
    required this.day,
    required this.isToday,
    required this.utcOffset,
  });

  final SolarDayForecast day;
  final bool isToday;
  final Duration utcOffset;

  /// Under 10% less than a clear day reads as "about as sunny".
  static const _nearClearShare = 0.10;

  /// Label every third hour so the axis stays readable on small phones.
  static const _labelEveryHours = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = context.colors.textMuted;
    final range = Formatters.kWhRange(day.lowKWh, day.highKWh);
    final nearClear = day.belowClearSky < _nearClearShare;

    return BbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isToday ? l10n.solarSunToday : l10n.solarSunTomorrow,
            style: context.textTheme.labelMedium?.copyWith(color: muted),
          ),
          const BbGap.xxs(),
          BbMetric(value: range, unit: l10n.unitKWh, tone: BbTone.solar),
          const BbGap.xs(),
          Row(
            children: [
              Icon(
                nearClear ? BbIcons.solar : BbIcons.cloudy,
                size: AppSizes.iconXs,
                color: muted,
              ),
              const BbGap.xs(),
              Expanded(
                child: Text(
                  nearClear
                      ? l10n.solarNearClear
                      : l10n.solarBelowClear(
                          Formatters.percent(day.belowClearSky),
                        ),
                  style: context.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
          const BbGap.lg(),
          BbSolarForecastStrip(
            bars: [
              for (final h in day.hours)
                BbSolarBar(
                  value: h.expectedWh,
                  potential: h.clearSkyWh,
                  label: _label(h),
                ),
            ],
            forecastLabel: l10n.solarLegendForecast,
            potentialLabel: l10n.solarLegendClearDay,
            semanticLabel: l10n.solarChartSemantics(range),
          ),
        ],
      ),
    );
  }

  String? _label(SolarHour h) {
    final start = h.endsAt.subtract(const Duration(hours: 1));
    return start.add(utcOffset).hour % _labelEveryHours == 0
        ? Formatters.hour(start, utcOffset)
        : null;
  }
}
