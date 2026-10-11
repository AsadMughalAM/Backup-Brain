import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/clock.dart';
import '../../../core/utils/formatters.dart';
import '../../backup/domain/system_repository.dart';
import '../../loads/domain/appliance_repository.dart';
import '../../solar/domain/solar_outlook.dart';

/// Everything the assistant may talk about: engine results only, already
/// rounded and formatted the way the app shows them, so the model never has
/// to calculate (TECH_STACK §3.1 snapshot mode, §7.6).
class EnergySnapshot {
  const EnergySnapshot({
    required this.facts,
    required this.backupHours,
    required this.loadW,
    this.bestSwitchOff,
    this.bestGainHours,
  });

  /// Sent to the model as JSON.
  final Map<String, Object?> facts;

  // For the template answer shown when the AI can't be reached (§7.6.4).
  final double backupHours;
  final double loadW;
  final String? bestSwitchOff;
  final double? bestGainHours;
}

/// How many single switch-offs the assistant hears about.
const _topSuggestions = 3;

/// Null until the household and its appliances have loaded.
final energySnapshotProvider = Provider<EnergySnapshot?>((ref) {
  final system = ref.watch(householdSystemProvider).value;
  final plan = ref.watch(loadPlanProvider);
  final appliances = ref.watch(appliancesProvider).value;
  final now = ref.watch(nowProvider).value ?? DateTime.now().toUtc();
  if (system == null || plan == null || appliances == null) return null;

  // Solar is a bonus: a missing or broken forecast must not silence the
  // assistant about the battery.
  SolarOutlook? outlook;
  try {
    outlook = ref.watch(solarOutlookProvider);
  } on Object {
    outlook = null;
  }
  final offset = outlook?.utcOffset ?? DateTime.now().timeZoneOffset;
  String clock(DateTime utc, {bool roundUp = false}) =>
      Formatters.clock(utc, offset, roundUp: roundUp);

  final current = plan.current;
  final best = plan.suggestions.firstOrNull;
  final combined = plan.topCombined;

  return EnergySnapshot(
    backupHours: current.hours,
    loadW: current.loadW,
    bestSwitchOff: best?.appliance.name,
    bestGainHours: best?.hoursGained,
    facts: {
      'timeNow': clock(now),
      'battery': {
        'chargeNow': Formatters.percent(system.soc),
        'backupStopsAtCharge': Formatters.percent(current.minSoc),
      },
      'inverterLimit': Formatters.watts(system.inverter.ratedW),
      'now': {
        'houseLoad': Formatters.watts(current.loadW),
        'backupTimeLeft': _duration(current.hours),
        if (!current.isUnlimited)
          'backupRunsUntilAbout': clock(_after(now, current.hours)),
        'inverterOverloaded': current.isOverloaded,
        'appliancesOn': [
          for (final a in appliances.map((a) => a.load).where((a) => a.isOn))
            {
              'name': a.name,
              'count': a.quantity,
              'load': Formatters.watts(a.effectiveW),
            },
        ],
      },
      'switchOffOne': [
        for (final s in plan.suggestions.take(_topSuggestions))
          {
            'turnOff': s.appliance.name,
            'saves': Formatters.watts(s.savedW),
            'backupTimeAfter': _duration(s.estimate.hours),
            'timeGained': _duration(s.hoursGained),
          },
      ],
      if (combined.appliances.isNotEmpty)
        'switchOffTogether': {
          'turnOff': [for (final a in combined.appliances) a.name],
          'backupTimeAfter': _duration(combined.estimate.hours),
          'timeGained': _duration(combined.hoursGained),
        },
      'solar': outlook == null
          ? null
          : {
              'city': outlook.city,
              'forecastFetchedAt': clock(outlook.fetchedAt),
              if (outlook.today case final today?)
                'today': _solarDay(today, clock),
              if (outlook.tomorrow case final tomorrow?)
                'tomorrow': _solarDay(tomorrow, clock),
            },
    },
  );
});

Map<String, Object?> _solarDay(
  SolarDayForecast day,
  String Function(DateTime, {bool roundUp}) clock,
) => {
  'expectedSolarEnergy': '${Formatters.kWhRange(day.lowKWh, day.highKWh)} kWh',
  'batteryChargeAtStart': Formatters.percent(day.startSoc),
  'batteryChargeAtSunset': Formatters.percent(day.socAtSunset),
  'batteryFullBy': day.fullAt == null
      ? null
      : clock(day.fullAt!, roundUp: true),
  'sunset': clock(day.sunset),
  'sunAlreadySet': day.sunIsOver,
};

DateTime _after(DateTime utc, double hours) =>
    utc.add(Duration(minutes: (hours * 60).floor()));

/// Same rounding as the countdown (minutes down), language-neutral.
String _duration(double hours) {
  if (hours.isInfinite) return 'unlimited';
  final minutes = (hours * 60).floor();
  final h = minutes ~/ 60, m = minutes % 60;
  return h == 0 ? '${m}m' : '${h}h ${m.toString().padLeft(2, '0')}m';
}
