import 'package:flutter/material.dart';

/// LAYER 2 — surface, text and status colors (DESIGN.md §2.4). Values live
/// in `palettes_light.dart` / `palettes_dark.dart`; read via `context.colors`.
///
/// Naming follows Material: [primary] is the action color (coral),
/// [secondary] is Indigo, and the surfaces are Mist.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceMuted,
    required this.hero,
    required this.textPrimary,
    required this.textMuted,
    required this.textOnPrimary,
    required this.outline,
    required this.outlineVariant,
    required this.primary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.link,
    required this.focusRing,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.onDanger,
    required this.info,
    required this.skeleton,
    required this.scrim,
  });

  /// Scaffold.
  final Color background;

  /// Cards, sheets, nav bar.
  final Color surface;

  /// Menus, sheets, dialogs. Light pairs it with a shadow; dark is lighter.
  final Color surfaceRaised;

  /// Input fills, tonal buttons, segmented track, inner groups in cards.
  final Color surfaceMuted;

  /// Indigo night hero card in both themes. Content on it is drawn with
  /// the dark palette (`BbCard` hero variant), so it needs no on-hero tokens.
  final Color hero;
  final Color textPrimary;

  /// Labels, captions, units, placeholders, timestamps.
  final Color textMuted;

  /// Ink on coral, in both themes.
  final Color textOnPrimary;

  /// Input boundaries (≥ 3:1). Never a container border.
  final Color outline;

  /// Hairline dividers, chart gridlines, ring track.
  final Color outlineVariant;

  /// Coral. Fill only: never text or icons on light surfaces.
  final Color primary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  /// Indigo: secondary buttons and selected states.
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color link;
  final Color focusRing;

  // Status colors are for battery/safety status only, always with an icon
  // and text (DESIGN.md §2.3).
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color dangerContainer;

  /// Text/icons on a [danger] fill (destructive buttons).
  final Color onDanger;
  final Color info;
  final Color skeleton;

  /// Behind sheets and dialogs.
  final Color scrim;

  /// Every token by name, for the parity and contrast tests.
  Map<String, Color> get tokens => {
    'background': background,
    'surface': surface,
    'surfaceRaised': surfaceRaised,
    'surfaceMuted': surfaceMuted,
    'hero': hero,
    'textPrimary': textPrimary,
    'textMuted': textMuted,
    'textOnPrimary': textOnPrimary,
    'outline': outline,
    'outlineVariant': outlineVariant,
    'primary': primary,
    'primaryContainer': primaryContainer,
    'onPrimaryContainer': onPrimaryContainer,
    'secondary': secondary,
    'onSecondary': onSecondary,
    'secondaryContainer': secondaryContainer,
    'onSecondaryContainer': onSecondaryContainer,
    'link': link,
    'focusRing': focusRing,
    'success': success,
    'successContainer': successContainer,
    'warning': warning,
    'warningContainer': warningContainer,
    'danger': danger,
    'dangerContainer': dangerContainer,
    'onDanger': onDanger,
    'info': info,
    'skeleton': skeleton,
    'scrim': scrim,
  };

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceMuted,
    Color? hero,
    Color? textPrimary,
    Color? textMuted,
    Color? textOnPrimary,
    Color? outline,
    Color? outlineVariant,
    Color? primary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? link,
    Color? focusRing,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? danger,
    Color? dangerContainer,
    Color? onDanger,
    Color? info,
    Color? skeleton,
    Color? scrim,
  }) => AppColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    hero: hero ?? this.hero,
    textPrimary: textPrimary ?? this.textPrimary,
    textMuted: textMuted ?? this.textMuted,
    textOnPrimary: textOnPrimary ?? this.textOnPrimary,
    outline: outline ?? this.outline,
    outlineVariant: outlineVariant ?? this.outlineVariant,
    primary: primary ?? this.primary,
    primaryContainer: primaryContainer ?? this.primaryContainer,
    onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
    secondary: secondary ?? this.secondary,
    onSecondary: onSecondary ?? this.onSecondary,
    secondaryContainer: secondaryContainer ?? this.secondaryContainer,
    onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
    link: link ?? this.link,
    focusRing: focusRing ?? this.focusRing,
    success: success ?? this.success,
    successContainer: successContainer ?? this.successContainer,
    warning: warning ?? this.warning,
    warningContainer: warningContainer ?? this.warningContainer,
    danger: danger ?? this.danger,
    dangerContainer: dangerContainer ?? this.dangerContainer,
    onDanger: onDanger ?? this.onDanger,
    info: info ?? this.info,
    skeleton: skeleton ?? this.skeleton,
    scrim: scrim ?? this.scrim,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceRaised: c(surfaceRaised, other.surfaceRaised),
      surfaceMuted: c(surfaceMuted, other.surfaceMuted),
      hero: c(hero, other.hero),
      textPrimary: c(textPrimary, other.textPrimary),
      textMuted: c(textMuted, other.textMuted),
      textOnPrimary: c(textOnPrimary, other.textOnPrimary),
      outline: c(outline, other.outline),
      outlineVariant: c(outlineVariant, other.outlineVariant),
      primary: c(primary, other.primary),
      primaryContainer: c(primaryContainer, other.primaryContainer),
      onPrimaryContainer: c(onPrimaryContainer, other.onPrimaryContainer),
      secondary: c(secondary, other.secondary),
      onSecondary: c(onSecondary, other.onSecondary),
      secondaryContainer: c(secondaryContainer, other.secondaryContainer),
      onSecondaryContainer: c(onSecondaryContainer, other.onSecondaryContainer),
      link: c(link, other.link),
      focusRing: c(focusRing, other.focusRing),
      success: c(success, other.success),
      successContainer: c(successContainer, other.successContainer),
      warning: c(warning, other.warning),
      warningContainer: c(warningContainer, other.warningContainer),
      danger: c(danger, other.danger),
      dangerContainer: c(dangerContainer, other.dangerContainer),
      onDanger: c(onDanger, other.onDanger),
      info: c(info, other.info),
      skeleton: c(skeleton, other.skeleton),
      scrim: c(scrim, other.scrim),
    );
  }
}
