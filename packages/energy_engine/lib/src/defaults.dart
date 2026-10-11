import 'models/battery_spec.dart';
import 'models/inverter_spec.dart';
import 'models/solar_spec.dart';

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

  // F3 solar model (ARCHITECTURE.md §5 F3).

  /// Wiring, inverter and mismatch losses of a typical rooftop system.
  static const performanceRatio = 0.78;

  /// Dust on the panels: clean within a week, within a month, or older /
  /// unknown.
  static double soilingFactor(int? daysSinceCleaned) =>
      daysSinceCleaned == null || daysSinceCleaned >= 30
      ? 0.90
      : daysSinceCleaned >= 7
      ? 0.95
      : 1.00;

  static double shadingFactor(PanelShading shading) => switch (shading) {
    PanelShading.none => 1.00,
    PanelShading.partial => 0.85,
    PanelShading.heavy => 0.65,
  };

  /// Panels lose 0.4% output per °C above 25 °C, and in sun they run about
  /// 20 °C hotter than the air.
  static const panelTempCoefficient = 0.004;
  static const panelTempRiseC = 20.0;
  static const panelRatedTempC = 25.0;

  static double chargeEfficiency(BatteryChemistry chemistry) =>
      chemistry.isLeadAcidFamily ? 0.80 : 0.90;

  /// ± spread on forecast energy: weather forecasts are not exact, so the
  /// app shows a range rather than one confident number.
  static const solarForecastUncertainty = 0.15;

  /// Length of the "most sun" window suggested for heavy loads.
  static const peakWindowHours = 3;

  // F8 outages and recharge (ARCHITECTURE.md §5 F8).

  /// Grid chargers in UPS / hybrid inverters typically charge at about C/10
  /// (15 A into a 150 Ah bank), used when the charger power is unknown.
  static const chargeRateC = 0.10;

  /// How far back logged outages count towards the learned pattern.
  static const outageLookbackDays = 14;

  /// Fewer observed days than this is too little to call a pattern.
  static const outageMinDays = 3;

  /// An hour is "outage-prone" when an outage started in it on at least
  /// this share of the observed days.
  static const outageMinShare = 0.30;
}
