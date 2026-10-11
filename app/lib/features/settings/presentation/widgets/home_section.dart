import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../backup/domain/entities/household_system.dart';
import '../../../backup/domain/system_repository.dart';

/// "My home": what the app thinks the household is, in one line, and the
/// way to change it. Hidden until there is a household.
class HomeSection extends ConsumerWidget {
  const HomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final system = ref.watch(householdSystemProvider).value;
    if (system == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.myHomeSection, style: context.textTheme.titleMedium),
        const BbGap.md(),
        BbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _summary(l10n, system),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              const BbGap.md(),
              BbButton.tonal(
                label: l10n.editHome,
                icon: BbIcons.home,
                expand: true,
                onPressed: () => context.push(Routes.editHome),
              ),
            ],
          ),
        ),
        const BbGap.xl(),
      ],
    );
  }

  static String _summary(AppLocalizations l10n, HouseholdSystem s) {
    final b = s.battery;
    final size =
        '${Formatters.volts(b.voltage)} ${Formatters.ampHours(b.ampHours)}';
    final battery = b.count > 1 ? l10n.batteryBank(b.count, size) : size;
    final city = s.location?.city ?? '';
    final solar = s.solar;
    return solar == null
        ? l10n.homeSummary(city, battery)
        : l10n.homeSummarySolar(city, battery, Formatters.kiloWatts(solar.kWp));
  }
}
