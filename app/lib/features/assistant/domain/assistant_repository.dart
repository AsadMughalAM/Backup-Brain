import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'energy_snapshot.dart';

enum ChatRole { user, assistant }

class ChatTurn {
  const ChatTurn(this.role, this.text);

  final ChatRole role;
  final String text;
}

enum ReplyLanguage { english, romanUrdu }

enum AssistantFailureCode {
  offline,
  unavailable,

  /// This user's assistant messages for today are used up.
  dailyLimit,
}

class AssistantFailure implements Exception {
  const AssistantFailure(this.code);

  final AssistantFailureCode code;

  @override
  String toString() => 'AssistantFailure($code)';
}

abstract interface class AssistantRepository {
  /// The model's answer to the last user turn in [history], explaining
  /// [snapshot] only. Throws [AssistantFailure].
  Future<String> reply({
    required List<ChatTurn> history,
    required EnergySnapshot snapshot,
    required ReplyLanguage language,
  });
}

/// Bound to the `assistantChat` Cloud Function in
/// `app/app_providers.dart`.
final assistantRepositoryProvider = Provider<AssistantRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);
