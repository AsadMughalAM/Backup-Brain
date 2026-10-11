import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/setup_draft.dart';
import '../domain/setup_draft_repository.dart';
import 'models/setup_draft_dto.dart';

/// Keeps the draft in SharedPreferences: it is one small JSON blob, read
/// synchronously so the router can decide the first screen without waiting.
class LocalSetupDraftRepository implements SetupDraftRepository {
  LocalSetupDraftRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'setupDraft';

  @override
  SetupDraft? load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return SetupDraftDto.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (e) {
      // An older app version's format: start setup fresh rather than crash.
      debugPrint('Saved setup draft unreadable, starting fresh: $e');
      return null;
    }
  }

  @override
  Future<void> save(SetupDraft draft) =>
      _prefs.setString(_key, json.encode(SetupDraftDto.toJson(draft)));

  @override
  Future<void> clear() => _prefs.remove(_key);
}
