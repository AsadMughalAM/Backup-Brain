import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';

import '../../../../app/l10n/app_localizations.dart';

/// "Where is this written?": opens, in place, a drawn sticker like the one
/// on the battery, UPS or panel with the line to read highlighted, so
/// people match what they see instead of decoding specs. Inline rather than
/// a dialog: the answer chips stay in view.
class LabelGuide extends StatefulWidget {
  const LabelGuide({super.key, required this.lines, required this.highlight});

  /// The sticker's text, top to bottom.
  final List<String> lines;

  /// Index into [lines] of the one to read.
  final int highlight;

  @override
  State<LabelGuide> createState() => _LabelGuideState();
}

class _LabelGuideState extends State<LabelGuide> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BbButton.ghost(
          label: _open ? l10n.guideHide : l10n.guideOpen,
          icon: BbIcons.info,
          size: BbButtonSize.sm,
          onPressed: () => setState(() => _open = !_open),
        ),
        AnimatedSize(
          duration: AppMotion.of(context, AppMotion.normal),
          curve: AppMotion.enter,
          alignment: Alignment.topCenter,
          child: !_open
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Semantics(
                    label: l10n.guideSemantics(widget.lines[widget.highlight]),
                    excludeSemantics: true,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: c.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final (i, line) in widget.lines.indexed)
                            i == widget.highlight
                                ? _Highlighted(line)
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.xxs,
                                    ),
                                    child: Text(
                                      line,
                                      style: context.text.metricCaption
                                          .copyWith(color: c.textMuted),
                                    ),
                                  ),
                          const BbGap.sm(),
                          Text(
                            l10n.guideCaption,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// The line to read: a coral marker plus an arrow, so it stands out by
/// shape too, not only color.
class _Highlighted extends StatelessWidget {
  const _Highlighted(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: c.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              text,
              style: context.text.metricSmall.copyWith(
                color: c.onPrimaryContainer,
              ),
            ),
          ),
          const BbGap.sm(),
          Icon(BbIcons.back, size: AppSizes.iconSm, color: c.textPrimary),
        ],
      ),
    );
  }
}
