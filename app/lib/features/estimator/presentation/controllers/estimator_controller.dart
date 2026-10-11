import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../backup/domain/system_repository.dart';
import '../../../loads/domain/appliance_repository.dart';
import '../../../setup/domain/entities/setup_presets.dart';
import '../../../setup/domain/setup_presets_repository.dart';
import '../../domain/pricing_repository.dart';

enum UsageUnit { units, bill }

class EstimatorForm {
  const EstimatorForm({
    this.unit = UsageUnit.units,
    this.amount,
    this.cityId,
    this.goal = SolarGoal.both,
    this.backupHours = 4,
    this.nightLoadW,
  });

  final UsageUnit unit;

  /// Units or rupees per month, per [unit]; null until typed.
  final double? amount;

  /// Null = the household's city, else the first preset.
  final String? cityId;
  final SolarGoal goal;
  final int backupHours;

  /// Null = the household's current load, else a typical night.
  final double? nightLoadW;

  EstimatorForm copyWith({
    UsageUnit? unit,
    double? Function()? amount,
    String? cityId,
    SolarGoal? goal,
    int? backupHours,
    double? Function()? nightLoadW,
  }) => EstimatorForm(
    unit: unit ?? this.unit,
    amount: amount == null ? this.amount : amount(),
    cityId: cityId ?? this.cityId,
    goal: goal ?? this.goal,
    backupHours: backupHours ?? this.backupHours,
    nightLoadW: nightLoadW == null ? this.nightLoadW : nightLoadW(),
  );
}

/// Kept for the session, so leaving and coming back keeps the answers.
class EstimatorController extends Notifier<EstimatorForm> {
  @override
  EstimatorForm build() => const EstimatorForm();

  void setUnit(UsageUnit unit) => state = state.copyWith(unit: unit);
  void setAmount(double? v) => state = state.copyWith(amount: () => v);
  void setCity(String id) => state = state.copyWith(cityId: id);
  void setGoal(SolarGoal goal) => state = state.copyWith(goal: goal);
  void setBackupHours(int h) => state = state.copyWith(backupHours: h);
  void setNightLoad(double? w) => state = state.copyWith(nightLoadW: () => w);
}

final estimatorControllerProvider =
    NotifierProvider<EstimatorController, EstimatorForm>(
      EstimatorController.new,
    );

final estimatorCitiesProvider = Provider<List<CityPreset>>(
  (ref) => ref.watch(setupPresetsProvider).value?.cities ?? const [],
);

/// Fans, lights and a fridge: a typical night when the user has no home set
/// up and didn't say.
const typicalNightLoadW = 500.0;

class EstimatorResult {
  const EstimatorResult({
    required this.sheet,
    required this.city,
    required this.nightLoadW,
    required this.monthlyKWh,
    this.packages,
  });

  final PriceSheet sheet;
  final CityPreset city;
  final double nightLoadW;
  final double? monthlyKWh;

  /// Null until the monthly use is entered.
  final List<SolarPackage>? packages;
}

/// Null until prices and city presets have loaded. Every package number
/// comes from the engine's `SolarSizing`.
final estimatorResultProvider = Provider<EstimatorResult?>((ref) {
  final form = ref.watch(estimatorControllerProvider);
  final sheet = ref.watch(priceSheetProvider).value;
  final presets = ref.watch(setupPresetsProvider).value;
  if (sheet == null || presets == null || presets.cities.isEmpty) return null;

  final home = ref.watch(householdSystemProvider).value?.location;
  final city =
      presets.cities.where((c) => c.id == form.cityId).firstOrNull ??
      (home == null ? null : presets.nearestCity(home.site)) ??
      presets.cities.first;
  final nightLoadW =
      form.nightLoadW ??
      ref.watch(loadPlanProvider)?.current.loadW ??
      typicalNightLoadW;

  final amount = form.amount;
  final monthlyKWh = amount == null || amount <= 0
      ? null
      : form.unit == UsageUnit.units
      ? amount
      : amount / sheet.pricing.tariffPerUnit;
  final psh = city.psh;

  return EstimatorResult(
    sheet: sheet,
    city: city,
    nightLoadW: nightLoadW,
    monthlyKWh: monthlyKWh,
    packages: monthlyKWh == null || psh == null
        ? null
        : const SolarSizing().packages(
            SizingInput(
              monthlyKWh: monthlyKWh,
              psh: psh,
              nightLoadW: nightLoadW,
              backupHours: form.backupHours.toDouble(),
              goal: form.goal,
            ),
            sheet.pricing,
          ),
  );
});
