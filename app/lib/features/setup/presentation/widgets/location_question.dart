import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/widgets/search_picker_sheet.dart';
import '../../domain/entities/setup_draft.dart';
import '../../domain/entities/setup_presets.dart';
import '../../domain/home_locator.dart';
import '../controllers/setup_controller.dart';
import 'setup_question.dart';

/// "Where is your home?": one tap on "Use my location" fills city and area,
/// or the user picks the city from a searchable list and types the area.
/// The line under the title says why before the phone asks (permission
/// priming), and every outcome, including a "no", leaves the manual fields
/// ready to use.
class LocationQuestion extends ConsumerStatefulWidget {
  const LocationQuestion({
    super.key,
    required this.draft,
    required this.presets,
    required this.mode,
  });

  final SetupDraft draft;
  final SetupPresets presets;
  final SetupMode mode;

  @override
  ConsumerState<LocationQuestion> createState() => _LocationQuestionState();
}

class _LocationQuestionState extends ConsumerState<LocationQuestion> {
  late final _area = TextEditingController(text: widget.draft.area);
  var _busy = false;
  FoundPlace? _found;
  LocateFailure? _failure;

  SetupController get _setup =>
      ref.read(setupControllerProvider(widget.mode).notifier);

  @override
  void didUpdateWidget(LocationQuestion old) {
    super.didUpdateWidget(old);
    // The location lookup filled the area: show it in the field.
    final area = widget.draft.area ?? '';
    if (area != _area.text.trim()) _area.text = area;
  }

  @override
  void dispose() {
    _area.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() {
      _busy = true;
      _failure = null;
      _found = null;
    });
    try {
      final place = await _setup.useMyLocation();
      if (mounted) setState(() => _found = place);
    } on LocateException catch (e) {
      if (mounted) setState(() => _failure = e.failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickCity(AppLocalizations l10n) async {
    final id = await showSearchPicker(
      ref,
      title: l10n.cityPickTitle,
      selectedId: widget.draft.cityId,
      options: [
        for (final c in widget.presets.cities) (id: c.id, label: c.name),
      ],
    );
    if (id == null) return;
    _setup.pickCity(id);
    // A hand-picked city replaces what the location said.
    setState(() => _found = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cityId = widget.draft.cityId;
    final city = cityId == null ? null : widget.presets.city(cityId);

    return SetupQuestion(
      title: l10n.cityQuestion,
      hint: l10n.locationWhy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BbButton.tonal(
            label: l10n.useMyLocation,
            icon: BbIcons.myLocation,
            loading: _busy,
            loadingLabel: l10n.locating,
            expand: true,
            onPressed: _busy ? null : _locate,
          ),
          if (_found case final found?)
            _Status(ok: true, text: _foundText(l10n, found, city)),
          if (_failure case final failure?)
            _Status(
              ok: false,
              text: switch (failure) {
                LocateFailure.denied => l10n.locationDenied,
                LocateFailure.blocked => l10n.locationBlocked,
                LocateFailure.off => l10n.locationOff,
                LocateFailure.unavailable => l10n.locationUnavailable,
              },
              action:
                  failure == LocateFailure.blocked ||
                      failure == LocateFailure.off
                  ? BbButton.ghost(
                      label: l10n.openSettings,
                      size: BbButtonSize.sm,
                      onPressed: () =>
                          ref.read(homeLocatorProvider).openSettings(failure),
                    )
                  : null,
            ),
          const BbGap.lg(),
          BbDropdown(
            label: l10n.cityLabel,
            value: city?.name,
            placeholder: l10n.cityPick,
            icon: BbIcons.location,
            onTap: () => _pickCity(l10n),
          ),
          const BbGap.xs(),
          Text(
            l10n.cityHint,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          const BbGap.lg(),
          BbTextField(
            label: l10n.areaLabel,
            hint: l10n.areaHint,
            controller: _area,
            textInputAction: TextInputAction.done,
            onChanged: _setup.setArea,
          ),
        ],
      ),
    );
  }

  /// "Gulberg III, Lahore, Pakistan", or, for a town that isn't listed,
  /// which listed city stands in for it.
  static String _foundText(
    AppLocalizations l10n,
    FoundPlace found,
    CityPreset? picked,
  ) {
    final town = found.city;
    if (picked != null &&
        town != null &&
        town.toLowerCase() != picked.name.toLowerCase()) {
      return l10n.locationNearest(town, picked.name);
    }
    final place = [
      found.area,
      town ?? picked?.name,
      found.country,
    ].nonNulls.join(', ');
    return l10n.locationFound(place);
  }
}

/// The outcome under the button: an icon and words, never color alone.
class _Status extends StatelessWidget {
  const _Status({required this.ok, required this.text, this.action});

  final bool ok;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final action = this.action;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Semantics(
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              ok ? BbIcons.success : BbIcons.warning,
              size: AppSizes.iconXs,
              color: ok ? c.success : c.warning,
            ),
            const BbGap.xs(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: context.textTheme.bodySmall),
                  ?action,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
