import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/locale/locale_controller.dart';
import '../../../../core/overlays/overlay_host.dart';
import '../../../../core/utils/formatters.dart';
import '../../../setup/domain/entities/setup_presets.dart';
import '../../domain/entities/appliance.dart';
import '../controllers/loads_controller.dart';

/// "Which fan?": the common kinds of [appliance] as one-tap choices, and a
/// ±5 W stepper for the exact number off the sticker. No typing.
void showWattageSheet(
  WidgetRef ref,
  AppLocalizations l10n,
  Appliance appliance,
  List<ApplianceVariant> variants,
) {
  ref
      .read(overlayHostProvider)
      .showSheet<void>(
        title: l10n.wattsTitle(appliance.name),
        builder: (_) =>
            _WattageChoices(appliance: appliance, variants: variants),
      );
}

class _WattageChoices extends ConsumerStatefulWidget {
  const _WattageChoices({required this.appliance, required this.variants});

  final Appliance appliance;
  final List<ApplianceVariant> variants;

  @override
  ConsumerState<_WattageChoices> createState() => _WattageChoicesState();
}

class _WattageChoicesState extends ConsumerState<_WattageChoices> {
  static const _step = 5.0;
  static const _min = 5.0;
  static const _max = 5000.0;

  late double _watts = widget.appliance.watts;

  void _save(double watts) {
    if (watts != widget.appliance.watts) {
      ref.read(loadsControllerProvider).setWatts(widget.appliance.id, watts);
    }
    ref.read(overlayHostProvider).close();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(localeProvider).locale.languageCode;
    final watts = Formatters.watts(_watts);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.wattsHint,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.textMuted,
          ),
        ),
        const BbGap.md(),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final v in widget.variants)
              BbChip(
                label: '${v.name(language)} · ${Formatters.watts(v.watts)}',
                selected: v.watts == widget.appliance.watts,
                onSelected: () => _save(v.watts),
              ),
          ],
        ),
        const BbGap.xl(),
        Row(
          children: [
            Expanded(
              child: Text(l10n.wattsExact, style: context.textTheme.titleSmall),
            ),
            BbIconButton(
              icon: BbIcons.remove,
              tooltip: l10n.wattsFewer,
              variant: BbIconButtonVariant.tonal,
              onPressed: _watts <= _min
                  ? null
                  : () => setState(() => _watts -= _step),
            ),
            SizedBox(
              width: 96,
              child: Semantics(
                label: '${l10n.wattsExact} $watts',
                liveRegion: true,
                excludeSemantics: true,
                child: Text(
                  watts,
                  textAlign: TextAlign.center,
                  style: context.text.metricMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ),
            BbIconButton(
              icon: BbIcons.add,
              tooltip: l10n.wattsMore,
              variant: BbIconButtonVariant.tonal,
              onPressed: _watts >= _max
                  ? null
                  : () => setState(() => _watts += _step),
            ),
          ],
        ),
        const BbGap.lg(),
        BbButton(
          label: l10n.done,
          expand: true,
          onPressed: () => _save(_watts),
        ),
      ],
    );
  }
}
