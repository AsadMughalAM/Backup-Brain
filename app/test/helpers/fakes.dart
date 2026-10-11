import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:backup_brain/features/backup/data/models/system_dto.dart';
import 'package:backup_brain/features/backup/domain/entities/household_system.dart';
import 'package:backup_brain/features/backup/domain/system_repository.dart';
import 'package:backup_brain/features/loads/data/models/appliance_dto.dart';
import 'package:backup_brain/features/loads/domain/appliance_repository.dart';
import 'package:backup_brain/features/loads/domain/entities/appliance.dart';

/// The real bundled demo file, so tests also prove the asset parses.
Map<String, dynamic> demoJson() =>
    json.decode(File('assets/data/demo_household.json').readAsStringSync())
        as Map<String, dynamic>;

HouseholdSystem demoSystem() =>
    SystemDto.fromMap(demoJson()['system'] as Map<String, dynamic>);

List<Appliance> demoAppliances() => [
  for (final (i, raw)
      in (demoJson()['appliances'] as List)
          .cast<Map<String, dynamic>>()
          .indexed)
    ApplianceDto.fromMap(raw['id'] as String, {...raw, 'order': i}),
];

/// In-memory stand-in for the Firestore repository: emits the current value
/// first, like the offline cache does.
class FakeSystemRepository implements SystemRepository {
  FakeSystemRepository([this._system]);

  HouseholdSystem? _system;
  final _changes = StreamController<HouseholdSystem?>.broadcast();

  @override
  Stream<HouseholdSystem?> watch() async* {
    yield _system;
    yield* _changes.stream;
  }

  void _emit(HouseholdSystem? s) => _changes.add(_system = s);

  @override
  Future<void> save(HouseholdSystem system) async => _emit(system);

  @override
  Future<void> setSoc(double soc) async => _emit(_system!.copyWith(soc: soc));

  @override
  Future<void> loadDemo() async => _emit(demoSystem());
}

class FakeApplianceRepository implements ApplianceRepository {
  FakeApplianceRepository([List<Appliance>? initial])
    : _items = initial ?? const [];

  List<Appliance> _items;
  final _changes = StreamController<List<Appliance>>.broadcast();

  @override
  Stream<List<Appliance>> watchAll() async* {
    yield _items;
    yield* _changes.stream;
  }

  @override
  Future<void> setOn(String id, {required bool isOn}) async {
    _items = [
      for (final a in _items)
        a.id == id
            ? Appliance(
                id: a.id,
                name: a.name,
                iconKey: a.iconKey,
                watts: a.watts,
                priority: a.priority,
                quantity: a.quantity,
                dutyCycle: a.dutyCycle,
                isOn: isOn,
                order: a.order,
              )
            : a,
    ];
    _changes.add(_items);
  }

  @override
  Future<void> loadDemo() async => _changes.add(_items = demoAppliances());
}
