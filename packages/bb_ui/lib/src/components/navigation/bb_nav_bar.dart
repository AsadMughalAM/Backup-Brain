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

/// Bottom navigation (DESIGN.md §10.5): the selected tab gets the yellow
/// pill behind a Fill icon — one of the two yellow highlights allowed per
/// screen.
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

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      // Shadow cast upward in light; dark relies on the lighter surface.
      boxShadow: AppElevation.level1
          .shadows(Theme.of(context).brightness)
          .map((s) => s.copyWith(offset: -s.offset))
          .toList(),
    ),
    child: SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Row(
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
      ),
    ),
  );
}

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
    final colors = context.colors;
    return Tappable(
      onTap: onTap,
      builder: (context, s) => Semantics(
        selected: selected,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FocusRing(
                visible: s.focused,
                radius: AppRadius.pill,
                child: AnimatedContainer(
                  duration: AppMotion.of(context, AppMotion.fast),
                  curve: AppMotion.enter,
                  width: 56,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primary
                        : colors.primary.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Icon(
                    selected ? item.activeIcon : item.icon,
                    size: AppSizes.iconMd,
                    color: selected ? colors.textOnPrimary : colors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  color: selected ? colors.textPrimary : colors.textMuted,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
