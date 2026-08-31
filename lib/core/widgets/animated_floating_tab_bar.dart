import 'package:flutter/material.dart';

class FloatingTabItem {
  final IconData icon;
  final String label;

  const FloatingTabItem({
    required this.icon,
    required this.label,
  });
}

class AnimatedFloatingTabBar extends StatelessWidget {
  final int selectedIndex;
  final List<FloatingTabItem> items;
  final ValueChanged<int> onItemSelected;

  const AnimatedFloatingTabBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          return _TabBarItemWidget(
            item: items[index],
            isSelected: selectedIndex == index,
            onTap: () => onItemSelected(index),
            theme: theme,
            isDark: isDark,
          );
        }),
      ),
    );
  }
}

class _TabBarItemWidget extends StatelessWidget {
  final FloatingTabItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isDark;

  const _TabBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedColor = isDark ? Colors.white54 : Colors.black54;
    final primaryColor = theme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: isSelected ? 1.0 : 0.0,
          end: isSelected ? 1.0 : 0.0,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: EdgeInsets.symmetric(horizontal: 16 + (4 * t), vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1 * t),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  color: Color.lerp(unselectedColor, primaryColor, t),
                  size: 20,
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: t,
                    child: Opacity(
                      opacity: t,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
