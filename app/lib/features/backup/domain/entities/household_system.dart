import 'package:energy_engine/energy_engine.dart';

/// The household's backup hardware and its current charge
/// (ARCHITECTURE.md §8 `System`).
class HouseholdSystem {
  const HouseholdSystem({
    required this.battery,
    required this.inverter,
    required this.soc,
    this.solar,
    this.panels,
    this.location,
  });

  final BatterySpec battery;
  final InverterSpec inverter;

  /// State of charge 0–1, entered by the user (ManualSource) for now.
  final double soc;

  /// Null when the household has no panels.
  final SolarSpec? solar;

  /// How the kWp is made up, so it can be shown and edited as "6 × 550 W".
  /// Null for households saved before it was recorded.
  final PanelArray? panels;
  final HomeLocation? location;

  bool get hasSolar => solar != null;

  BackupInput get backupInput =>
      BackupInput(battery: battery, inverter: inverter, socNow: soc);

  HouseholdSystem copyWith({double? soc}) => HouseholdSystem(
    battery: battery,
    inverter: inverter,
    soc: soc ?? this.soc,
    solar: solar,
    panels: panels,
    location: location,
  );
}

/// Where the panels are: the weather forecast is fetched for this point.
class HomeLocation {
  const HomeLocation({required this.city, required this.site});

  final String city;
  final SiteLocation site;
}

class PanelArray {
  const PanelArray({required this.count, required this.watts});

  final int count;

  /// Rated watts of one panel.
  final double watts;
}
