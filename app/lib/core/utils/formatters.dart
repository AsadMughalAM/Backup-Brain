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

  static final _oneDecimal = NumberFormat('0.0', 'en');
  static const _clockStepMinutes = 5;

  /// Energy range with one decimal and an en dash: "3.3–4.5".
  static String kWhRange(double low, double high) =>
      '${_oneDecimal.format(low)}–${_oneDecimal.format(high)}';

  /// Wall-clock time at the panels' location ("5:35 PM"), to 5 minutes.
  /// Rounds down by default so a backup end is never promised late;
  /// [roundUp] for "full by", so a full battery is never promised early.
  static String clock(
    DateTime utc,
    Duration utcOffset, {
    bool roundUp = false,
  }) {
    final local = utc.add(utcOffset);
    final midnight = DateTime.utc(local.year, local.month, local.day);
    final steps = local.difference(midnight).inSeconds / 60 / _clockStepMinutes;
    final rounded =
        (roundUp ? steps.ceil() : steps.floor()) * _clockStepMinutes;
    final time = midnight.add(Duration(minutes: rounded));
    final minutes = time.minute.toString().padLeft(2, '0');
    return '${_hour12(time)}:$minutes ${time.hour < 12 ? 'AM' : 'PM'}';
  }

  /// Hour of day for chart labels: "6", "12", "3".
  static String hour(DateTime utc, Duration utcOffset) =>
      '${_hour12(utc.add(utcOffset))}';

  /// Wall-clock time of a local [DateTime] ("7:10 PM").
  static String localClock(DateTime local) =>
      clock(local.toUtc(), local.timeZoneOffset);

  /// A coming moment relative to [nowLocal]: "7:10 PM" today,
  /// "tomorrow 9:30 AM", else "Wed 7:00 PM".
  static String dayTime(
    AppLocalizations l10n,
    DateTime local,
    DateTime nowLocal,
  ) {
    final time = localClock(local);
    final days = DateTime.utc(local.year, local.month, local.day)
        .difference(DateTime.utc(nowLocal.year, nowLocal.month, nowLocal.day))
        .inDays;
    return switch (days) {
      <= 0 => time,
      1 => l10n.tomorrowAt(time),
      _ => l10n.weekdayAt('${local.weekday}', time),
    };
  }

  /// "19:00" style minutes after midnight, on the 12-hour clock: "7:00 PM".
  static String minuteOfDay(int minute) {
    final t = DateTime.utc(2000, 1, 1, 0, minute);
    return '${_hour12(t)}:${t.minute.toString().padLeft(2, '0')} '
        '${t.hour < 12 ? 'AM' : 'PM'}';
  }

  // The 12-hour clock is how both English and Roman Urdu users read time.
  static int _hour12(DateTime t) => t.hour % 12 == 0 ? 12 : t.hour % 12;

  /// How old saved data is: "just now", "20 min ago", "3 h ago".
  static String age(AppLocalizations l10n, Duration age) {
    if (age.inMinutes < 1) return l10n.ageJustNow;
    if (age.inHours < 1) return l10n.ageMinutes(age.inMinutes);
    if (age.inDays < 1) return l10n.ageHours(age.inHours);
    return l10n.ageDays(age.inDays);
  }
}
