import 'package:dio/dio.dart';
import 'package:energy_engine/energy_engine.dart';

import '../domain/nearby_shops_repository.dart';

/// Geoapify Places (OpenStreetMap data): free tier of 3,000 credits a day,
/// no card. MVP: key from `env.json` like the Gemini key
/// (docs/decisions/0003).
class GeoapifyShopsRepository implements NearbyShopsRepository {
  GeoapifyShopsRepository(this._dio, {required this.apiKey});

  final Dio _dio;
  final String apiKey;

  static const _placesUrl = 'https://api.geoapify.com/v2/places';
  static const _geocodeUrl = 'https://api.geoapify.com/v1/geocode/search';

  // Lahore's map has few such shops, so look well beyond the area; the
  // nearest still come first.
  static const _radiusMeters = 40000;

  // An area is looked up only inside its own city: "Johar Town" alone
  // first finds the one in Multan.
  static const _cityRadiusMeters = 30000;
  static const _shown = 8;

  // 20 places cost one credit, so each word is one credit.
  static const _perWord = 20;

  /// Area name → its point, for the session: one lookup per area.
  final _areas = <String, SiteLocation>{};

  @override
  Future<List<NearbyShop>> find(
    ShopKind kind,
    SiteLocation home, {
    String? area,
  }) async {
    final near = await _centre(home, area);
    final search = _searches[kind]!;
    // One slow word (dense Karachi can pass the timeout) must not cost the
    // whole list: keep what came back, fail only when nothing did.
    final failures = <Object>[];
    Future<List<NearbyShop>> tolerant(_Word word) => _search(word, near).then(
      (shops) => shops,
      onError: (Object e) {
        failures.add(e);
        return const <NearbyShop>[];
      },
    );
    // Both groups start at once; the related one is only waited for when
    // the exact matches don't fill the list.
    final exactSearch = Future.wait(search.exact.map(tolerant));
    final relatedSearch = Future.wait(search.related.map(tolerant));
    final exact = _distinct(_nearestFirst(await exactSearch));
    if (exact.length >= _shown) return exact.take(_shown).toList();
    final related = _nearestFirst(await relatedSearch);
    if (failures.length == search.exact.length + search.related.length) {
      throw failures.first;
    }
    return _distinct([...exact, ...related]).take(_shown).toList();
  }

  // The same shop is often mapped twice (a point and its building), or
  // found by two words.
  static List<NearbyShop> _distinct(List<NearbyShop> shops) {
    final seen = <String>{};
    return shops.where((s) => seen.add(s.name.trim().toLowerCase())).toList();
  }

  Future<SiteLocation> _centre(SiteLocation home, String? area) async {
    final name = area?.trim() ?? '';
    if (name.isEmpty) return home;
    final known = _areas[name.toLowerCase()];
    if (known != null) return known;
    final response = await _dio.get<Map<String, dynamic>>(
      _geocodeUrl,
      queryParameters: {
        'text': name,
        'filter': 'circle:${home.lon},${home.lat},$_cityRadiusMeters',
        'bias': 'proximity:${home.lon},${home.lat}',
        'limit': 1,
        'format': 'json',
        'apiKey': apiKey,
      },
    );
    final found = switch (response.data?['results']) {
      [{'lat': final num lat, 'lon': final num lon}, ...] => SiteLocation(
        lat: lat.toDouble(),
        lon: lon.toDouble(),
      ),
      // Not on the map: the home point is the next best centre.
      _ => home,
    };
    return _areas[name.toLowerCase()] = found;
  }

  static List<NearbyShop> _nearestFirst(Iterable<List<NearbyShop>> perWord) =>
      perWord.expand((s) => s).toList()
        ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

  Future<List<NearbyShop>> _search(_Word word, SiteLocation near) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _placesUrl,
      queryParameters: {
        'categories': 'commercial',
        'name': word.query,
        'filter': 'circle:${near.lon},${near.lat},$_radiusMeters',
        'bias': 'proximity:${near.lon},${near.lat}',
        'limit': _perWord,
        'apiKey': apiKey,
      },
    );
    final features =
        response.data?['features'] as List? ??
        (throw const FormatException('Empty Geoapify response'));
    return [
      for (final feature in features.cast<Map<String, dynamic>>())
        if (feature['properties']
            case {
                  'name': final String name,
                  'lat': final num lat,
                  'lon': final num lon,
                } &&
                final p
            when word.pattern.hasMatch(name))
          NearbyShop(
            name: name,
            address: p['address_line2'] as String? ?? '',
            site: SiteLocation(lat: lat.toDouble(), lon: lon.toDouble()),
            distanceMeters: (p['distance'] as num? ?? 0).toDouble(),
          ),
    ];
  }

  // Pakistani battery and solar shops are tagged loosely on the map (a
  // generic shop, car repair, electronics...), so categories miss most of
  // them; searching shop names finds them (checked live, October 2026).
  // Geoapify matches any part of a name ("ups" finds "Groups"), so each
  // word also has a pattern that must match on its own.
  static final _batt = _Word('batt', RegExp(r'\bbatt', caseSensitive: false));
  static final _ups = _Word('ups', RegExp(r'\bups\b', caseSensitive: false));
  static final _inverter = _Word(
    'inverter',
    RegExp(r'\binverter', caseSensitive: false),
  );
  static final _stabiliser = _Word(
    'stabili',
    RegExp(r'\bstabili', caseSensitive: false),
  );
  static final _solar = _Word(
    'solar',
    RegExp(r'\bsolar', caseSensitive: false),
  );

  // Where few shops are mapped (most of Lahore), related dealers fill the
  // list after the exact matches: solar, UPS and inverter shops in
  // Pakistan also sell and repair batteries.
  static final _searches = {
    ShopKind.battery: _Search(
      exact: [_batt],
      related: [_ups, _inverter, _solar],
    ),
    ShopKind.upsRepair: _Search(
      exact: [_ups, _inverter, _stabiliser],
      related: [_batt, _solar],
    ),
    ShopKind.solarInstaller: _Search(exact: [_solar], related: [_inverter]),
  };
}

class _Search {
  const _Search({required this.exact, required this.related});

  final List<_Word> exact;
  final List<_Word> related;
}

class _Word {
  const _Word(this.query, this.pattern);

  /// Sent to Geoapify's name filter.
  final String query;

  /// What the name must really contain.
  final RegExp pattern;
}
