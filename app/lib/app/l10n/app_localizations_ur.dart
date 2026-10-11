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
  String get setupTitle => 'Apna ghar set karein';

  @override
  String get setupStepHome => 'Ghar';

  @override
  String get setupStepBattery => 'Battery';

  @override
  String get setupStepAppliances => 'Appliances';

  @override
  String setupStepOf(int step, int total, String name) {
    return 'Step $step / $total: $name';
  }

  @override
  String get setupNext => 'Aage';

  @override
  String get setupBack => 'Wapas';

  @override
  String get setupFinish => 'Mera backup time dikhayein';

  @override
  String get setupTryDemo => 'Sirf dekh rahe hain? Demo ghar dekhein';

  @override
  String get setupUnderTwoMinutes =>
      '2 minute se kam. Baad mein sab badal sakte hain.';

  @override
  String get cityQuestion => 'Aap ka ghar kahan hai?';

  @override
  String get cityHint =>
      'Aap ke ilaqe ki dhoop ke liye. Shehar list mein nahi? Qareeb tareen shehar chunein.';

  @override
  String get solarQuestion => 'Kya aap ke paas solar panels hain?';

  @override
  String get solarYes => 'Haan, solar hai';

  @override
  String get solarYesHint => 'Chhat par panels';

  @override
  String get solarNo => 'Nahi, sirf UPS aur battery';

  @override
  String get solarNoHint =>
      'Backup time aur solar ke kharche ka andaza phir bhi milega';

  @override
  String get panelCountLabel => 'Kitne panels?';

  @override
  String get panelWattsLabel => 'Har panel ke watt';

  @override
  String get panelWattsHint => 'Panel ke label par likha hota hai, jaise 550 W';

  @override
  String panelsTotal(String kw) {
    return 'Kul $kw panels';
  }

  @override
  String get batteryQuestion => 'Aap ki battery kaun si hai?';

  @override
  String get chemLeadAcid => 'Dry battery (lead-acid)';

  @override
  String get chemLeadAcidHint => 'Band battery, pani nahi dalta';

  @override
  String get chemTubular => 'Tubular battery';

  @override
  String get chemTubularHint => 'Lambi battery jis mein pani dalta hai';

  @override
  String get chemLithium => 'Lithium battery';

  @override
  String get chemLithiumHint => 'LiFePO4 pack, aksar solar inverter ke saath';

  @override
  String get batteryCountLabel => 'Kitni batteries?';

  @override
  String get batterySizeLabel => 'Battery ka size';

  @override
  String get batteryVoltageLabel => 'Pack voltage';

  @override
  String get batteryLabelHint => 'Battery par likha hota hai, jaise 12V 200Ah';

  @override
  String get inverterLabelUps => 'UPS ka size';

  @override
  String get inverterLabelHybrid => 'Inverter ka size';

  @override
  String get inverterHint =>
      'Label par likha hota hai. 1 kVA UPS taqreeban 800 W ka hota hai.';

  @override
  String get socQuestion => 'Abhi kitni charge hai?';

  @override
  String get socHint =>
      'UPS ki screen dekhein. Baad mein kabhi bhi badal sakte hain.';

  @override
  String setupPreviewValue(String time) {
    return 'Aap ka backup: taqreeban $time';
  }

  @override
  String get appliancesQuestion => 'Load-shedding mein kya chalta hai?';

  @override
  String get appliancesHint =>
      'Hum ne aam ghar ki cheezein chun li hain. Apne hisaab se number badlein.';

  @override
  String get heavyTitle => 'Bhaari appliances';

  @override
  String get heavyHint =>
      'Backup par aam tor par band rakhe jate hain. Shamil karein taake hum khabardar kar sakein.';

  @override
  String applianceEach(String watts) {
    return 'Har aik $watts';
  }

  @override
  String setupBackupAt(String load) {
    return '$load par backup';
  }

  @override
  String get fewer => 'Kam';

  @override
  String get more => 'Zyada';

  @override
  String get setUpMyHome => 'Apna ghar set karein';

  @override
  String get setupDoneTitle => 'Aap ka ghar tayyar hai';

  @override
  String setupDoneBody(String time) {
    return 'Backup taqreeban $time. Ise mehfooz rakhne ke liye account banayein, kisi bhi phone par.';
  }

  @override
  String get editHomeTitle => 'Apna ghar badlein';

  @override
  String get editHomeSave => 'Tabdeeliyan save karein';

  @override
  String get myHomeSection => 'Mera ghar';

  @override
  String get editHome => 'Apna ghar badlein';

  @override
  String homeSummary(String city, String battery) {
    return '$city · $battery';
  }

  @override
  String homeSummarySolar(String city, String battery, String kw) {
    return '$city · $battery · $kw solar';
  }

  @override
  String batteryBank(int count, String size) {
    return '$count × $size';
  }

  @override
  String get guideOpen => 'Yeh kahan likha hota hai?';

  @override
  String get guideHide => 'Misaal band karein';

  @override
  String get guideCaption =>
      'Sticker par yeh line dhoondein. Aap ka sticker thora mukhtalif ho sakta hai.';

  @override
  String guideSemantics(String line) {
    return 'Misaal sticker. Is jaisi line dhoondein: $line.';
  }

  @override
  String get guideBattery1 => 'DEEP CYCLE BATTERY';

  @override
  String get guideBattery2 => '12V 200Ah';

  @override
  String get guideBattery3 => 'Charge before use · Keep upright';

  @override
  String get guideUps1 => 'UPS / INVERTER';

  @override
  String get guideUps2 => '1000VA / 800W';

  @override
  String get guideUps3 => 'Input 220V AC · Battery 12V DC';

  @override
  String get guidePanel1 => 'MONO PV MODULE';

  @override
  String get guidePanel2 => 'Pmax 550W';

  @override
  String get guidePanel3 => 'Voc 49.6V · Isc 14.0A';

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
  String get continueWithGoogle => 'Google se jaari rakhein';

  @override
  String signedInAs(String who) {
    return '$who se signed in';
  }

  @override
  String get googleAccount => 'aap ke Google account';

  @override
  String get signOut => 'Sign out';

  @override
  String get showPassword => 'Password dikhayein';

  @override
  String get hidePassword => 'Password chhupayein';

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

  @override
  String get signUpTitle => 'Behtar backup ke liye shamil hon.';

  @override
  String get loginTitle => 'Khush aamdeed!';

  @override
  String get back => 'Wapas';

  @override
  String get nameHint => 'Apna naam likhein';

  @override
  String get emailHint => 'Apna email likhein';

  @override
  String get passwordHint => 'Apna password likhein';

  @override
  String get rememberMe => 'Mujhe yaad rakhein';

  @override
  String get signUp => 'Sign up';

  @override
  String get signingUp => 'Sign up ho raha hai…';

  @override
  String get login => 'Login';

  @override
  String get loggingIn => 'Login ho raha hai…';

  @override
  String get orDivider => 'Ya';

  @override
  String get haveAccountQuestion => 'Account pehle se hai?';

  @override
  String get noAccountQuestion => 'Account nahi hai?';

  @override
  String get createAnAccount => 'Account banayein';

  @override
  String get errorNameRequired => 'Apna naam likhein.';

  @override
  String greetingName(String name) {
    return 'Assalam-o-alaikum, $name';
  }

  @override
  String get settingUpHomeTitle => 'Aap ka ghar tayyar ho raha hai';

  @override
  String get settingUpHomeBody =>
      'Hum demo ghar load kar rahe hain taake aap backup time dekh sakein. Apni setting agle step mein.';

  @override
  String get useDemoHousehold => 'Demo ghar load karein';

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
}

/// The translations for Urdu, using the Latin script (`ur_Latn`).
class AppLocalizationsUrLatn extends AppLocalizationsUr {
  AppLocalizationsUrLatn() : super('ur_Latn');
}
