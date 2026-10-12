import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';

// One-color artwork (alpha only): tinted at runtime so the same files work
// in light and dark. Cropped from the master logo in assets/brand-logo.png.
const _markAsset = 'assets/brand/mark.png';
const _wordmarkAsset = 'assets/brand/wordmark.png';

/// The house-and-battery symbol, in the text ink color.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Image.asset(
    _markAsset,
    width: width,
    color: context.colors.textPrimary,
    colorBlendMode: BlendMode.srcIn,
    excludeFromSemantics: true,
  );
}

/// "Backup Brain" set in the logo's typeface.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Image.asset(
    _wordmarkAsset,
    height: height,
    color: context.colors.textPrimary,
    colorBlendMode: BlendMode.srcIn,
    excludeFromSemantics: true,
  );
}

/// Mark and wordmark side by side, for the Home app bar.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key});

  static const _markWidth = 28.0;
  static const _wordmarkHeight = 17.0;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).appTitle,
    header: true,
    excludeSemantics: true,
    // Shrinks rather than overflow next to the actions on a narrow phone.
    child: const FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandMark(width: _markWidth),
          SizedBox(width: AppSpacing.sm),
          BrandWordmark(height: _wordmarkHeight),
        ],
      ),
    ),
  );
}
