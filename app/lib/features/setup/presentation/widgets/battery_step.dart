import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/setup_draft.dart';
import '../../domain/entities/setup_presets.dart';
import '../controllers/setup_controller.dart';
import 'label_guide.dart';
import 'setup_question.dart';

/// Step 2: battery type (described by what it looks like, since few people
/// know the chemistry), then sizes pre-set to the most common ones.
class BatteryStep extends ConsumerWidget {
  const BatteryStep({
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
    final chemistry = draft.chemistry;
    final types = [
      (BatteryChemistry.leadAcid, l10n.chemLeadAcid, l10n.chemLeadAcidHint),
      (BatteryChemistry.tubular, l10n.chemTubular, l10n.chemTubularHint),
      (BatteryChemistry.lifepo4, l10n.chemLithium, l10n.chemLithiumHint),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SetupQuestion(
          title: l10n.batteryQuestion,
          child: Column(
            children: [
              for (final (i, (type, title, hint)) in types.indexed) ...[
                if (i > 0) const BbGap.md(),
                BbChoiceCard(
                  icon: BbIcons.battery,
                  title: title,
                  subtitle: hint,
                  selected: chemistry == type,
                  onSelected: () => setup.setChemistry(type),
                ),
              ],
            ],
          ),
        ),
        // Sizes appear once the type is known, because the choices depend
        // on it.
        if (chemistry != null) ...[
          const BbGap.lg(),
          BbCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CountRow(
                  label: l10n.batteryCountLabel,
                  stepper: BbQuantityStepper(
                    value: draft.batteryCount,
                    min: presets.batteryCount.min,
                    max: presets.batteryCount.max,
                    label: l10n.batteryCountLabel,
                    decreaseLabel: l10n.fewer,
                    increaseLabel: l10n.more,
                    onChanged: setup.setBatteryCount,
                  ),
                ),
                if (!chemistry.isLeadAcidFamily) ...[
                  const BbGap.lg(),
                  SetupQuestion(
                    title: l10n.batteryVoltageLabel,
                    child: SizeChips(
                      options: presets.lithium.voltages.options,
                      selected: draft.voltageFor(presets),
                      label: Formatters.volts,
                      onSelected: setup.setVoltage,
                    ),
                  ),
                ],
                const BbGap.lg(),
                SetupQuestion(
                  title: l10n.batterySizeLabel,
                  hint: l10n.batteryLabelHint,
                  guide: LabelGuide(
                    lines: [
                      l10n.guideBattery1,
                      l10n.guideBattery2,
                      l10n.guideBattery3,
                    ],
                    highlight: 1,
                  ),
                  child: SizeChips(
                    options: presets.battery(chemistry).ampHours.options,
                    selected: draft.ampHoursFor(presets),
                    label: Formatters.ampHours,
                    onSelected: setup.setAmpHours,
                  ),
                ),
              ],
            ),
          ),
          const BbGap.xl(),
          SetupQuestion(
            title: draft.hasSolar == true
                ? l10n.inverterLabelHybrid
                : l10n.inverterLabelUps,
            hint: l10n.inverterHint,
            guide: LabelGuide(
              lines: [l10n.guideUps1, l10n.guideUps2, l10n.guideUps3],
              highlight: 1,
            ),
            child: SizeChips(
              options: draft.inverterChoices(presets).options,
              selected: draft.inverterWFor(presets),
              label: Formatters.watts,
              onSelected: setup.setInverterW,
            ),
          ),
          const BbGap.xl(),
          SetupQuestion(
            title: l10n.socQuestion,
            hint: l10n.socHint,
            child: SizeChips(
              options: presets.socChoices,
              selected: draft.soc,
              label: Formatters.percent,
              onSelected: setup.setSoc,
            ),
          ),
        ],
      ],
    );
  }
}
