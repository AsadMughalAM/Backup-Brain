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

  /// The AI service is rate-limiting; try again in a minute.
  busy,
  unavailable,

  /// This user's assistant messages for today are used up.
  dailyLimit,

  /// No Gemini key in this build and no deployed `assistantChat` function.
  notConfigured,

  /// Gemini rejected the API key (wrong, revoked or restricted).
  badKey,

  /// Gemini doesn't know the model name in `GEMINI_MODEL`.
  badModel,
}

class AssistantFailure implements Exception {
  const AssistantFailure(this.code, {this.detail});

  final AssistantFailureCode code;

  /// The raw cause (HTTP status, server message), for logs and debug builds
  /// only; users see the localized text for [code].
  final String? detail;

  @override
  String toString() =>
      'AssistantFailure($code${detail == null ? '' : ': $detail'})';
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

/// Bound in `app/app_providers.dart`: Gemini directly when a key was
/// passed at build time (MVP), else the `assistantChat` Cloud Function. See
/// `app/app_providers.dart`.
final assistantRepositoryProvider = Provider<AssistantRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);
