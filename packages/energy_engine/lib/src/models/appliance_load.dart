enum AppliancePriority { essential, comfort, avoidOnBackup }

final class ApplianceLoad {
  const ApplianceLoad({
    required this.id,
    required this.name,
    required this.watts,
    required this.priority,
    this.quantity = 1,
    this.dutyCycle = 1.0,
    this.isOn = true,
  });

  final String id;
  final String name;

  /// Rated power of one unit.
  final double watts;
  final int quantity;

  /// Share of time the appliance actually draws power, 0–1 (a fridge
  /// compressor cycles, so ≈ 0.4).
  final double dutyCycle;
  final AppliancePriority priority;
  final bool isOn;

  double get effectiveW => watts * quantity * dutyCycle;
}
