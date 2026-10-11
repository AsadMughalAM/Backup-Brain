import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fire_and_forget.dart';
import '../../domain/entities/setup_draft.dart';
import '../../domain/entities/setup_presets.dart';
import '../../domain/setup_draft_repository.dart';
import '../../domain/setup_presets_repository.dart';

/// The setup answers. Every change is one tap and is saved on the phone at
/// once, so leaving the app mid-setup loses nothing.
class SetupController extends AsyncNotifier<SetupDraft> {
  @override
  Future<SetupDraft> build() async {
    final presets = await ref.watch(setupPresetsProvider.future);
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

  /// Marks every step answered. The household is written to an account by
  /// `HouseholdSetup.adoptLocalHome`, now if signed in or right after
  /// sign-in otherwise.
  void finish() => _update((d) => d.copyWith(finished: true));
}

final setupControllerProvider =
    AsyncNotifierProvider.autoDispose<SetupController, SetupDraft>(
      SetupController.new,
    );

/// Backup time for the answers so far, so people see what they get while
/// they set up. Null until the home and battery questions are answered.
final setupPreviewProvider = Provider.autoDispose<BackupEstimate?>((ref) {
  final draft = ref.watch(setupControllerProvider).value;
  final presets = ref.watch(setupPresetsProvider).value;
  if (draft == null || presets == null) return null;
  if (!draft.homeDone || !draft.batteryDone) return null;
  final appliances = draft.toAppliances(presets, 'en');
  return const BackupCalculator().estimate(
    draft.toSystem(presets).backupInput,
    loadW: LoadPlanner.loadW([for (final a in appliances) a.load]),
  );
});
