import 'dart:async';

import 'package:flutter/foundation.dart';

/// Starts a write without awaiting it. Firestore applies writes to the local
/// cache immediately and syncs when back online, so the UI must not wait on
/// the network (TECH_STACK.md §7.2 rule 4). Failures are still logged.
void fireAndForget(Future<void> write, String what) {
  unawaited(
    write.catchError((Object e, StackTrace s) {
      debugPrint('Write failed ($what): $e');
    }),
  );
}
