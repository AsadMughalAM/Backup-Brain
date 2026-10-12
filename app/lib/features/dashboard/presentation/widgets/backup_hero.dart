import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';

/// Home's hero card: the battery as a half ring that fills on arrival, the
/// backup time as the one big number inside it, and the screen's single
/// coral action. Strings come formatted from the screen.
class BackupHero extends StatelessWidget {
  const BackupHero({
    super.key,
    required this.soc,
    required this.time,
    required this.caption,
    required this.footnote,
    required this.semanticLabel,
    required this.isOverloaded,
    required this.actionLabel,
    required this.onAction,
  });

  /// Battery charge, 0–1: the ring's fill.
  final double soc;

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

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.textMuted;
    return BbCard(
      child: Column(
        children: [
          const BbGap.xs(),
          BbBackupGauge(
            soc: soc,
            semanticLabel: semanticLabel,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BbMetric(
                  value: time,
                  size: BbMetricSize.hero,
                  tone: isOverloaded ? BbTone.danger : BbTone.neutral,
                ),
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          const BbGap.md(),
          Text(
            footnote,
            textAlign: TextAlign.center,
            style: context.textTheme.labelMedium?.copyWith(color: muted),
          ),
          const BbGap.lg(),
          BbButton(
            label: actionLabel,
            icon: BbIcons.loads,
            size: BbButtonSize.lg,
            expand: true,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}
