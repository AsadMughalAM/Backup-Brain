import 'package:flutter/widgets.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Semantic icon registry (DESIGN.md §6.4). Features use `BbIcons.<meaning>`
/// and never import Phosphor directly, so swapping a glyph is a one-line
/// change here.
///
/// Style policy: Regular by default; the `…Active` / status entries are Fill
/// (selected tabs, status inside banners and badges, grid pill); Duotone
/// only for large empty-state illustrations.
abstract final class BbIcons {
  // Navigation tabs: Regular when unselected, Fill when selected.
  static const IconData home = PhosphorIconsRegular.house;
  static const IconData homeActive = PhosphorIconsFill.house;
  static const IconData loads = PhosphorIconsRegular.plugs;
  static const IconData loadsActive = PhosphorIconsFill.plugs;
  static const IconData solar = PhosphorIconsRegular.sun;
  static const IconData solarActive = PhosphorIconsFill.sun;
  static const IconData battery = PhosphorIconsRegular.batteryHigh;
  static const IconData batteryActive = PhosphorIconsFill.batteryHigh;
  static const IconData assistant = PhosphorIconsRegular.chatCircleDots;
  static const IconData assistantActive = PhosphorIconsFill.chatCircleDots;

  /// Marks AI-generated advice.
  static const IconData ai = PhosphorIconsRegular.sparkle;

  /// Grid power present ("Light aa gayi"). Fill, as used in the grid pill.
  static const IconData gridOn = PhosphorIconsFill.lightning;

  /// Outage ("Light gayi").
  static const IconData gridOff = PhosphorIconsFill.lightningSlash;

  // Battery level — always paired with the % text.
  static const IconData batteryFull = PhosphorIconsRegular.batteryFull;
  static const IconData batteryHigh = PhosphorIconsRegular.batteryHigh;
  static const IconData batteryMedium = PhosphorIconsRegular.batteryMedium;
  static const IconData batteryLow = PhosphorIconsRegular.batteryLow;
  static const IconData batteryEmpty = PhosphorIconsRegular.batteryEmpty;
  static const IconData batteryCharging = PhosphorIconsRegular.batteryCharging;
  static const IconData batteryWarning = PhosphorIconsRegular.batteryWarning;

  static const IconData solarPanel = PhosphorIconsRegular.solarPanel;
  static const IconData cloudy = PhosphorIconsRegular.cloudSun;
  static const IconData countdown = PhosphorIconsRegular.timer;
  static const IconData schedule = PhosphorIconsRegular.calendarDots;
  static const IconData estimator = PhosphorIconsRegular.calculator;
  static const IconData money = PhosphorIconsRegular.coins;
  static const IconData shop = PhosphorIconsRegular.storefront;
  static const IconData repair = PhosphorIconsRegular.wrench;
  static const IconData location = PhosphorIconsRegular.mapPin;

  // Appliance presets. Anything without a preset uses [plug].
  static const IconData fan = PhosphorIconsRegular.fan;
  static const IconData light = PhosphorIconsRegular.lightbulb;
  static const IconData tv = PhosphorIconsRegular.television;
  static const IconData router = PhosphorIconsRegular.wifiHigh;
  static const IconData water = PhosphorIconsRegular.drop;
  static const IconData iron = PhosphorIconsRegular.tShirt;
  static const IconData plug = PhosphorIconsRegular.plug;

  static const IconData offline = PhosphorIconsRegular.wifiSlash;

  // Status icons are Fill: they sit inside banners and badges.
  static const IconData success = PhosphorIconsFill.checkCircle;
  static const IconData warning = PhosphorIconsFill.warning;
  static const IconData danger = PhosphorIconsFill.warningOctagon;
  static const IconData info = PhosphorIconsFill.info;

  static const IconData themeLight = PhosphorIconsRegular.sun;
  static const IconData themeDark = PhosphorIconsRegular.moon;
  static const IconData themeSystem = PhosphorIconsRegular.circleHalf;
  static const IconData settings = PhosphorIconsRegular.gearSix;

  // Account & sign-in.
  static const IconData account = PhosphorIconsRegular.userCircle;
  static const IconData email = PhosphorIconsRegular.envelope;
  static const IconData person = PhosphorIconsRegular.user;
  static const IconData lock = PhosphorIconsRegular.lock;
  static const IconData google = PhosphorIconsRegular.googleLogo;
  static const IconData signOut = PhosphorIconsRegular.signOut;
  static const IconData showPassword = PhosphorIconsRegular.eye;
  static const IconData hidePassword = PhosphorIconsRegular.eyeSlash;

  static const IconData back = PhosphorIconsRegular.arrowLeft;
  static const IconData forward = PhosphorIconsRegular.arrowRight;
  static const IconData next = PhosphorIconsRegular.caretRight;
  static const IconData expand = PhosphorIconsRegular.caretDown;
  static const IconData close = PhosphorIconsRegular.x;
  static const IconData add = PhosphorIconsRegular.plus;
  static const IconData send = PhosphorIconsFill.paperPlaneRight;
  static const IconData more = PhosphorIconsRegular.dotsThree;
  static const IconData check = PhosphorIconsRegular.check;
  static const IconData refresh = PhosphorIconsRegular.arrowClockwise;
}
