import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../overlays/overlay_host.dart';
import '../utils/formatters.dart';

/// The number off a sticker when it isn't one of the usual chips ("Other"):
/// one field on the number pad, checked against [min]–[max] so a typo
/// (5500 for 550) can't skew the backup time. Completes with the number,
/// or null when closed.
Future<double?> showNumberEntrySheet(
  WidgetRef ref, {
  required String title,
  required String unit,
  required double min,
  required double max,
  double? initial,
}) => ref
    .read(overlayHostProvider)
    .showSheet<double>(
      title: title,
      builder: (_) => _NumberEntry(
        label: title,
        unit: unit,
        min: min,
        max: max,
        initial: initial,
      ),
    );

class _NumberEntry extends ConsumerStatefulWidget {
  const _NumberEntry({
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    required this.initial,
  });

  final String label;
  final String unit;
  final double min;
  final double max;
  final double? initial;

  @override
  ConsumerState<_NumberEntry> createState() => _NumberEntryState();
}

class _NumberEntryState extends ConsumerState<_NumberEntry> {
  late final _text = TextEditingController(
    text: switch (widget.initial) {
      null => '',
      final v => Formatters.plainNumber(v),
    },
  );
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final value = double.tryParse(_text.text.trim());
    if (value == null || value < widget.min || value > widget.max) {
      setState(
        () => _error = l10n.numberOutOfRange(
          Formatters.plainNumber(widget.min),
          Formatters.plainNumber(widget.max),
          widget.unit,
        ),
      );
      return;
    }
    ref.read(overlayHostProvider).close(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BbTextField(
          label: widget.label,
          controller: _text,
          autofocus: true,
          suffixText: widget.unit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
          errorText: _error,
          helper: l10n.numberRange(
            Formatters.plainNumber(widget.min),
            Formatters.plainNumber(widget.max),
            widget.unit,
          ),
        ),
        const BbGap.lg(),
        BbButton(label: l10n.done, expand: true, onPressed: _save),
      ],
    );
  }
}
