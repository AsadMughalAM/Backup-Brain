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

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

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

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

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

  /// No description provided for @introNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get introNext;

  /// No description provided for @introPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String introPageOf(int current, int total);

  /// No description provided for @intro1Title.
  ///
  /// In en, this message translates to:
  /// **'Backup Brain'**
  String get intro1Title;

  /// No description provided for @intro1Body.
  ///
  /// In en, this message translates to:
  /// **'Know exactly how long your battery will last during load-shedding — in hours and minutes.'**
  String get intro1Body;

  /// No description provided for @intro2Title.
  ///
  /// In en, this message translates to:
  /// **'Switch off the right things'**
  String get intro2Title;

  /// No description provided for @intro2Body.
  ///
  /// In en, this message translates to:
  /// **'See which appliance to turn off first and how much backup time it gives you back.'**
  String get intro2Body;

  /// No description provided for @intro3Title.
  ///
  /// In en, this message translates to:
  /// **'Plan with the sun'**
  String get intro3Title;

  /// No description provided for @intro3Body.
  ///
  /// In en, this message translates to:
  /// **'Solar forecasts, battery health and costs — so every outage is planned, not a surprise.'**
  String get intro3Body;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Join for a smarter backup.'**
  String get signUpTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginTitle;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameHint;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @signingUp.
  ///
  /// In en, this message translates to:
  /// **'Signing up…'**
  String get signingUp;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in…'**
  String get loggingIn;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get orDivider;

  /// No description provided for @haveAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccountQuestion;

  /// No description provided for @noAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountQuestion;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get errorNameRequired;

  /// No description provided for @greetingName.
  ///
  /// In en, this message translates to:
  /// **'Assalam-o-alaikum, {name}'**
  String greetingName(String name);

  /// No description provided for @settingUpHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Setting up your home'**
  String get settingUpHomeTitle;

  /// No description provided for @settingUpHomeBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re loading the demo household so you can see your backup time. Your own setup comes next.'**
  String get settingUpHomeBody;

  /// No description provided for @useDemoHousehold.
  ///
  /// In en, this message translates to:
  /// **'Load the demo household'**
  String get useDemoHousehold;

  /// No description provided for @solarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get solarToday;

  /// No description provided for @solarTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get solarTomorrow;

  /// No description provided for @solarFullBy.
  ///
  /// In en, this message translates to:
  /// **'Battery full by {time}'**
  String solarFullBy(String time);

  /// No description provided for @solarStaysFull.
  ///
  /// In en, this message translates to:
  /// **'Battery stays full'**
  String get solarStaysFull;

  /// No description provided for @solarReaches.
  ///
  /// In en, this message translates to:
  /// **'Battery reaches {percent} by sunset'**
  String solarReaches(String percent);

  /// No description provided for @solarSunOver.
  ///
  /// In en, this message translates to:
  /// **'No more sun today'**
  String get solarSunOver;

  /// No description provided for @solarStartNow.
  ///
  /// In en, this message translates to:
  /// **'Starting from {percent} now'**
  String solarStartNow(String percent);

  /// No description provided for @solarStartSunrise.
  ///
  /// In en, this message translates to:
  /// **'If it starts the day at {percent}'**
  String solarStartSunrise(String percent);

  /// No description provided for @solarAtSunset.
  ///
  /// In en, this message translates to:
  /// **'at sunset, {time}'**
  String solarAtSunset(String time);

  /// No description provided for @solarBatteryNow.
  ///
  /// In en, this message translates to:
  /// **'battery now'**
  String get solarBatteryNow;

  /// No description provided for @solarNightUntil.
  ///
  /// In en, this message translates to:
  /// **'Lasts until about {time} at {load}'**
  String solarNightUntil(String time, String load);

  /// No description provided for @solarNightAll.
  ///
  /// In en, this message translates to:
  /// **'Lasts all night at {load}'**
  String solarNightAll(String load);

  /// No description provided for @solarNightNoLoad.
  ///
  /// In en, this message translates to:
  /// **'Nothing is drawing power'**
  String get solarNightNoLoad;

  /// No description provided for @solarSunToday.
  ///
  /// In en, this message translates to:
  /// **'Sun today'**
  String get solarSunToday;

  /// No description provided for @solarSunTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Sun tomorrow'**
  String get solarSunTomorrow;

  /// No description provided for @unitKWh.
  ///
  /// In en, this message translates to:
  /// **'kWh'**
  String get unitKWh;

  /// No description provided for @solarBelowClear.
  ///
  /// In en, this message translates to:
  /// **'{percent} less sun than a clear day'**
  String solarBelowClear(String percent);

  /// No description provided for @solarNearClear.
  ///
  /// In en, this message translates to:
  /// **'About as sunny as a clear day'**
  String get solarNearClear;

  /// No description provided for @solarChartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Hourly sun forecast, {range} kWh in total'**
  String solarChartSemantics(String range);

  /// No description provided for @solarLegendForecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get solarLegendForecast;

  /// No description provided for @solarLegendClearDay.
  ///
  /// In en, this message translates to:
  /// **'Clear day'**
  String get solarLegendClearDay;

  /// No description provided for @solarAdvicePeak.
  ///
  /// In en, this message translates to:
  /// **'Most sun from {start} to {end}. Run heavy loads like the iron or water motor then.'**
  String solarAdvicePeak(String start, String end);

  /// No description provided for @solarAdviceWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak sun. Your battery may reach only {percent}, so avoid heavy loads after {time}.'**
  String solarAdviceWeak(String percent, String time);

  /// No description provided for @solarUpdated.
  ///
  /// In en, this message translates to:
  /// **'{city} · updated {age}'**
  String solarUpdated(String city, String age);

  /// No description provided for @ageJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get ageJustNow;

  /// No description provided for @ageMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String ageMinutes(int minutes);

  /// No description provided for @ageHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String ageHours(int hours);

  /// No description provided for @ageDays.
  ///
  /// In en, this message translates to:
  /// **'{days} d ago'**
  String ageDays(int days);

  /// No description provided for @solarUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update. Showing the saved forecast.'**
  String get solarUpdateFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @refreshForecast.
  ///
  /// In en, this message translates to:
  /// **'Refresh forecast'**
  String get refreshForecast;

  /// No description provided for @solarNoPanelsTitle.
  ///
  /// In en, this message translates to:
  /// **'No solar panels added'**
  String get solarNoPanelsTitle;

  /// No description provided for @solarNoPanelsBody.
  ///
  /// In en, this message translates to:
  /// **'Add your panels during setup to see how much the sun will charge your battery.'**
  String get solarNoPanelsBody;

  /// No description provided for @solarNeedsInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs internet once'**
  String get solarNeedsInternetTitle;

  /// No description provided for @solarNeedsInternetBody.
  ///
  /// In en, this message translates to:
  /// **'Connect once to get the sun forecast. After that it works offline.'**
  String get solarNeedsInternetBody;

  /// No description provided for @solarFetching.
  ///
  /// In en, this message translates to:
  /// **'Getting forecast…'**
  String get solarFetching;
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
