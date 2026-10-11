import 'package:cloud_functions/cloud_functions.dart';

import '../domain/assistant_repository.dart';
import '../domain/energy_snapshot.dart';

/// The `assistantChat` Cloud Function (TECH_STACK §3.2). The Gemini key stays
/// in Secret Manager; the app only sends the question and the snapshot.
class CallableAssistantRepository implements AssistantRepository {
  CallableAssistantRepository(this._functions);

  final FirebaseFunctions _functions;

  static const _timeout = Duration(seconds: 45);

  /// Older turns add cost but rarely change the answer; the function rejects
  /// more than this.
  static const _maxTurns = 12;

  @override
  Future<String> reply({
    required List<ChatTurn> history,
    required EnergySnapshot snapshot,
    required ReplyLanguage language,
  }) async {
    final turns = history.length > _maxTurns
        ? history.sublist(history.length - _maxTurns)
        : history;
    try {
      final result = await _functions
          .httpsCallable(
            'assistantChat',
            options: HttpsCallableOptions(timeout: _timeout),
          )
          .call<Map<String, dynamic>>({
            'messages': [
              for (final t in turns) {'role': t.role.name, 'text': t.text},
            ],
            'snapshot': snapshot.facts,
            'language': switch (language) {
              ReplyLanguage.english => 'en',
              ReplyLanguage.romanUrdu => 'ur_Latn',
            },
          });
      final reply = (result.data['reply'] as String?)?.trim();
      if (reply == null || reply.isEmpty) {
        throw const AssistantFailure(AssistantFailureCode.unavailable);
      }
      return reply;
    } on FirebaseFunctionsException catch (e) {
      throw AssistantFailure(switch (e.code) {
        'resource-exhausted' => AssistantFailureCode.dailyLimit,
        // The SDK reports a dropped or missing connection as these.
        'unavailable' || 'deadline-exceeded' => AssistantFailureCode.offline,
        _ => AssistantFailureCode.unavailable,
      });
    } on AssistantFailure {
      rethrow;
    } on Exception {
      throw const AssistantFailure(AssistantFailureCode.offline);
    }
  }
}
