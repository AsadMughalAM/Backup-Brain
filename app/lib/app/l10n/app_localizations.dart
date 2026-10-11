import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
    Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Brain'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabLoads.
  ///
  /// In en, this message translates to:
  /// **'Loads'**
  String get tabLoads;

  /// No description provided for @tabSolar.
  ///
  /// In en, this message translates to:
  /// **'Solar'**
  String get tabSolar;

  /// No description provided for @tabBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get tabBattery;

  /// No description provided for @tabAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get tabAssistant;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Assalam-o-alaikum'**
  String get greeting;

  /// No description provided for @switchTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch theme'**
  String get switchTheme;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @durationUnlimited.
  ///
  /// In en, this message translates to:
  /// **'No load'**
  String get durationUnlimited;

  /// No description provided for @gainedTime.
  ///
  /// In en, this message translates to:
  /// **'+{time}'**
  String gainedTime(String time);

  /// No description provided for @backupLeftAt.
  ///
  /// In en, this message translates to:
  /// **'left at {load}'**
  String backupLeftAt(String load);

  /// No description provided for @stopsProtectingAt.
  ///
  /// In en, this message translates to:
  /// **'Stops protecting battery at {percent}'**
  String stopsProtectingAt(String percent);

  /// No description provided for @backupSemantics.
  ///
  /// In en, this message translates to:
  /// **'{time} of backup left at {load}. Battery {percent}.'**
  String backupSemantics(String time, String load, String percent);

  /// No description provided for @whatToTurnOff.
  ///
  /// In en, this message translates to:
  /// **'What should I turn off?'**
  String get whatToTurnOff;

  /// No description provided for @statBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get statBattery;

  /// No description provided for @statLoad.
  ///
  /// In en, this message translates to:
  /// **'Load now'**
  String get statLoad;

  /// No description provided for @overloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Overload'**
  String get overloadTitle;

  /// No description provided for @overloadBody.
  ///
  /// In en, this message translates to:
  /// **'{load} is more than your inverter can supply ({rated}). Turn something off now.'**
  String overloadBody(String load, String rated);

  /// No description provided for @adviceTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off {name} to get {time} more backup.'**
  String adviceTurnOff(String name, String time);

  /// No description provided for @adviceOnlyEssentials.
  ///
  /// In en, this message translates to:
  /// **'Only essentials are on — your backup is already as long as it can be.'**
  String get adviceOnlyEssentials;

  /// No description provided for @loadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Load planner'**
  String get loadsTitle;

  /// No description provided for @batteryNow.
  ///
  /// In en, this message translates to:
  /// **'Battery now'**
  String get batteryNow;

  /// No description provided for @turnOffFirst.
  ///
  /// In en, this message translates to:
  /// **'Turn off first'**
  String get turnOffFirst;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get turnOff;

  /// No description provided for @topCombined.
  ///
  /// In en, this message translates to:
  /// **'Turn off the top {count}: {time} in total'**
  String topCombined(int count, String time);

  /// No description provided for @nothingToTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Nothing to switch off — only essentials are on.'**
  String get nothingToTurnOff;

  /// No description provided for @appliancesSection.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get appliancesSection;

  /// No description provided for @priorityEssential.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get priorityEssential;

  /// No description provided for @priorityComfort.
  ///
  /// In en, this message translates to:
  /// **'Use carefully'**
  String get priorityComfort;

  /// No description provided for @priorityAvoid.
  ///
  /// In en, this message translates to:
  /// **'Avoid on backup'**
  String get priorityAvoid;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Know exactly how long your backup will last'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Backup Brain turns your battery and appliances into one clear answer, and tells you what to switch off first. It works offline.'**
  String get welcomeBody;

  /// No description provided for @tryDemo.
  ///
  /// In en, this message translates to:
  /// **'Try the demo household'**
  String get tryDemo;

  /// No description provided for @tryDemoLoading.
  ///
  /// In en, this message translates to:
  /// **'Setting up…'**
  String get tryDemoLoading;

  /// No description provided for @welcomeOwnSetupSoon.
  ///
  /// In en, this message translates to:
  /// **'Setting up your own battery and appliances comes next.'**
  String get welcomeOwnSetupSoon;

  /// No description provided for @needsInternetFirstTime.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet once to get started. After that, Backup Brain works offline.'**
  String get needsInternetFirstTime;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// No description provided for @comingSolar.
  ///
  /// In en, this message translates to:
  /// **'Solar forecast: how much tomorrow\'s sun will charge your battery.'**
  String get comingSolar;

  /// No description provided for @comingBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery health, plus where to buy or repair a battery.'**
  String get comingBattery;

  /// No description provided for @comingAssistant.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about your backup in English or Roman Urdu.'**
  String get comingAssistant;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRomanUrdu.
  ///
  /// In en, this message translates to:
  /// **'Roman Urdu'**
  String get languageRomanUrdu;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @saveDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your data'**
  String get saveDataTitle;

  /// No description provided for @saveDataBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in so your battery and appliance setup is safe if you change or lose your phone.'**
  String get saveDataBody;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @useEmail.
  ///
  /// In en, this message translates to:
  /// **'Use email'**
  String get useEmail;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {who}'**
  String signedInAs(String who);

  /// No description provided for @googleAccount.
  ///
  /// In en, this message translates to:
  /// **'your Google account'**
  String get googleAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccountTitle;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account…'**
  String get creatingAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signingIn;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @switchToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToSignIn;

  /// No description provided for @switchToCreate.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get switchToCreate;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset link to {email}.'**
  String resetSent(String email);

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters.'**
  String get errorPasswordShort;

  /// No description provided for @errorWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get errorWrongCredentials;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email already has an account. Sign in instead.'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get errorWeakPassword;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Try again when you\'re online.'**
  String get errorNetwork;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a minute and try again.'**
  String get errorTooManyRequests;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'ur':
      {
        switch (locale.scriptCode) {
          case 'Latn':
            return AppLocalizationsUrLatn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
