import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fire_and_forget.dart';
import '../../../backup/domain/system_repository.dart';
import '../../../outages/domain/outage_repository.dart';

class ReadingController {
  ReadingController(this._ref);

  final Ref _ref;

  /// Saves the battery % read off the inverter after outage [id]. For the
  /// latest outage it is also the battery's charge now — better than the
  /// estimate set when the power came back.
  void save(String id, double soc) {
    fireAndForget(
      _ref.read(outageRepositoryProvider).recordEndSoc(id, soc),
      'battery reading $id',
    );
    final latest = _ref.read(recentOutagesProvider).value?.firstOrNull;
    if (latest?.id == id && latest?.isOngoing == false) {
      fireAndForget(
        _ref.read(systemRepositoryProvider).setSoc(soc),
        'soc from reading',
      );
    }
  }
}

final readingControllerProvider = Provider<ReadingController>(
  ReadingController.new,
);
