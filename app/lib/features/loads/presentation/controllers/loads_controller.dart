import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fire_and_forget.dart';
import '../../../backup/domain/system_repository.dart';
import '../../domain/appliance_repository.dart';

/// User actions on the load planner. The countdown updates as soon as the
/// local cache does — no network round-trip.
class LoadsController {
  LoadsController(this._ref);

  final Ref _ref;

  void setOn(String applianceId, {required bool isOn}) => fireAndForget(
    _ref.read(applianceRepositoryProvider).setOn(applianceId, isOn: isOn),
    'appliance $applianceId on=$isOn',
  );

  /// [soc] is 0–1.
  void setSoc(double soc) =>
      fireAndForget(_ref.read(systemRepositoryProvider).setSoc(soc), 'soc');
}

final loadsControllerProvider = Provider<LoadsController>(LoadsController.new);
