import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../overlays/overlay_host.dart';

/// One row of a [showSearchPicker] list.
typedef PickerOption = ({String id, String label});

/// A long list of names (cities) as a sheet with a search box on top: type
/// two letters instead of scrolling. Completes with the picked id, or null
/// when closed.
Future<String?> showSearchPicker(
  WidgetRef ref, {
  required String title,
  required List<PickerOption> options,
  String? selectedId,
}) => ref
    .read(overlayHostProvider)
    .showSheet<String>(
      title: title,
      builder: (_) => _SearchPicker(options: options, selectedId: selectedId),
    );

class _SearchPicker extends ConsumerStatefulWidget {
  const _SearchPicker({required this.options, required this.selectedId});

  final List<PickerOption> options;
  final String? selectedId;

  @override
  ConsumerState<_SearchPicker> createState() => _SearchPickerState();
}

class _SearchPickerState extends ConsumerState<_SearchPicker> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _query.trim().toLowerCase();
    // Names that start with what was typed come first, then names that
    // only contain it ("Khan" finds Rahim Yar Khan too).
    final matches = [
      for (final o in widget.options)
        if (o.label.toLowerCase().startsWith(query)) o,
      for (final o in widget.options)
        if (!o.label.toLowerCase().startsWith(query) &&
            o.label.toLowerCase().contains(query))
          o,
    ];
    void pick(String id) => ref.read(overlayHostProvider).close(id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BbTextField(
          label: l10n.searchLabel,
          pill: true,
          prefixIcon: BbIcons.search,
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _query = v),
          onSubmitted: (_) {
            if (matches.length == 1) pick(matches.single.id);
          },
        ),
        const BbGap.sm(),
        if (matches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              l10n.searchNoMatch,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ),
        for (final o in matches)
          _OptionRow(
            label: o.label,
            selected: o.id == widget.selectedId,
            onTap: () => pick(o.id),
          ),
      ],
    );
  }
}

/// Selected = check icon and bold text, not color alone.
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: selected
                          ? context.textTheme.titleSmall
                          : context.textTheme.bodyLarge,
                    ),
                  ),
                  if (selected)
                    Icon(
                      BbIcons.check,
                      size: AppSizes.iconSm,
                      color: c.textPrimary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
