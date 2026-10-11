import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/setup_draft.dart';
import '../../domain/entities/setup_presets.dart';
import '../controllers/setup_controller.dart';
import 'label_guide.dart';
import 'setup_question.dart';

/// Step 1: where the home is and whether it has panels. The panel
/// questions only appear after "Yes", so people without solar never see
/// them.
class HomeStep extends ConsumerWidget {
  const HomeStep({
    super.key,
    required this.draft,
    required this.presets,
    required this.mode,
  });

  final SetupDraft draft;
  final SetupPresets presets;
  final SetupMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final setup = ref.read(setupControllerProvider(mode).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SetupQuestion(
          title: l10n.cityQuestion,
          hint: l10n.cityHint,
          child: Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final city in presets.cities)
                BbChip(
                  label: city.name,
                  selected: draft.cityId == city.id,
                  onSelected: () => setup.pickCity(city.id),
                ),
            ],
          ),
        ),
        const BbGap.xl(),
        SetupQuestion(
          title: l10n.solarQuestion,
          child: Column(
            children: [
              BbChoiceCard(
                icon: BbIcons.solarPanel,
                title: l10n.solarYes,
                subtitle: l10n.solarYesHint,
                selected: draft.hasSolar == true,
                onSelected: () => setup.setHasSolar(true),
              ),
              const BbGap.md(),
              BbChoiceCard(
                icon: BbIcons.battery,
                title: l10n.solarNo,
                subtitle: l10n.solarNoHint,
                selected: draft.hasSolar == false,
                onSelected: () => setup.setHasSolar(false),
              ),
            ],
          ),
        ),
        if (draft.hasSolar == true) ...[
          const BbGap.lg(),
          BbCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CountRow(
                  label: l10n.panelCountLabel,
                  stepper: BbQuantityStepper(
                    value: draft.panelCount,
                    min: presets.panelCount.min,
                    max: presets.panelCount.max,
                    label: l10n.panelCountLabel,
                    decreaseLabel: l10n.fewer,
                    increaseLabel: l10n.more,
                    onChanged: setup.setPanelCount,
                  ),
                ),
                const BbGap.lg(),
                SetupQuestion(
                  title: l10n.panelWattsLabel,
                  hint: l10n.panelWattsHint,
                  guide: LabelGuide(
                    lines: [
                      l10n.guidePanel1,
                      l10n.guidePanel2,
                      l10n.guidePanel3,
                    ],
                    highlight: 1,
                  ),
                  child: SizeChips(
                    options: presets.panelWatts.options,
                    selected: draft.panelWatts,
                    label: Formatters.watts,
                    onSelected: setup.setPanelWatts,
                  ),
                ),
                const BbGap.md(),
                Text(
                  l10n.panelsTotal(Formatters.kiloWatts(draft.solarKWp)),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.energy.solarText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
