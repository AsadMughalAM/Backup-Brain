import 'package:energy_engine/energy_engine.dart';

import '../../domain/entities/setup_draft.dart';

/// JSON for the on-device copy of the setup answers.
abstract final class SetupDraftDto {
  static Map<String, dynamic> toJson(SetupDraft d) => {
    'cityId': d.cityId,
    'hasSolar': d.hasSolar,
    'panelCount': d.panelCount,
    'panelWatts': d.panelWatts,
    'chemistry': d.chemistry?.name,
    'batteryCount': d.batteryCount,
    'voltage': d.voltage,
    'ampHours': d.ampHours,
    'inverterW': d.inverterW,
    'soc': d.soc,
    'quantities': d.quantities,
    'step': d.step,
    'finished': d.finished,
  };

  static SetupDraft fromJson(Map<String, dynamic> m) => SetupDraft(
    cityId: m['cityId'] as String?,
    hasSolar: m['hasSolar'] as bool?,
    panelCount: (m['panelCount'] as num).toInt(),
    panelWatts: (m['panelWatts'] as num).toDouble(),
    chemistry: switch (m['chemistry']) {
      null => null,
      final String name =>
        BatteryChemistry.values.asNameMap()[name] ??
            (throw FormatException('Unknown chemistry: $name')),
      final other => throw FormatException('Bad chemistry: $other'),
    },
    batteryCount: (m['batteryCount'] as num).toInt(),
    voltage: (m['voltage'] as num?)?.toDouble(),
    ampHours: (m['ampHours'] as num?)?.toDouble(),
    inverterW: (m['inverterW'] as num?)?.toDouble(),
    soc: (m['soc'] as num).toDouble(),
    quantities: {
      for (final e in (m['quantities'] as Map<String, dynamic>).entries)
        e.key: (e.value as num).toInt(),
    },
    step: (m['step'] as num?)?.toInt() ?? 0,
    finished: m['finished'] as bool? ?? false,
  );
}
