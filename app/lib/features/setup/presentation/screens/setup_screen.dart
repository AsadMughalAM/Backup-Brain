import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/session/household_setup.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/setup_draft.dart';
import '../../domain/entities/setup_presets.dart';
import '../controllers/setup_controller.dart';
import '../widgets/appliances_step.dart';
import '../widgets/battery_step.dart';
import '../widgets/home_step.dart';

/// First-run setup (ARCHITECTURE.md §10): three short steps, tap-only
/// answers with common sizes pre-picked, and the backup time shown live
/// from step 2 so people see the payoff before they finish.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  var _step = 0;

  static const _steps = 3;

  bool _canContinue(SetupDraft d) => switch (_step) {
    0 => d.homeDone,
    1 => d.batteryDone,
    _ => true,
  };

  void _back() => setState(() => _step--);

  void _next(String languageCode) {
    if (_step < _steps - 1) {
      setState(() => _step++);
      return;
    }
    ref.read(setupControllerProvider.notifier).finish(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(setupControllerProvider).value;
    final presets = ref.watch(setupPresetsProvider).value;
    final languageCode = l10n.localeName.split('_').first;
    final labels = [
      l10n.setupStepHome,
      l10n.setupStepBattery,
      l10n.setupStepAppliances,
    ];

    return PopScope(
      // System back steps back through setup before leaving it.
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: BbScaffold(
        title: l10n.setupTitle,
        body: draft == null || presets == null
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BbGap.sm(),
                  BbStepIndicator(
                    labels: labels,
                    current: _step,
                    semanticLabel: l10n.setupStepOf(
                      _step + 1,
                      _steps,
                      labels[_step],
                    ),
                  ),
                  const BbGap.md(),
                  Expanded(
                    child: ListView(
                      // A fresh list per step starts at the top.
                      key: ValueKey(_step),
                      padding: const EdgeInsets.only(
                        top: AppSpacing.md,
                        bottom: AppSpacing.xl,
                      ),
                      children: [
                        _stepBody(draft, presets, languageCode),
                        if (_step == 0) ...[
                          const BbGap.xl(),
                          Text(
                            l10n.setupUnderTwoMinutes,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.textMuted,
                            ),
                          ),
                          BbButton.ghost(
                            label: l10n.setupTryDemo,
                            onPressed: () => ref
                                .read(householdSetupProvider.notifier)
                                .useDemo(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
        bottomAction: draft == null
            ? null
            : _BottomBar(
                step: _step,
                isLast: _step == _steps - 1,
                canContinue: _canContinue(draft),
                onBack: _back,
                onNext: () => _next(languageCode),
              ),
      ),
    );
  }

  Widget _stepBody(SetupDraft d, SetupPresets p, String languageCode) =>
      switch (_step) {
        0 => HomeStep(draft: d, presets: p),
        1 => BatteryStep(draft: d, presets: p),
        _ => AppliancesStep(draft: d, presets: p, languageCode: languageCode),
      };
}

/// Sticky: the live backup time (once it can be worked out) above Back and
/// Next, in the thumb zone.
class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.step,
    required this.isLast,
    required this.canContinue,
    required this.onBack,
    required this.onNext,
  });

  final int step;
  final bool isLast;
  final bool canContinue;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preview = ref.watch(setupPreviewProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (preview != null && step > 0) ...[
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                Icon(
                  BbIcons.countdown,
                  size: AppSizes.iconSm,
                  color: context.colors.textMuted,
                ),
                const BbGap.sm(),
                Expanded(
                  child: Text(
                    l10n.setupPreviewValue(
                      Formatters.duration(l10n, preview.hours),
                    ),
                    style: context.textTheme.titleSmall,
                  ),
                ),
                Text(
                  l10n.setupBackupAt(Formatters.watts(preview.loadW)),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const BbGap.md(),
        ],
        Row(
          children: [
            if (step > 0) ...[
              BbIconButton(
                icon: BbIcons.back,
                tooltip: l10n.setupBack,
                variant: BbIconButtonVariant.tonal,
                onPressed: onBack,
              ),
              const BbGap.md(),
            ],
            Expanded(
              child: BbButton(
                label: isLast ? l10n.setupFinish : l10n.setupNext,
                expand: true,
                onPressed: canContinue ? onNext : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
