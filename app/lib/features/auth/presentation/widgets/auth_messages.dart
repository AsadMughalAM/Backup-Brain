import '../../../../app/l10n/app_localizations.dart';
import '../../domain/auth_repository.dart';

/// Friendly, actionable text for each failure — never raw exception text
/// (DESIGN.md §8.6).
String authErrorText(AppLocalizations l10n, AuthFailureCode code) =>
    switch (code) {
      AuthFailureCode.invalidEmail => l10n.errorInvalidEmail,
      AuthFailureCode.wrongCredentials => l10n.errorWrongCredentials,
      AuthFailureCode.emailInUse => l10n.errorEmailInUse,
      AuthFailureCode.weakPassword => l10n.errorWeakPassword,
      AuthFailureCode.network => l10n.errorNetwork,
      AuthFailureCode.tooManyRequests => l10n.errorTooManyRequests,
      AuthFailureCode.cancelled || AuthFailureCode.unknown => l10n.errorUnknown,
    };
