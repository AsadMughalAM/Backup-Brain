import 'package:energy_engine/energy_engine.dart';

/// The demo household from ARCHITECTURE.md §12. The demo script quotes the
/// numbers this produces, so changing it means updating §12 too.
const demoInput = BackupInput(
  battery: BatterySpec(
    chemistry: BatteryChemistry.lifepo4,
    voltage: 24,
    ampHours: 150,
  ),
  inverter: InverterSpec(type: InverterType.hybrid, ratedW: 2000),
  socNow: 0.60,
);

const fanBedroom = ApplianceLoad(
  id: 'fan-bedroom',
  name: 'Ceiling fan (bedroom)',
  watts: 75,
  priority: AppliancePriority.comfort,
);
const fanLounge = ApplianceLoad(
  id: 'fan-lounge',
  name: 'Ceiling fan (lounge)',
  watts: 75,
  priority: AppliancePriority.comfort,
);
const fridge = ApplianceLoad(
  id: 'fridge',
  name: 'Fridge',
  watts: 200,
  dutyCycle: 0.4,
  priority: AppliancePriority.comfort,
);
const tv = ApplianceLoad(
  id: 'tv',
  name: 'LED TV',
  watts: 90,
  priority: AppliancePriority.comfort,
);
const laptop = ApplianceLoad(
  id: 'laptop',
  name: 'Laptop',
  watts: 40,
  priority: AppliancePriority.comfort,
);
const router = ApplianceLoad(
  id: 'router',
  name: 'Router',
  watts: 10,
  priority: AppliancePriority.essential,
);
const ledBulbs = ApplianceLoad(
  id: 'led',
  name: 'LED bulb',
  watts: 10,
  quantity: 5,
  priority: AppliancePriority.essential,
);
const iron = ApplianceLoad(
  id: 'iron',
  name: 'Iron',
  watts: 1000,
  priority: AppliancePriority.avoidOnBackup,
);
const waterMotor = ApplianceLoad(
  id: 'motor',
  name: 'Water motor',
  watts: 750,
  priority: AppliancePriority.avoidOnBackup,
);

/// 420 W in total.
const demoAppliances = [
  fanBedroom,
  fanLounge,
  fridge,
  tv,
  laptop,
  router,
  ledBulbs,
];
