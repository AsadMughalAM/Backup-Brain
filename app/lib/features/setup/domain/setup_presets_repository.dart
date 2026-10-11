import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entities/setup_presets.dart';

abstract interface class SetupPresetsRepository {
  /// Bundled with the app, so setup works offline.
  Future<SetupPresets> load();
}

/// Bound to the asset implementation in `app/app_providers.dart`.
final setupPresetsRepositoryProvider = Provider<SetupPresetsRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);
