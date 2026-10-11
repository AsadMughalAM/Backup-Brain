import '../../../../app/l10n/app_localizations.dart';

/// Firebase's own minimum; checked locally so the user hears it instantly.
const minPasswordLength = 6;

String? validateEmail(AppLocalizations l10n, String email) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())
    ? null
    : l10n.errorInvalidEmail;

String? validatePassword(AppLocalizations l10n, String password) =>
    password.length >= minPasswordLength ? null : l10n.errorPasswordShort;
