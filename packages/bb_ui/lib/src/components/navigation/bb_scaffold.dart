import 'package:flutter/material.dart';

import '../../foundations/tokens/elevation.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../layout/bb_appear.dart';
import '../layout/bb_page_padding.dart';

/// Every screen's frame (DESIGN.md §11): app bar → optional banner (e.g. the
/// offline banner) → page-padded [body] → optional sticky [bottomAction] →
/// optional [navigationBar] on top-level tabs.
///
/// ```dart
/// BbScaffold(
///   title: l10n.loadPlanner,
///   banner: isOffline ? const ConnectedOfflineBanner() : null,
///   body: ListView(children: [...]),
///   bottomAction: BbButton(label: l10n.apply, size: BbButtonSize.lg, expand: true, onPressed: apply),
/// )
/// ```
class BbScaffold extends StatelessWidget {
  const BbScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.leading,
    this.banner,
    this.bottomAction,
    this.navigationBar,
  }) : assert(
         title == null || titleWidget == null,
         'Give the app bar a title string or a title widget, not both',
       );

  final Widget body;
  final String? title;

  /// In place of [title], e.g. the brand logo on Home.
  final Widget? titleWidget;

  /// `BbIconButton`s.
  final List<Widget> actions;
  final Widget? leading;

  /// Full-width, under the app bar; never blocks interaction.
  final Widget? banner;

  /// Usually a full-width `lg` primary `BbButton`.
  final Widget? bottomAction;
  final Widget? navigationBar;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final titleWidget = this.titleWidget;
    final banner = this.banner;
    final bottomAction = this.bottomAction;
    final navigationBar = this.navigationBar;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: title == null && titleWidget == null
          ? null
          : AppBar(
              title:
                  titleWidget ??
                  Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis),
              leading: leading,
              actions: [
                ...actions,
                const SizedBox(width: AppSpacing.xs),
              ],
            ),
      body: Column(
        children: [
          ?banner,
          Expanded(
            child: BbPagePadding(
              // Every screen arrives with the same soft rise (DESIGN.md §7).
              child: BbAppear(child: body),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomAction == null && navigationBar == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bottomAction != null) _StickyBar(child: bottomAction),
                ?navigationBar,
              ],
            ),
    );
  }
}

class _StickyBar extends StatelessWidget {
  const _StickyBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      // Light: shadow cast upward onto the content. Dark: lighter surface.
      boxShadow: AppElevation.level1
          .shadows(Theme.of(context).brightness)
          .map((s) => s.copyWith(offset: -s.offset))
          .toList(),
    ),
    child: SafeArea(
      top: false,
      child: BbPagePadding(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: child,
        ),
      ),
    ),
  );
}
