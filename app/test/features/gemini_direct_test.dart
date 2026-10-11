import 'dart:convert';
import 'dart:typed_data';

import 'package:backup_brain/features/assistant/data/assistant_prompt.dart';
import 'package:backup_brain/features/assistant/data/gemini_direct_assistant_repository.dart';
import 'package:backup_brain/features/assistant/domain/assistant_repository.dart';
import 'package:backup_brain/features/assistant/domain/energy_snapshot.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers every request with [status] and [body], and remembers the last
/// request. A null [status] fails like a dropped connection.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, this.body);

  final int? status;
  final Object body;
  RequestOptions? last;
  Object? lastData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    lastData = options.data;
    final code = status;
    if (code == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      code,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _snapshot = EnergySnapshot(
  facts: {
    'now': {'backupTimeLeft': '3h 28m'},
  },
  backupHours: 3.47,
  loadW: 420,
);

const _question = [ChatTurn(ChatRole.user, 'Kitni der chalegi battery?')];

Future<(GeminiDirectAssistantRepository, _FakeAdapter)> _repo(
  int? status,
  Object body,
) async {
  SharedPreferences.setMockInitialValues({});
  final adapter = _FakeAdapter(status, body);
  final dio = Dio()..httpClientAdapter = adapter;
  return (
    GeminiDirectAssistantRepository(
      dio,
      await SharedPreferences.getInstance(),
      apiKey: 'test-key',
    ),
    adapter,
  );
}

Map<String, Object> _answer(String text) => {
  'candidates': [
    {
      'content': {
        'parts': [
          {'text': text},
        ],
      },
    },
  ],
};

void main() {
  test(
    'sends the key as a header and the snapshot in the system prompt',
    () async {
      final (repo, http) = await _repo(
        200,
        _answer('**Aap ki** battery 3h 28m chalegi.'),
      );
      final reply = await repo.reply(
        history: _question,
        snapshot: _snapshot,
        language: ReplyLanguage.romanUrdu,
      );
      expect(reply, 'Aap ki battery 3h 28m chalegi.');
      expect(http.last!.headers['x-goog-api-key'], 'test-key');
      expect(http.last!.uri.toString(), isNot(contains('test-key')));
      final sent = jsonEncode(http.lastData);
      expect(sent, contains('3h 28m'));
      expect(sent, contains('Kitni der chalegi battery?'));
    },
  );

  test(
    'rate limit, bad key and no connection map to the right failure',
    () async {
      for (final (status, code) in [
        (429, AssistantFailureCode.busy),
        (400, AssistantFailureCode.unavailable),
        (null, AssistantFailureCode.offline),
      ]) {
        final (repo, _) = await _repo(status, {'error': 'x'});
        await expectLater(
          repo.reply(
            history: _question,
            snapshot: _snapshot,
            language: ReplyLanguage.english,
          ),
          throwsA(isA<AssistantFailure>().having((f) => f.code, 'code', code)),
        );
      }
    },
  );

  test('stops after the daily limit on this phone', () async {
    final (repo, _) = await _repo(200, _answer('ok'));
    for (var i = 0; i < GeminiDirectAssistantRepository.dailyLimit; i++) {
      await repo.reply(
        history: _question,
        snapshot: _snapshot,
        language: ReplyLanguage.english,
      );
    }
    await expectLater(
      repo.reply(
        history: _question,
        snapshot: _snapshot,
        language: ReplyLanguage.english,
      ),
      throwsA(
        isA<AssistantFailure>().having(
          (f) => f.code,
          'code',
          AssistantFailureCode.dailyLimit,
        ),
      ),
    );
  });

  test('the prompt forbids new numbers and carries the snapshot', () {
    final prompt = buildSystemPrompt(_snapshot, ReplyLanguage.romanUrdu);
    expect(prompt, contains('Never calculate'));
    expect(prompt, contains('"backupTimeLeft": "3h 28m"'));
    expect(prompt, contains('Roman Urdu'));
  });
}
