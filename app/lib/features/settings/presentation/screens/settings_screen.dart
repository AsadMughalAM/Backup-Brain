import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/locale/locale_controller.dart';
import '../../../../app/theme_mode/theme_mode_controller.dart';
import '../widgets/account_section.dart';
import '../widgets/home_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(themeModeProvider);
    final language = ref.watch(localeProvider);

    return BbScaffold(
      title: l10n.settings,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          const AccountSection(),
          const BbGap.xl(),
          const HomeSection(),
          Text(l10n.settingsTheme, style: context.textTheme.titleMedium),
          const BbGap.md(),
          _Choices(
            options: [
              (ThemeMode.system, l10n.themeSystem, BbIcons.themeSystem),
              (ThemeMode.light, l10n.themeLight, BbIcons.themeLight),
              (ThemeMode.dark, l10n.themeDark, BbIcons.themeDark),
            ],
            selected: mode,
            onSelect: ref.read(themeModeProvider.notifier).set,
          ),
          const BbGap.xl(),
          Text(l10n.settingsLanguage, style: context.textTheme.titleMedium),
          const BbGap.md(),
          _Choices(
            options: [
              (AppLanguage.english, l10n.languageEnglish, null),
              (AppLanguage.romanUrdu, l10n.languageRomanUrdu, null),
            ],
            selected: language,
            onSelect: ref.read(localeProvider.notifier).set,
          ),
        ],
      ),
    );
  }
}

/// Selected = navy secondary, others tonal (DESIGN.md §2.1: selected
/// states are navy). Stands in for BbSegmentedControl until it exists.
class _Choices<T> extends StatelessWidget {
  const _Choices({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<(T, String, IconData?)> options;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      for (final (value, label, icon) in options)
        BbButton(
          label: label,
          icon: icon,
          variant: value == selected
              ? BbButtonVariant.secondary
              : BbButtonVariant.tonal,
          onPressed: () => onSelect(value),
        ),
    ],
  );
}
