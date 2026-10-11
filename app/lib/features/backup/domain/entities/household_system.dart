import 'package:energy_engine/energy_engine.dart';

/// The household's backup hardware and its current charge
/// (ARCHITECTURE.md §8 `System`).
class HouseholdSystem {
  const HouseholdSystem({
    required this.battery,
    required this.inverter,
    required this.soc,
    this.hasSolar = false,
  });

  final BatterySpec battery;
  final InverterSpec inverter;

  /// State of charge 0–1, entered by the user (ManualSource) for now.
  final double soc;
  final bool hasSolar;

  BackupInput get backupInput =>
      BackupInput(battery: battery, inverter: inverter, socNow: soc);

  HouseholdSystem copyWith({double? soc}) => HouseholdSystem(
    battery: battery,
    inverter: inverter,
    soc: soc ?? this.soc,
    hasSolar: hasSolar,
  );
}
