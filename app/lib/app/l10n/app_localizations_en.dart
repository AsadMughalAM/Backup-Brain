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
}
