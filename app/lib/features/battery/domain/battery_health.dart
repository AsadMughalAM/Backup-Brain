import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backup/domain/system_repository.dart';
import '../../outages/domain/outage_repository.dart';

/// F6 health from the outages where the user entered the real battery %.
/// Null until there are enough readings (engine decides how many).
final batteryHealthProvider = Provider<BatteryHealth?>((ref) {
  final system = ref.watch(householdSystemProvider).value;
  final outages = ref.watch(recentOutagesProvider).value ?? const [];
  if (system == null) return null;
  return const BatteryHealthMonitor().assess(
    system.battery,
    system.inverter,
    _sessions(outages),
  );
});

/// How many usable readings exist, for "1 of 3 readings".
final healthReadingsProvider = Provider<int>(
  (ref) => _sessions(ref.watch(recentOutagesProvider).value ?? const []).length,
);

/// Finished outages without a measured battery % yet, newest first: the
/// ones worth asking about.
final outagesAwaitingReadingProvider = Provider<List<OutageEvent>>(
  (ref) => [
    for (final o in ref.watch(recentOutagesProvider).value ?? const [])
      if (!o.isOngoing &&
          !o.endSocMeasured &&
          o.startSoc != null &&
          o.avgLoadW != null)
        o,
  ],
);

/// Oldest first, as the engine expects.
List<DischargeSession> _sessions(List<OutageEvent> outages) => [
  for (final o in outages.reversed)
    if (o.endSocMeasured &&
        o.endedAt != null &&
        o.startSoc != null &&
        o.endSoc != null &&
        o.avgLoadW != null)
      DischargeSession(
        startSoc: o.startSoc!,
        endSoc: o.endSoc!,
        avgLoadW: o.avgLoadW!,
        hours: o.endedAt!.difference(o.startedAt).inMinutes / 60,
      ),
];
