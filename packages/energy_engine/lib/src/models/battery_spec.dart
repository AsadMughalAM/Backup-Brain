enum BatteryChemistry {
  leadAcid,
  tubular,
  lifepo4;

  bool get isLeadAcidFamily => this != lifepo4;
}

/// A battery bank of [count] identical batteries.
final class BatterySpec {
  const BatterySpec({
    required this.chemistry,
    required this.voltage,
    required this.ampHours,
    this.count = 1,
    this.minSoc,
  });

  final BatteryChemistry chemistry;

  /// Nominal voltage of one battery (12, 24 or 48 V).
  final double voltage;
  final double ampHours;
  final int count;

  /// Overrides the chemistry default from `EngineDefaults.minSoc`, as a
  /// fraction 0–1.
  final double? minSoc;

  double get nominalWh => voltage * ampHours * count;
}
