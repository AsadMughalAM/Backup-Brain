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
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSolar =>
      'Solar forecast: how much tomorrow\'s sun will charge your battery.';

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
  String get continueWithGoogle => 'Continue with Google';

  @override
  String signedInAs(String who) {
    return 'Signed in as $who';
  }

  @override
  String get googleAccount => 'your Google account';

  @override
  String get signOut => 'Sign out';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

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

  @override
  String get introNext => 'Next';

  @override
  String introPageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get intro1Title => 'Backup Brain';

  @override
  String get intro1Body =>
      'Know exactly how long your battery will last during load-shedding — in hours and minutes.';

  @override
  String get intro2Title => 'Switch off the right things';

  @override
  String get intro2Body =>
      'See which appliance to turn off first and how much backup time it gives you back.';

  @override
  String get intro3Title => 'Plan with the sun';

  @override
  String get intro3Body =>
      'Solar forecasts, battery health and costs — so every outage is planned, not a surprise.';

  @override
  String get signUpTitle => 'Join for a smarter backup.';

  @override
  String get loginTitle => 'Welcome back!';

  @override
  String get back => 'Back';

  @override
  String get nameHint => 'Enter your name';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get signUp => 'Sign up';

  @override
  String get signingUp => 'Signing up…';

  @override
  String get login => 'Login';

  @override
  String get loggingIn => 'Logging in…';

  @override
  String get orDivider => 'Or';

  @override
  String get haveAccountQuestion => 'Already have an account?';

  @override
  String get noAccountQuestion => 'Don\'t have an account?';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get errorNameRequired => 'Enter your name.';

  @override
  String greetingName(String name) {
    return 'Assalam-o-alaikum, $name';
  }

  @override
  String get settingUpHomeTitle => 'Setting up your home';

  @override
  String get settingUpHomeBody =>
      'We\'re loading the demo household so you can see your backup time. Your own setup comes next.';

  @override
  String get useDemoHousehold => 'Load the demo household';
}
