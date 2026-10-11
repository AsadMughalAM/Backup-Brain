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
    this.guide,
  });

  final String title;
  final String? hint;
  final Widget child;

  /// Usually a `LabelGuide` for numbers printed on a sticker.
  final Widget? guide;

  @override
  Widget build(BuildContext context) {
    final hint = this.hint;
    final guide = this.guide;
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
        ?guide,
        const BbGap.md(),
        child,
      ],
    );
  }
}

/// Sizes as one-tap chips (no typing): "150 Ah", "200 Ah", … A saved size
/// that isn't a usual one (e.g. 185 Ah) gets its own chip, so editing never
/// silently changes it.
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
      for (final v
          in options.contains(selected)
              ? options
              : ([...options, selected]..sort()))
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
