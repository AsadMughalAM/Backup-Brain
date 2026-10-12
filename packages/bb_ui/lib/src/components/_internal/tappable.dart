import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/tokens/motion.dart';
import '../../foundations/tokens/sizes.dart';
import '../../theme/context_extensions.dart';

/// Interaction state handed to a [Tappable] builder.
typedef TapState = ({bool pressed, bool hovered, bool focused, bool enabled});

/// Shared interaction shell for Bb components: keyboard activation
/// (Enter/Space), hover, press, button semantics and a minimum 48 × 48 hit
/// area even when the visible shape is smaller (DESIGN.md §4.5 rule 7).
/// Visuals are entirely the builder's job.
class Tappable extends StatefulWidget {
  const Tappable({
    super.key,
    required this.onTap,
    required this.builder,
    this.semanticLabel,
    this.minSize = const Size.square(AppSizes.minTouchTarget),
  });

  /// Null disables the control.
  final VoidCallback? onTap;
  final Widget Function(BuildContext context, TapState state) builder;

  /// Replaces the child's text in the semantics tree (icon-only controls).
  final String? semanticLabel;
  final Size minSize;

  @override
  State<Tappable> createState() => _TappableState();
}

/// How far a pressed control sinks (DESIGN.md §7).
const pressedScale = 0.97;

class _TappableState extends State<Tappable> {
  var _pressed = false;
  var _hovered = false;
  var _focused = false;

  bool get _enabled => widget.onTap != null;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  void didUpdateWidget(Tappable old) {
    super.didUpdateWidget(old);
    if (!_enabled) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = (
      pressed: _pressed,
      hovered: _hovered,
      focused: _focused,
      enabled: _enabled,
    );
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: _enabled,
        label: widget.semanticLabel,
        excludeSemantics: widget.semanticLabel != null,
        child: FocusableActionDetector(
          enabled: _enabled,
          mouseCursor: _enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          onShowHoverHighlight: (v) => setState(() => _hovered = v),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onTap?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _enabled ? (_) => _setPressed(true) : null,
            onTapUp: _enabled ? (_) => _setPressed(false) : null,
            onTapCancel: _enabled ? () => _setPressed(false) : null,
            onTap: _enabled
                ? () {
                    HapticFeedback.selectionClick();
                    widget.onTap!();
                  }
                : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: widget.minSize.width,
                minHeight: widget.minSize.height,
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                // A slight press-in gives every control the same tactile
                // answer; scale never moves the layout around it.
                child: AnimatedScale(
                  scale: _pressed ? pressedScale : 1,
                  duration: AppMotion.of(context, AppMotion.fast),
                  curve: AppMotion.enter,
                  child: widget.builder(context, state),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the 2 px focus outline 2 px outside its child (DESIGN.md §5.2),
/// without changing layout. [radius] is the child's corner radius.
class FocusRing extends StatelessWidget {
  const FocusRing({
    super.key,
    required this.visible,
    required this.radius,
    required this.child,
  });

  final bool visible;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: visible
        ? _FocusRingPainter(context.colors.focusRing, radius)
        : null,
    child: child,
  );
}

class _FocusRingPainter extends CustomPainter {
  _FocusRingPainter(this.color, this.radius);

  final Color color;
  final double radius;

  static const _width = 2.0, _offset = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    const grow = _offset + _width / 2;
    final rect = (Offset.zero & size).inflate(grow);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius + grow)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _width
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter old) =>
      old.color != color || old.radius != radius;
}
