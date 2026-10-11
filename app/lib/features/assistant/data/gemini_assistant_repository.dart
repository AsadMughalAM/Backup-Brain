import 'package:firebase_ai/firebase_ai.dart';

import '../domain/assistant_repository.dart';
import '../domain/energy_snapshot.dart';
import 'assistant_prompt.dart';

/// Gemini through Firebase AI Logic: Firebase keeps the API key on its
/// server, so the app ships no secret (golden rule 9).
class GeminiAssistantRepository implements AssistantRepository {
  GeminiAssistantRepository(this._ai);

  final FirebaseAI _ai;

  static const _model = 'gemini-3.1-flash-lite';
  static const _timeout = Duration(seconds: 30);

  /// Older turns add cost but rarely change the answer.
  static const _maxTurns = 12;

  @override
  Future<String> reply({
    required List<ChatTurn> history,
    required EnergySnapshot snapshot,
    required ReplyLanguage language,
  }) async {
    // A fresh model per message: the system prompt carries the newest
    // snapshot, which changes as soon as an appliance is switched.
    final model = _ai.generativeModel(
      model: _model,
      systemInstruction: Content.system(buildSystemPrompt(snapshot, language)),
      generationConfig: GenerationConfig(temperature: 0.2),
    );
    final turns = history.length > _maxTurns
        ? history.sublist(history.length - _maxTurns)
        : history;
    try {
      final response = await model
          .generateContent([
            for (final t in turns)
              t.role == ChatRole.user
                  ? Content.text(t.text)
                  : Content.model([TextPart(t.text)]),
          ])
          .timeout(_timeout);
      final text = response.text?.replaceAll('**', '').trim();
      if (text == null || text.isEmpty) {
        throw const AssistantFailure(AssistantFailureCode.unavailable);
      }
      return text;
    } on AssistantFailure {
      rethrow;
    } on QuotaExceeded {
      throw const AssistantFailure(AssistantFailureCode.busy);
    } on FirebaseAIException {
      throw const AssistantFailure(AssistantFailureCode.unavailable);
    } on FirebaseAISdkException {
      throw const AssistantFailure(AssistantFailureCode.unavailable);
    } on Exception {
      // Timeouts and socket / XHR errors: almost always the connection.
      throw const AssistantFailure(AssistantFailureCode.offline);
    }
  }
}
