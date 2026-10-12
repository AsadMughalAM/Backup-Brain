import 'package:flutter/material.dart';

import '../../foundations/tokens/elevation.dart';
import '../../foundations/tokens/motion.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../_internal/tappable.dart';

class BbNavItem {
  const BbNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  /// Regular glyph, e.g. `BbIcons.home`.
  final IconData icon;

  /// Fill glyph for the selected tab, e.g. `BbIcons.homeActive`.
  final IconData activeIcon;
  final String label;
}

/// Bottom navigation (DESIGN.md §10.5): a floating rounded bar; an indigo
/// pill slides to the selected tab behind its Fill icon, and the label turns
/// bold. Indigo, not coral, so the screen's coral goes to its one action.
///
/// ```dart
/// BbNavBar(
///   items: [BbNavItem(icon: BbIcons.home, activeIcon: BbIcons.homeActive, label: l10n.tabHome), ...],
///   selectedIndex: shell.currentIndex,
///   onSelect: shell.goBranch,
/// )
/// ```
class BbNavBar extends StatelessWidget {
  const BbNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<BbNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const _height = 74.0;
  static const _pillWidth = 56.0;
  static const _pillHeight = 32.0;
  static const _pillTop = 10.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppElevation.level2.shadows(
              Theme.of(context).brightness,
            ),
          ),
          child: SizedBox(
            height: _height,
            child: LayoutBuilder(
              builder: (context, box) {
                final tab = box.maxWidth / items.length;
                return Stack(
                  children: [
                    // The indicator slides between tabs instead of blinking.
                    AnimatedPositioned(
                      duration: AppMotion.of(context, AppMotion.normal),
                      curve: AppMotion.emphasized,
                      top: _pillTop,
                      left: tab * selectedIndex + (tab - _pillWidth) / 2,
                      width: _pillWidth,
                      height: _pillHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.secondary,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final (i, item) in items.indexed)
                          Expanded(
                            child: _NavTab(
                              item: item,
                              selected: i == selectedIndex,
                              onTap: () => onSelect(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill 32 + gap 6 + label 16 = 54, centred in the 74 bar: the icon sits
/// exactly over the sliding pill at `_pillTop`.
const _labelGap = 6.0;

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final BbNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tappable(
      onTap: onTap,
      builder: (context, s) => Semantics(
        selected: selected,
        // The full bar height with the icon at the pill's top, so icon and
        // sliding pill always line up.
        child: SizedBox(
          height: BbNavBar._height,
          child: Column(
            children: [
              const SizedBox(height: BbNavBar._pillTop),
              FocusRing(
                visible: s.focused,
                radius: AppRadius.pill,
                child: SizedBox(
                  width: BbNavBar._pillWidth,
                  height: BbNavBar._pillHeight,
                  child: Center(
                    // The new tab's icon pops in; the old one settles.
                    child: AnimatedScale(
                      scale: selected ? 1.08 : 1,
                      duration: AppMotion.of(context, AppMotion.normal),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        selected ? item.activeIcon : item.icon,
                        size: AppSizes.iconMd,
                        color: selected ? c.onSecondary : c.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _labelGap),
              AnimatedDefaultTextStyle(
                duration: AppMotion.of(context, AppMotion.fast),
                style: context.textTheme.labelMedium!.copyWith(
                  color: selected ? c.textPrimary : c.textMuted,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
