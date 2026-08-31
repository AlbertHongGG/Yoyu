import 'package:flutter/material.dart';

class AppBottomSheetItemData<T> {
  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final T value;

  AppBottomSheetItemData({
    required this.title,
    this.subtitle,
    required this.leadingIcon,
    required this.value,
  });
}

class AppBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<AppBottomSheetItemData<T>> items;
  final T selectedValue;
  final ValueChanged<T> onItemSelected;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onItemSelected,
  });

  static void show<T>({
    required BuildContext context,
    required String title,
    required List<AppBottomSheetItemData<T>> items,
    required T selectedValue,
    required ValueChanged<T> onItemSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: AppBottomSheet(
              title: title,
              items: items,
              selectedValue: selectedValue,
              onItemSelected: (val) {
                onItemSelected(val);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black54;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle
        Container(
          width: 48,
          height: 5,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white24 : Colors.black12,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        // Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Items
        ...items.map((item) {
          final isSelected = selectedValue == item.value;
          return InkWell(
            onTap: () => onItemSelected(item.value),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: item.subtitle != null ? 16 : 10, horizontal: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.leadingIcon, color: theme.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle!,
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: theme.primaryColor, size: 24),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
