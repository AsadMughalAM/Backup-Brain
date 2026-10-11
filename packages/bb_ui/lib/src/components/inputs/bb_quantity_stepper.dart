import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../buttons/bb_icon_button.dart';

/// − value + for small counts (DESIGN.md §10.2), so nobody has to open a
/// keyboard to say "2 fans". Screen readers get one adjustable control:
/// swipe up or down to change it.
///
/// ```dart
/// BbQuantityStepper(
///   value: 2,
///   onChanged: (n) => controller.setQuantity('fan', n),
///   label: 'Ceiling fan',
///   decreaseLabel: l10n.fewer,
///   increaseLabel: l10n.more,
/// )
/// ```
class BbQuantityStepper extends StatelessWidget {
  const BbQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.decreaseLabel,
    required this.increaseLabel,
    this.min = 0,
    this.max = 99,
  });

  final int value;
  final ValueChanged<int> onChanged;

  /// What is being counted, for screen readers ("Ceiling fan").
  final String label;
  final String decreaseLabel;
  final String increaseLabel;
  final int min;
  final int max;

  static const _valueWidth = 32.0;

  @override
  Widget build(BuildContext context) {
    final canDecrease = value > min;
    final canIncrease = value < max;
    void decrease() => onChanged(value - 1);
    void increase() => onChanged(value + 1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: BbIconButton(
            icon: BbIcons.remove,
            tooltip: decreaseLabel,
            variant: BbIconButtonVariant.tonal,
            onPressed: canDecrease ? decrease : null,
          ),
        ),
        Semantics(
          container: true,
          label: label,
          value: '$value',
          increasedValue: canIncrease ? '${value + 1}' : null,
          decreasedValue: canDecrease ? '${value - 1}' : null,
          onIncrease: canIncrease ? increase : null,
          onDecrease: canDecrease ? decrease : null,
          // The number is announced as the value, not appended to the label.
          child: ExcludeSemantics(
            child: SizedBox(
              width: _valueWidth,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: context.text.metricSmall.copyWith(
                  color: value == 0
                      ? context.colors.textMuted
                      : context.colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        ExcludeSemantics(
          child: BbIconButton(
            icon: BbIcons.add,
            tooltip: increaseLabel,
            variant: BbIconButtonVariant.tonal,
            onPressed: canIncrease ? increase : null,
          ),
        ),
      ],
    );
  }
}
