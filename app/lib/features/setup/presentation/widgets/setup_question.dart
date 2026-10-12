import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/widgets/number_entry_sheet.dart';
import '../../domain/entities/setup_presets.dart';

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

/// Sizes as one-tap chips: "150 Ah", "200 Ah", … then "Other" to type
/// the number off the sticker when it isn't listed. A size that isn't a
/// usual one (e.g. 185 Ah) gets its own chip, so editing never silently
/// changes it.
class SizeChips extends ConsumerWidget {
  const SizeChips({
    super.key,
    required this.options,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.other,
  });

  final List<double> options;
  final double selected;
  final String Function(double value) label;
  final ValueChanged<double> onSelected;

  /// What "Other" asks for; null = no "Other" chip.
  final OtherSize? other;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final other = this.other;
    final custom = !options.contains(selected);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final v in custom ? ([...options, selected]..sort()) : options)
          BbChip(
            label: label(v),
            selected: v == selected,
            onSelected: () => onSelected(v),
          ),
        if (other != null)
          BbChip(
            label: AppLocalizations.of(context).sizeOther,
            icon: BbIcons.edit,
            selected: false,
            onSelected: () async {
              final typed = await showNumberEntrySheet(
                ref,
                title: other.title,
                unit: other.unit,
                min: other.range.min,
                max: other.range.max,
                initial: custom ? selected : null,
              );
              if (typed != null) onSelected(typed);
            },
          ),
      ],
    );
  }
}

/// The typed "Other" size: its sheet title, unit and allowed range.
typedef OtherSize = ({String title, String unit, ValueRange range});

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
