import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:backup_brain/features/auth/domain/auth_repository.dart';
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

  /// How many times the demo household was written.
  int demoLoads = 0;

  @override
  Future<void> loadDemo() async {
    demoLoads++;
    _emit(demoSystem());
  }

  /// Set to make the server check fail, like being offline.
  bool offline = false;

  @override
  Future<bool> existsOnServer() async {
    if (offline) throw StateError('offline');
    return _system != null;
  }
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

const signedInAsAsad = AccountInfo(
  uid: 'asad',
  kind: AccountKind.email,
  email: 'asad@example.pk',
  displayName: 'Asad Ali',
);

/// Records calls; [failWith] makes the next actions throw that failure.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.account, this.failWith});

  AccountInfo? account;
  AuthFailureCode? failWith;
  final calls = <String>[];
  final _changes = StreamController<AccountInfo?>.broadcast();

  Future<void> _act(String call, AccountInfo? after) async {
    calls.add(call);
    final code = failWith;
    if (code != null) throw AuthFailure(code);
    _changes.add(account = after);
  }

  @override
  Stream<AccountInfo?> watchAccount() async* {
    yield account;
    yield* _changes.stream;
  }

  @override
  Future<void> continueWithGoogle() => _act(
    'google',
    const AccountInfo(
      uid: 'g1',
      kind: AccountKind.google,
      displayName: 'Arham',
    ),
  );

  @override
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) => _act(
    'signUp $name <$email>',
    AccountInfo(
      uid: 'new',
      kind: AccountKind.email,
      email: email,
      displayName: name,
    ),
  );

  @override
  Future<void> signInWithEmail(String email, String password) => _act(
    'login $email',
    AccountInfo(uid: 'old', kind: AccountKind.email, email: email),
  );

  @override
  Future<void> sendPasswordReset(String email) => _act('reset $email', account);

  @override
  Future<void> setRememberMe(bool remember) async {}

  @override
  Future<void> signOut() => _act('signOut', null);
}
