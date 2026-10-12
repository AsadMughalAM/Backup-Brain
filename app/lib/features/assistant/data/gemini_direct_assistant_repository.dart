import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/assistant_repository.dart';
import '../domain/energy_snapshot.dart';
import 'assistant_prompt.dart';

/// MVP path (docs/decisions/0002): the app calls the Gemini API itself with
/// a key passed at build time (`--dart-define-from-file=env.json`). The key
/// is in the build, so it is not secret — use a key from a Google project
/// without billing, restricted to the Generative Language API. Replace with
/// the `assistantChat` Cloud Function before a public release.
class GeminiDirectAssistantRepository implements AssistantRepository {
  GeminiDirectAssistantRepository(
    this._dio,
    this._prefs, {
    required this.apiKey,
  });

  final Dio _dio;
  final SharedPreferences _prefs;
  final String apiKey;

  static const model = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-3.1-flash-lite',
  );

  /// Messages per phone per day, so one phone can't use up the key's free
  /// quota for everyone. The server-side limit replaces it on Blaze.
  static const dailyLimit = 50;
  static const _usageKey = 'assistantUsage';
  static const _maxTurns = 12;

  @override
  Future<String> reply({
    required List<ChatTurn> history,
    required EnergySnapshot snapshot,
    required ReplyLanguage language,
  }) async {
    if (!_takeOneFromToday()) {
      throw const AssistantFailure(AssistantFailureCode.dailyLimit);
    }
    final turns = history.length > _maxTurns
        ? history.sublist(history.length - _maxTurns)
        : history;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$model:generateContent',
        options: Options(headers: {'x-goog-api-key': apiKey}),
        data: {
          'systemInstruction': {
            'parts': [
              {'text': buildSystemPrompt(snapshot, language)},
            ],
          },
          'contents': [
            for (final t in turns)
              {
                'role': t.role == ChatRole.user ? 'user' : 'model',
                'parts': [
                  {'text': t.text},
                ],
              },
          ],
          'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 600},
        },
      );
      final reply = _text(response.data)?.replaceAll('**', '').trim();
      if (reply == null || reply.isEmpty) {
        throw AssistantFailure(
          AssistantFailureCode.unavailable,
          detail: 'Gemini $model sent no text (${_whyEmpty(response.data)})',
        );
      }
      return reply;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = _errorMessage(e.response?.data);
      final detail = status == null
          ? 'Gemini $model unreachable: ${e.type.name} ${e.message ?? ''}'
          : 'Gemini $model HTTP $status: $message';
      throw AssistantFailure(switch (status) {
        null => AssistantFailureCode.offline,
        429 => AssistantFailureCode.busy,
        401 || 403 => AssistantFailureCode.badKey,
        // Google answers an invalid key with 400, not 401.
        400 when message.contains('API key') => AssistantFailureCode.badKey,
        404 => AssistantFailureCode.badModel,
        _ => AssistantFailureCode.unavailable,
      }, detail: detail);
    }
  }

  /// Google's `{error: {status, message}}` body, or whatever came back.
  static String _errorMessage(Object? body) {
    if (body case {'error': {'message': final String message}}) {
      final status = (body['error'] as Map)['status'];
      return status == null ? message : '$status $message';
    }
    return '$body';
  }

  /// A blocked prompt or a cut-off answer explains an empty reply.
  static String _whyEmpty(Map<String, dynamic>? data) {
    final blocked = (data?['promptFeedback'] as Map?)?['blockReason'];
    if (blocked != null) return 'prompt blocked: $blocked';
    final candidates = data?['candidates'] as List?;
    final finish = (candidates?.firstOrNull as Map?)?['finishReason'];
    return 'finishReason: ${finish ?? 'none'}';
  }

  static String? _text(Map<String, dynamic>? data) {
    final candidates = data?['candidates'] as List?;
    final content = (candidates?.firstOrNull as Map?)?['content'] as Map?;
    final parts = content?['parts'] as List?;
    if (parts == null) return null;
    return [
      for (final p in parts)
        if ((p as Map)['text'] case final String text) text,
    ].join();
  }

  /// Counts this message against today's local limit; false when used up.
  bool _takeOneFromToday() {
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    final saved = _prefs.getString(_usageKey)?.split('|');
    final count = saved != null && saved.first == today
        ? int.tryParse(saved.last) ?? 0
        : 0;
    if (count >= dailyLimit) return false;
    _prefs.setString(_usageKey, '$today|${count + 1}');
    return true;
  }
}
