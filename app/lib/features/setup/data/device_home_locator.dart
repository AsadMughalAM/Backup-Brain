import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/home_locator.dart';
import 'geoapify_place_names.dart';

/// The phone's location through `geolocator`, at low accuracy: a city and
/// area need no more, and coarse location is the gentler permission. Names
/// come from [placeNames] when there is a key and a connection; without
/// them the point alone still picks the nearest listed city.
class DeviceHomeLocator implements HomeLocator {
  DeviceHomeLocator({this.placeNames});

  final GeoapifyPlaceNames? placeNames;

  static const _timeLimit = Duration(seconds: 20);

  @override
  Future<FoundPlace> locate() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocateException(LocateFailure.off);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
        throw const LocateException(LocateFailure.denied);
      case LocationPermission.deniedForever:
        throw const LocateException(LocateFailure.blocked);
      case LocationPermission.unableToDetermine:
        throw const LocateException(LocateFailure.unavailable);
      case LocationPermission.whileInUse || LocationPermission.always:
        break;
    }
    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: _timeLimit,
        ),
      );
    } catch (e) {
      debugPrint('No location fix: $e');
      throw const LocateException(LocateFailure.unavailable);
    }
    final site = SiteLocation(lat: position.latitude, lon: position.longitude);
    final names = placeNames;
    if (names == null) return FoundPlace(site: site);
    try {
      final found = await names.lookUp(site);
      return FoundPlace(
        site: site,
        city: found.city,
        area: found.area,
        country: found.country,
      );
    } catch (e) {
      // Offline or the lookup failed: the point is still good.
      debugPrint('Place names lookup failed: $e');
      return FoundPlace(site: site);
    }
  }

  @override
  Future<void> openSettings(LocateFailure failure) async {
    final opened = failure == LocateFailure.off
        ? await Geolocator.openLocationSettings()
        : await Geolocator.openAppSettings();
    if (!opened) debugPrint('Could not open settings for $failure');
  }
}
