import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/overlays/overlay_host.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/appliance_icon.dart';
import '../../domain/entities/custom_appliance.dart';
import '../../domain/entities/setup_presets.dart';
import 'setup_question.dart';

/// "Add an appliance": for something the list doesn't have, or a second
/// kind of one it has (tube lights next to the LED bulbs). Picking a type
/// fills in its usual name and watts, and its common kinds are one tap, so
/// typing is only needed for the unusual. Completes with the appliance, or
/// null when closed.
Future<CustomAppliance?> showAddApplianceSheet(
  WidgetRef ref, {
  required AppLocalizations l10n,
  required SetupPresets presets,
  required String languageCode,
}) => ref
    .read(overlayHostProvider)
    .showSheet<CustomAppliance>(
      title: l10n.addApplianceTitle,
      builder: (_) =>
          _AddAppliance(presets: presets, languageCode: languageCode),
    );

class _AddAppliance extends ConsumerStatefulWidget {
  const _AddAppliance({required this.presets, required this.languageCode});

  final SetupPresets presets;
  final String languageCode;

  @override
  ConsumerState<_AddAppliance> createState() => _AddApplianceState();
}

class _AddApplianceState extends ConsumerState<_AddAppliance> {
  static const _otherIcon = 'plug';
  static const _maxQuantity = 20;

  final _name = TextEditingController();
  final _watts = TextEditingController();
  AppliancePreset? _type;
  var _iconKey = _otherIcon;
  var _quantity = 1;
  var _heavy = false;
  String? _nameError;
  String? _wattsError;

  @override
  void dispose() {
    _name.dispose();
    _watts.dispose();
    super.dispose();
  }

  void _pickType(AppliancePreset? type) => setState(() {
    _type = type;
    _iconKey = type?.iconKey ?? _otherIcon;
    _heavy = type?.priority == AppliancePriority.avoidOnBackup;
    _name.text = type?.name(widget.languageCode) ?? '';
    _watts.text = type == null ? '' : Formatters.plainNumber(type.watts);
    _nameError = _wattsError = null;
  });

  void _pickKind(ApplianceVariant kind) => setState(() {
    _name.text = kind.name(widget.languageCode);
    _watts.text = Formatters.plainNumber(kind.watts);
    _nameError = _wattsError = null;
  });

  void _add() {
    final l10n = AppLocalizations.of(context);
    final range = widget.presets.applianceWatts;
    final name = _name.text.trim();
    final watts = double.tryParse(_watts.text.trim());
    final wattsOk = watts != null && watts >= range.min && watts <= range.max;
    if (name.isEmpty || !wattsOk) {
      setState(() {
        _nameError = name.isEmpty ? l10n.addApplianceNameMissing : null;
        _wattsError = wattsOk
            ? null
            : l10n.numberOutOfRange(
                Formatters.plainNumber(range.min),
                Formatters.plainNumber(range.max),
                Formatters.wattUnit,
              );
      });
      return;
    }
    ref
        .read(overlayHostProvider)
        .close(
          CustomAppliance(
            id:
                '${CustomAppliance.idPrefix}'
                '${DateTime.now().microsecondsSinceEpoch}',
            name: name,
            iconKey: _iconKey,
            watts: watts,
            quantity: _quantity,
            heavy: _heavy,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kinds = _type?.variants ?? const <ApplianceVariant>[];
    final watts = double.tryParse(_watts.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SetupQuestion(
          title: l10n.addApplianceType,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final type in widget.presets.appliances)
                BbChip(
                  label: type.name(widget.languageCode),
                  icon: applianceIcon(type.iconKey),
                  selected: _type?.id == type.id,
                  onSelected: () => _pickType(type),
                ),
              BbChip(
                label: l10n.addApplianceOtherType,
                icon: applianceIcon(_otherIcon),
                selected: _type == null && _iconKey == _otherIcon,
                onSelected: () => _pickType(null),
              ),
            ],
          ),
        ),
        if (kinds.isNotEmpty) ...[
          const BbGap.lg(),
          SetupQuestion(
            title: l10n.addApplianceKind,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final kind in kinds)
                  BbChip(
                    label:
                        '${kind.name(widget.languageCode)} · '
                        '${Formatters.watts(kind.watts)}',
                    selected:
                        _name.text == kind.name(widget.languageCode) &&
                        watts == kind.watts,
                    onSelected: () => _pickKind(kind),
                  ),
              ],
            ),
          ),
        ],
        const BbGap.lg(),
        BbTextField(
          label: l10n.addApplianceName,
          hint: l10n.addApplianceNameHint,
          controller: _name,
          errorText: _nameError,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const BbGap.md(),
        BbTextField(
          label: l10n.addApplianceWatts,
          helper: l10n.addApplianceWattsHint,
          controller: _watts,
          errorText: _wattsError,
          suffixText: Formatters.wattUnit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
        ),
        const BbGap.lg(),
        CountRow(
          label: l10n.addApplianceHowMany,
          stepper: BbQuantityStepper(
            value: _quantity,
            min: 1,
            max: _maxQuantity,
            label: l10n.addApplianceHowMany,
            decreaseLabel: l10n.fewer,
            increaseLabel: l10n.more,
            onChanged: (n) => setState(() => _quantity = n),
          ),
        ),
        const BbGap.md(),
        MergeSemantics(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.addApplianceHeavy,
                      style: context.textTheme.titleSmall,
                    ),
                    Text(
                      l10n.addApplianceHeavyHint,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              BbSwitch(
                value: _heavy,
                onChanged: (v) => setState(() => _heavy = v),
              ),
            ],
          ),
        ),
        const BbGap.xl(),
        BbButton(label: l10n.addApplianceSave, expand: true, onPressed: _add),
      ],
    );
  }
}
