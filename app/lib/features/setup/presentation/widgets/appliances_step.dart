import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/appliance_icon.dart';
import '../../domain/entities/setup_draft.dart';
import '../../domain/entities/setup_presets.dart';
import '../controllers/setup_controller.dart';
import 'add_appliance_sheet.dart';
import 'setup_question.dart';

/// Step 3: the usual appliances are already counted in; people only adjust
/// numbers. Heavy ones are listed apart and start at zero. Anything the
/// list lacks, or another kind of one it has, is added under the list.
class AppliancesStep extends ConsumerWidget {
  const AppliancesStep({
    super.key,
    required this.draft,
    required this.presets,
    required this.languageCode,
    required this.mode,
  });

  final SetupDraft draft;
  final SetupPresets presets;
  final String languageCode;
  final SetupMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final setup = ref.read(setupControllerProvider(mode).notifier);
    bool heavy(AppliancePreset a) =>
        a.priority == AppliancePriority.avoidOnBackup;
    List<Widget> rows(bool heavyOnes) => [
      for (final a in presets.appliances)
        if (heavy(a) == heavyOnes)
          _ApplianceRow(
            iconKey: a.iconKey,
            name: a.name(languageCode),
            watts: a.watts,
            quantity: draft.quantities[a.id] ?? 0,
            onChanged: (n) => setup.setQuantity(a.id, n),
          ),
      for (final a in draft.customAppliances)
        if (a.heavy == heavyOnes)
          _ApplianceRow(
            iconKey: a.iconKey,
            name: a.name,
            watts: a.watts,
            quantity: a.quantity,
            onChanged: (n) => setup.setAddedQuantity(a.id, n),
            onRemove: () => setup.removeAppliance(a.id),
          ),
    ];

    Future<void> add() async {
      final added = await showAddApplianceSheet(
        ref,
        l10n: l10n,
        presets: presets,
        languageCode: languageCode,
      );
      if (added != null) setup.addAppliance(added);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SetupQuestion(
          title: l10n.appliancesQuestion,
          hint: l10n.appliancesHint,
          child: BbCard.list(children: rows(false)),
        ),
        const BbGap.md(),
        BbButton.tonal(
          label: l10n.addApplianceOpen,
          icon: BbIcons.add,
          expand: true,
          onPressed: add,
        ),
        const BbGap.xs(),
        Text(
          l10n.addApplianceOpenHint,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textMuted,
          ),
        ),
        const BbGap.xl(),
        SetupQuestion(
          title: l10n.heavyTitle,
          hint: l10n.heavyHint,
          child: BbCard.list(children: rows(true)),
        ),
      ],
    );
  }
}

class _ApplianceRow extends StatelessWidget {
  const _ApplianceRow({
    required this.iconKey,
    required this.name,
    required this.watts,
    required this.quantity,
    required this.onChanged,
    this.onRemove,
  });

  final String iconKey;
  final String name;
  final double watts;
  final int quantity;
  final ValueChanged<int> onChanged;

  /// Only for appliances the user added.
  final VoidCallback? onRemove;

  static const _disc = 40.0;
  static const _maxQuantity = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final onRemove = this.onRemove;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: _disc,
            height: _disc,
            decoration: BoxDecoration(
              color: c.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              applianceIcon(iconKey),
              size: AppSizes.iconSm,
              color: quantity > 0 ? c.textPrimary : c.textMuted,
            ),
          ),
          const BbGap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: context.textTheme.bodyLarge),
                Text(
                  l10n.applianceEach(Formatters.watts(watts)),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            BbIconButton(
              icon: BbIcons.delete,
              tooltip: l10n.addApplianceRemove(name),
              onPressed: onRemove,
            ),
          BbQuantityStepper(
            value: quantity,
            max: _maxQuantity,
            label: name,
            decreaseLabel: l10n.fewer,
            increaseLabel: l10n.more,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
