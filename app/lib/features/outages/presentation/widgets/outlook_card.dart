import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/outage_outlook.dart';

/// F8's answer: the power is out (and how the battery is doing), or when
/// it goes next and whether the battery will be ready — or how to get a
/// prediction at all.
class OutlookCard extends StatelessWidget {
  const OutlookCard({super.key, required this.outlook, required this.now});

  final OutageOutlook outlook;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final load = Formatters.watts(outlook.loadW);
    final ongoing = outlook.ongoing;
    final next = outlook.next;
    final readiness = outlook.readiness;

    if (ongoing != null) {
      return _Body(
        icon: BbIcons.gridOff,
        title: l10n.ongoingTitle(Formatters.duration(l10n, ongoing.hours)),
        lines: [
          l10n.ongoingBody(
            Formatters.percent(ongoing.socNow),
            Formatters.duration(l10n, ongoing.backup.hours),
            load,
          ),
        ],
      );
    }
    if (next == null || readiness == null) {
      return _Body(
        icon: BbIcons.schedule,
        title: l10n.noPredictionTitle,
        lines: [l10n.noPredictionBody],
      );
    }

    final when = Formatters.dayTime(l10n, next.start, now.toLocal());
    final outage = next.hours;
    final short = readiness.coversOutage == false;
    return _Body(
      icon: short ? BbIcons.warning : BbIcons.batteryCharging,
      iconColor: short ? context.colors.warning : null,
      title: next.source == PredictionSource.schedule
          ? l10n.nextOutageScheduled(when)
          : l10n.nextOutageLikely(when),
      lines: [
        l10n.readinessBattery(
          Formatters.percent(readiness.socAtStart),
          Formatters.duration(l10n, readiness.backup.hours),
        ),
        if (outage != null)
          short
              ? l10n.readinessShort(Formatters.duration(l10n, outage), load)
              : l10n.readinessCovers(Formatters.duration(l10n, outage), load),
        if (!readiness.fullByThen)
          l10n.readinessFull(Formatters.duration(l10n, readiness.hoursToFull)),
      ],
      footnotes: [
        next.source == PredictionSource.schedule
            ? l10n.readinessBasisSchedule
            : l10n.readinessBasisPattern(
                '${next.daysObserved}',
                Formatters.percent(next.share ?? 0),
              ),
        l10n.readinessNoSolar,
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.icon,
    required this.title,
    required this.lines,
    this.iconColor,
    this.footnotes = const [],
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final List<String> lines;
  final List<String> footnotes;

  @override
  Widget build(BuildContext context) {
    final muted = context.textTheme.bodySmall?.copyWith(
      color: context.colors.textMuted,
    );
    return BbCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppSizes.iconMd,
            color: iconColor ?? context.colors.textPrimary,
          ),
          const BbGap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.titleMedium),
                for (final line in lines) ...[
                  const BbGap.xs(),
                  Text(line, style: context.textTheme.bodyMedium),
                ],
                for (final note in footnotes) ...[
                  const BbGap.xs(),
                  Text(note, style: muted),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
