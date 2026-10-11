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
  String get solarToday => 'Aaj';

  @override
  String get solarTomorrow => 'Kal';

  @override
  String solarFullBy(String time) {
    return 'Battery $time tak full';
  }

  @override
  String get solarStaysFull => 'Battery full rahegi';

  @override
  String solarReaches(String percent) {
    return 'Suraj doobne tak battery $percent';
  }

  @override
  String get solarSunOver => 'Aaj ki dhoop khatam';

  @override
  String solarStartNow(String percent) {
    return 'Abhi $percent se';
  }

  @override
  String solarStartSunrise(String percent) {
    return 'Agar subah $percent se shuru ho';
  }

  @override
  String solarAtSunset(String time) {
    return 'suraj doobne par, $time';
  }

  @override
  String get solarBatteryNow => 'battery abhi';

  @override
  String solarNightUntil(String time, String load) {
    return '$load par taqreeban $time tak chalegi';
  }

  @override
  String solarNightAll(String load) {
    return '$load par poori raat chalegi';
  }

  @override
  String get solarNightNoLoad => 'Koi cheez bijli nahi le rahi';

  @override
  String get solarSunToday => 'Aaj ki dhoop';

  @override
  String get solarSunTomorrow => 'Kal ki dhoop';

  @override
  String get unitKWh => 'units';

  @override
  String solarBelowClear(String percent) {
    return 'Saaf din se $percent kam dhoop';
  }

  @override
  String get solarNearClear => 'Taqreeban saaf din jitni dhoop';

  @override
  String solarChartSemantics(String range) {
    return 'Ghante war dhoop ka forecast, kul $range units';
  }

  @override
  String get solarLegendForecast => 'Forecast';

  @override
  String get solarLegendClearDay => 'Saaf din';

  @override
  String solarAdvicePeak(String start, String end) {
    return 'Sab se zyada dhoop $start se $end tak. Istri ya pani ki motor tab chalayein.';
  }

  @override
  String solarAdviceWeak(String percent, String time) {
    return 'Dhoop kam hai. Battery sirf $percent tak pohanch sakti hai, is liye $time ke baad bhaari load na chalayein.';
  }

  @override
  String solarUpdated(String city, String age) {
    return '$city · $age update hua';
  }

  @override
  String get ageJustNow => 'abhi abhi';

  @override
  String ageMinutes(int minutes) {
    return '$minutes min pehle';
  }

  @override
  String ageHours(int hours) {
    return '$hours ghante pehle';
  }

  @override
  String ageDays(int days) {
    return '$days din pehle';
  }

  @override
  String get solarUpdateFailed =>
      'Update nahi ho saka. Mehfooz forecast dikha rahe hain.';

  @override
  String get tryAgain => 'Dobara koshish karein';

  @override
  String get refreshForecast => 'Forecast refresh karein';

  @override
  String get solarNoPanelsTitle => 'Solar panels shamil nahi';

  @override
  String get solarNoPanelsBody =>
      'Setup mein apne panels shamil karein, phir dekhein dhoop battery ko kitna charge karegi.';

  @override
  String get solarNeedsInternetTitle => 'Ek dafa internet chahiye';

  @override
  String get solarNeedsInternetBody =>
      'Dhoop ka forecast lene ke liye ek dafa connect karein. Us ke baad yeh offline bhi chalega.';

  @override
  String get solarFetching => 'Forecast aa raha hai…';

  @override
  String get comingSoonTitle => 'Jald aa raha hai';

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

  @override
  String get accountSection => 'Account';

  @override
  String get saveDataTitle => 'Apna data mehfooz karein';

  @override
  String get saveDataBody =>
      'Sign in karein taake phone badalne ya kho jane par bhi aap ki battery aur appliances ki setting mehfooz rahe.';

  @override
  String get continueWithGoogle => 'Google se jaari rakhein';

  @override
  String get useEmail => 'Email istemal karein';

  @override
  String signedInAs(String who) {
    return '$who se signed in';
  }

  @override
  String get googleAccount => 'aap ke Google account';

  @override
  String get signOut => 'Sign out';

  @override
  String get alreadyHaveAccount => 'Mera account pehle se hai';

  @override
  String get createAccountTitle => 'Apna account banayein';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Password dikhayein';

  @override
  String get hidePassword => 'Password chhupayein';

  @override
  String get createAccount => 'Account banayein';

  @override
  String get creatingAccount => 'Account ban raha hai…';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Sign in ho raha hai…';

  @override
  String get orDivider => 'ya';

  @override
  String get switchToSignIn => 'Account pehle se hai? Sign in karein';

  @override
  String get switchToCreate => 'Naye hain? Account banayein';

  @override
  String get forgotPassword => 'Password bhool gaye?';

  @override
  String resetSent(String email) {
    return '$email par password reset ka link bhej diya hai.';
  }

  @override
  String get errorInvalidEmail => 'Sahi email address likhein.';

  @override
  String get errorPasswordShort => 'Kam az kam 6 characters istemal karein.';

  @override
  String get errorWrongCredentials => 'Email ya password ghalat hai.';

  @override
  String get errorEmailInUse =>
      'Is email ka account pehle se hai. Sign in karein.';

  @override
  String get errorWeakPassword => 'Zyada mazboot password chunein.';

  @override
  String get errorNetwork =>
      'Internet connection nahi hai. Online hone par dobara koshish karein.';

  @override
  String get errorTooManyRequests =>
      'Bohat zyada koshishein. Ek minute ruk kar dobara koshish karein.';

  @override
  String get errorUnknown => 'Kuch ghalat ho gaya. Dobara koshish karein.';
}

/// The translations for Urdu, using the Latin script (`ur_Latn`).
class AppLocalizationsUrLatn extends AppLocalizationsUr {
  AppLocalizationsUrLatn() : super('ur_Latn');
}
