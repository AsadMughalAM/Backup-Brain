import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/fire_and_forget.dart';
import '../../domain/outage_repository.dart';

/// Schedule edits. Offline-first: the list updates from the local cache.
class ScheduleController {
  ScheduleController(this._ref);

  final Ref _ref;

  /// One slot per picked day, all with the same times.
  void add({
    required Set<int> weekdays,
    required int startMinute,
    required int endMinute,
  }) {
    final repo = _ref.read(outageRepositoryProvider);
    for (final day in weekdays) {
      fireAndForget(
        repo.addSlot(
          ScheduleSlot(
            weekday: day,
            startMinute: startMinute,
            endMinute: endMinute,
          ),
        ),
        'schedule add',
      );
    }
  }

  void remove(String id) => fireAndForget(
    _ref.read(outageRepositoryProvider).removeSlot(id),
    'schedule remove $id',
  );
}

final scheduleControllerProvider = Provider<ScheduleController>(
  ScheduleController.new,
);
