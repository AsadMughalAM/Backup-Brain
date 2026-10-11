import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundations/tokens/motion.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';

/// The backup countdown (DESIGN.md §10.6): a ring whose arc is the battery
/// level in its status color, with the time left in the center.
///
/// All text comes in already formatted and localized; this widget only
/// draws. Pair an overload with a `danger` [BbBanner] — the ring pulses
/// once when [isOverloaded] turns on.
///
/// ```dart
/// BbCountdownRing(
///   soc: 0.62,
///   timeLabel: '3h 28m',
///   caption: l10n.leftAtLoad('420 W'),
///   footnote: l10n.stopsProtectingAt('50%'),
/// )
/// ```
class BbCountdownRing extends StatefulWidget {
  const BbCountdownRing({
    super.key,
    required this.soc,
    required this.timeLabel,
    required this.caption,
    this.footnote,
    this.isOverloaded = false,
    this.semanticLabel,
  });

  /// Battery state of charge 0–1: arc length and color.
  final double soc;

  /// e.g. "3h 28m".
  final String timeLabel;

  /// e.g. "left at 420 W".
  final String caption;

  /// e.g. "Stops protecting battery at 50%".
  final String? footnote;
  final bool isOverloaded;

  /// Full sentence for screen readers; defaults to time + caption.
  final String? semanticLabel;

  @override
  State<BbCountdownRing> createState() => _BbCountdownRingState();
}

class _BbCountdownRingState extends State<BbCountdownRing>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this);

  static const _stroke = 12.0;

  @override
  void didUpdateWidget(BbCountdownRing old) {
    super.didUpdateWidget(old);
    if (widget.isOverloaded && !old.isOverloaded) {
      _pulse.duration = AppMotion.of(context, AppMotion.normal);
      _pulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final diameter = MediaQuery.sizeOf(context).width < 360 ? 200.0 : 240.0;
    final footnote = widget.footnote;

    final ring = TweenAnimationBuilder<double>(
      tween: Tween(end: widget.soc.clamp(0.0, 1.0)),
      duration: AppMotion.of(context, AppMotion.slow),
      curve: AppMotion.emphasized,
      builder: (context, soc, child) => CustomPaint(
        painter: _RingPainter(
          fraction: soc,
          track: colors.outlineVariant,
          arc: context.energy.battery(soc),
          stroke: _stroke,
        ),
        child: child,
      ),
      child: SizedBox.square(
        dimension: diameter,
        child: Padding(
          padding: const EdgeInsets.all(_stroke + AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The one style allowed to clamp, at 1.3× (DESIGN.md §3.5),
              // and scaled down rather than overflow the ring.
              MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.timeLabel,
                    style: context.text.metricHero.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              Text(
                widget.caption,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      label: widget.semanticLabel ?? '${widget.timeLabel}, ${widget.caption}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) => Transform.scale(
              scale: 1 + 0.04 * math.sin(math.pi * _pulse.value),
              child: child,
            ),
            child: ring,
          ),
          if (footnote != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              footnote,
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                color: colors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.track,
    required this.arc,
    required this.stroke,
  });

  final double fraction;
  final Color track;
  final Color arc;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        paint..color = arc,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.arc != arc || old.track != track;
}
