import 'package:flutter/material.dart';

import '../../foundations/tokens/elevation.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';

/// The bottom sheet surface (DESIGN.md §10.3): `surfaceRaised`, top radius
/// `xl`, a drag handle, `level3`, and a title that names the sheet for
/// screen readers. Shown only through the app's `OverlayHost`, which owns
/// the scrim, focus trap and closing (scrim tap, Escape, back).
///
/// ```dart
/// overlays.showSheet(title: l10n.batteryCheckTitle, builder: (_) => BatteryCheck(...))
/// ```
class BbBottomSheet extends StatelessWidget {
  const BbBottomSheet({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  static const _handleSize = Size(32, 4);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: title,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          boxShadow: AppElevation.level3.shadows(Theme.of(context).brightness),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: _handleSize.width,
                    height: _handleSize.height,
                    decoration: BoxDecoration(
                      color: c.outline,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Semantics(
                  header: true,
                  child: Text(title, style: context.textTheme.titleLarge),
                ),
                const SizedBox(height: AppSpacing.md),
                // Tall content (a long list of choices) scrolls inside the
                // sheet instead of pushing the title off screen.
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
