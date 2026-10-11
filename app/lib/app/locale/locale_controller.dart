import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/preferences.dart';

enum AppLanguage {
  english(Locale('en')),
  romanUrdu(Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'));

  const AppLanguage(this.locale);
  final Locale locale;
}

/// The user's language, saved locally. English until they pick Roman Urdu
/// in Settings.
class LocaleController extends Notifier<AppLanguage> {
  static const _key = 'language';

  @override
  AppLanguage build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    return AppLanguage.values.asNameMap()[saved] ?? AppLanguage.english;
  }

  void set(AppLanguage language) {
    state = language;
    ref.read(sharedPreferencesProvider).setString(_key, language.name);
  }
}

final localeProvider = NotifierProvider<LocaleController, AppLanguage>(
  LocaleController.new,
);
