import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/fire_and_forget.dart';
import 'clock.dart';
import 'preferences.dart';

enum InboxKind {
  /// F8's heads-up before a predicted outage.
  outageAlert,

  /// "Power gone?" after a scheduled or usual cut.
  cutCheck,

  /// "Power back?" after a cut should have ended.
  backCheck,
}

/// A phone notification as the app keeps it for the in-app list: the
/// system tray forgets a notification once swiped away; this doesn't.
class InboxEntry {
  const InboxEntry({
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
  });

  final InboxKind kind;

  /// When the phone shows (or showed) it, UTC.
  final DateTime at;
  final String title;
  final String body;

  Map<String, Object> toJson() => {
    'kind': kind.name,
    'at': at.toUtc().toIso8601String(),
    'title': title,
    'body': body,
  };

  static InboxEntry fromJson(Map<String, dynamic> m) => InboxEntry(
    kind:
        InboxKind.values.asNameMap()[m['kind']] ??
        (throw FormatException('Unknown inbox kind: ${m['kind']}')),
    at: DateTime.parse(m['at'] as String),
    title: m['title'] as String,
    body: m['body'] as String,
  );
}

class InboxState {
  const InboxState({required this.entries, this.seenAt});

  /// Oldest first.
  final List<InboxEntry> entries;

  /// When the user last opened the list; later ones are new.
  final DateTime? seenAt;
}

/// Every notification the app sets on the phone is also planned here
/// (where it is scheduled, so this works where the phone can't post them,
/// like the web preview). A planned one counts as shown once its time has
/// passed; replanning drops only the ones still to come. Kept on the phone:
/// it is about this phone's notifications, and must work offline.
class NotificationInbox extends Notifier<InboxState> {
  static const _entriesKey = 'notificationInbox';
  static const _seenKey = 'notificationInbox.seenAt';

  /// Enough to look back over a week of load-shedding.
  static const _keep = Duration(days: 14);
  static const _maxEntries = 60;

  @override
  InboxState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return InboxState(
      entries: _read(prefs.getString(_entriesKey)),
      seenAt: DateTime.tryParse(prefs.getString(_seenKey) ?? ''),
    );
  }

  static List<InboxEntry> _read(String? raw) {
    if (raw == null) return const [];
    try {
      return [
        for (final e in (json.decode(raw) as List).cast<Map<String, dynamic>>())
          InboxEntry.fromJson(e),
      ];
    } catch (e) {
      // An older format: start the list again rather than crash.
      debugPrint('Notification inbox unreadable, starting fresh: $e');
      return const [];
    }
  }

  /// Replaces the still-to-come entries of [kinds] with [planned].
  void plan(Set<InboxKind> kinds, List<InboxEntry> planned, DateTime now) {
    final kept = [
      for (final e in state.entries)
        if (!(kinds.contains(e.kind) && e.at.isAfter(now)) &&
            now.difference(e.at) < _keep)
          e,
    ];
    final entries = [
      ...kept,
      for (final e in planned)
        if (e.at.isAfter(now)) e,
    ]..sort((a, b) => a.at.compareTo(b.at));
    final trimmed = entries.length > _maxEntries
        ? entries.sublist(entries.length - _maxEntries)
        : entries;
    state = InboxState(entries: trimmed, seenAt: state.seenAt);
    fireAndForget(
      ref
          .read(sharedPreferencesProvider)
          .setString(
            _entriesKey,
            json.encode([for (final e in trimmed) e.toJson()]),
          ),
      'notification inbox',
    );
  }

  void markSeen(DateTime now) {
    state = InboxState(entries: state.entries, seenAt: now);
    fireAndForget(
      ref
          .read(sharedPreferencesProvider)
          .setString(_seenKey, now.toUtc().toIso8601String()),
      'notification inbox seen',
    );
  }
}

final notificationInboxProvider =
    NotifierProvider<NotificationInbox, InboxState>(NotificationInbox.new);

/// [NotificationInbox.plan] from a provider that is still building or
/// reacting (Riverpod forbids changing another provider there): done right
/// after, unless [ref] has been disposed by then.
void planInbox(
  Ref ref,
  Set<InboxKind> kinds,
  List<InboxEntry> planned,
  DateTime now,
) => scheduleMicrotask(() {
  if (!ref.mounted) return;
  ref.read(notificationInboxProvider.notifier).plan(kinds, planned, now);
});

DateTime _now(Ref ref) =>
    ref.watch(nowProvider).value ?? DateTime.now().toUtc();

/// Shown already, newest first.
final shownNotificationsProvider = Provider<List<InboxEntry>>((ref) {
  final now = _now(ref);
  return [
    for (final e in ref.watch(notificationInboxProvider).entries.reversed)
      if (!e.at.isAfter(now)) e,
  ];
});

/// Set on the phone but not shown yet, soonest first.
final upcomingNotificationsProvider = Provider<List<InboxEntry>>((ref) {
  final now = _now(ref);
  return [
    for (final e in ref.watch(notificationInboxProvider).entries)
      if (e.at.isAfter(now)) e,
  ];
});

/// Shown since the list was last opened: the bell's badge.
final unreadNotificationsProvider = Provider<int>((ref) {
  final seenAt = ref.watch(notificationInboxProvider).seenAt;
  return ref
      .watch(shownNotificationsProvider)
      .where((e) => seenAt == null || e.at.isAfter(seenAt))
      .length;
});
