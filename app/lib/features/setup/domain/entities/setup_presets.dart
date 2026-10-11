import 'package:energy_engine/energy_engine.dart';

/// One-tap answers for setup, from the bundled JSON in `assets/data/`
/// (config over code: sizes and wattages are data, not code).
class SetupPresets {
  const SetupPresets({
    required this.cities,
    required this.appliances,
    required this.leadAcid,
    required this.lithium,
    required this.batteryCount,
    required this.upsW,
    required this.hybridW,
    required this.panelWatts,
    required this.panelCount,
    required this.socChoices,
    required this.defaultSoc,
  });

  final List<CityPreset> cities;
  final List<AppliancePreset> appliances;
  final BatteryPreset leadAcid;
  final BatteryPreset lithium;
  final CountRange batteryCount;
  final SizeChoices upsW;
  final SizeChoices hybridW;
  final SizeChoices panelWatts;
  final CountRange panelCount;

  /// "How full is it now?" answers, as fractions 0–1.
  final List<double> socChoices;
  final double defaultSoc;

  /// Lead-acid and tubular share sizes; lithium packs differ.
  BatteryPreset battery(BatteryChemistry chemistry) =>
      chemistry.isLeadAcidFamily ? leadAcid : lithium;

  CityPreset city(String id) => cities.firstWhere((c) => c.id == id);

  /// The listed city closest to [site]. Plain degree distance is enough to
  /// tell Pakistani cities apart.
  CityPreset nearestCity(SiteLocation site) => cities.reduce(
    (best, c) =>
        _distance(c.site, site) < _distance(best.site, site) ? c : best,
  );

  /// The preset a saved appliance counts as, matched by its icon key (the
  /// appliance type). Null for anything setup doesn't offer.
  AppliancePreset? presetForIcon(String iconKey) {
    for (final a in appliances) {
      if (a.iconKey == iconKey) return a;
    }
    return null;
  }

  static double _distance(SiteLocation a, SiteLocation b) =>
      (a.lat - b.lat) * (a.lat - b.lat) + (a.lon - b.lon) * (a.lon - b.lon);
}

class CityPreset {
  const CityPreset({required this.id, required this.name, required this.site});

  final String id;
  final String name;
  final SiteLocation site;
}

class AppliancePreset {
  const AppliancePreset({
    required this.id,
    required this.names,
    required this.iconKey,
    required this.watts,
    required this.dutyCycle,
    required this.priority,
    required this.defaultQuantity,
  });

  final String id;

  /// By language code; English is always there.
  final Map<String, String> names;
  final String iconKey;
  final double watts;
  final double dutyCycle;
  final AppliancePriority priority;

  /// What a usual home runs on backup; 0 = offered, not picked.
  final int defaultQuantity;

  String name(String languageCode) => names[languageCode] ?? names['en']!;
}

class BatteryPreset {
  const BatteryPreset({required this.voltages, required this.ampHours});

  /// One choice for lead-acid (12 V units); several for lithium packs.
  final SizeChoices voltages;
  final SizeChoices ampHours;
}

/// Sizes offered as chips, plus the one pre-selected.
class SizeChoices {
  const SizeChoices({required this.options, required this.fallback});

  final List<double> options;
  final double fallback;
}

class CountRange {
  const CountRange({
    required this.min,
    required this.max,
    required this.fallback,
  });

  final int min;
  final int max;
  final int fallback;
}
