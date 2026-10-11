import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:backup_brain/core/services/alert_scheduler.dart';
import 'package:backup_brain/core/services/external_links.dart';
import 'package:backup_brain/features/battery/data/battery_catalog_repository_impl.dart';
import 'package:backup_brain/features/battery/domain/battery_catalog_repository.dart';
import 'package:backup_brain/features/assistant/domain/assistant_repository.dart';
import 'package:backup_brain/features/assistant/domain/energy_snapshot.dart';
import 'package:backup_brain/features/auth/domain/auth_repository.dart';
import 'package:backup_brain/features/backup/data/models/system_dto.dart';
import 'package:backup_brain/features/backup/domain/entities/household_system.dart';
import 'package:backup_brain/features/backup/domain/system_repository.dart';
import 'package:backup_brain/features/estimator/data/pricing_repository_impl.dart';
import 'package:backup_brain/features/estimator/domain/pricing_repository.dart';
import 'package:backup_brain/features/loads/data/models/appliance_dto.dart';
import 'package:backup_brain/features/loads/domain/appliance_repository.dart';
import 'package:backup_brain/features/loads/domain/entities/appliance.dart';
import 'package:backup_brain/features/outages/domain/outage_repository.dart';
import 'package:backup_brain/features/setup/data/models/setup_presets_dto.dart';
import 'package:backup_brain/features/setup/domain/entities/setup_presets.dart';
import 'package:backup_brain/features/setup/domain/setup_presets_repository.dart';
import 'package:backup_brain/features/solar/data/models/weather_dto.dart';
import 'package:backup_brain/features/solar/domain/solar_log_repository.dart';
import 'package:backup_brain/features/solar/domain/entities/weather_forecast.dart';
import 'package:backup_brain/features/solar/domain/weather_repository.dart';
import 'package:energy_engine/energy_engine.dart';

/// The real bundled demo file, so tests also prove the asset parses.
Map<String, dynamic> demoJson() =>
    json.decode(File('assets/data/demo_household.json').readAsStringSync())
        as Map<String, dynamic>;

/// A real Open-Meteo response for Lahore, saved 11 Oct 2026: a hazy,
/// cloudy day, then a clearer one.
Map<String, dynamic> openMeteoLahoreJson() =>
    json.decode(File('test/fixtures/open_meteo_lahore.json').readAsStringSync())
        as Map<String, dynamic>;

/// 08:00 PKT on the fixture's first day.
final lahoreMorning = DateTime.utc(2026, 10, 11, 3);

WeatherForecast lahoreForecast({DateTime? fetchedAt}) =>
    WeatherDto.fromOpenMeteo(
      openMeteoLahoreJson(),
      site: const SiteLocation(lat: 31.5204, lon: 74.3587),
      fetchedAt:
          fetchedAt ?? lahoreMorning.subtract(const Duration(minutes: 20)),
    );

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
  HouseholdSystem? get current => _system;
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
  Future<void> addAll(
    List<Appliance> appliances, {
    Set<String> removing = const {},
  }) async {
    final added = {for (final a in appliances) a.id};
    _changes.add(
      _items = [
        for (final a in _items)
          if (!removing.contains(a.id) && !added.contains(a.id)) a,
        ...appliances,
      ],
    );
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

class FakeWeatherRepository implements WeatherRepository {
  FakeWeatherRepository({this.saved, this.onRefresh});

  WeatherForecast? saved;

  /// What a fetch returns; null makes it fail like a dropped connection.
  final WeatherForecast? Function()? onRefresh;
  var refreshCalls = 0;
  final _changes = StreamController<WeatherForecast?>.broadcast();

  @override
  Stream<WeatherForecast?> watchLatest() async* {
    yield saved;
    yield* _changes.stream;
  }

  @override
  Future<void> refresh(SiteLocation site) async {
    refreshCalls++;
    final fresh = onRefresh?.call();
    if (fresh == null) throw StateError('offline');
    _changes.add(saved = fresh);
  }
}

/// The real bundled setup JSON, read from disk: `rootBundle` caches asset
/// futures across tests, which stalls every test after the first.
class FileSetupPresetsRepository implements SetupPresetsRepository {
  const FileSetupPresetsRepository();

  @override
  Future<SetupPresets> load() async => setupPresets();
}

SetupPresets setupPresets() {
  Map<String, dynamic> read(String name) =>
      json.decode(File('assets/data/$name').readAsStringSync())
          as Map<String, dynamic>;
  return SetupPresetsDto.fromJson(
    cities: read('cities_psh.json'),
    appliances: read('appliances_pk.json'),
    equipment: read('equipment_pk.json'),
  );
}

class FakeAssistantRepository implements AssistantRepository {
  FakeAssistantRepository({this.answer = 'Your backup lasts 3h 28m.'});

  /// Null fails the next calls like a dropped connection.
  String? answer;
  final calls = <({List<ChatTurn> history, EnergySnapshot snapshot})>[];

  @override
  Future<String> reply({
    required List<ChatTurn> history,
    required EnergySnapshot snapshot,
    required ReplyLanguage language,
  }) async {
    calls.add((history: history, snapshot: snapshot));
    final a = answer;
    if (a == null) throw const AssistantFailure(AssistantFailureCode.offline);
    return a;
  }
}

class FakeOutageRepository implements OutageRepository {
  FakeOutageRepository({
    List<OutageEvent> outages = const [],
    List<ScheduleEntry> schedule = const [],
    DateTime Function()? clock,
  }) : outages = [...outages],
       schedule = [...schedule],
       _clock = clock ?? DateTime.now;

  /// Newest first, like the Firestore query.
  final List<OutageEvent> outages;
  final List<ScheduleEntry> schedule;
  final DateTime Function() _clock;
  final _outageChanges = StreamController<List<OutageEvent>>.broadcast();
  final _scheduleChanges = StreamController<List<ScheduleEntry>>.broadcast();
  var _ids = 0;

  @override
  Stream<List<OutageEvent>> watchRecent() async* {
    yield [...outages];
    yield* _outageChanges.stream;
  }

  @override
  Stream<List<ScheduleEntry>> watchSchedule() async* {
    yield [...schedule];
    yield* _scheduleChanges.stream;
  }

  @override
  Future<void> start({required double soc, required double loadW}) async {
    outages.insert(
      0,
      OutageEvent(
        id: 'o${_ids++}',
        startedAt: _clock(),
        startSoc: soc,
        avgLoadW: loadW,
      ),
    );
    _outageChanges.add([...outages]);
  }

  @override
  Future<void> end(String id, {required double soc}) async {
    final i = outages.indexWhere((o) => o.id == id);
    final o = outages[i];
    outages[i] = OutageEvent(
      id: o.id,
      startedAt: o.startedAt,
      endedAt: _clock(),
      startSoc: o.startSoc,
      endSoc: soc,
      avgLoadW: o.avgLoadW,
    );
    _outageChanges.add([...outages]);
  }

  @override
  Future<void> recordEndSoc(String id, double soc) async {
    final i = outages.indexWhere((o) => o.id == id);
    final o = outages[i];
    outages[i] = OutageEvent(
      id: o.id,
      startedAt: o.startedAt,
      endedAt: o.endedAt,
      startSoc: o.startSoc,
      endSoc: soc,
      endSocMeasured: true,
      avgLoadW: o.avgLoadW,
    );
    _outageChanges.add([...outages]);
  }

  @override
  Future<void> addSlot(ScheduleSlot slot) async {
    schedule.add(ScheduleEntry('s${_ids++}', slot));
    _scheduleChanges.add([...schedule]);
  }

  @override
  Future<void> removeSlot(String id) async {
    schedule.removeWhere((e) => e.id == id);
    _scheduleChanges.add([...schedule]);
  }
}

class FakeAlertScheduler implements AlertScheduler {
  /// The pending alert, or null after a cancel.
  ({DateTime atUtc, String title, String body})? pending;
  var schedules = 0;
  final tapController = StreamController<void>.broadcast();

  @override
  Future<void> schedule({
    required DateTime atUtc,
    required String title,
    required String body,
  }) async {
    schedules++;
    pending = (atUtc: atUtc, title: title, body: body);
  }

  @override
  Future<void> cancel() async => pending = null;

  @override
  Stream<void> get taps => tapController.stream;
}

/// The real bundled prices, so tests also prove the asset parses.
class FakePricingRepository implements PricingRepository {
  @override
  Future<PriceSheet> load() async => PricingDto.fromMap(
    json.decode(File('assets/data/pricing_pk.json').readAsStringSync())
        as Map<String, dynamic>,
  );
}

/// The real bundled catalog, so tests also prove the asset parses.
class FakeBatteryCatalogRepository implements BatteryCatalogRepository {
  @override
  Future<BatteryCatalog> load() async => BatteryCatalogDto.fromMap(
    json.decode(File('assets/data/battery_catalog_pk.json').readAsStringSync())
        as Map<String, dynamic>,
  );
}

class FakeExternalLinks implements ExternalLinks {
  final searches = <String>[];

  @override
  Future<bool> openMapsSearch(String query) async {
    searches.add(query);
    return true;
  }

  final priceSearches = <(PriceSite, String)>[];

  @override
  Future<bool> openPriceSearch(PriceSite site, String query) async {
    priceSearches.add((site, query));
    return true;
  }
}

class FakeSolarLogRepository implements SolarLogRepository {
  FakeSolarLogRepository([List<SolarLog> logs = const []]) : logs = [...logs];

  /// Newest first.
  final List<SolarLog> logs;
  final _changes = StreamController<List<SolarLog>>.broadcast();

  @override
  Stream<List<SolarLog>> watchRecent() async* {
    yield [...logs];
    yield* _changes.stream;
  }

  @override
  Future<void> save(SolarLog log) async {
    logs
      ..removeWhere((l) => l.day == log.day)
      ..add(log)
      ..sort((a, b) => b.day.compareTo(a.day));
    _changes.add([...logs]);
  }
}
