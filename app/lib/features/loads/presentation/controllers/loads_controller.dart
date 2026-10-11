import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fire_and_forget.dart';
import '../../../backup/domain/battery_estimate.dart';
import '../../../backup/domain/charge_recorder.dart';
import '../../domain/appliance_repository.dart';

/// User actions on the load planner. The countdown updates as soon as the
/// local cache does — no network round-trip.
class LoadsController {
  LoadsController(this._ref);

  final Ref _ref;

  void setOn(String applianceId, {required bool isOn}) {
    _beforeLoadChange();
    fireAndForget(
      _ref.read(applianceRepositoryProvider).setOn(applianceId, isOn: isOn),
      'appliance $applianceId on=$isOn',
    );
  }

  /// [watts] is what one of these appliances draws.
  void setWatts(String applianceId, double watts) {
    _beforeLoadChange();
    fireAndForget(
      _ref.read(applianceRepositoryProvider).setWatts(applianceId, watts),
      'appliance $applianceId watts=$watts',
    );
  }

  /// The user read the battery % off the UPS; [soc] is 0–1.
  void setSoc(double soc) => _ref.read(chargeRecorderProvider).confirm(soc);

  /// During a cut the drain so far was at the old load: save it before the
  /// load changes, so the new load only counts from now.
  void _beforeLoadChange() {
    if (_ref.read(batteryEstimateProvider)?.gridOn ?? true) return;
    _ref.read(chargeRecorderProvider).rebase();
  }
}

final loadsControllerProvider = Provider<LoadsController>(LoadsController.new);
