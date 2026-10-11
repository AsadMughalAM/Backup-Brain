enum InverterType { ups, hybrid, ongrid }

final class InverterSpec {
  const InverterSpec({
    required this.type,
    required this.ratedW,
    this.efficiency,
  });

  final InverterType type;

  /// Maximum continuous output. A load above this is an overload.
  final double ratedW;

  /// Overrides the type default from `EngineDefaults.inverterEfficiency`.
  final double? efficiency;
}
