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
import 'setup_question.dart';

/// Step 3: the usual appliances are already counted in; people only adjust
/// numbers. Heavy ones are listed apart and start at zero.
class AppliancesStep extends ConsumerWidget {
  const AppliancesStep({
    super.key,
    required this.draft,
    required this.presets,
    required this.languageCode,
  });

  final SetupDraft draft;
  final SetupPresets presets;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    bool heavy(AppliancePreset a) =>
        a.priority == AppliancePriority.avoidOnBackup;
    List<Widget> rows(bool heavyOnes) => [
      for (final a in presets.appliances)
        if (heavy(a) == heavyOnes)
          _ApplianceRow(
            preset: a,
            name: a.name(languageCode),
            quantity: draft.quantities[a.id] ?? 0,
          ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SetupQuestion(
          title: l10n.appliancesQuestion,
          hint: l10n.appliancesHint,
          child: BbCard.list(children: rows(false)),
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

class _ApplianceRow extends ConsumerWidget {
  const _ApplianceRow({
    required this.preset,
    required this.name,
    required this.quantity,
  });

  final AppliancePreset preset;
  final String name;
  final int quantity;

  static const _disc = 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
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
              applianceIcon(preset.iconKey),
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
                  l10n.applianceEach(Formatters.watts(preset.watts)),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
          ),
          BbQuantityStepper(
            value: quantity,
            max: 20,
            label: name,
            decreaseLabel: l10n.fewer,
            increaseLabel: l10n.more,
            onChanged: (n) => ref
                .read(setupControllerProvider.notifier)
                .setQuantity(preset.id, n),
          ),
        ],
      ),
    );
  }
}
