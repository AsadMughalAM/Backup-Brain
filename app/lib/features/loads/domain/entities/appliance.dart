import 'package:energy_engine/energy_engine.dart';

/// An appliance as the app stores it (ARCHITECTURE.md §8): the engine's
/// [ApplianceLoad] plus display fields.
class Appliance {
  const Appliance({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.watts,
    required this.priority,
    this.quantity = 1,
    this.dutyCycle = 1.0,
    this.isOn = true,
    this.order = 0,
  });

  final String id;
  final String name;

  /// Appliance preset key ("fan", "tv", …), mapped to a `BbIcons` glyph by
  /// the UI.
  final String iconKey;
  final double watts;
  final AppliancePriority priority;
  final int quantity;
  final double dutyCycle;
  final bool isOn;

  /// Position in the user's list.
  final int order;

  Appliance copyWith({bool? isOn}) => Appliance(
    id: id,
    name: name,
    iconKey: iconKey,
    watts: watts,
    priority: priority,
    quantity: quantity,
    dutyCycle: dutyCycle,
    isOn: isOn ?? this.isOn,
    order: order,
  );

  ApplianceLoad get load => ApplianceLoad(
    id: id,
    name: name,
    watts: watts,
    priority: priority,
    quantity: quantity,
    dutyCycle: dutyCycle,
    isOn: isOn,
  );
}
