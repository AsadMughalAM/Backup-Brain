import 'package:energy_engine/energy_engine.dart';

/// The household's backup hardware and its current charge
/// (ARCHITECTURE.md §8 `System`).
class HouseholdSystem {
  const HouseholdSystem({
    required this.battery,
    required this.inverter,
    required this.soc,
    this.socAt,
    this.socCheckedAt,
    this.solar,
    this.panels,
    this.location,
  });

  final BatterySpec battery;
  final InverterSpec inverter;

  /// The last known charge, 0–1: the user's own reading, or the app's
  /// estimate saved when the power went or came back or the load changed
  /// during a cut. The charge now is worked forward from it
  /// (`batteryEstimateProvider`).
  final double soc;

  /// When [soc] was known. Null for households saved before this was
  /// recorded (and the demo): their charge stays as saved until the next
  /// power cut is logged.
  final DateTime? socAt;

  /// When the user last read the battery % themselves (setup, the battery
  /// check, the planner slider). Null = never.
  final DateTime? socCheckedAt;

  /// Null when the household has no panels.
  final SolarSpec? solar;

  /// How the kWp is made up, so it can be shown and edited as "6 × 550 W".
  /// Null for households saved before it was recorded.
  final PanelArray? panels;
  final HomeLocation? location;

  bool get hasSolar => solar != null;

  BackupInput get backupInput =>
      BackupInput(battery: battery, inverter: inverter, socNow: soc);

  HouseholdSystem copyWith({
    double? soc,
    DateTime? socAt,
    DateTime? socCheckedAt,
    SolarSpec? solar,
  }) => HouseholdSystem(
    battery: battery,
    inverter: inverter,
    soc: soc ?? this.soc,
    socAt: socAt ?? this.socAt,
    socCheckedAt: socCheckedAt ?? this.socCheckedAt,
    solar: solar ?? this.solar,
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
