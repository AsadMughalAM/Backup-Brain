// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'Backup Brain';

  @override
  String get tabHome => 'Ghar';

  @override
  String get tabLoads => 'Appliances';

  @override
  String get tabSolar => 'Solar';

  @override
  String get tabBattery => 'Battery';

  @override
  String get tabAssistant => 'Madadgar';

  @override
  String get greeting => 'Assalam-o-alaikum';

  @override
  String get switchTheme => 'Theme badlein';

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
  String get durationUnlimited => 'Koi load nahi';

  @override
  String gainedTime(String time) {
    return '+$time';
  }

  @override
  String backupLeftAt(String load) {
    return '$load par baqi';
  }

  @override
  String stopsProtectingAt(String percent) {
    return 'Battery bachane ke liye $percent par band ho jayega';
  }

  @override
  String backupSemantics(String time, String load, String percent) {
    return '$load par $time ka backup baqi hai. Battery $percent.';
  }

  @override
  String get whatToTurnOff => 'Kya band karun?';

  @override
  String get statBattery => 'Battery';

  @override
  String get statLoad => 'Abhi ka load';

  @override
  String get overloadTitle => 'Overload';

  @override
  String overloadBody(String load, String rated) {
    return '$load aap ke inverter ki had ($rated) se zyada hai. Abhi kuch band karein.';
  }

  @override
  String adviceTurnOff(String name, String time) {
    return '$name band karein, backup $time zyada chalega.';
  }

  @override
  String get adviceOnlyEssentials =>
      'Sirf zaroori cheezein chal rahi hain — backup pehle hi sab se lamba hai.';

  @override
  String get loadsTitle => 'Load planner';

  @override
  String get batteryNow => 'Battery abhi';

  @override
  String get turnOffFirst => 'Pehle yeh band karein';

  @override
  String get turnOff => 'Band karein';

  @override
  String topCombined(int count, String time) {
    return 'Upar wali $count band karein: kul $time';
  }

  @override
  String get nothingToTurnOff =>
      'Band karne ko kuch nahi — sirf zaroori cheezein on hain.';

  @override
  String get appliancesSection => 'Appliances';

  @override
  String get priorityEssential => 'Zaroori';

  @override
  String get priorityComfort => 'Soch kar chalayein';

  @override
  String get priorityAvoid => 'Backup par na chalayein';

  @override
  String get welcomeTitle => 'Jaanein aap ka backup kitni der chalega';

  @override
  String get welcomeBody =>
      'Backup Brain aap ki battery aur appliances dekh kar saaf jawab deta hai, aur batata hai pehle kya band karein. Yeh offline bhi chalta hai.';

  @override
  String get tryDemo => 'Demo ghar dekhein';

  @override
  String get tryDemoLoading => 'Tayyar ho raha hai…';

  @override
  String get welcomeOwnSetupSoon =>
      'Apni battery aur appliances set karna agle step mein aa raha hai.';

  @override
  String get needsInternetFirstTime =>
      'Shuru karne ke liye ek dafa internet se connect karein. Us ke baad Backup Brain offline bhi chalega.';

  @override
  String get comingSoonTitle => 'Jald aa raha hai';

  @override
  String get comingSolar =>
      'Solar forecast: kal ki dhoop battery ko kitna charge karegi.';

  @override
  String get comingBattery =>
      'Battery ki sehat, aur battery kahan se lein ya repair karwayein.';

  @override
  String get comingAssistant =>
      'Apne backup ke baare mein English ya Roman Urdu mein kuch bhi poochein.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Zabaan';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRomanUrdu => 'Roman Urdu';
}

/// The translations for Urdu, using the Latin script (`ur_Latn`).
class AppLocalizationsUrLatn extends AppLocalizationsUr {
  AppLocalizationsUrLatn() : super('ur_Latn');
}
