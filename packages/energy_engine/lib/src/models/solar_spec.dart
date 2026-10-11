enum PanelShading { none, partial, heavy }

/// A rooftop panel array (ARCHITECTURE.md §8 `System.solar`).
final class SolarSpec {
  const SolarSpec({
    required this.kWp,
    this.shading = PanelShading.none,
    this.lastCleanedAt,
    this.performanceRatio,
  });

  /// Total panel capacity in kilowatt-peak.
  final double kWp;
  final PanelShading shading;

  /// Unknown → the dusty-panel soiling factor applies.
  final DateTime? lastCleanedAt;

  /// Overrides `EngineDefaults.performanceRatio`.
  final double? performanceRatio;
}

/// Where the panels are, in decimal degrees.
final class SiteLocation {
  const SiteLocation({required this.lat, required this.lon});

  final double lat;
  final double lon;
}
