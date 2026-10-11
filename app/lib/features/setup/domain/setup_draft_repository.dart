import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entities/setup_draft.dart';

/// Setup answers kept on the phone until they belong to an account: people
/// can leave mid-setup and continue later, signed in or not.
abstract interface class SetupDraftRepository {
  /// Null when nothing is saved, or the saved copy can't be read anymore.
  SetupDraft? load();

  /// Not awaited by callers: the local write is near-instant.
  Future<void> save(SetupDraft draft);

  Future<void> clear();
}

/// Bound to the on-device implementation in `app/app_providers.dart`.
final setupDraftRepositoryProvider = Provider<SetupDraftRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);
