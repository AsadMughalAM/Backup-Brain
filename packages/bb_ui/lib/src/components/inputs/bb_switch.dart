import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// On/off switch (DESIGN.md §10.2): 52 × 32 pill; on = indigo track with
/// light thumb, off = muted track with an outline. Material's switch
/// already gives the 48 dp target, focus and semantics; this pins the
/// colors to our tokens.
///
/// ```dart
/// BbSwitch(value: appliance.isOn, onChanged: controller.toggle)
/// ```
class BbSwitch extends StatelessWidget {
  const BbSwitch({super.key, required this.value, required this.onChanged});

  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    WidgetStateProperty<Color> pick(Color on, Color off) =>
        WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? on : off,
        );
    return Switch(
      value: value,
      onChanged: onChanged,
      trackColor: pick(c.secondary, c.surfaceMuted),
      thumbColor: pick(c.onSecondary, c.textMuted),
      trackOutlineColor: pick(c.secondary, c.outline),
      focusColor: c.focusRing.withValues(alpha: 0.24),
    );
  }
}
