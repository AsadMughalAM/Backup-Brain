import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the user needs a shop for (F7 "find help nearby").
enum ShopKind { battery, upsRepair, solarInstaller }

/// One real place from the map, nearest first.
class NearbyShop {
  const NearbyShop({
    required this.name,
    required this.address,
    required this.site,
    required this.distanceMeters,
  });

  final String name;

  /// Street and area; may be empty when the map has no address.
  final String address;
  final SiteLocation site;
  final double distanceMeters;
}

abstract interface class NearbyShopsRepository {
  /// Shops near [area] (a neighbourhood of the home city, e.g. "Johar
  /// Town") when given, else near [home]. Needs internet; throws when
  /// offline or the service fails.
  Future<List<NearbyShop>> find(
    ShopKind kind,
    SiteLocation home, {
    String? area,
  });
}

/// Bound in `app/app_providers.dart`. Null when the build has no map key:
/// the screen then offers only the Google Maps search link.
final nearbyShopsRepositoryProvider = Provider<NearbyShopsRepository?>(
  (ref) => null,
);

/// What to search: a record, so equal searches share one cached result.
typedef ShopQuery = ({ShopKind kind, double lat, double lon, String? area});

/// Kept for the session, so reopening the screen costs no request. No
/// automatic retry: offline, the user gets "Try again" and the Maps link.
final nearbyShopsProvider = FutureProvider.family<List<NearbyShop>, ShopQuery>((
  ref,
  query,
) {
  final repository = ref.watch(nearbyShopsRepositoryProvider);
  if (repository == null) return const [];
  return repository.find(
    query.kind,
    SiteLocation(lat: query.lat, lon: query.lon),
    area: query.area,
  );
}, retry: (_, _) => null);
