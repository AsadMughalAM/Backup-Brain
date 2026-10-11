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
      'Aap ka ghar solar panels ke baghair save hai. Panels shamil karein, phir dekhein dhoop battery ko kitna charge karegi.';

  @override
  String get solarNeedsInternetTitle => 'Ek dafa internet chahiye';

  @override
  String get solarNeedsInternetBody =>
      'Dhoop ka forecast lene ke liye ek dafa connect karein. Us ke baad yeh offline bhi chalega.';

  @override
  String get solarFetching => 'Forecast aa raha hai…';

  @override
  String get assistantIntroTitle => 'Apne backup ke baare mein poochein';

  @override
  String get assistantIntroBody =>
      'Main aap ki Home, Loads aur Solar screens ke numbers samjhata hoon, English ya Roman Urdu mein.';

  @override
  String get assistantSuggestBackup => 'Kitni der chalegi battery?';

  @override
  String get assistantSuggestTurnOff => 'Pehle kya band karun?';

  @override
  String get assistantSuggestSolar => 'Kal solar kitna charge karega?';

  @override
  String get assistantFootnote =>
      'Jawab app ke apne numbers se aate hain. Phir bhi AI se ghalti ho sakti hai, is liye pakke numbers Home screen par dekhein.';

  @override
  String get assistantInputLabel => 'Sawal poochein';

  @override
  String get assistantSend => 'Bhejein';

  @override
  String get assistantTyping => 'Assistant likh raha hai';

  @override
  String get assistantOffline =>
      'Internet nahi hai, is liye assistant abhi jawab nahi de sakta. Aap ke numbers offline bhi chalte hain:';

  @override
  String get assistantUnavailable =>
      'Assistant abhi dastyab nahi. Tab tak aap ke numbers:';

  @override
  String assistantFallbackBackup(String time, String load) {
    return '$load par backup $time chalega.';
  }

  @override
  String get assistantNoData =>
      'Aap ka ghar abhi set up nahi hua, is liye samjhane ko koi numbers nahi. Pehle Home par demo household load karein.';

  @override
  String get assistantSafetyTitle => 'Battery abhi disconnect karein';

  @override
  String get assistantSafetyBody =>
      'Phooli hui, garam ya boo wali battery ko aag lag sakti hai. Inverter band karein, battery disconnect karein aur technician ko bulayein. Check hone tak istemal na karein.';

  @override
  String get assistantDailyLimit =>
      'Aaj ke assistant messages khatam ho gaye. Raat 12 baje dobara milenge. Tab tak aap ke numbers:';

  @override
  String get gridOn => 'Light hai';

  @override
  String get gridOff => 'Light gayi';

  @override
  String get logPowerCut => 'Light gayi?';

  @override
  String get logPowerBack => 'Light aa gayi?';

  @override
  String get outagesTitle => 'Load-shedding';

  @override
  String get outagesOpen => 'Load-shedding aur schedule';

  @override
  String tomorrowAt(String time) {
    return 'kal $time';
  }

  @override
  String weekdayAt(String day, String time) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'Peer',
      '2': 'Mangal',
      '3': 'Budh',
      '4': 'Jumeraat',
      '5': 'Jumma',
      '6': 'Hafta',
      '7': 'Itwaar',
      'other': '',
    });
    return '$_temp0 $time';
  }

  @override
  String nextOutageLikely(String when) {
    return 'Agli light shayad $when jayegi';
  }

  @override
  String nextOutageScheduled(String when) {
    return 'Schedule ke mutabiq light $when jayegi';
  }

  @override
  String readinessBattery(String soc, String backup) {
    return 'Tab tak battery $soc · $backup chalegi';
  }

  @override
  String readinessCovers(String outage, String load) {
    return '$load par aam $outage ki load-shedding ke liye kaafi hai.';
  }

  @override
  String readinessShort(String outage, String load) {
    return '$load par aam $outage ki load-shedding se kam hai. Abhi bhaari cheezain na chalayein taake battery zyada charge ho.';
  }

  @override
  String readinessFull(String time) {
    return 'Grid par $time mein full ho jayegi.';
  }

  @override
  String readinessBasisPattern(String days, String share) {
    return 'Aap ke $days din ke record se; $share dinon mein is waqt light gayi.';
  }

  @override
  String get readinessBasisSchedule => 'Aap ke area ke schedule se.';

  @override
  String get readinessNoSolar =>
      'Sirf grid charging gini hai; dhoop se mazeed charge hogi.';

  @override
  String get noPredictionTitle => 'Abhi koi pattern nahi';

  @override
  String get noPredictionBody =>
      'Jab bhi light jaye \"Light gayi?\" dabayein, ya apne area ka schedule shamil karein. 3 din baad app agli load-shedding ka andaza lagayegi.';

  @override
  String ongoingTitle(String duration) {
    return '$duration se light nahi';
  }

  @override
  String ongoingBody(String soc, String backup, String load) {
    return 'Battery abhi taqreeban $soc: $load par $backup baqi.';
  }

  @override
  String get scheduleTitle => 'Aap ke area ka schedule';

  @override
  String get scheduleEmpty =>
      'Abhi koi waqt nahi. Apni DISCO ke schedule se load-shedding ke auqaat shamil karein.';

  @override
  String get scheduleAdd => 'Waqt shamil karein';

  @override
  String scheduleRemove(String slot) {
    return '$slot hatayein';
  }

  @override
  String scheduleSlot(String day, String from, String to) {
    return '$day $from–$to';
  }

  @override
  String get scheduleDays => 'Din';

  @override
  String get scheduleFrom => 'Se';

  @override
  String get scheduleTo => 'Tak';

  @override
  String get scheduleSave => 'Save karein';

  @override
  String get scheduleCancel => 'Cancel';

  @override
  String get scheduleNeedDay => 'Kam az kam ek din chunein.';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'Peer',
      '2': 'Mangal',
      '3': 'Budh',
      '4': 'Jumeraat',
      '5': 'Jumma',
      '6': 'Hafta',
      '7': 'Itwaar',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get recentOutagesTitle => 'Haal ki load-shedding';

  @override
  String get recentOutagesEmpty => 'Abhi kuch log nahi hua.';

  @override
  String get outageStillOut => 'abhi tak';

  @override
  String scheduleEarlier(String label) {
    return '$label: 30 minute pehle';
  }

  @override
  String scheduleLater(String label) {
    return '$label: 30 minute baad';
  }

  @override
  String get alertChannelName => 'Load-shedding alerts';

  @override
  String alertTitleLikely(String time) {
    return 'Light shayad $time par jayegi';
  }

  @override
  String alertTitleScheduled(String time) {
    return '$time par load-shedding';
  }

  @override
  String alertBodyReady(String soc, String backup) {
    return 'Battery taqreeban $soc hogi: abhi ke load par $backup backup.';
  }

  @override
  String alertBodyShort(String soc, String backup, String outage) {
    return 'Battery taqreeban $soc hogi: sirf $backup, aam $outage se kam. Bhaari cheezain abhi band karein.';
  }

  @override
  String get settingsOutageAlerts => 'Load-shedding alerts';

  @override
  String get settingsOutageAlertsBody =>
      'Agli load-shedding se 30 minute pehle notification. Internet ke baghair bhi.';

  @override
  String get solarAddPanels => 'Apne panels shamil karein';

  @override
  String get assistantBusy =>
      'Assistant abhi masroof hai. Ek minute baad dobara koshish karein. Tab tak aap ke numbers:';

  @override
  String get estimatorTitle => 'Solar ka kharcha';

  @override
  String get estimatorIntro =>
      'Aap ke ghar ke liye solar ka kitna kharcha aayega? Chand taps mein size, qeemat aur bachat ka andaza.';

  @override
  String get estimatorUsage => 'Mahana bijli ka istemal';

  @override
  String get estimatorUnits => 'Units (kWh)';

  @override
  String get estimatorBill => 'Bill (Rs)';

  @override
  String get estimatorUnitsLabel => 'Mahana units';

  @override
  String get estimatorBillLabel => 'Mahana bill (rupay)';

  @override
  String estimatorTariffNote(String tariff) {
    return 'Rs $tariff fi unit ke hisaab se.';
  }

  @override
  String get estimatorCity => 'Shehr';

  @override
  String get estimatorGoal => 'Sab se zaroori kya hai?';

  @override
  String get goalBill => 'Bill kam karna';

  @override
  String get goalBillHint => 'Battery nahi, sab se sasta';

  @override
  String get goalBoth => 'Bill aur backup';

  @override
  String get goalBothHint => 'Load-shedding ke liye battery';

  @override
  String get goalBackup => 'Poora backup';

  @override
  String get goalBackupHint => 'Poori raat ki battery';

  @override
  String get estimatorBackupHours => 'Kitne ghante backup chahiye';

  @override
  String get estimatorHoursLess => 'Kam ghante';

  @override
  String get estimatorHoursMore => 'Zyada ghante';

  @override
  String get estimatorNightLoad => 'Raat ka load (W)';

  @override
  String get estimatorNightLoadHint =>
      'Pankhe, bulb aur fridge mila kar. Khaali chhorein to aap ke ghar se liya jayega.';

  @override
  String get estimatorEmptyTitle => 'Packages yahan nazar aayenge';

  @override
  String get estimatorEnterUsage =>
      'Mahana units ya bill likhein, phir teen packages qeemat aur wapsi ke saath dekhein.';

  @override
  String get packageBasic => 'Basic';

  @override
  String get packageBasicSub => 'On-grid: bill kam, backup nahi';

  @override
  String get packageHybrid => 'Hybrid';

  @override
  String get packageHybridSub => 'Bill bhi kam, load-shedding mein backup bhi';

  @override
  String get packageFull => 'Poora backup';

  @override
  String get packageFullSub => 'Poori raat battery par';

  @override
  String get packageRecommended => 'Behtar intikhab';

  @override
  String packageCost(String min, String max) {
    return 'Rs $min–$max';
  }

  @override
  String packagePanels(String count, String watts, String kw) {
    return '$count × $watts W panels ($kw)';
  }

  @override
  String packageInverterOngrid(String size) {
    return '$size on-grid inverter';
  }

  @override
  String packageInverterHybrid(String size) {
    return '$size hybrid inverter';
  }

  @override
  String packageBattery(String kwh, String hours, String load) {
    return '$kwh kWh lithium battery: $load par taqreeban $hours';
  }

  @override
  String get packageNoBattery => 'Battery nahi: load-shedding mein backup nahi';

  @override
  String packageProduction(String units) {
    return 'Mahana taqreeban $units units banayega';
  }

  @override
  String packageSavings(String amount) {
    return 'Mahana taqreeban Rs $amount ki bachat';
  }

  @override
  String packagePayback(String min, String max) {
    return '$min–$max saal mein qeemat wapas';
  }

  @override
  String get installerTitle => 'Installer se yeh zaroor poochein';

  @override
  String get installerQ1 =>
      'Kya panels tier-1 hain, aur output ki warranty kitni hai?';

  @override
  String get installerQ2 =>
      'Kya inverter hybrid hai, aur kaun si batteries chalata hai?';

  @override
  String get installerQ3 =>
      'Lithium (LiFePO4) battery kaun si brand, kitne cycles, kitni warranty?';

  @override
  String get installerQ4 =>
      'Kya qeemat mein structure, wiring, breakers aur earthing shamil hain?';

  @override
  String get installerQ5 =>
      'DISCO se net metering kaun karwayega, aur kitna waqt lagega?';

  @override
  String estimatorDisclaimer(String date) {
    return 'Sirf andaza hai: 2–3 installers se qeemat lein. Qeematein aakhri dafa $date ko update hui.';
  }

  @override
  String get estimatorPricesUnverified =>
      'Yeh namoone ki qeematein hain, abhi installers se check nahi hui.';
}

/// The translations for Urdu, using the Latin script (`ur_Latn`).
class AppLocalizationsUrLatn extends AppLocalizationsUr {
  AppLocalizationsUrLatn() : super('ur_Latn');
}
