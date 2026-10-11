import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Applies the window class side margin, the horizontal safe area and the
/// max content width (DESIGN.md §4.2). Screens never hard-code horizontal
/// padding.
class BbPagePadding extends StatelessWidget {
  const BbPagePadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final window = context.windowClass;
    final maxWidth = window.maxContentWidth;
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: window.margin),
        child: maxWidth == null
            ? child
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: child,
                ),
              ),
      ),
    );
  }
}
