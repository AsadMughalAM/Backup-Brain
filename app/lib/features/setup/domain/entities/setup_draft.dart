import 'package:energy_engine/energy_engine.dart';

import '../../../backup/domain/entities/household_system.dart';
import '../../../loads/domain/entities/appliance.dart';
import 'setup_presets.dart';

/// The answers so far, and where the user is in setup. Saved on the phone
/// after every tap, so setup resumes where it was left. Only city, "do you
/// have solar?" and battery type must be picked; every size starts on the
/// most common choice, so most people only confirm.
class SetupDraft {
  const SetupDraft({
    required this.quantities,
    required this.soc,
    required this.batteryCount,
    required this.panelCount,
    required this.panelWatts,
    this.cityId,
    this.hasSolar,
    this.chemistry,
    this.voltage,
    this.ampHours,
    this.inverterW,
    this.step = 0,
    this.finished = false,
  });

  factory SetupDraft.initial(SetupPresets p) => SetupDraft(
    quantities: {for (final a in p.appliances) a.id: a.defaultQuantity},
    soc: p.defaultSoc,
    batteryCount: p.batteryCount.fallback,
    panelCount: p.panelCount.fallback,
    panelWatts: p.panelWatts.fallback,
  );

  final String? cityId;
  final bool? hasSolar;
  final int panelCount;
  final double panelWatts;
  final BatteryChemistry? chemistry;
  final int batteryCount;

  // Null = not picked; the preset default for the chosen type applies.
  final double? voltage;
  final double? ampHours;
  final double? inverterW;

  final double soc;

  /// Appliance preset id → how many; 0 = not used.
  final Map<String, int> quantities;

  /// Zero-based step on screen.
  final int step;

  /// All steps answered; waiting to be saved to an account.
  final bool finished;

  bool get homeDone => cityId != null && hasSolar != null;
  bool get batteryDone => chemistry != null;

  double voltageFor(SetupPresets p) =>
      voltage ??
      p.battery(chemistry ?? BatteryChemistry.tubular).voltages.fallback;

  double ampHoursFor(SetupPresets p) =>
      ampHours ??
      p.battery(chemistry ?? BatteryChemistry.tubular).ampHours.fallback;

  SizeChoices inverterChoices(SetupPresets p) =>
      hasSolar == true ? p.hybridW : p.upsW;

  double inverterWFor(SetupPresets p) =>
      inverterW ?? inverterChoices(p).fallback;

  double get solarKWp => panelCount * panelWatts / 1000;

  /// The household as the engine and Firestore see it. Call only when
  /// [homeDone] and [batteryDone].
  HouseholdSystem toSystem(SetupPresets p) {
    final city = p.city(cityId!);
    return HouseholdSystem(
      battery: BatterySpec(
        chemistry: chemistry!,
        voltage: voltageFor(p),
        ampHours: ampHoursFor(p),
        count: batteryCount,
      ),
      inverter: InverterSpec(
        // Solar homes almost always run a hybrid inverter; without solar
        // it's a UPS. One question fewer for the user.
        type: hasSolar! ? InverterType.hybrid : InverterType.ups,
        ratedW: inverterWFor(p),
      ),
      soc: soc,
      solar: hasSolar! ? SolarSpec(kWp: solarKWp) : null,
      location: HomeLocation(city: city.name, site: city.site),
    );
  }

  /// Picked appliances in preset order. Heavy ones start switched off:
  /// they are "avoid on backup" by definition.
  List<Appliance> toAppliances(SetupPresets p, String languageCode) => [
    for (final (i, a) in p.appliances.indexed)
      if ((quantities[a.id] ?? 0) > 0)
        Appliance(
          id: a.id,
          name: a.name(languageCode),
          iconKey: a.iconKey,
          watts: a.watts,
          priority: a.priority,
          quantity: quantities[a.id]!,
          dutyCycle: a.dutyCycle,
          isOn: a.priority != AppliancePriority.avoidOnBackup,
          order: i,
        ),
  ];

  SetupDraft copyWith({
    String? cityId,
    bool? hasSolar,
    int? panelCount,
    double? panelWatts,
    BatteryChemistry? chemistry,
    int? batteryCount,
    double? soc,
    Map<String, int>? quantities,
    double? voltage,
    double? ampHours,
    double? inverterW,
    int? step,
    bool? finished,
    bool clearCity = false,
    bool resetBatterySizes = false,
    bool resetInverter = false,
  }) => SetupDraft(
    cityId: clearCity ? null : cityId ?? this.cityId,
    hasSolar: hasSolar ?? this.hasSolar,
    panelCount: panelCount ?? this.panelCount,
    panelWatts: panelWatts ?? this.panelWatts,
    chemistry: chemistry ?? this.chemistry,
    batteryCount: batteryCount ?? this.batteryCount,
    soc: soc ?? this.soc,
    quantities: quantities ?? this.quantities,
    voltage: resetBatterySizes ? null : voltage ?? this.voltage,
    ampHours: resetBatterySizes ? null : ampHours ?? this.ampHours,
    inverterW: resetInverter ? null : inverterW ?? this.inverterW,
    step: step ?? this.step,
    finished: finished ?? this.finished,
  );
}
