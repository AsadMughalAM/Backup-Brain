import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../backup/domain/battery_estimate.dart';
import '../../../backup/domain/system_repository.dart';
import '../../../setup/domain/setup_presets_repository.dart';
import '../../domain/appliance_repository.dart';
import '../../domain/load_plan.dart';
import '../../domain/entities/appliance.dart';
import '../controllers/loads_controller.dart';
import '../../../../core/widgets/appliance_icon.dart';
import '../widgets/appliance_visuals.dart';
import '../widgets/wattage_sheet.dart';

/// F2 — live backup time at the top, "turn off first" ranking, then every
/// appliance as a toggle (DESIGN.md §11 Load Planner).
class LoadPlannerScreen extends ConsumerWidget {
  const LoadPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plan = ref.watch(loadPlanProvider);
    final system = ref.watch(householdSystemProvider).value;
    final appliances = ref.watch(appliancesProvider).value ?? const [];
    final charge = ref.watch(batteryEstimateProvider);
    final presets = ref.watch(setupPresetsProvider).value;
    final controller = ref.read(loadsControllerProvider);

    if (plan == null || system == null || charge == null) {
      return BbScaffold(title: l10n.loadsTitle, body: const SizedBox.shrink());
    }

    final byId = {for (final a in appliances) a.id: a};
    final suggestions = plan.suggestions.take(5).toList();
    final sorted = [...appliances]
      ..sort((a, b) {
        final p = a.priority.index.compareTo(b.priority.index);
        return p != 0 ? p : a.order.compareTo(b.order);
      });

    return BbScaffold(
      title: l10n.loadsTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sticky: the number the user is changing stays in view.
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: _LiveBackup(plan: plan),
          ),
          const BbGap.sm(),
          _SocSlider(soc: charge.soc, onChangeEnd: controller.setSoc),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: [
                if (plan.current.isOverloaded) ...[
                  BbBanner(
                    tone: BbBannerTone.danger,
                    title: l10n.overloadTitle,
                    message: l10n.overloadBody(
                      Formatters.watts(plan.current.loadW),
                      Formatters.watts(system.inverter.ratedW),
                    ),
                  ),
                  const BbGap.lg(),
                ],
                _SectionTitle(l10n.turnOffFirst),
                if (suggestions.isEmpty)
                  BbCard(child: Text(l10n.nothingToTurnOff))
                else ...[
                  BbCard.list(
                    children: [
                      for (final s in suggestions)
                        _SuggestionRow(
                          suggestion: s,
                          appliance: byId[s.appliance.id],
                          onTurnOff: () =>
                              controller.setOn(s.appliance.id, isOn: false),
                        ),
                    ],
                  ),
                  if (plan.suggestions.length > 1) ...[
                    const BbGap.sm(),
                    Text(
                      l10n.topCombined(
                        plan.topCombined.appliances.length,
                        Formatters.duration(
                          l10n,
                          plan.topCombined.estimate.hours,
                        ),
                      ),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ],
                const BbGap.xl(),
                _SectionTitle(l10n.appliancesSection),
                BbCard.list(
                  children: [
                    for (final a in sorted)
                      BbLoadToggleTile(
                        key: ValueKey(a.id),
                        icon: applianceIcon(a.iconKey),
                        name: a.quantity > 1
                            ? '${a.name} × ${a.quantity}'
                            : a.name,
                        watts: Formatters.watts(a.load.effectiveW),
                        priority: bbPriority(a.priority),
                        priorityLabel: priorityLabel(l10n, a.priority),
                        value: a.isOn,
                        onChanged: (on) => controller.setOn(a.id, isOn: on),
                        onEditWatts: () => showWattageSheet(
                          ref,
                          l10n,
                          a,
                          presets?.presetForIcon(a.iconKey)?.variants ??
                              const [],
                        ),
                        editWattsLabel: l10n.wattsEdit(
                          a.name,
                          Formatters.watts(a.load.effectiveW),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBackup extends StatelessWidget {
  const _LiveBackup({required this.plan});

  final LoadPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = plan.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BbMetric(
          value: Formatters.duration(l10n, current.hours),
          size: BbMetricSize.hero,
          tone: current.isOverloaded ? BbTone.danger : BbTone.neutral,
        ),
        Text(
          l10n.backupLeftAt(Formatters.watts(current.loadW)),
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Manual battery level (ManualSource, ARCHITECTURE.md F10) until an
/// inverter integration reports it. Writes only when the drag ends.
class _SocSlider extends StatefulWidget {
  const _SocSlider({required this.soc, required this.onChangeEnd});

  final double soc;
  final ValueChanged<double> onChangeEnd;

  @override
  State<_SocSlider> createState() => _SocSliderState();
}

class _SocSliderState extends State<_SocSlider> {
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = _dragging ?? widget.soc;
    return Row(
      children: [
        Text(l10n.batteryNow, style: context.textTheme.labelLarge),
        Expanded(
          child: Slider(
            value: value,
            divisions: 20,
            semanticFormatterCallback: Formatters.percent,
            onChanged: (v) => setState(() => _dragging = v),
            onChangeEnd: (v) {
              widget.onChangeEnd(v);
              setState(() => _dragging = null);
            },
          ),
        ),
        SizedBox(
          width: 48,
          child: BbMetric(
            value: Formatters.percent(value),
            size: BbMetricSize.small,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Text(text, style: context.textTheme.titleLarge),
  );
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.suggestion,
    required this.appliance,
    required this.onTurnOff,
  });

  final SwitchOffSuggestion suggestion;
  final Appliance? appliance;
  final VoidCallback onTurnOff;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appliance = this.appliance;
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.lg,
        end: AppSpacing.xs,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(
            applianceIcon(appliance?.iconKey ?? ''),
            size: AppSizes.iconSm,
            color: context.colors.textMuted,
          ),
          const BbGap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.appliance.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge,
                ),
                BbMetric(
                  value: Formatters.gained(l10n, suggestion.hoursGained),
                  size: BbMetricSize.small,
                  tone: BbTone.success,
                ),
              ],
            ),
          ),
          BbButton.ghost(
            label: l10n.turnOff,
            size: BbButtonSize.sm,
            onPressed: onTurnOff,
          ),
        ],
      ),
    );
  }
}
