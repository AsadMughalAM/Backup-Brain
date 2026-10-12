import 'package:flutter/material.dart';

import '../../foundations/tokens/motion.dart';

/// Entrance for screen content (DESIGN.md §7): fades in while rising
/// 16 px, each [index] a beat after the one before, so a screen assembles
/// top to bottom instead of popping in at once. Plays once, on first build;
/// with reduced motion the content is simply there.
///
/// ```dart
/// ListView(children: [
///   BbAppear(index: 0, child: heroCard),
///   BbAppear(index: 1, child: statsRow),
/// ])
/// ```
class BbAppear extends StatefulWidget {
  const BbAppear({super.key, required this.child, this.index = 0});

  final Widget child;

  /// Position in the stagger; later items start later.
  final int index;

  static const _step = Duration(milliseconds: 45);
  static const _maxSteps = 8;
  static const _rise = 16.0;

  @override
  State<BbAppear> createState() => _BbAppearState();
}

class _BbAppearState extends State<BbAppear>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Scrolled off and back in a list, a section must not play its entrance
  // again: keep the state alive.
  @override
  bool get wantKeepAlive => true;

  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    final steps = widget.index.clamp(0, BbAppear._maxSteps);
    final delay = BbAppear._step * steps;
    final total = delay + AppMotion.slow;
    _controller = AnimationController(vsync: this, duration: total);
    // One controller, no timers: the delay is the start of the interval.
    _t = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: AppMotion.enter,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _t.value) * BbAppear._rise),
          child: child,
        ),
      ),
    );
  }
}
