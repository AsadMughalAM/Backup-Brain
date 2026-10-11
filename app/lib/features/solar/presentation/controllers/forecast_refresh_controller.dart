import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/clock.dart';
import '../../../backup/domain/system_repository.dart';
import '../../domain/weather_repository.dart';

enum ForecastRefresh { idle, fetching, failed }

/// Keeps the saved forecast fresh. The screen never waits on it: the saved
/// forecast stays visible while this runs (DESIGN.md §8.1 "Refreshing").
class ForecastRefreshController extends Notifier<ForecastRefresh> {
  @override
  ForecastRefresh build() => ForecastRefresh.idle;

  /// Fetches when the saved forecast is missing, older than an hour or for
  /// another place; [force] always fetches (the user tapped refresh).
  Future<void> refresh({bool force = false}) async {
    if (state == ForecastRefresh.fetching) return;
    state = ForecastRefresh.fetching;
    try {
      final system = await ref.read(householdSystemProvider.future);
      // It runs from app start too: the session may be gone by now.
      if (!ref.mounted) return;
      final site = system?.location?.site;
      if (site == null) {
        state = ForecastRefresh.idle;
        return;
      }
      // Wait for the offline cache's first answer, so opening the tab with
      // a fresh saved forecast doesn't trigger a fetch.
      final saved = await ref.read(latestForecastProvider.future);
      if (!ref.mounted) return;
      final now = await ref.read(nowProvider.future);
      if (!ref.mounted) return;
      if (!force && saved != null && saved.isFreshFor(site, now)) {
        state = ForecastRefresh.idle;
        return;
      }
      await ref.read(weatherRepositoryProvider).refresh(site);
      if (ref.mounted) state = ForecastRefresh.idle;
    } catch (e) {
      debugPrint('Forecast refresh failed: $e');
      if (ref.mounted) state = ForecastRefresh.failed;
    }
  }
}

final forecastRefreshProvider =
    NotifierProvider<ForecastRefreshController, ForecastRefresh>(
      ForecastRefreshController.new,
    );
