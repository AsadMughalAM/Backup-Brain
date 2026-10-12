import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundations/tokens/motion.dart';
import '../../theme/context_extensions.dart';

/// Home's hero gauge (DESIGN.md §10.6): a half ring whose fill is the
/// battery's charge, in its status color (green / amber / red), with the
/// backup time inside. The fill sweeps up from empty when it appears and
/// glides when the charge changes. The screen gives the words; [child]
/// sits in the bowl of the arc.
///
/// ```dart
/// BbBackupGauge(
///   soc: 0.6,
///   semanticLabel: l10n.backupSemantics(time, load, soc),
///   child: BbMetric(value: '3h 28m', size: BbMetricSize.hero),
/// )
/// ```
class BbBackupGauge extends StatelessWidget {
  const BbBackupGauge({
    super.key,
    required this.soc,
    required this.semanticLabel,
    required this.child,
  });

  /// Battery charge, 0–1.
  final double soc;

  /// The whole answer in one sentence: the arc itself is decoration.
  final String semanticLabel;
  final Widget child;

  static const width = 280.0;
  static const height = 160.0;
  static const _stroke = 18.0;

  @override
  Widget build(BuildContext context) {
    final e = context.energy;
    // Visible on a card and on the page alike.
    final track = context.colors.outlineVariant;
    final target = soc.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: target),
          duration: AppMotion.of(context, AppMotion.slow * 2),
          curve: AppMotion.enter,
          builder: (context, value, child) => CustomPaint(
            painter: _ArcPainter(
              value: value,
              fill: e.battery(target),
              track: track,
              stroke: _stroke,
            ),
            child: child,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _stroke * 2),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.value,
    required this.fill,
    required this.track,
    required this.stroke,
  });

  final double value;
  final Color fill;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.width / 2),
      radius: radius,
    );
    Paint paint(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, math.pi, math.pi, false, paint(track));
    if (value > 0) {
      canvas.drawArc(rect, math.pi, math.pi * value, false, paint(fill));
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.value != value || old.fill != fill || old.track != track;
}
