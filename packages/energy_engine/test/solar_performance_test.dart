import 'package:energy_engine/energy_engine.dart';
import 'package:test/test.dart';

DayPerformance day(
  int d,
  double actual, {
  double expected = 10,
  double clear = 0.9,
}) => DayPerformance(
  day: DateTime.utc(2026, 10, d),
  actualKWh: actual,
  expectedKWh: expected,
  clearShare: clear,
);

void main() {
  const check = SolarPerformance();

  test('index = actual / expected', () {
    expect(day(1, 8.5).index, closeTo(0.85, 1e-9));
  });

  test('≥ 0.90 healthy, 0.75–0.90 slightly low', () {
    expect(check.status([day(1, 9.2)]), PerformanceStatus.healthy);
    expect(check.status([day(1, 8.0)]), PerformanceStatus.slightlyLow);
  });

  test('one very low day is only "slightly low": could be a bad forecast', () {
    expect(check.status([day(1, 5)]), PerformanceStatus.slightlyLow);
  });

  test('< 0.75 on three clear days in a week is significant', () {
    expect(
      check.status([day(1, 6), day(3, 6.5), day(5, 7), day(6, 9.5)]),
      PerformanceStatus.significantlyLow,
    );
  });

  test('cloudy low days do not raise the alarm', () {
    expect(
      check.status([
        day(1, 6, clear: 0.3),
        day(2, 6, clear: 0.4),
        day(3, 6, clear: 0.5),
      ]),
      PerformanceStatus.slightlyLow,
    );
  });

  test('low clear days older than a week no longer count', () {
    expect(
      check.status([day(1, 6), day(2, 6), day(3, 6), day(20, 9.5)]),
      PerformanceStatus.healthy,
    );
  });

  test('days with almost no expected sun are not judged', () {
    expect(check.status([day(1, 0.1, expected: 0.2)]), isNull);
  });
}
