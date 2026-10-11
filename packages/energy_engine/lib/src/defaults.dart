import 'models/battery_spec.dart';
import 'models/inverter_spec.dart';

/// Engine default constants (ARCHITECTURE.md §5). This is the only place they
/// live; every one can be overridden through the inputs.
abstract final class EngineDefaults {
  /// Lowest state of charge the inverter should drain to. Lead-acid loses
  /// cycle life quickly below 50%; LiFePO4 tolerates deep discharge.
  static double minSoc(BatteryChemistry chemistry) => switch (chemistry) {
    BatteryChemistry.leadAcid || BatteryChemistry.tubular => 0.50,
    BatteryChemistry.lifepo4 => 0.15,
  };

  /// The spec gives 0.85 for UPS and 0.90 for hybrid inverters. On-grid
  /// inverters have no battery, so their value only matters if one is added.
  static double inverterEfficiency(InverterType type) => switch (type) {
    InverterType.ups => 0.85,
    InverterType.hybrid || InverterType.ongrid => 0.90,
  };

  /// Peukert-style derate for lead-acid: above a 0.2C discharge rate the
  /// battery delivers noticeably less than its rated capacity.
  static const peukertLoadRatio = 0.2;
  static const peukertDerate = 0.85;
}
