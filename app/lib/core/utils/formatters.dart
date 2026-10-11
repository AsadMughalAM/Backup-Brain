import 'package:intl/intl.dart';

import '../../app/l10n/app_localizations.dart';

/// Display formatting for engine numbers (DESIGN.md §3.5). The only place
/// numbers become text.
abstract final class Formatters {
  // South-Asian grouping (1,85,000) for every supported language. Spelled
  // out as a pattern: intl's en_PK data groups in thousands (185,000).
  static final _number = NumberFormat('#,##,##0', 'en');

  /// Backup time. Minutes round *down*: a countdown must never promise more
  /// time than the battery has.
  static String duration(AppLocalizations l10n, double hours) {
    if (hours.isInfinite) return l10n.durationUnlimited;
    final totalMinutes = (hours * 60).floor();
    final h = totalMinutes ~/ 60, m = totalMinutes % 60;
    return h == 0 ? l10n.durationMinutes(m) : l10n.durationHoursMinutes(h, m);
  }

  /// "+57m" for time gained by switching something off.
  static String gained(AppLocalizations l10n, double hours) =>
      l10n.gainedTime(duration(l10n, hours));

  /// Rounded, grouped: 1,85,000. For a value shown with a separate unit.
  static String number(double v) => _number.format(v.round());

  static String watts(double w) => '${number(w)} W';

  /// [fraction] is 0–1.
  static String percent(double fraction) => '${(fraction * 100).round()}%';
}
