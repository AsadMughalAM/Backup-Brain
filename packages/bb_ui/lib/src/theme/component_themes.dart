import 'package:flutter/material.dart';

import '../foundations/semantic/app_colors.dart';
import '../foundations/tokens/radius.dart';
import '../foundations/tokens/spacing.dart';

/// Defaults for stock Material widgets so anything not yet wrapped by a `Bb`
/// component still follows DESIGN.md: no container borders, our radii and
/// surfaces, no surface tint. `Bb` components set their own visuals.
abstract final class ComponentThemes {
  static AppBarTheme appBar(AppColors c, TextTheme t) => AppBarTheme(
    backgroundColor: c.background,
    foregroundColor: c.textPrimary,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: t.titleLarge?.copyWith(color: c.textPrimary),
  );

  static CardThemeData card(AppColors c) => CardThemeData(
    color: c.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
  );

  static DialogThemeData dialog(AppColors c, TextTheme t) => DialogThemeData(
    backgroundColor: c.surfaceRaised,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    titleTextStyle: t.headlineSmall?.copyWith(color: c.textPrimary),
    contentTextStyle: t.bodyMedium?.copyWith(color: c.textPrimary),
  );

  static BottomSheetThemeData bottomSheet(AppColors c) => BottomSheetThemeData(
    backgroundColor: c.surfaceRaised,
    surfaceTintColor: Colors.transparent,
    modalBarrierColor: c.scrim,
    showDragHandle: true,
    dragHandleColor: c.outline,
    dragHandleSize: const Size(32, 4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
  );

  /// Inputs are the one place with a visible boundary (WCAG 1.4.11); errors
  /// change the fill, not the border (DESIGN.md §5.2).
  static InputDecorationTheme input(AppColors c, TextTheme t) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
      border: border(c.outline),
      enabledBorder: border(c.outline),
      focusedBorder: border(c.focusRing, 2),
      errorBorder: border(c.outline),
      focusedErrorBorder: border(c.focusRing, 2),
      hintStyle: t.bodyLarge?.copyWith(color: c.textMuted),
      helperStyle: t.bodySmall?.copyWith(color: c.textMuted),
      errorStyle: t.bodySmall?.copyWith(color: c.danger),
    );
  }

  static DividerThemeData divider(AppColors c) =>
      DividerThemeData(color: c.outlineVariant, thickness: 1, space: 1);

  static SnackBarThemeData snackBar(ColorScheme s, TextTheme t) =>
      SnackBarThemeData(
        backgroundColor: s.inverseSurface,
        contentTextStyle: t.bodyMedium?.copyWith(color: s.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      );
}
