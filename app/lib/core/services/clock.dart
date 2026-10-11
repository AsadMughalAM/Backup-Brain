import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time (UTC), re-emitted every minute so time-based answers
/// ("full by 1 PM", "the sun has set") stay right while a screen is open.
/// Tests override it with a fixed time.
final nowProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now().toUtc();
  yield* Stream.periodic(
    const Duration(minutes: 1),
    (_) => DateTime.now().toUtc(),
  );
});
