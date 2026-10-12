import 'package:dio/dio.dart';
import 'package:energy_engine/energy_engine.dart';

/// The names of a point (city, area, country) from Geoapify's reverse
/// geocoding, on the same key and free tier as F7's shop search
/// (docs/decisions/0003): one credit per lookup, once per setup.
class GeoapifyPlaceNames {
  GeoapifyPlaceNames(this._dio, {required this.apiKey});

  final Dio _dio;
  final String apiKey;

  static const _url = 'https://api.geoapify.com/v1/geocode/reverse';

  Future<({String? city, String? area, String? country})> lookUp(
    SiteLocation site,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _url,
      queryParameters: {
        'lat': site.lat,
        'lon': site.lon,
        'format': 'json',
        'lang': 'en',
        'apiKey': apiKey,
      },
    );
    final results =
        response.data?['results'] as List? ??
        (throw const FormatException('Empty Geoapify response'));
    if (results.isEmpty) return (city: null, area: null, country: null);
    final p = results.first as Map<String, dynamic>;
    String? field(List<String> keys) {
      for (final k in keys) {
        if (p[k] case final String v when v.trim().isNotEmpty) return v.trim();
      }
      return null;
    }

    // Pakistani addresses are mapped unevenly: a town may only be a county,
    // a neighbourhood only a district.
    return (
      city: field(['city', 'town', 'village', 'county']),
      area: field(['suburb', 'district', 'neighbourhood', 'quarter']),
      country: field(['country']),
    );
  }
}
