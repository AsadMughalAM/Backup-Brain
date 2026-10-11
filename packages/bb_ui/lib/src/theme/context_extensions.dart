import 'package:flutter/material.dart';

import '../foundations/semantic/app_colors.dart';
import '../foundations/semantic/app_typography.dart';
import '../foundations/semantic/energy_colors.dart';
import '../foundations/tokens/breakpoints.dart';

/// The only way widgets read theme values (TECH_STACK.md §6.3):
///
/// ```dart
/// context.colors.textPrimary   // AppColors
/// context.energy.solar         // EnergyColors
/// context.text.metricLarge     // AppTypography (Geist Mono)
/// context.textTheme.bodyMedium // Material roles (Geist)
/// ```
extension BbThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  EnergyColors get energy => Theme.of(this).extension<EnergyColors>()!;
  AppTypography get text => Theme.of(this).extension<AppTypography>()!;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
  WindowClass get windowClass =>
      WindowClass.forWidth(MediaQuery.sizeOf(this).width);
}
