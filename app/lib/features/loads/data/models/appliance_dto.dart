import 'package:energy_engine/energy_engine.dart';

import '../../domain/entities/appliance.dart';

/// Firestore/JSON shape of `appliances/{id}` (ARCHITECTURE.md §8).
abstract final class ApplianceDto {
  static const _priority = {
    AppliancePriority.essential: 'essential',
    AppliancePriority.comfort: 'comfort',
    AppliancePriority.avoidOnBackup: 'avoid_on_backup',
  };

  static Appliance fromMap(String id, Map<String, dynamic> map) => Appliance(
    id: id,
    name: map['name'] as String,
    iconKey: map['icon'] as String? ?? 'plug',
    watts: (map['watts'] as num).toDouble(),
    quantity: (map['quantity'] as num? ?? 1).toInt(),
    dutyCycle: (map['dutyCycle'] as num? ?? 1).toDouble(),
    priority: _priority.entries
        .firstWhere(
          (e) => e.value == map['priority'],
          orElse: () =>
              throw FormatException('Unknown priority: ${map['priority']}'),
        )
        .key,
    isOn: map['isOn'] as bool? ?? false,
    order: (map['order'] as num? ?? 0).toInt(),
  );

  static Map<String, dynamic> toMap(Appliance a) => {
    'name': a.name,
    'icon': a.iconKey,
    'watts': a.watts,
    'quantity': a.quantity,
    'dutyCycle': a.dutyCycle,
    'priority': _priority[a.priority],
    'isOn': a.isOn,
    'order': a.order,
  };
}
