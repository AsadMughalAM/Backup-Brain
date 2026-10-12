import 'package:flutter/material.dart';

import '../foundations/primitives/color_primitives.dart';

/// Material 3 [ColorScheme]s, mapped row for row from DESIGN.md §2.6 so stock
/// Material widgets (date pickers, snackbars) match our palette.
///
/// Never use `ColorScheme.fromSeed`: it generates hues outside our families.
/// `tertiary` deliberately repeats `secondary` — there is no extra hue.
abstract final class AppColorSchemes {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: CoralP.c500,
    onPrimary: IndigoP.c950,
    primaryContainer: CoralP.c100,
    onPrimaryContainer: CoralP.c900,
    secondary: IndigoP.c900,
    onSecondary: MistP.c0,
    secondaryContainer: IndigoP.c100,
    onSecondaryContainer: IndigoP.c900,
    tertiary: IndigoP.c900,
    onTertiary: MistP.c0,
    tertiaryContainer: IndigoP.c100,
    onTertiaryContainer: IndigoP.c900,
    error: StatusP.danger600,
    onError: MistP.c0,
    errorContainer: StatusP.danger100,
    onErrorContainer: IndigoP.c950,
    surface: MistP.c100,
    onSurface: IndigoP.c900,
    surfaceContainerLowest: MistP.c0,
    surfaceContainerLow: MistP.c0,
    surfaceContainer: MistP.c0,
    surfaceContainerHigh: MistP.c50,
    surfaceContainerHighest: MistP.c200,
    onSurfaceVariant: MistP.c600,
    outline: MistP.c500,
    outlineVariant: MistP.c200,
    inverseSurface: IndigoP.c900,
    onInverseSurface: MistP.c100,
    inversePrimary: CoralP.c400,
    surfaceTint: Colors.transparent,
    scrim: IndigoP.c950,
    shadow: IndigoP.c950,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: CoralP.c400,
    onPrimary: IndigoP.c950,
    primaryContainer: CoralP.night,
    onPrimaryContainer: CoralP.c200,
    secondary: IndigoP.c300,
    onSecondary: IndigoP.c950,
    secondaryContainer: IndigoP.c800,
    onSecondaryContainer: IndigoP.c100,
    tertiary: IndigoP.c300,
    onTertiary: IndigoP.c950,
    tertiaryContainer: IndigoP.c800,
    onTertiaryContainer: IndigoP.c100,
    error: StatusP.danger300,
    onError: IndigoP.c950,
    errorContainer: StatusP.danger900,
    onErrorContainer: MistP.c100,
    surface: MistP.c950,
    onSurface: MistP.c100,
    surfaceContainerLowest: MistP.c950,
    surfaceContainerLow: MistP.c900,
    surfaceContainer: MistP.c900,
    surfaceContainerHigh: MistP.c850,
    surfaceContainerHighest: MistP.c800,
    onSurfaceVariant: MistP.c400,
    outline: MistP.c500,
    outlineVariant: MistP.c800,
    inverseSurface: MistP.c100,
    onInverseSurface: IndigoP.c900,
    inversePrimary: CoralP.c500,
    surfaceTint: Colors.transparent,
    scrim: MistP.black,
    shadow: MistP.black,
  );
}
