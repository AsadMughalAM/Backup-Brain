import 'package:flutter/material.dart';

import '../foundations/primitives/color_primitives.dart';

/// Material 3 [ColorScheme]s, mapped row for row from DESIGN.md §2.6 so stock
/// Material widgets (date pickers, snackbars) match our palette.
///
/// Never use `ColorScheme.fromSeed`: it generates hues outside our three
/// families. `tertiary` deliberately repeats `secondary` — there is no 4th hue.
abstract final class AppColorSchemes {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: YellowP.c500,
    onPrimary: NavyP.c950,
    primaryContainer: YellowP.c100,
    onPrimaryContainer: YellowP.c900,
    secondary: NavyP.c800,
    onSecondary: CanvasP.c0,
    secondaryContainer: NavyP.c100,
    onSecondaryContainer: NavyP.c900,
    tertiary: NavyP.c800,
    onTertiary: CanvasP.c0,
    tertiaryContainer: NavyP.c100,
    onTertiaryContainer: NavyP.c900,
    error: StatusP.danger600,
    onError: CanvasP.c0,
    errorContainer: StatusP.danger100,
    onErrorContainer: NavyP.c950,
    surface: CanvasP.c50,
    onSurface: NavyP.c950,
    surfaceContainerLowest: CanvasP.c0,
    surfaceContainerLow: CanvasP.c0,
    surfaceContainer: CanvasP.c0,
    surfaceContainerHigh: CanvasP.c100,
    surfaceContainerHighest: CanvasP.c200,
    onSurfaceVariant: CanvasP.c600,
    outline: CanvasP.c500,
    outlineVariant: CanvasP.c200,
    inverseSurface: NavyP.c950,
    onInverseSurface: CanvasP.c100,
    inversePrimary: YellowP.c400,
    surfaceTint: Colors.transparent,
    scrim: NavyP.c950,
    shadow: NavyP.c950,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: YellowP.c400,
    onPrimary: NavyP.c950,
    primaryContainer: YellowP.c950,
    onPrimaryContainer: YellowP.c200,
    secondary: NavyP.c300,
    onSecondary: NavyP.c950,
    secondaryContainer: NavyP.c900,
    onSecondaryContainer: NavyP.c100,
    tertiary: NavyP.c300,
    onTertiary: NavyP.c950,
    tertiaryContainer: NavyP.c900,
    onTertiaryContainer: NavyP.c100,
    error: StatusP.danger300,
    onError: NavyP.c950,
    errorContainer: StatusP.danger900,
    onErrorContainer: CanvasP.c100,
    surface: CanvasP.c950,
    onSurface: CanvasP.c100,
    surfaceContainerLowest: CanvasP.c950,
    surfaceContainerLow: CanvasP.c900,
    surfaceContainer: CanvasP.c900,
    surfaceContainerHigh: CanvasP.c850,
    surfaceContainerHighest: CanvasP.c800,
    onSurfaceVariant: CanvasP.c400,
    outline: CanvasP.c500,
    outlineVariant: CanvasP.c800,
    inverseSurface: CanvasP.c100,
    onInverseSurface: NavyP.c950,
    inversePrimary: YellowP.c500,
    surfaceTint: Colors.transparent,
    scrim: CanvasP.black,
    shadow: CanvasP.black,
  );
}
