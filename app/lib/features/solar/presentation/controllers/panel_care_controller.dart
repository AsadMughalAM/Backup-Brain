import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/clock.dart';
import '../../../../core/utils/fire_and_forget.dart';
import '../../../backup/domain/system_repository.dart';

/// "Cleaned today": clean panels make up to 10% more (F3 soiling factor).
class PanelCare {
  PanelCare(this._ref);

  final Ref _ref;

  void cleanedToday() => fireAndForget(
    _ref
        .read(systemRepositoryProvider)
        .setPanelsCleaned(
          _ref.read(nowProvider).value ?? DateTime.now().toUtc(),
        ),
    'panels cleaned',
  );
}

final panelCareProvider = Provider<PanelCare>(PanelCare.new);
