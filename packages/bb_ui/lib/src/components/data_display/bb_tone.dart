import 'package:flutter/widgets.dart';

import '../../theme/context_extensions.dart';

/// The meaning of a value or icon. Components take a tone, never a raw
/// color (TECH_STACK.md §6.7 rule 3); the tone picks the right token for
/// text vs. icons and for light vs. dark.
enum BbTone {
  neutral,
  muted,
  solar,
  grid,
  load,
  success,
  warning,
  danger;

  /// For numbers and words.
  Color textColor(BuildContext context) {
    final c = context.colors, e = context.energy;
    return switch (this) {
      neutral => c.textPrimary,
      muted => c.textMuted,
      // Yellow fill fails contrast as text on light; solarText is the
      // readable shade (DESIGN.md §2.7 rule 2).
      solar => e.solarText,
      grid => e.grid,
      load => e.load,
      success => c.success,
      warning => c.warning,
      danger => c.danger,
    };
  }

  /// For icons and thin marks (≥ 3:1).
  Color iconColor(BuildContext context) => switch (this) {
    solar => context.energy.solarStroke,
    _ => textColor(context),
  };

  /// Soft fill behind an icon of this tone, e.g. the stat tile's icon disc.
  Color containerColor(BuildContext context) {
    final c = context.colors;
    return switch (this) {
      neutral || muted || load => c.surfaceMuted,
      solar => c.primaryContainer,
      grid => c.secondaryContainer,
      success => c.successContainer,
      warning => c.warningContainer,
      danger => c.dangerContainer,
    };
  }
}
