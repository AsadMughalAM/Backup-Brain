import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the phone is, with the names of the place when they could be
/// looked up (that needs internet; the point itself does not).
class FoundPlace {
  const FoundPlace({required this.site, this.city, this.area, this.country});

  final SiteLocation site;
  final String? city;
  final String? area;
  final String? country;
}

enum LocateFailure {
  /// The user said no this time; asking again may work.
  denied,

  /// Said no for good: only the phone's settings can change it.
  blocked,

  /// Location is switched off on the phone.
  off,

  /// No fix in time, or the platform can't tell.
  unavailable,
}

class LocateException implements Exception {
  const LocateException(this.failure);

  final LocateFailure failure;

  @override
  String toString() => 'LocateException($failure)';
}

/// "Use my location" in setup. Asks for permission only when the user
/// taps it, after the screen has said why.
abstract interface class HomeLocator {
  /// Throws [LocateException].
  Future<FoundPlace> locate();

  /// For [LocateFailure.blocked] and [LocateFailure.off].
  Future<void> openSettings(LocateFailure failure);
}

/// Bound in `app/app_providers.dart`; tests pass a fake.
final homeLocatorProvider = Provider<HomeLocator>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);
