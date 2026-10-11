import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';

/// One question: a plain-language title, an optional hint that says where
/// to find the answer, then the answer controls.
class SetupQuestion extends StatelessWidget {
  const SetupQuestion({
    super.key,
    required this.title,
    required this.child,
    this.hint,
  });

  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hint = this.hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: context.textTheme.titleMedium),
        ),
        if (hint != null) ...[
          const BbGap.xxs(),
          Text(
            hint,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
        const BbGap.md(),
        child,
      ],
    );
  }
}

/// Sizes as one-tap chips (no typing): "150 Ah", "200 Ah", …
class SizeChips extends StatelessWidget {
  const SizeChips({
    super.key,
    required this.options,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<double> options;
  final double selected;
  final String Function(double value) label;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    children: [
      for (final v in options)
        BbChip(
          label: label(v),
          selected: v == selected,
          onSelected: () => onSelected(v),
        ),
    ],
  );
}

/// A label on the left and a − n + stepper on the right.
class CountRow extends StatelessWidget {
  const CountRow({super.key, required this.label, required this.stepper});

  final String label;
  final Widget stepper;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label, style: context.textTheme.titleSmall)),
      stepper,
    ],
  );
}
