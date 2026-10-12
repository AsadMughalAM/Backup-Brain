import 'dart:convert';
import 'dart:typed_data';

import 'package:backup_brain/features/battery/data/geoapify_shops_repository.dart';
import 'package:backup_brain/features/battery/domain/nearby_shops_repository.dart';
import 'package:dio/dio.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Plays Geoapify: an area lookup answers with [areaAt] (none when null),
/// a shop search with the places in [places] whose name contains the
/// searched word, as the real name filter does. [offline] fails every call;
/// [slowWord] times out only that word's search.
class _FakeGeoapify implements HttpClientAdapter {
  _FakeGeoapify(
    this.places, {
    this.areaAt,
    this.offline = false,
    this.slowWord,
  });

  final List<Map<String, dynamic>> places;
  final SiteLocation? areaAt;
  final bool offline;
  final String? slowWord;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    final area = areaAt;
    final word = options.queryParameters['name'] as String?;
    if (word != null && word == slowWord) {
      throw DioException.receiveTimeout(
        timeout: const Duration(seconds: 15),
        requestOptions: options,
      );
    }
    final body = options.path.contains('geocode')
        ? {
            'results': [
              if (area != null) {'lat': area.lat, 'lon': area.lon},
            ],
          }
        : {
            'features': [
              for (final p in places)
                if (word == null ||
                    ((p['properties'] as Map)['name'] as String? ?? '')
                        .toLowerCase()
                        .contains(word))
                  p,
            ],
          };
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _place(String? name, double distance, {String? address}) =>
    {
      'type': 'Feature',
      'properties': {
        'name': ?name,
        'address_line2': ?address,
        'lat': 31.5,
        'lon': 74.3,
        'distance': distance,
      },
    };

// Real Lahore and Karachi names. Geoapify's name filter matches any part of
// a name, and maps some shops twice.
final _shops = [
  _place('SSB Groups', 300),
  _place('Malik Battery Agency', 12300, address: 'Saddar, Lahore'),
  _place('Ghazi Battery Service', 1900),
  _place('Falco Solar', 2700),
  _place('Shahjee UPS & Stabilisers', 2600),
  _place('Max Power Solar | Inverters | Battaries', 2400),
  _place('Max Power Solar | Inverters | Battaries', 2450),
  _place('Combat Gym', 500),
  _place(null, 100),
];

const _lahore = SiteLocation(lat: 31.5204, lon: 74.3587);
const _joharTown = SiteLocation(lat: 31.4632, lon: 74.2939);

GeoapifyShopsRepository _repo(_FakeGeoapify server) =>
    GeoapifyShopsRepository(Dio()..httpClientAdapter = server, apiKey: 'k');

void main() {
  test('battery shops first, then dealers that also sell batteries', () async {
    final shops = await _repo(_FakeGeoapify(_shops))
        .find(ShopKind.battery, _lahore);

    // "Combat" contains "bat" but is no battery shop; the misspelt
    // "Battaries" still counts. UPS and solar shops fill in after.
    expect(shops.map((s) => s.name), [
      'Ghazi Battery Service',
      'Max Power Solar | Inverters | Battaries',
      'Malik Battery Agency',
      'Shahjee UPS & Stabilisers',
      'Falco Solar',
    ]);
    expect(shops[2].address, 'Saddar, Lahore');
    expect(shops.first.address, '');
  });

  test('UPS repair: whole word "UPS", so no "Groups"', () async {
    final shops = await _repo(_FakeGeoapify(_shops))
        .find(ShopKind.upsRepair, _lahore);
    expect(shops.take(2).map((s) => s.name), [
      'Max Power Solar | Inverters | Battaries',
      'Shahjee UPS & Stabilisers',
    ]);
    expect(shops.map((s) => s.name), isNot(contains('SSB Groups')));
  });

  test(
    'an area is looked up inside the home city, then searched around',
    () async {
      final server = _FakeGeoapify(_shops, areaAt: _joharTown);
      final repo = _repo(server);
      await repo.find(ShopKind.solarInstaller, _lahore, area: 'Johar Town');

      // "Johar Town" alone first finds the one in Multan.
      final lookup = server.requests.first.queryParameters;
      expect(lookup['text'], 'Johar Town');
      expect(lookup['filter'], 'circle:74.3587,31.5204,30000');
      final search = server.requests.last.queryParameters;
      expect(search['categories'], 'commercial');
      expect(search['filter'], 'circle:74.2939,31.4632,40000');
      expect(search['bias'], 'proximity:74.2939,31.4632');
      expect(search['apiKey'], 'k');

      // The area's point is remembered: the next search makes no lookup.
      server.requests.clear();
      await repo.find(ShopKind.battery, _lahore, area: 'johar town');
      expect(server.requests.where((r) => r.path.contains('geocode')), isEmpty);
    },
  );

  test('an area not on the map: search around home instead', () async {
    final server = _FakeGeoapify(_shops);
    await _repo(server).find(ShopKind.battery, _lahore, area: 'Nowhere');
    expect(
      server.requests.last.queryParameters['filter'],
      'circle:74.3587,31.5204,40000',
    );
  });

  test("one slow word keeps the other words' shops", () async {
    final shops = await _repo(_FakeGeoapify(_shops, slowWord: 'batt'))
        .find(ShopKind.battery, _lahore);
    expect(shops.map((s) => s.name), [
      'Max Power Solar | Inverters | Battaries',
      'Shahjee UPS & Stabilisers',
      'Falco Solar',
    ]);
  });

  test('offline throws, so the screen can offer Try again', () async {
    expect(
      _repo(_FakeGeoapify(_shops, offline: true))
          .find(ShopKind.battery, _lahore),
      throwsA(isA<DioException>()),
    );
  });
}
