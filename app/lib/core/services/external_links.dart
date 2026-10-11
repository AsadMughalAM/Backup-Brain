import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens things outside the app. Behind a provider so tests can record
/// what would have opened.
abstract interface class ExternalLinks {
  /// Google Maps (app or browser) searching for [query]. No API key: the
  /// Maps URL scheme is public (F7, instead of the Places API).
  Future<bool> openMapsSearch(String query);
}

class UrlLauncherLinks implements ExternalLinks {
  const UrlLauncherLinks();

  @override
  Future<bool> openMapsSearch(String query) => launchUrl(
    Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query}),
    mode: LaunchMode.externalApplication,
  );
}

final externalLinksProvider = Provider<ExternalLinks>(
  (ref) => const UrlLauncherLinks(),
);
