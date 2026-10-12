import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/locale/locale_controller.dart';
import '../../domain/assistant_repository.dart';
import '../../domain/energy_snapshot.dart';

enum ChatEntryKind {
  user,
  assistant,

  /// Fixed safety text, never generated (TECH_STACK §7.6.3).
  safety,

  /// The AI couldn't answer: template text from the snapshot instead.
  fallback,

  /// No household yet, so there are no numbers to explain.
  noData,
}

class ChatEntry {
  const ChatEntry(this.kind, {this.text = '', this.failure});

  final ChatEntryKind kind;
  final String text;
  final AssistantFailure? failure;
}

class ChatState {
  const ChatState({this.entries = const [], this.waiting = false});

  final List<ChatEntry> entries;
  final bool waiting;

  ChatState copyWith({List<ChatEntry>? entries, bool? waiting}) => ChatState(
    entries: entries ?? this.entries,
    waiting: waiting ?? this.waiting,
  );
}

/// The conversation lives in memory only: it is gone after a restart, which
/// is fine while chats are not stored (TECH_STACK §4, `chats` is P1).
class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  // Swollen, smell, smoke, burning or a hot battery, in English or Roman
  // Urdu. Word starts only, so "heater" or "garmi" don't trigger it.
  static final _danger = RegExp(
    r'\b(swell\w*|swollen|bulg\w*|smell\w*|smok\w*|burn\w*|overheat\w*|hot|'
    r'phool\w*|phul\w*|boo|badboo|dhu[a]?[a]?n\w*|garam|jal (raha|rahi|gaya|gayi))\b',
    caseSensitive: false,
  );

  Future<void> send(String text) async {
    final question = text.trim();
    if (question.isEmpty || state.waiting) return;
    _add(ChatEntry(ChatEntryKind.user, text: question));

    if (_danger.hasMatch(question)) {
      _add(const ChatEntry(ChatEntryKind.safety));
      return;
    }
    final snapshot = ref.read(energySnapshotProvider);
    if (snapshot == null) {
      _add(const ChatEntry(ChatEntryKind.noData));
      return;
    }
    await _ask(snapshot);
  }

  /// Asks again after a failed answer, without repeating the question.
  Future<void> retry() async {
    final snapshot = ref.read(energySnapshotProvider);
    final last = state.entries.lastOrNull;
    if (state.waiting ||
        snapshot == null ||
        last?.kind != ChatEntryKind.fallback) {
      return;
    }
    state = state.copyWith(
      entries: state.entries.sublist(0, state.entries.length - 1),
    );
    await _ask(snapshot);
  }

  Future<void> _ask(EnergySnapshot snapshot) async {
    state = state.copyWith(waiting: true);
    ChatEntry answer;
    try {
      final reply = await ref
          .read(assistantRepositoryProvider)
          .reply(
            history: _history(),
            snapshot: snapshot,
            language: switch (ref.read(localeProvider)) {
              AppLanguage.english => ReplyLanguage.english,
              AppLanguage.romanUrdu => ReplyLanguage.romanUrdu,
            },
          );
      answer = ChatEntry(ChatEntryKind.assistant, text: reply);
    } on AssistantFailure catch (e) {
      log('$e', name: 'assistant');
      answer = ChatEntry(ChatEntryKind.fallback, failure: e);
    } catch (e, stack) {
      // A bug (say, an unexpected response shape) must not leave the chat
      // stuck on "typing": show the numbers and log the cause.
      log(
        'Unexpected assistant error',
        name: 'assistant',
        error: e,
        stackTrace: stack,
      );
      answer = ChatEntry(
        ChatEntryKind.fallback,
        failure: AssistantFailure(
          AssistantFailureCode.unavailable,
          detail: '$e',
        ),
      );
    }
    if (!ref.mounted) return;
    state = ChatState(entries: [...state.entries, answer]);
  }

  /// Only real questions and answers; template and safety text stay local.
  List<ChatTurn> _history() => [
    for (final e in state.entries)
      if (e.kind == ChatEntryKind.user)
        ChatTurn(ChatRole.user, e.text)
      else if (e.kind == ChatEntryKind.assistant)
        ChatTurn(ChatRole.assistant, e.text),
  ];

  void _add(ChatEntry entry) =>
      state = state.copyWith(entries: [...state.entries, entry]);
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);
