import 'defaults.dart';
import 'models/battery_spec.dart';
import 'models/inverter_spec.dart';

/// Everything about the battery's current situation that F1 needs, apart from
/// the load. Shared by the backup calculator and the load planner.
final class BackupInput {
  const BackupInput({
    required this.battery,
    required this.inverter,
    required this.socNow,
    this.healthFactor = 1.0,
  });

  final BatterySpec battery;
  final InverterSpec inverter;

  /// Current state of charge as a fraction 0–1.
  final double socNow;

  /// Remaining capacity vs. nominal, from F6 battery health. 1.0 = new.
  final double healthFactor;
}

final class BackupEstimate {
  const BackupEstimate({
    required this.hours,
    required this.loadW,
    required this.usableWh,
    required this.minSoc,
    required this.isOverloaded,
    required this.isDerated,
  });

  /// Hours of backup left. [double.infinity] when nothing is drawing power.
  final double hours;
  final double loadW;

  /// Battery energy available above [minSoc], before inverter losses.
  final double usableWh;

  /// The SoC at which the inverter stops, to protect the battery.
  final double minSoc;

  /// Load exceeds the inverter's rated output (shown as a red warning).
  final bool isOverloaded;

  /// The lead-acid high-load derate was applied.
  final bool isDerated;

  bool get isUnlimited => hours.isInfinite;
}

/// F1 — "How long will my backup last right now?" (ARCHITECTURE.md §5 F1).
final class BackupCalculator {
  const BackupCalculator();

  BackupEstimate estimate(BackupInput input, {required double loadW}) {
    _validate(input, loadW);
    final battery = input.battery;
    final minSoc = battery.minSoc ?? EngineDefaults.minSoc(battery.chemistry);
    final efficiency =
        input.inverter.efficiency ??
        EngineDefaults.inverterEfficiency(input.inverter.type);

    final nominalWh = battery.nominalWh;
    final usableWh =
        nominalWh *
        input.healthFactor *
        (input.socNow - minSoc).clamp(0.0, 1.0);

    var hours = loadW == 0 ? double.infinity : usableWh * efficiency / loadW;

    // Compared against Wh because 0.2 × Wh is the 0.2C discharge rate in W.
    final isDerated =
        battery.chemistry.isLeadAcidFamily &&
        loadW > EngineDefaults.peukertLoadRatio * nominalWh;
    if (isDerated) hours *= EngineDefaults.peukertDerate;

    return BackupEstimate(
      hours: hours,
      loadW: loadW,
      usableWh: usableWh,
      minSoc: minSoc,
      isOverloaded: loadW > input.inverter.ratedW,
      isDerated: isDerated,
    );
  }

  static void _validate(BackupInput input, double loadW) {
    final battery = input.battery;
    _check(battery.voltage > 0, 'battery.voltage', battery.voltage);
    _check(battery.ampHours > 0, 'battery.ampHours', battery.ampHours);
    _check(battery.count >= 1, 'battery.count', battery.count);
    final minSoc = battery.minSoc;
    if (minSoc != null) _check(_isFraction(minSoc), 'battery.minSoc', minSoc);
    _check(_isFraction(input.socNow), 'socNow', input.socNow);
    _check(
      input.healthFactor > 0 && input.healthFactor <= 1,
      'healthFactor',
      input.healthFactor,
    );
    _check(input.inverter.ratedW > 0, 'inverter.ratedW', input.inverter.ratedW);
    final eff = input.inverter.efficiency;
    if (eff != null) _check(eff > 0 && eff <= 1, 'inverter.efficiency', eff);
    _check(loadW >= 0 && loadW.isFinite, 'loadW', loadW);
  }

  static bool _isFraction(double v) => v >= 0 && v <= 1;

  static void _check(bool ok, String name, Object value) {
    if (!ok) throw ArgumentError.value(value, name);
  }
}
