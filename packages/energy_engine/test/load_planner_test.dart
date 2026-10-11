import 'package:energy_engine/energy_engine.dart';
import 'package:test/test.dart';

import 'fixtures/demo_household.dart';

const _planner = LoadPlanner();

// usable energy × efficiency for the demo battery: 3600 × 0.45 × 0.90.
const _demoWh = 1458.0;

ApplianceLoad _off(ApplianceLoad a) => ApplianceLoad(
  id: a.id,
  name: a.name,
  watts: a.watts,
  quantity: a.quantity,
  dutyCycle: a.dutyCycle,
  priority: a.priority,
  isOn: false,
);

void main() {
  group('normal case (demo household)', () {
    final plan = _planner.plan(demoInput, appliances: demoAppliances);

    test('total load is 420 W', () {
      expect(LoadPlanner.loadW(demoAppliances), closeTo(420, 1e-9));
      expect(plan.current.loadW, closeTo(420, 1e-9));
    });

    test(
      'ranks by effective watts, keeps list order on ties, skips essentials',
      () {
        expect(plan.suggestions.map((s) => s.appliance.id), [
          'tv',
          'fridge',
          'fan-bedroom',
          'fan-lounge',
          'laptop',
        ]);
      },
    );

    test('marginal gain is backup(load − W) − backup(load)', () {
      final first = plan.suggestions.first;
      expect(first.savedW, 90);
      expect(first.hoursGained, closeTo(_demoWh / 330 - _demoWh / 420, 1e-9));
    });

    test('top 3 combined: TV + fridge + one fan → 175 W', () {
      expect(plan.topCombined.appliances.map((a) => a.id), [
        'tv',
        'fridge',
        'fan-bedroom',
      ]);
      expect(plan.topCombined.estimate.hours, closeTo(_demoWh / 175, 1e-9));
    });

    test('demo step 3: top two off gives 5 h 49 min (ARCHITECTURE §12)', () {
      final p = _planner.plan(
        demoInput,
        appliances: demoAppliances,
        combineTop: 2,
      );
      expect(p.topCombined.estimate.loadW, closeTo(250, 1e-9));
      expect((p.topCombined.estimate.hours * 60).floor(), 5 * 60 + 49);
    });
  });

  group('target duration', () {
    test('greedy picks the shortest ranked prefix that reaches it', () {
      final p = _planner.plan(
        demoInput,
        appliances: demoAppliances,
        targetHours: 5,
      );
      expect(p.toReachTarget!.appliances.map((a) => a.id), ['tv', 'fridge']);
      expect(p.targetReached, isTrue);
    });

    test('already met needs no switch-offs', () {
      final p = _planner.plan(
        demoInput,
        appliances: demoAppliances,
        targetHours: 3,
      );
      expect(p.toReachTarget!.appliances, isEmpty);
      expect(p.targetReached, isTrue);
    });

    test('unreachable switches off every candidate and reports it', () {
      final p = _planner.plan(
        demoInput,
        appliances: demoAppliances,
        targetHours: 30,
      );
      expect(p.toReachTarget!.appliances, hasLength(5));
      // Only essentials (60 W) remain.
      expect(p.toReachTarget!.estimate.hours, closeTo(_demoWh / 60, 1e-9));
      expect(p.targetReached, isFalse);
    });

    test('no target means no target plan', () {
      final p = _planner.plan(demoInput, appliances: demoAppliances);
      expect(p.toReachTarget, isNull);
      expect(p.targetReached, isFalse);
    });
  });

  group('overload and priorities', () {
    test('demo step 2: iron + motor overload, and are ranked first', () {
      final p = _planner.plan(
        demoInput,
        appliances: [...demoAppliances, iron, waterMotor],
      );
      expect(p.current.loadW, closeTo(2170, 1e-9));
      expect(p.current.isOverloaded, isTrue);
      expect(p.suggestions.take(3).map((s) => s.appliance.id), [
        'iron',
        'motor',
        'tv',
      ]);
    });

    test('appliances that are off are ignored', () {
      final p = _planner.plan(
        demoInput,
        appliances: [...demoAppliances, _off(iron)],
      );
      expect(p.current.loadW, closeTo(420, 1e-9));
      expect(p.suggestions.map((s) => s.appliance.id), isNot(contains('iron')));
    });
  });

  group('zero load', () {
    test('everything off: unlimited backup, nothing to suggest', () {
      final p = _planner.plan(
        demoInput,
        appliances: demoAppliances.map(_off).toList(),
      );
      expect(p.current.isUnlimited, isTrue);
      expect(p.suggestions, isEmpty);
      expect(p.topCombined.hoursGained, 0);
    });

    test('a 0 W appliance left on gains 0 h, not NaN', () {
      const charger = ApplianceLoad(
        id: 'idle',
        name: 'Idle charger',
        watts: 0,
        priority: AppliancePriority.comfort,
      );
      final p = _planner.plan(demoInput, appliances: [charger]);
      expect(p.suggestions.single.hoursGained, 0);
    });
  });

  group('SoC at minimum', () {
    test('every option is 0 h and gains nothing', () {
      const input = BackupInput(
        battery: BatterySpec(
          chemistry: BatteryChemistry.lifepo4,
          voltage: 24,
          ampHours: 150,
        ),
        inverter: InverterSpec(type: InverterType.hybrid, ratedW: 2000),
        socNow: 0.15,
      );
      final p = _planner.plan(input, appliances: demoAppliances);
      expect(p.current.hours, 0);
      expect(p.suggestions.every((s) => s.hoursGained == 0), isTrue);
    });
  });

  group('lead-acid vs LiFePO4', () {
    // 12 V × 100 Ah = 1200 Wh → 0.2C derate threshold at 240 W.
    BackupInput bank(BatteryChemistry c) => BackupInput(
      battery: BatterySpec(chemistry: c, voltage: 12, ampHours: 100),
      inverter: const InverterSpec(type: InverterType.ups, ratedW: 1000),
      socNow: 1.0,
    );
    const appliances = [
      ApplianceLoad(
        id: 'fans',
        name: 'Fans',
        watts: 75,
        quantity: 3,
        priority: AppliancePriority.comfort,
      ),
      ApplianceLoad(
        id: 'tv',
        name: 'TV',
        watts: 80,
        priority: AppliancePriority.comfort,
      ),
    ];

    test('lead-acid: switching off below 0.2C also removes the derate', () {
      final p = _planner.plan(
        bank(BatteryChemistry.leadAcid),
        appliances: appliances,
      );
      expect(p.current.isDerated, isTrue); // 305 W
      final tvOff = p.suggestions.firstWhere((s) => s.appliance.id == 'tv');
      expect(tvOff.estimate.isDerated, isFalse); // 225 W
      expect(tvOff.estimate.hours, closeTo(600 * 0.85 / 225, 1e-9));
    });

    test('LiFePO4 has no derate jump', () {
      final p = _planner.plan(
        bank(BatteryChemistry.lifepo4),
        appliances: appliances,
      );
      expect(p.current.isDerated, isFalse);
      expect(p.current.hours, closeTo(1020 * 0.85 / 305, 1e-9));
    });
  });

  group('invalid input', () {
    ApplianceLoad bad({double watts = 50, int qty = 1, double duty = 1}) =>
        ApplianceLoad(
          id: 'x',
          name: 'X',
          watts: watts,
          quantity: qty,
          dutyCycle: duty,
          priority: AppliancePriority.comfort,
        );

    test('bad appliance values', () {
      for (final a in [
        bad(watts: -1),
        bad(qty: 0),
        bad(duty: 0),
        bad(duty: 1.5),
      ]) {
        expect(
          () => _planner.plan(demoInput, appliances: [a]),
          throwsArgumentError,
        );
      }
    });

    test('non-positive target or combineTop', () {
      expect(
        () => _planner.plan(
          demoInput,
          appliances: demoAppliances,
          targetHours: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () =>
            _planner.plan(demoInput, appliances: demoAppliances, combineTop: 0),
        throwsArgumentError,
      );
    });
  });
}
