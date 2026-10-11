import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';

/// The answer first: one sentence ("Battery full by 1:15 PM"), the starting
/// point it assumes, and the ring with the battery at sunset and how long
/// that lasts the night.
class SolarDayHero extends StatelessWidget {
  const SolarDayHero({
    super.key,
    required this.day,
    required this.isToday,
    required this.utcOffset,
    required this.loadW,
  });

  final SolarDayForecast day;
  final bool isToday;
  final Duration utcOffset;
  final double loadW;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final headline = _headline(l10n);
    final caption = day.sunIsOver
        ? l10n.solarBatteryNow
        : l10n.solarAtSunset(Formatters.clock(day.sunset, utcOffset));
    final night = _night(l10n);
    final start = Formatters.percent(day.startSoc);

    return BbCard(
      variant: BbCardVariant.hero,
      // The hero draws with the dark palette; styles must be read from a
      // context inside the card, or they come out dark-on-dark.
      child: Builder(
        builder: (context) => Column(
          children: [
            Text(
              headline,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall,
            ),
            if (!day.sunIsOver) ...[
              const BbGap.xs(),
              Text(
                isToday
                    ? l10n.solarStartNow(start)
                    : l10n.solarStartSunrise(start),
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
            const BbGap.xl(),
            BbCountdownRing(
              soc: day.socAtSunset,
              timeLabel: Formatters.percent(day.socAtSunset),
              caption: caption,
              footnote: night,
              semanticLabel: '$headline. $caption. $night.',
            ),
          ],
        ),
      ),
    );
  }

  String _headline(AppLocalizations l10n) {
    if (day.sunIsOver) return l10n.solarSunOver;
    if (day.socAtSunset < 1) {
      return l10n.solarReaches(Formatters.percent(day.socAtSunset));
    }
    final fullAt = day.fullAt;
    return fullAt == null
        ? l10n.solarStaysFull
        : l10n.solarFullBy(Formatters.clock(fullAt, utcOffset, roundUp: true));
  }

  String _night(AppLocalizations l10n) {
    final load = Formatters.watts(loadW);
    final endsAt = day.nightEndsAt;
    if (endsAt == null) return l10n.solarNightNoLoad;
    if (day.lastsUntilSunrise) return l10n.solarNightAll(load);
    return l10n.solarNightUntil(Formatters.clock(endsAt, utcOffset), load);
  }
}
