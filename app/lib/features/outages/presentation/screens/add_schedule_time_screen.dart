import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../core/overlays/overlay_host.dart';
import '../../../../core/utils/formatters.dart';
import '../controllers/schedule_controller.dart';

/// Adds the area's load-shedding times. Most areas cut at the same times
/// every day, so every day starts picked; areas with several cuts a day,
/// or other times on some days, add more times on the same screen and save
/// them together. A full screen rather than a sheet: there is a lot to set
/// and back is "cancel".
class AddScheduleTimeScreen extends ConsumerStatefulWidget {
  const AddScheduleTimeScreen({super.key});

  @override
  ConsumerState<AddScheduleTimeScreen> createState() =>
      _AddScheduleTimeScreenState();
}

/// One time range and the days it applies to.
class _Block {
  _Block({required this.from, required this.to})
    : days = {for (var d = DateTime.monday; d <= DateTime.sunday; d++) d};

  final Set<int> days;
  int from;
  int to;

  bool get valid => days.isNotEmpty && from != to;
}

class _AddScheduleTimeScreenState extends ConsumerState<AddScheduleTimeScreen> {
  // Evening is the most common cut.
  final _blocks = [_Block(from: 19 * 60, to: 21 * 60)];
  bool _triedSave = false;

  static const _day = Duration.minutesPerDay;

  /// The next cut is rarely back-to-back with the last: start the new time
  /// a few hours after it ends, at the same length.
  static const _gapToNext = 4 * 60;

  void _addBlock() {
    final last = _blocks.last;
    final length = (last.to - last.from) % _day;
    final from = (last.to + _gapToNext) % _day;
    setState(() => _blocks.add(_Block(from: from, to: (from + length) % _day)));
  }

  void _save() {
    if (!_blocks.every((b) => b.valid)) {
      setState(() => _triedSave = true);
      return;
    }
    final schedule = ref.read(scheduleControllerProvider);
    for (final b in _blocks) {
      schedule.add(weekdays: b.days, startMinute: b.from, endMinute: b.to);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BbScaffold(
      title: l10n.scheduleAdd,
      bottomAction: BbButton(
        label: _blocks.length == 1
            ? l10n.scheduleSave
            : l10n.scheduleSaveAll(_blocks.length),
        size: BbButtonSize.lg,
        expand: true,
        onPressed: _save,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          Text(
            l10n.scheduleAddHint,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          const BbGap.lg(),
          for (final (i, block) in _blocks.indexed) ...[
            if (i > 0) const BbGap.lg(),
            _BlockCard(
              title: l10n.scheduleTimeN(i + 1),
              block: block,
              showErrors: _triedSave,
              onChanged: () => setState(() {}),
              onRemove: _blocks.length == 1
                  ? null
                  : () => setState(() => _blocks.removeAt(i)),
            ),
          ],
          const BbGap.lg(),
          BbButton.tonal(
            label: l10n.scheduleAddAnother,
            icon: BbIcons.add,
            expand: true,
            onPressed: _addBlock,
          ),
        ],
      ),
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.title,
    required this.block,
    required this.showErrors,
    required this.onChanged,
    required this.onRemove,
  });

  final String title;
  final _Block block;
  final bool showErrors;
  final VoidCallback onChanged;

  /// Null for the only block: there must be one.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onRemove = this.onRemove;
    final allDays = block.days.length == DateTime.daysPerWeek;
    return BbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: context.textTheme.titleMedium),
                ),
              ),
              if (onRemove != null)
                BbIconButton(
                  icon: BbIcons.delete,
                  tooltip: l10n.scheduleRemoveTime(title),
                  onPressed: onRemove,
                ),
            ],
          ),
          const BbGap.sm(),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.scheduleDays,
                  style: context.textTheme.titleSmall,
                ),
              ),
              BbButton.ghost(
                label: allDays ? l10n.scheduleClearDays : l10n.scheduleEveryDay,
                size: BbButtonSize.sm,
                onPressed: () {
                  if (allDays) {
                    block.days.clear();
                  } else {
                    block.days.addAll([
                      for (var d = DateTime.monday; d <= DateTime.sunday; d++)
                        d,
                    ]);
                  }
                  onChanged();
                },
              ),
            ],
          ),
          const BbGap.sm(),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var d = DateTime.monday; d <= DateTime.sunday; d++)
                BbChip(
                  label: l10n.weekdayShort('$d'),
                  selected: block.days.contains(d),
                  onSelected: () {
                    block.days.contains(d)
                        ? block.days.remove(d)
                        : block.days.add(d);
                    onChanged();
                  },
                ),
            ],
          ),
          if (showErrors && block.days.isEmpty) _Error(l10n.scheduleNeedDay),
          const BbGap.lg(),
          _TimeRow(
            label: l10n.scheduleFrom,
            minute: block.from,
            onChanged: (m) {
              block.from = m;
              onChanged();
            },
          ),
          const BbGap.md(),
          _TimeRow(
            label: l10n.scheduleTo,
            minute: block.to,
            onChanged: (m) {
              block.to = m;
              onChanged();
            },
          ),
          const BbGap.sm(),
          if (block.from == block.to)
            _Error(l10n.scheduleSameTimes)
          else
            Text(
              l10n.scheduleLength(
                Formatters.duration(
                  l10n,
                  ((block.to - block.from) % Duration.minutesPerDay) / 60,
                ),
              ),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

/// − time +: half-hour steps for the usual DISCO times, wrapping round
/// midnight; tapping the time types any exact minute.
class _TimeRow extends ConsumerWidget {
  const _TimeRow({
    required this.label,
    required this.minute,
    required this.onChanged,
  });

  final String label;
  final int minute;
  final ValueChanged<int> onChanged;

  static const _step = 30;
  static const _day = Duration.minutesPerDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final time = Formatters.minuteOfDay(minute);

    Future<void> type() async {
      final picked = await ref
          .read(overlayHostProvider)
          .pickTime(
            title: label,
            initial: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
          );
      if (picked != null) onChanged(picked.hour * 60 + picked.minute);
    }

    return Row(
      children: [
        Expanded(child: Text(label, style: context.textTheme.titleSmall)),
        BbIconButton(
          icon: BbIcons.remove,
          tooltip: l10n.scheduleEarlier(label),
          variant: BbIconButtonVariant.tonal,
          onPressed: () => onChanged((minute - _step) % _day),
        ),
        Tooltip(
          message: l10n.scheduleTypeTime(label),
          child: Semantics(
            liveRegion: true,
            child: BbButton.ghost(
              label: time,
              icon: BbIcons.clock,
              onPressed: type,
            ),
          ),
        ),
        BbIconButton(
          icon: BbIcons.add,
          tooltip: l10n.scheduleLater(label),
          variant: BbIconButtonVariant.tonal,
          onPressed: () => onChanged((minute + _step) % _day),
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.sm),
    child: Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Icon(
            BbIcons.warning,
            size: AppSizes.iconXs,
            color: context.colors.danger,
          ),
          const BbGap.xs(),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.danger,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
