import 'dart:math' as math;

import 'package:flutter/material.dart';

enum BbSpinnerSize {
  xs(12),
  sm(16),
  md(20);

  const BbSpinnerSize(this.dimension);
  final double dimension;
}

/// Small inline spinner (DESIGN.md §8.3) — 2 px stroke, 270° arc, 900 ms per
/// turn. There is no larger spinner: full-screen and centered loaders are
/// banned; use skeletons for missing content.
///
/// Takes the surrounding icon color, so it matches the content it replaces
/// (ink inside a yellow button, muted inline).
///
/// ```dart
/// Row(children: [BbSpinner(size: BbSpinnerSize.xs), Text('updated 3 h ago')])
/// ```
class BbSpinner extends StatefulWidget {
  const BbSpinner({
    super.key,
    this.size = BbSpinnerSize.sm,
    this.semanticLabel,
  });

  final BbSpinnerSize size;

  /// Announced to screen readers, e.g. "Loading". Omit when the surrounding
  /// control already says it is busy.
  final String? semanticLabel;

  @override
  State<BbSpinner> createState() => _BbSpinnerState();
}

class _BbSpinnerState extends State<BbSpinner>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion: a static arc still reads as "busy".
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
    final color = IconTheme.of(context).color!;
    final spinner = SizedBox.square(
      dimension: widget.size.dimension,
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(painter: _ArcPainter(color)),
      ),
    );
    return Semantics(
      label: widget.semanticLabel,
      liveRegion: widget.semanticLabel != null,
      excludeSemantics: true,
      child: spinner,
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color);

  final Color color;
  static const _stroke = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}
