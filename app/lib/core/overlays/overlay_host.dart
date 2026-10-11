import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's root navigator: every overlay opens on it, above the tabs.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// The one place overlays open (CLAUDE.md golden rule 7). A modal route
/// gives each sheet a focus trap and closes it on a scrim tap, Escape or
/// back; the sheet's title names it for screen readers.
class OverlayHost {
  OverlayHost(this._navigator);

  final GlobalKey<NavigatorState> _navigator;
  var _openSheets = 0;

  /// Opens a bottom sheet titled [title]. Completes with what the sheet
  /// closed with (null for scrim, Escape or back).
  Future<T?> showSheet<T>({
    required String title,
    required WidgetBuilder builder,
  }) async {
    final context = _navigator.currentContext;
    if (context == null) return null;
    _openSheets++;
    try {
      return await showModalBottomSheet<T>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        // The same surface and corners BbBottomSheet paints, so the modal's
        // own material never shows around it.
        backgroundColor: context.colors.surfaceRaised,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        barrierColor: context.colors.scrim,
        builder: (context) =>
            BbBottomSheet(title: title, child: builder(context)),
      );
    } finally {
      _openSheets--;
    }
  }

  /// Closes the top sheet with [result]; does nothing when none is open,
  /// so it can never pop a page.
  void close<T>([T? result]) {
    if (_openSheets == 0) return;
    _navigator.currentState?.pop(result);
  }
}

final overlayHostProvider = Provider<OverlayHost>(
  (ref) => OverlayHost(rootNavigatorKey),
);
