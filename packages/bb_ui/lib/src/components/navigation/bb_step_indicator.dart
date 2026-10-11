import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';

/// Where the user is in a short stepped flow (DESIGN.md §10.5): numbered
/// circles joined by a line, each with its label. Done = check icon on the
/// success tint, current = navy with its number, upcoming = muted. Shape
/// and icon carry the state too, never color alone.
///
/// ```dart
/// BbStepIndicator(
///   labels: [l10n.stepHome, l10n.stepBattery, l10n.stepAppliances],
///   current: 1,
///   semanticLabel: l10n.stepOf(2, 3, l10n.stepBattery),
/// )
/// ```
class BbStepIndicator extends StatelessWidget {
  const BbStepIndicator({
    super.key,
    required this.labels,
    required this.current,
    required this.semanticLabel,
  }) : assert(current >= 0 && current < labels.length);

  final List<String> labels;

  /// Zero-based index of the step on screen.
  final int current;

  /// e.g. "Step 2 of 3: Battery".
  final String semanticLabel;

  static const _dot = 28.0;
  static const _line = 2.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color lineColor(bool done) => done ? c.success : c.outlineVariant;

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, label) in labels.indexed)
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: i == 0
                            ? const SizedBox.shrink()
                            : Container(
                                height: _line,
                                color: lineColor(i <= current),
                              ),
                      ),
                      _Dot(index: i, current: current, size: _dot),
                      Expanded(
                        child: i == labels.length - 1
                            ? const SizedBox.shrink()
                            : Container(
                                height: _line,
                                color: lineColor(i < current),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: i <= current ? c.textPrimary : c.textMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index, required this.current, required this.size});

  final int index;
  final int current;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = index < current;
    final (fill, fg) = done
        ? (c.successContainer, c.success)
        : index == current
        ? (c.secondary, c.onSecondary)
        : (c.surfaceMuted, c.textMuted);
    final mark = done
        ? Icon(BbIcons.check, size: AppSizes.iconXs, color: fg)
        // The digit must fit the fixed circle at any text scale; the label
        // below scales normally.
        : MediaQuery.withNoTextScaling(
            child: Text(
              '${index + 1}',
              style: context.text.metricCaption.copyWith(color: fg),
            ),
          );
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        child: Center(child: mark),
      ),
    );
  }
}
