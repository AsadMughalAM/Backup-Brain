import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fire_and_forget.dart';
import '../../../backup/domain/system_repository.dart';
import '../../../loads/domain/appliance_repository.dart';
import '../../domain/entities/setup_draft.dart';
import '../../domain/entities/setup_presets.dart';
import '../../domain/setup_presets_repository.dart';

final setupPresetsProvider = FutureProvider<SetupPresets>(
  (ref) => ref.watch(setupPresetsRepositoryProvider).load(),
);

/// The setup answers. Every change is one tap; nothing is saved until the
/// last step, so going back and forth is free.
class SetupController extends AsyncNotifier<SetupDraft> {
  @override
  Future<SetupDraft> build() async =>
      SetupDraft.initial(await ref.watch(setupPresetsProvider.future));

  void _update(SetupDraft Function(SetupDraft d) change) {
    final draft = state.value;
    if (draft != null) state = AsyncData(change(draft));
  }

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

  /// Saves the household. Writes land in the offline cache at once; the
  /// router leaves setup as soon as the system appears there.
  void finish(String languageCode) {
    final draft = state.value;
    final presets = ref.read(setupPresetsProvider).value;
    if (draft == null || presets == null) return;
    // Appliances first, so the dashboard never shows the system with an
    // empty appliance list.
    fireAndForget(
      ref
          .read(applianceRepositoryProvider)
          .addAll(draft.toAppliances(presets, languageCode)),
      'setup appliances',
    );
    fireAndForget(
      ref.read(systemRepositoryProvider).save(draft.toSystem(presets)),
      'setup system',
    );
  }
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
