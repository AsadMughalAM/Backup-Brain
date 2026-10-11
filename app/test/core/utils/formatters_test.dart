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
}
