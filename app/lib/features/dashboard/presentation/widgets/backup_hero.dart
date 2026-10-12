import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';

/// Home's hero, straight on the page: the backup time as the one big
/// number, the house, and the screen's single yellow action. Strings come
/// formatted from the screen.
class BackupHero extends StatelessWidget {
  const BackupHero({
    super.key,
    required this.time,
    required this.caption,
    required this.footnote,
    required this.semanticLabel,
    required this.isOverloaded,
    required this.actionLabel,
    required this.onAction,
  });

  /// e.g. "3h 20m".
  final String time;

  /// e.g. "left at 420 W".
  final String caption;

  /// e.g. "Stops protecting battery at 50%".
  final String footnote;

  /// The whole answer in one sentence for screen readers.
  final String semanticLabel;

  /// Shows the time in the danger tone; the screen's banner says why.
  final bool isOverloaded;

  final String actionLabel;
  final VoidCallback onAction;

  static const _houseAsset = 'assets/images/house_solar.webp';

  /// Of the cropped artwork, so the box hugs the house.
  static const _houseAspectRatio = 1.26;

  /// Beyond this the house stops growing (tablets, landscape).
  static const _houseMaxWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.textMuted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: semanticLabel,
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BbMetric(
                value: time,
                size: BbMetricSize.hero,
                tone: isOverloaded ? BbTone.danger : BbTone.neutral,
              ),
              Text(
                caption,
                style: context.textTheme.bodyLarge?.copyWith(color: muted),
              ),
              const BbGap.xs(),
              Text(
                footnote,
                style: context.textTheme.labelMedium?.copyWith(color: muted),
              ),
            ],
          ),
        ),
        const BbGap.sm(),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _houseMaxWidth),
            child: AspectRatio(
              aspectRatio: _houseAspectRatio,
              child: DecoratedBox(
                // A soft pool of light behind the house, in the card
                // surface tone, so it sits on the page in both themes.
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.6,
                    colors: [
                      context.colors.surface,
                      context.colors.surface.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: Image.asset(
                  _houseAsset,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
        const BbGap.lg(),
        BbButton(
          label: actionLabel,
          icon: BbIcons.loads,
          expand: true,
          onPressed: onAction,
        ),
      ],
    );
  }
}
