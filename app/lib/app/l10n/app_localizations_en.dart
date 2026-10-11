// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Backup Brain';

  @override
  String get tabHome => 'Home';

  @override
  String get tabLoads => 'Loads';

  @override
  String get tabSolar => 'Solar';

  @override
  String get tabBattery => 'Battery';

  @override
  String get tabAssistant => 'Assistant';

  @override
  String get greeting => 'Assalam-o-alaikum';

  @override
  String get switchTheme => 'Switch theme';

  @override
  String get settings => 'Settings';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get durationUnlimited => 'No load';

  @override
  String gainedTime(String time) {
    return '+$time';
  }

  @override
  String backupLeftAt(String load) {
    return 'left at $load';
  }

  @override
  String stopsProtectingAt(String percent) {
    return 'Stops protecting battery at $percent';
  }

  @override
  String backupSemantics(String time, String load, String percent) {
    return '$time of backup left at $load. Battery $percent.';
  }

  @override
  String get whatToTurnOff => 'What should I turn off?';

  @override
  String get statBattery => 'Battery';

  @override
  String get statLoad => 'Load now';

  @override
  String get overloadTitle => 'Overload';

  @override
  String overloadBody(String load, String rated) {
    return '$load is more than your inverter can supply ($rated). Turn something off now.';
  }

  @override
  String adviceTurnOff(String name, String time) {
    return 'Turn off $name to get $time more backup.';
  }

  @override
  String get adviceOnlyEssentials =>
      'Only essentials are on — your backup is already as long as it can be.';

  @override
  String get loadsTitle => 'Load planner';

  @override
  String get batteryNow => 'Battery now';

  @override
  String get turnOffFirst => 'Turn off first';

  @override
  String get turnOff => 'Turn off';

  @override
  String topCombined(int count, String time) {
    return 'Turn off the top $count: $time in total';
  }

  @override
  String get nothingToTurnOff =>
      'Nothing to switch off — only essentials are on.';

  @override
  String get appliancesSection => 'Appliances';

  @override
  String get priorityEssential => 'Keep';

  @override
  String get priorityComfort => 'Use carefully';

  @override
  String get priorityAvoid => 'Avoid on backup';

  @override
  String get welcomeTitle => 'Know exactly how long your backup will last';

  @override
  String get welcomeBody =>
      'Backup Brain turns your battery and appliances into one clear answer, and tells you what to switch off first. It works offline.';

  @override
  String get tryDemo => 'Try the demo household';

  @override
  String get tryDemoLoading => 'Setting up…';

  @override
  String get welcomeOwnSetupSoon =>
      'Setting up your own battery and appliances comes next.';

  @override
  String get needsInternetFirstTime =>
      'Connect to the internet once to get started. After that, Backup Brain works offline.';

  @override
  String get solarToday => 'Today';

  @override
  String get solarTomorrow => 'Tomorrow';

  @override
  String solarFullBy(String time) {
    return 'Battery full by $time';
  }

  @override
  String get solarStaysFull => 'Battery stays full';

  @override
  String solarReaches(String percent) {
    return 'Battery reaches $percent by sunset';
  }

  @override
  String get solarSunOver => 'No more sun today';

  @override
  String solarStartNow(String percent) {
    return 'Starting from $percent now';
  }

  @override
  String solarStartSunrise(String percent) {
    return 'If it starts the day at $percent';
  }

  @override
  String solarAtSunset(String time) {
    return 'at sunset, $time';
  }

  @override
  String get solarBatteryNow => 'battery now';

  @override
  String solarNightUntil(String time, String load) {
    return 'Lasts until about $time at $load';
  }

  @override
  String solarNightAll(String load) {
    return 'Lasts all night at $load';
  }

  @override
  String get solarNightNoLoad => 'Nothing is drawing power';

  @override
  String get solarSunToday => 'Sun today';

  @override
  String get solarSunTomorrow => 'Sun tomorrow';

  @override
  String get unitKWh => 'kWh';

  @override
  String solarBelowClear(String percent) {
    return '$percent less sun than a clear day';
  }

  @override
  String get solarNearClear => 'About as sunny as a clear day';

  @override
  String solarChartSemantics(String range) {
    return 'Hourly sun forecast, $range kWh in total';
  }

  @override
  String get solarLegendForecast => 'Forecast';

  @override
  String get solarLegendClearDay => 'Clear day';

  @override
  String solarAdvicePeak(String start, String end) {
    return 'Most sun from $start to $end. Run heavy loads like the iron or water motor then.';
  }

  @override
  String solarAdviceWeak(String percent, String time) {
    return 'Weak sun. Your battery may reach only $percent, so avoid heavy loads after $time.';
  }

  @override
  String solarUpdated(String city, String age) {
    return '$city · updated $age';
  }

  @override
  String get ageJustNow => 'just now';

  @override
  String ageMinutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String ageHours(int hours) {
    return '$hours h ago';
  }

  @override
  String ageDays(int days) {
    return '$days d ago';
  }

  @override
  String get solarUpdateFailed =>
      'Couldn\'t update. Showing the saved forecast.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get refreshForecast => 'Refresh forecast';

  @override
  String get solarNoPanelsTitle => 'No solar panels added';

  @override
  String get solarNoPanelsBody =>
      'Add your panels during setup to see how much the sun will charge your battery.';

  @override
  String get solarNeedsInternetTitle => 'Needs internet once';

  @override
  String get solarNeedsInternetBody =>
      'Connect once to get the sun forecast. After that it works offline.';

  @override
  String get solarFetching => 'Getting forecast…';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingBattery =>
      'Battery health, plus where to buy or repair a battery.';

  @override
  String get comingAssistant =>
      'Ask anything about your backup in English or Roman Urdu.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRomanUrdu => 'Roman Urdu';

  @override
  String get accountSection => 'Account';

  @override
  String get saveDataTitle => 'Save your data';

  @override
  String get saveDataBody =>
      'Sign in so your battery and appliance setup is safe if you change or lose your phone.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get useEmail => 'Use email';

  @override
  String signedInAs(String who) {
    return 'Signed in as $who';
  }

  @override
  String get googleAccount => 'your Google account';

  @override
  String get signOut => 'Sign out';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get createAccountTitle => 'Create your account';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get createAccount => 'Create account';

  @override
  String get creatingAccount => 'Creating account…';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get orDivider => 'or';

  @override
  String get switchToSignIn => 'Already have an account? Sign in';

  @override
  String get switchToCreate => 'New here? Create an account';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String resetSent(String email) {
    return 'We sent a password reset link to $email.';
  }

  @override
  String get errorInvalidEmail => 'Enter a valid email address.';

  @override
  String get errorPasswordShort => 'Use at least 6 characters.';

  @override
  String get errorWrongCredentials => 'Email or password is incorrect.';

  @override
  String get errorEmailInUse =>
      'This email already has an account. Sign in instead.';

  @override
  String get errorWeakPassword => 'Choose a stronger password.';

  @override
  String get errorNetwork =>
      'No internet connection. Try again when you\'re online.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Wait a minute and try again.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';
}
