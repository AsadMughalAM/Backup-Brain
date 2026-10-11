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

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your home'**
  String get setupTitle;

  /// No description provided for @setupStepHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get setupStepHome;

  /// No description provided for @setupStepBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get setupStepBattery;

  /// No description provided for @setupStepAppliances.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get setupStepAppliances;

  /// No description provided for @setupStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}: {name}'**
  String setupStepOf(int step, int total, String name);

  /// No description provided for @setupNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get setupNext;

  /// No description provided for @setupBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get setupBack;

  /// No description provided for @setupFinish.
  ///
  /// In en, this message translates to:
  /// **'Show my backup time'**
  String get setupFinish;

  /// No description provided for @setupTryDemo.
  ///
  /// In en, this message translates to:
  /// **'Just looking? Try the demo home'**
  String get setupTryDemo;

  /// No description provided for @setupUnderTwoMinutes.
  ///
  /// In en, this message translates to:
  /// **'Takes under 2 minutes. You can change anything later.'**
  String get setupUnderTwoMinutes;

  /// No description provided for @cityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Where is your home?'**
  String get cityQuestion;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'For your local sun forecast. Not listed? Pick the nearest city.'**
  String get cityHint;

  /// No description provided for @solarQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you have solar panels?'**
  String get solarQuestion;

  /// No description provided for @solarYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, I have solar'**
  String get solarYes;

  /// No description provided for @solarYesHint.
  ///
  /// In en, this message translates to:
  /// **'Panels on the roof'**
  String get solarYesHint;

  /// No description provided for @solarNo.
  ///
  /// In en, this message translates to:
  /// **'No, just UPS and battery'**
  String get solarNo;

  /// No description provided for @solarNoHint.
  ///
  /// In en, this message translates to:
  /// **'You still get backup time and solar cost estimates'**
  String get solarNoHint;

  /// No description provided for @panelCountLabel.
  ///
  /// In en, this message translates to:
  /// **'How many panels?'**
  String get panelCountLabel;

  /// No description provided for @panelWattsLabel.
  ///
  /// In en, this message translates to:
  /// **'Watts per panel'**
  String get panelWattsLabel;

  /// No description provided for @panelWattsHint.
  ///
  /// In en, this message translates to:
  /// **'Printed on the panel\'s label, e.g. 550 W'**
  String get panelWattsHint;

  /// No description provided for @panelsTotal.
  ///
  /// In en, this message translates to:
  /// **'{kw} of panels in total'**
  String panelsTotal(String kw);

  /// No description provided for @batteryQuestion.
  ///
  /// In en, this message translates to:
  /// **'What battery do you have?'**
  String get batteryQuestion;

  /// No description provided for @chemLeadAcid.
  ///
  /// In en, this message translates to:
  /// **'Dry battery (lead-acid)'**
  String get chemLeadAcid;

  /// No description provided for @chemLeadAcidHint.
  ///
  /// In en, this message translates to:
  /// **'Sealed, no water needed'**
  String get chemLeadAcidHint;

  /// No description provided for @chemTubular.
  ///
  /// In en, this message translates to:
  /// **'Tubular battery'**
  String get chemTubular;

  /// No description provided for @chemTubularHint.
  ///
  /// In en, this message translates to:
  /// **'Tall battery you top up with water'**
  String get chemTubularHint;

  /// No description provided for @chemLithium.
  ///
  /// In en, this message translates to:
  /// **'Lithium battery'**
  String get chemLithium;

  /// No description provided for @chemLithiumHint.
  ///
  /// In en, this message translates to:
  /// **'LiFePO4 pack, often with a solar inverter'**
  String get chemLithiumHint;

  /// No description provided for @batteryCountLabel.
  ///
  /// In en, this message translates to:
  /// **'How many batteries?'**
  String get batteryCountLabel;

  /// No description provided for @batterySizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery size'**
  String get batterySizeLabel;

  /// No description provided for @batteryVoltageLabel.
  ///
  /// In en, this message translates to:
  /// **'Pack voltage'**
  String get batteryVoltageLabel;

  /// No description provided for @batteryLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Printed on the battery, e.g. 12V 200Ah'**
  String get batteryLabelHint;

  /// No description provided for @inverterLabelUps.
  ///
  /// In en, this message translates to:
  /// **'UPS size'**
  String get inverterLabelUps;

  /// No description provided for @inverterLabelHybrid.
  ///
  /// In en, this message translates to:
  /// **'Inverter size'**
  String get inverterLabelHybrid;

  /// No description provided for @inverterHint.
  ///
  /// In en, this message translates to:
  /// **'Written on its label. A 1 kVA UPS is about 800 W.'**
  String get inverterHint;

  /// No description provided for @socQuestion.
  ///
  /// In en, this message translates to:
  /// **'How full is it right now?'**
  String get socQuestion;

  /// No description provided for @socHint.
  ///
  /// In en, this message translates to:
  /// **'Check the UPS display. You can change it anytime.'**
  String get socHint;

  /// No description provided for @setupPreviewValue.
  ///
  /// In en, this message translates to:
  /// **'Your backup: about {time}'**
  String setupPreviewValue(String time);

  /// No description provided for @appliancesQuestion.
  ///
  /// In en, this message translates to:
  /// **'What runs during load-shedding?'**
  String get appliancesQuestion;

  /// No description provided for @appliancesHint.
  ///
  /// In en, this message translates to:
  /// **'We picked what most homes run. Change the numbers to match yours.'**
  String get appliancesHint;

  /// No description provided for @heavyTitle.
  ///
  /// In en, this message translates to:
  /// **'Heavy appliances'**
  String get heavyTitle;

  /// No description provided for @heavyHint.
  ///
  /// In en, this message translates to:
  /// **'Usually kept off on backup. Add yours so we can warn you.'**
  String get heavyHint;

  /// No description provided for @applianceEach.
  ///
  /// In en, this message translates to:
  /// **'{watts} each'**
  String applianceEach(String watts);

  /// No description provided for @setupBackupAt.
  ///
  /// In en, this message translates to:
  /// **'backup at {load}'**
  String setupBackupAt(String load);

  /// No description provided for @fewer.
  ///
  /// In en, this message translates to:
  /// **'Fewer'**
  String get fewer;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @setUpMyHome.
  ///
  /// In en, this message translates to:
  /// **'Set up my home'**
  String get setUpMyHome;

  /// No description provided for @setupDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Your home is ready'**
  String get setupDoneTitle;

  /// No description provided for @setupDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Backup about {time}. Create an account to keep it safe, on any phone.'**
  String setupDoneBody(String time);

  /// No description provided for @editHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit my home'**
  String get editHomeTitle;

  /// No description provided for @editHomeSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editHomeSave;

  /// No description provided for @myHomeSection.
  ///
  /// In en, this message translates to:
  /// **'My home'**
  String get myHomeSection;

  /// No description provided for @editHome.
  ///
  /// In en, this message translates to:
  /// **'Edit my home'**
  String get editHome;

  /// No description provided for @homeSummary.
  ///
  /// In en, this message translates to:
  /// **'{city} · {battery}'**
  String homeSummary(String city, String battery);

  /// No description provided for @homeSummarySolar.
  ///
  /// In en, this message translates to:
  /// **'{city} · {battery} · {kw} solar'**
  String homeSummarySolar(String city, String battery, String kw);

  /// No description provided for @batteryBank.
  ///
  /// In en, this message translates to:
  /// **'{count} × {size}'**
  String batteryBank(int count, String size);

  /// No description provided for @guideOpen.
  ///
  /// In en, this message translates to:
  /// **'Where is this written?'**
  String get guideOpen;

  /// No description provided for @guideHide.
  ///
  /// In en, this message translates to:
  /// **'Hide the example'**
  String get guideHide;

  /// No description provided for @guideCaption.
  ///
  /// In en, this message translates to:
  /// **'Look for this line on the sticker. Yours may look a little different.'**
  String get guideCaption;

  /// No description provided for @guideSemantics.
  ///
  /// In en, this message translates to:
  /// **'Example sticker. Look for a line like {line}.'**
  String guideSemantics(String line);

  /// No description provided for @guideBattery1.
  ///
  /// In en, this message translates to:
  /// **'DEEP CYCLE BATTERY'**
  String get guideBattery1;

  /// No description provided for @guideBattery2.
  ///
  /// In en, this message translates to:
  /// **'12V 200Ah'**
  String get guideBattery2;

  /// No description provided for @guideBattery3.
  ///
  /// In en, this message translates to:
  /// **'Charge before use · Keep upright'**
  String get guideBattery3;

  /// No description provided for @guideUps1.
  ///
  /// In en, this message translates to:
  /// **'UPS / INVERTER'**
  String get guideUps1;

  /// No description provided for @guideUps2.
  ///
  /// In en, this message translates to:
  /// **'1000VA / 800W'**
  String get guideUps2;

  /// No description provided for @guideUps3.
  ///
  /// In en, this message translates to:
  /// **'Input 220V AC · Battery 12V DC'**
  String get guideUps3;

  /// No description provided for @guidePanel1.
  ///
  /// In en, this message translates to:
  /// **'MONO PV MODULE'**
  String get guidePanel1;

  /// No description provided for @guidePanel2.
  ///
  /// In en, this message translates to:
  /// **'Pmax 550W'**
  String get guidePanel2;

  /// No description provided for @guidePanel3.
  ///
  /// In en, this message translates to:
  /// **'Voc 49.6V · Isc 14.0A'**
  String get guidePanel3;

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

  /// No description provided for @assistantIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about your backup'**
  String get assistantIntroTitle;

  /// No description provided for @assistantIntroBody.
  ///
  /// In en, this message translates to:
  /// **'I explain the numbers from your Home, Loads and Solar screens, in English or Roman Urdu.'**
  String get assistantIntroBody;

  /// No description provided for @assistantSuggestBackup.
  ///
  /// In en, this message translates to:
  /// **'How long will my battery last?'**
  String get assistantSuggestBackup;

  /// No description provided for @assistantSuggestTurnOff.
  ///
  /// In en, this message translates to:
  /// **'What should I turn off first?'**
  String get assistantSuggestTurnOff;

  /// No description provided for @assistantSuggestSolar.
  ///
  /// In en, this message translates to:
  /// **'Will solar charge my battery tomorrow?'**
  String get assistantSuggestSolar;

  /// No description provided for @assistantFootnote.
  ///
  /// In en, this message translates to:
  /// **'Answers use your app\'s own numbers. AI can still word things wrongly, so check the Home screen for exact figures.'**
  String get assistantFootnote;

  /// No description provided for @assistantInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Ask a question'**
  String get assistantInputLabel;

  /// No description provided for @assistantSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get assistantSend;

  /// No description provided for @assistantTyping.
  ///
  /// In en, this message translates to:
  /// **'Assistant is typing'**
  String get assistantTyping;

  /// No description provided for @assistantOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet, so the assistant can\'t answer right now. Your numbers still work offline:'**
  String get assistantOffline;

  /// No description provided for @assistantUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The assistant isn\'t available right now. Meanwhile, your numbers:'**
  String get assistantUnavailable;

  /// No description provided for @assistantFallbackBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup lasts {time} at {load}.'**
  String assistantFallbackBackup(String time, String load);

  /// No description provided for @assistantNoData.
  ///
  /// In en, this message translates to:
  /// **'Your home isn\'t set up yet, so there are no numbers to explain. Load the demo household on Home first.'**
  String get assistantNoData;

  /// No description provided for @assistantSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect the battery now'**
  String get assistantSafetyTitle;

  /// No description provided for @assistantSafetyBody.
  ///
  /// In en, this message translates to:
  /// **'A swollen, hot or smelly battery can catch fire. Switch off the inverter, disconnect the battery and call a technician. Don\'t use it until it has been checked.'**
  String get assistantSafetyBody;

  /// No description provided for @assistantDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used today\'s assistant messages. They reset at midnight. Meanwhile, your numbers:'**
  String get assistantDailyLimit;

  /// No description provided for @gridOn.
  ///
  /// In en, this message translates to:
  /// **'Power on'**
  String get gridOn;

  /// No description provided for @gridOff.
  ///
  /// In en, this message translates to:
  /// **'Power cut'**
  String get gridOff;

  /// No description provided for @logPowerCut.
  ///
  /// In en, this message translates to:
  /// **'Power gone?'**
  String get logPowerCut;

  /// No description provided for @logPowerBack.
  ///
  /// In en, this message translates to:
  /// **'Power back?'**
  String get logPowerBack;

  /// No description provided for @outagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Outages'**
  String get outagesTitle;

  /// No description provided for @outagesOpen.
  ///
  /// In en, this message translates to:
  /// **'Outages and schedule'**
  String get outagesOpen;

  /// No description provided for @tomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'tomorrow {time}'**
  String tomorrowAt(String time);

  /// No description provided for @weekdayAt.
  ///
  /// In en, this message translates to:
  /// **'{day, select, 1{Mon} 2{Tue} 3{Wed} 4{Thu} 5{Fri} 6{Sat} 7{Sun} other{}} {time}'**
  String weekdayAt(String day, String time);

  /// No description provided for @nextOutageLikely.
  ///
  /// In en, this message translates to:
  /// **'Next outage likely {when}'**
  String nextOutageLikely(String when);

  /// No description provided for @nextOutageScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled outage {when}'**
  String nextOutageScheduled(String when);

  /// No description provided for @readinessBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery {soc} by then · lasts {backup}'**
  String readinessBattery(String soc, String backup);

  /// No description provided for @readinessCovers.
  ///
  /// In en, this message translates to:
  /// **'Enough for the usual {outage} outage at {load}.'**
  String readinessCovers(String outage, String load);

  /// No description provided for @readinessShort.
  ///
  /// In en, this message translates to:
  /// **'Less than the usual {outage} outage at {load}. Avoid heavy loads now so it charges more.'**
  String readinessShort(String outage, String load);

  /// No description provided for @readinessFull.
  ///
  /// In en, this message translates to:
  /// **'Full in {time} on grid power.'**
  String readinessFull(String time);

  /// No description provided for @readinessBasisPattern.
  ///
  /// In en, this message translates to:
  /// **'Based on {days} days of your logs, {share} of them with an outage at this hour.'**
  String readinessBasisPattern(String days, String share);

  /// No description provided for @readinessBasisSchedule.
  ///
  /// In en, this message translates to:
  /// **'From your area\'s schedule.'**
  String get readinessBasisSchedule;

  /// No description provided for @readinessNoSolar.
  ///
  /// In en, this message translates to:
  /// **'Counts grid charging only; sun adds more.'**
  String get readinessNoSolar;

  /// No description provided for @noPredictionTitle.
  ///
  /// In en, this message translates to:
  /// **'No outage pattern yet'**
  String get noPredictionTitle;

  /// No description provided for @noPredictionBody.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Power gone?\" whenever the light goes, or add your area\'s schedule. After 3 days the app predicts the next outage.'**
  String get noPredictionBody;

  /// No description provided for @ongoingTitle.
  ///
  /// In en, this message translates to:
  /// **'Power cut for {duration}'**
  String ongoingTitle(String duration);

  /// No description provided for @ongoingBody.
  ///
  /// In en, this message translates to:
  /// **'Battery about {soc} now: {backup} left at {load}.'**
  String ongoingBody(String soc, String backup, String load);

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Your area\'s schedule'**
  String get scheduleTitle;

  /// No description provided for @scheduleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No times yet. Add the load-shedding times from your DISCO\'s schedule.'**
  String get scheduleEmpty;

  /// No description provided for @scheduleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get scheduleAdd;

  /// No description provided for @scheduleRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {slot}'**
  String scheduleRemove(String slot);

  /// No description provided for @scheduleSlot.
  ///
  /// In en, this message translates to:
  /// **'{day} {from}–{to}'**
  String scheduleSlot(String day, String from, String to);

  /// No description provided for @scheduleDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get scheduleDays;

  /// No description provided for @scheduleFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get scheduleFrom;

  /// No description provided for @scheduleTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get scheduleTo;

  /// No description provided for @scheduleSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get scheduleSave;

  /// No description provided for @scheduleCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get scheduleCancel;

  /// No description provided for @scheduleNeedDay.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day.'**
  String get scheduleNeedDay;

  /// No description provided for @weekdayShort.
  ///
  /// In en, this message translates to:
  /// **'{day, select, 1{Mon} 2{Tue} 3{Wed} 4{Thu} 5{Fri} 6{Sat} 7{Sun} other{}}'**
  String weekdayShort(String day);

  /// No description provided for @recentOutagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent outages'**
  String get recentOutagesTitle;

  /// No description provided for @recentOutagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet.'**
  String get recentOutagesEmpty;

  /// No description provided for @outageStillOut.
  ///
  /// In en, this message translates to:
  /// **'still out'**
  String get outageStillOut;

  /// No description provided for @scheduleEarlier.
  ///
  /// In en, this message translates to:
  /// **'{label}: 30 minutes earlier'**
  String scheduleEarlier(String label);

  /// No description provided for @scheduleLater.
  ///
  /// In en, this message translates to:
  /// **'{label}: 30 minutes later'**
  String scheduleLater(String label);
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
