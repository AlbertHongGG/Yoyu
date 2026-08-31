import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/home/presentation/controllers/card_list_controller.dart';
import 'package:yoyu/core/notifications/controllers/notification_controller.dart';

void showAddCardBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AddCardBottomSheet(),
  );
}

class AddCardBottomSheet extends ConsumerStatefulWidget {
  const AddCardBottomSheet({super.key});

  @override
  ConsumerState<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends ConsumerState<AddCardBottomSheet> {
  final TextEditingController _noController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _noFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _noFocusNode.dispose();
    _nameFocusNode.dispose();
    _noController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final cardNo = _noController.text.trim();
    final cardName = _nameController.text.trim();
    if (cardNo.isEmpty) {
      ref.read(notificationProvider.notifier).showWarning('請輸入卡號');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ref.read(cardListProvider.notifier).addCard(cardNo, cardName);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle and Header Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header with Title and Done Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48), // Placeholder to keep title perfectly centered
                      Text(
                        '新增卡片',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              onPressed: _handleSubmit,
                              icon: const Icon(Icons.check_circle_rounded),
                              color: theme.primaryColor,
                              iconSize: 28,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Input Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              child: Column(
                children: [
                  // Card Number Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    child: TextField(
                      controller: _noController,
                      focusNode: _noFocusNode,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      enabled: !_isLoading,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        letterSpacing: 2.0,
                      ),
                      decoration: InputDecoration(
                        hintText: '請輸入 11 碼或 16 碼卡號',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white30 : Colors.black38,
                          letterSpacing: 0,
                        ),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.credit_card,
                          color: theme.primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _nameFocusNode.requestFocus(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Card Name Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      keyboardType: TextInputType.text,
                      enabled: !_isLoading,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                      decoration: InputDecoration(
                        hintText: '自訂卡片名稱 (預設: 我的卡片)',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white30 : Colors.black38,
                          letterSpacing: 0,
                        ),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.badge_rounded,
                          color: theme.primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
