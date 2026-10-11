import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/primitives/font_primitives.dart';
import '../foundations/semantic/app_colors.dart';
import '../foundations/semantic/app_typography.dart';
import '../foundations/semantic/energy_colors.dart';
import '../foundations/semantic/palettes_dark.dart';
import '../foundations/semantic/palettes_light.dart';
import 'color_scheme_builder.dart';
import 'component_themes.dart';

/// Complete light and dark [ThemeData] (TECH_STACK.md §6.3):
///
/// ```dart
/// MaterialApp.router(
///   theme: AppTheme.light(),
///   darkTheme: AppTheme.dark(),
///   themeMode: themeMode,
/// )
/// ```
abstract final class AppTheme {
  static ThemeData light() =>
      _build(AppColorSchemes.light, lightAppColors, lightEnergyColors);

  static ThemeData dark() =>
      _build(AppColorSchemes.dark, darkAppColors, darkEnergyColors);

  static ThemeData _build(ColorScheme scheme, AppColors c, EnergyColors e) {
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: c.textPrimary,
      displayColor: c.textPrimary,
    );
    final isDark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: FontP.sans,
      package: FontP.package,
      textTheme: textTheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.outlineVariant,
      // Status/nav bar icons follow the theme (DESIGN.md §9.3 rule 5).
      appBarTheme: ComponentThemes.appBar(c, textTheme).copyWith(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: ComponentThemes.card(c),
      dialogTheme: ComponentThemes.dialog(c, textTheme),
      bottomSheetTheme: ComponentThemes.bottomSheet(c),
      inputDecorationTheme: ComponentThemes.input(c, textTheme),
      dividerTheme: ComponentThemes.divider(c),
      snackBarTheme: ComponentThemes.snackBar(scheme, textTheme),
      extensions: [c, e, AppTypography.standard],
    );
  }
}
