import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fire_and_forget.dart';
import '../../../backup/domain/charge_recorder.dart';
import '../../../outages/domain/outage_repository.dart';

class ReadingController {
  ReadingController(this._ref);

  final Ref _ref;

  /// Saves the battery % read off the inverter after outage [id]. For the
  /// latest outage it is also the battery's known charge from that moment
  /// on — better than the estimate saved when the power came back; the
  /// live estimate charges on from there.
  void save(String id, double soc) {
    fireAndForget(
      _ref.read(outageRepositoryProvider).recordEndSoc(id, soc),
      'battery reading $id',
    );
    final latest = _ref.read(recentOutagesProvider).value?.firstOrNull;
    final endedAt = latest?.endedAt;
    if (latest?.id == id && endedAt != null) {
      _ref.read(chargeRecorderProvider).recordReading(soc, at: endedAt);
    }
  }
}

final readingControllerProvider = Provider<ReadingController>(
  ReadingController.new,
);
