import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../controllers/schedule_controller.dart';

/// Adds one load-shedding time for one or more days. A full screen rather
/// than a dialog: no OverlayHost exists yet (TECH_STACK §7.1 rule 8), and
/// back is "cancel".
class AddScheduleTimeScreen extends ConsumerStatefulWidget {
  const AddScheduleTimeScreen({super.key});

  @override
  ConsumerState<AddScheduleTimeScreen> createState() =>
      _AddScheduleTimeScreenState();
}

class _AddScheduleTimeScreenState extends ConsumerState<AddScheduleTimeScreen> {
  final _days = <int>{};

  // DISCO schedules run in whole or half hours; evening is the common case.
  int _from = 19 * 60;
  int _to = 21 * 60;
  bool _triedSave = false;

  static const _step = 30;
  static const _day = Duration.minutesPerDay;

  void _save() {
    if (_days.isEmpty) {
      setState(() => _triedSave = true);
      return;
    }
    ref
        .read(scheduleControllerProvider)
        .add(weekdays: _days, startMinute: _from, endMinute: _to);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BbScaffold(
      title: l10n.scheduleAdd,
      bottomAction: BbButton(
        label: l10n.scheduleSave,
        size: BbButtonSize.lg,
        expand: true,
        onPressed: _save,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          Text(l10n.scheduleDays, style: context.textTheme.titleMedium),
          const BbGap.md(),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var d = DateTime.monday; d <= DateTime.sunday; d++)
                BbChip(
                  label: l10n.weekdayShort('$d'),
                  selected: _days.contains(d),
                  onSelected: () => setState(
                    () => _days.contains(d) ? _days.remove(d) : _days.add(d),
                  ),
                ),
            ],
          ),
          if (_triedSave && _days.isEmpty) ...[
            const BbGap.sm(),
            Row(
              children: [
                Icon(
                  BbIcons.warning,
                  size: AppSizes.iconXs,
                  color: context.colors.danger,
                ),
                const BbGap.xs(),
                Text(
                  l10n.scheduleNeedDay,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.danger,
                  ),
                ),
              ],
            ),
          ],
          const BbGap.xl(),
          _TimeStepper(
            label: l10n.scheduleFrom,
            minute: _from,
            onChanged: (m) => setState(() => _from = m),
          ),
          const BbGap.lg(),
          _TimeStepper(
            label: l10n.scheduleTo,
            minute: _to,
            onChanged: (m) => setState(() => _to = m),
          ),
        ],
      ),
    );
  }
}

/// Half-hour steps, wrapping round midnight.
class _TimeStepper extends StatelessWidget {
  const _TimeStepper({
    required this.label,
    required this.minute,
    required this.onChanged,
  });

  final String label;
  final int minute;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final time = Formatters.minuteOfDay(minute);
    const step = _AddScheduleTimeScreenState._step;
    const day = _AddScheduleTimeScreenState._day;
    return Row(
      children: [
        Expanded(child: Text(label, style: context.textTheme.titleMedium)),
        BbIconButton(
          icon: BbIcons.remove,
          tooltip: AppLocalizations.of(context).scheduleEarlier(label),
          variant: BbIconButtonVariant.tonal,
          onPressed: () => onChanged((minute - step) % day),
        ),
        SizedBox(
          width: 96,
          child: Semantics(
            label: '$label $time',
            liveRegion: true,
            excludeSemantics: true,
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: context.text.metricMedium.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ),
        BbIconButton(
          icon: BbIcons.add,
          tooltip: AppLocalizations.of(context).scheduleLater(label),
          variant: BbIconButtonVariant.tonal,
          onPressed: () => onChanged((minute + step) % day),
        ),
      ],
    );
  }
}
