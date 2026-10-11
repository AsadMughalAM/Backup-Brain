import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Where live prices can be looked up: real listings, no scraping, no key.
enum PriceSite { google, daraz, olx }

/// Opens things outside the app. Behind a provider so tests can record
/// what would have opened.
abstract interface class ExternalLinks {
  /// Google Maps (app or browser) searching for [query]. No API key: the
  /// Maps URL scheme is public (F7, instead of the Places API).
  Future<bool> openMapsSearch(String query);

  /// Today's listings for [query] on [site]. Sellers' asking prices, shown
  /// by the site itself; the app never reads or computes with them.
  Future<bool> openPriceSearch(PriceSite site, String query);
}

class UrlLauncherLinks implements ExternalLinks {
  const UrlLauncherLinks();

  @override
  Future<bool> openMapsSearch(String query) => _open(
    Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query}),
  );

  @override
  Future<bool> openPriceSearch(PriceSite site, String query) => _open(
    switch (site) {
      PriceSite.google => Uri.https('www.google.com', '/search', {'q': query}),
      PriceSite.daraz => Uri.https('www.daraz.pk', '/catalog/', {'q': query}),
      // OLX takes the search as a path segment with hyphens for spaces.
      PriceSite.olx => Uri.https(
        'www.olx.com.pk',
        '/items/q-${query.trim().replaceAll(RegExp(r'\s+'), '-')}',
      ),
    },
  );

  static Future<bool> _open(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}

final externalLinksProvider = Provider<ExternalLinks>(
  (ref) => const UrlLauncherLinks(),
);
