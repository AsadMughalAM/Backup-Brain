import 'package:flutter/material.dart';

import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';

/// "The assistant is writing" (DESIGN.md §8): three dots that fade in turn.
/// Under reduced motion they stand still — three dots still read as "busy".
/// Usually shown inside `BbChatBubble.typing`.
///
/// ```dart
/// BbTypingIndicator(semanticLabel: l10n.assistantTyping)
/// ```
class BbTypingIndicator extends StatefulWidget {
  const BbTypingIndicator({super.key, required this.semanticLabel});

  /// Announced once to screen readers, e.g. "Assistant is typing".
  final String semanticLabel;

  @override
  State<BbTypingIndicator> createState() => _BbTypingIndicatorState();
}

class _BbTypingIndicatorState extends State<BbTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  static const _dot = 8.0;
  static const _dimmest = 0.3;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textMuted;
    return Semantics(
      label: widget.semanticLabel,
      liveRegion: true,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: _dot,
                height: _dot,
                margin: EdgeInsets.only(left: i == 0 ? 0 : AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: _opacity(i)),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Each dot peaks a third of a cycle after the one before it.
  double _opacity(int i) {
    if (!_controller.isAnimating) return 1;
    final phase = (_controller.value - i / 3) % 1;
    final peak = 1 - (phase * 2 - 1).abs();
    return _dimmest + (1 - _dimmest) * peak;
  }
}
