import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/locale/locale_controller.dart';
import '../../../../app/session/household_setup.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/utils/fire_and_forget.dart';
import '../../../backup/domain/entities/household_system.dart';
import '../../../backup/domain/system_repository.dart';
import '../../../loads/domain/appliance_repository.dart';
import '../../domain/entities/setup_draft.dart';
import '../../domain/entities/setup_presets.dart';
import '../../domain/setup_draft_repository.dart';
import '../../domain/setup_presets_repository.dart';

enum SetupMode {
  /// The app's first screen; answers wait on the phone for an account.
  firstRun,

  /// "Edit my home" from Settings; starts from the saved household.
  editHome,
}

/// The setup answers. Every change is one tap. In the first run each change
/// is saved on the phone at once, so leaving mid-setup loses nothing; an
/// edit stays in memory until "Save changes".
class SetupController extends AsyncNotifier<SetupDraft> {
  SetupController(this.mode);

  final SetupMode mode;

  @override
  Future<SetupDraft> build() async {
    final presets = await ref.watch(setupPresetsProvider.future);
    if (mode == SetupMode.editHome) {
      // Read, not watch: a battery % change elsewhere must not wipe edits.
      final system = await ref.read(householdSystemProvider.future);
      final appliances = await ref.read(appliancesProvider.future);
      if (system != null) {
        return SetupDraft.fromHousehold(presets, system, appliances);
      }
    }
    final saved = ref.read(setupDraftRepositoryProvider).load();
    return saved == null ? SetupDraft.initial(presets) : _fit(saved, presets);
  }

  /// A saved draft from an older preset list: drop a city that no longer
  /// exists and give new appliances their usual count.
  static SetupDraft _fit(SetupDraft saved, SetupPresets presets) =>
      saved.copyWith(
        clearCity: !presets.cities.any((c) => c.id == saved.cityId),
        quantities: {
          for (final a in presets.appliances)
            a.id: saved.quantities[a.id] ?? a.defaultQuantity,
        },
      );

  void _update(SetupDraft Function(SetupDraft d) change) {
    final draft = state.value;
    if (draft == null) return;
    final next = change(draft);
    state = AsyncData(next);
    if (mode == SetupMode.editHome) return;
    fireAndForget(
      ref.read(setupDraftRepositoryProvider).save(next),
      'setup draft',
    );
  }

  void setStep(int step) => _update((d) => d.copyWith(step: step));

  void pickCity(String id) => _update((d) => d.copyWith(cityId: id));

  /// Inverter sizes differ for UPS and hybrid, so a size picked for one
  /// goes back to the other's usual size.
  void setHasSolar(bool value) => _update(
    (d) => d.copyWith(hasSolar: value, resetInverter: d.hasSolar != value),
  );

  void setPanelCount(int n) => _update((d) => d.copyWith(panelCount: n));
  void setPanelWatts(double w) => _update((d) => d.copyWith(panelWatts: w));
  void setShading(PanelShading s) => _update((d) => d.copyWith(shading: s));

  /// Lead-acid and lithium come in different sizes; switching between the
  /// families goes back to the new family's usual size.
  void setChemistry(BatteryChemistry c) => _update(
    (d) => d.copyWith(
      chemistry: c,
      resetBatterySizes: d.chemistry?.isLeadAcidFamily != c.isLeadAcidFamily,
    ),
  );

  void setBatteryCount(int n) => _update((d) => d.copyWith(batteryCount: n));
  void setVoltage(double v) => _update((d) => d.copyWith(voltage: v));
  void setAmpHours(double ah) => _update((d) => d.copyWith(ampHours: ah));
  void setInverterW(double w) => _update((d) => d.copyWith(inverterW: w));
  void setSoc(double soc) => _update((d) => d.copyWith(soc: soc));

  void setQuantity(String applianceId, int n) =>
      _update((d) => d.copyWith(quantities: {...d.quantities, applianceId: n}));

  /// First run: marks every step answered; `HouseholdSetup.adoptLocalHome`
  /// writes it to the account, now if signed in or right after sign-in.
  /// Edit: saves over the account's household straight away.
  Future<void> finish() async {
    if (mode == SetupMode.firstRun) {
      _update((d) => d.copyWith(finished: true));
      return;
    }
    final draft = state.value;
    final presets = ref.read(setupPresetsProvider).value;
    if (draft == null || presets == null) return;
    final current = await ref.read(appliancesProvider.future);
    // Setup's list replaces the appliances it knows; anything it doesn't
    // offer stays. What the user switched on or off in the planner stays.
    final matched = [
      for (final a in current)
        if (presets.presetForIcon(a.iconKey) case final preset?)
          (appliance: a, presetId: preset.id),
    ];
    final wasOn = <String, bool>{};
    for (final m in matched) {
      wasOn[m.presetId] = (wasOn[m.presetId] ?? false) || m.appliance.isOn;
    }
    final language = ref.read(localeProvider).locale.languageCode;
    final saved = await ref.read(householdSystemProvider.future);
    ref
        .read(householdSetupProvider.notifier)
        .saveHome(
          _keepTracking(
            draft.toSystem(presets),
            saved,
            ref.read(nowProvider).value ?? DateTime.now().toUtc(),
          ),
          [
            for (final a in draft.toAppliances(presets, language))
              a.copyWith(isOn: wasOn[a.id] ?? a.isOn),
          ],
          replacing: {for (final m in matched) m.appliance.id},
        );
  }
}

/// An edit replaces the whole household, but what setup doesn't ask must
/// survive it: the battery's last known charge and its time (unless the
/// user picked a new %), and when the panels were cleaned.
HouseholdSystem _keepTracking(
  HouseholdSystem edited,
  HouseholdSystem? saved,
  DateTime now,
) {
  if (saved == null) return edited;
  final cleanedAt = saved.solar?.lastCleanedAt;
  final solar = edited.solar;
  final kept = solar == null || cleanedAt == null
      ? edited
      : edited.copyWith(
          solar: SolarSpec(
            kWp: solar.kWp,
            shading: solar.shading,
            lastCleanedAt: cleanedAt,
            performanceRatio: solar.performanceRatio,
          ),
        );
  if (edited.soc != saved.soc) {
    return kept.copyWith(socAt: now, socCheckedAt: now);
  }
  return kept.copyWith(socAt: saved.socAt, socCheckedAt: saved.socCheckedAt);
}

final setupControllerProvider = AsyncNotifierProvider.autoDispose
    .family<SetupController, SetupDraft, SetupMode>(SetupController.new);

/// Backup time for the answers so far, so people see what they get while
/// they set up. Null until the home and battery questions are answered.
final setupPreviewProvider = Provider.autoDispose
    .family<BackupEstimate?, SetupMode>((ref, mode) {
      final draft = ref.watch(setupControllerProvider(mode)).value;
      final presets = ref.watch(setupPresetsProvider).value;
      if (draft == null || presets == null) return null;
      if (!draft.homeDone || !draft.batteryDone) return null;
      final appliances = draft.toAppliances(presets, 'en');
      return const BackupCalculator().estimate(
        draft.toSystem(presets).backupInput,
        loadW: LoadPlanner.loadW([for (final a in appliances) a.load]),
      );
    });
