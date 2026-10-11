import 'package:backup_brain/features/backup/data/models/system_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fakes.dart';

void main() {
  testWidgets('no panels: the Solar tab offers to add them in Edit my home', (
    tester,
  ) async {
    final withoutSolar = SystemDto.fromMap({
      ...demoJson()['system'] as Map<String, dynamic>,
      'hasSolar': false,
    });
    await pumpApp(
      tester,
      auth: FakeAuthRepository(account: signedInAsAsad),
      system: FakeSystemRepository(withoutSolar),
      appliances: FakeApplianceRepository(demoAppliances()),
    );
    await tester.tap(find.text('Solar'));
    await tester.pumpAndSettle();
    expect(find.text('No solar panels added'), findsOneWidget);

    await tester.tap(find.text('Add my panels'));
    await tester.pumpAndSettle();
    expect(find.text('Edit my home'), findsWidgets);
  });
}
