import 'package:backup_brain/app/l10n/app_localizations.dart';
import 'package:backup_brain/core/utils/formatters.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations en;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('duration rounds minutes down (never over-promise)', () {
    expect(Formatters.duration(en, 1458 / 420), '3h 28m'); // 3.4714 h
    expect(Formatters.duration(en, 5.832), '5h 49m');
    expect(Formatters.duration(en, 2.9999), '2h 59m');
  });

  test('under an hour shows minutes only; zero is 0m', () {
    expect(Formatters.duration(en, 0.95), '57m');
    expect(Formatters.duration(en, 0), '0m');
  });

  test('an estimated countdown is coarsened down to 10 minutes', () {
    expect(Formatters.duration(en, 1458 / 420, stepMinutes: 10), '3h 20m');
    expect(Formatters.duration(en, 0.16, stepMinutes: 10), '0m');
    expect(Formatters.duration(en, 2, stepMinutes: 10), '2h 0m');
  });

  test('a battery reading shows as given; an estimate rounds down to 5%', () {
    expect(Formatters.charge(0.6, estimate: false), '60%');
    expect(Formatters.charge(0.6, estimate: true), '60%');
    expect(Formatters.charge(0.7733, estimate: true), '75%');
    expect(Formatters.charge(0.749, estimate: true), '70%');
    expect(Formatters.chargeNumber(0.95, estimate: true), '95');
  });

  test('no load reads as words, not infinity', () {
    expect(Formatters.duration(en, double.infinity), 'No load');
  });

  test('gained time has a plus sign', () {
    expect(Formatters.gained(en, 0.9467), '+56m');
  });

  test('watts and numbers use South-Asian grouping', () {
    expect(Formatters.watts(420), '420 W');
    expect(Formatters.watts(2170.4), '2,170 W');
    expect(Formatters.number(185000), '1,85,000');
  });

  test('percent from a 0–1 fraction', () {
    expect(Formatters.percent(0.6), '60%');
    expect(Formatters.percent(0.15), '15%');
  });

  group("clock (panels' local time, 5-minute steps)", () {
    const pkt = Duration(hours: 5);
    final sunset = DateTime.utc(2026, 10, 11, 12, 32, 22); // 5:32 PM PKT

    test('rounds down by default: never promise a later end', () {
      expect(Formatters.clock(sunset, pkt), '5:30 PM');
    });

    test('rounds up for "full by": never promise an earlier full', () {
      expect(Formatters.clock(sunset, pkt, roundUp: true), '5:35 PM');
    });

    test('a time already on the step is unchanged either way', () {
      final noon = DateTime.utc(2026, 10, 11, 7);
      expect(Formatters.clock(noon, pkt), '12:00 PM');
      expect(Formatters.clock(noon, pkt, roundUp: true), '12:00 PM');
    });

    test('chart hour labels', () {
      expect(Formatters.hour(DateTime.utc(2026, 10, 11, 10), pkt), '3');
    });
  });

  test('kWh range has one decimal and an en dash', () {
    expect(Formatters.kWhRange(3.345, 4.52), '3.3–4.5');
  });

  test('age reads in the largest whole unit', () {
    expect(Formatters.age(en, const Duration(seconds: 30)), 'just now');
    expect(Formatters.age(en, const Duration(minutes: 20)), '20 min ago');
    expect(
      Formatters.age(en, const Duration(hours: 3, minutes: 50)),
      '3 h ago',
    );
    expect(Formatters.age(en, const Duration(days: 2)), '2 d ago');
  });
}
