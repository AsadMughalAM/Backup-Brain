import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/auth_service.dart';
import '../../../../core/utils/fire_and_forget.dart';
import '../../../backup/domain/system_repository.dart';
import '../../../loads/domain/appliance_repository.dart';

enum OnboardingStatus { idle, working, needsInternet }

class OnboardingController extends Notifier<OnboardingStatus> {
  @override
  OnboardingStatus build() => OnboardingStatus.idle;

  /// Signs in (needs the network once) and writes the demo household. The
  /// router leaves the welcome screen as soon as the system appears in the
  /// local cache, so the writes are not awaited.
  Future<void> startDemo() async {
    state = OnboardingStatus.working;
    final uid = await ref.read(authServiceProvider).ensureSignedIn();
    if (uid == null) {
      state = OnboardingStatus.needsInternet;
      return;
    }
    // Appliances first, so the dashboard never shows the system with an
    // empty appliance list.
    fireAndForget(
      ref.read(applianceRepositoryProvider).loadDemo(),
      'demo appliances',
    );
    fireAndForget(ref.read(systemRepositoryProvider).loadDemo(), 'demo system');
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingStatus>(
      OnboardingController.new,
    );
