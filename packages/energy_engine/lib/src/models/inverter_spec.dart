enum InverterType { ups, hybrid, ongrid }

final class InverterSpec {
  const InverterSpec({
    required this.type,
    required this.ratedW,
    this.efficiency,
    this.chargerW,
  });

  final InverterType type;

  /// Maximum continuous output. A load above this is an overload.
  final double ratedW;

  /// Overrides the type default from `EngineDefaults.inverterEfficiency`.
  final double? efficiency;

  /// Power the built-in charger puts into the battery from the grid.
  /// Overrides the C-rate default from `EngineDefaults.chargeRateC`.
  final double? chargerW;
}
