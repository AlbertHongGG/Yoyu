import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/home/presentation/controllers/card_list_controller.dart';
import 'package:yoyu/features/home/presentation/widgets/add_card_bottom_sheet.dart';
import 'package:yoyu/features/home/presentation/widgets/card_item_widget.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsyncValue = ref.watch(cardListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent moving up with keyboard
      appBar: AppBar(
        title: const Text(
          'Yoyu 一卡通',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          cardsAsyncValue.when(
            data: (cards) {
              if (cards.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.credit_card_off_rounded,
                          size: 64,
                          color: isDark ? Colors.white30 : Colors.black26,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '目前尚未綁定任何卡片',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '點擊下方按鈕新增您的第一張一卡通',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(cardListProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120), // Added more bottom padding for the FAB
                  itemCount: cards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return CardItemWidget(
                      card: card,
                      onTap: () {
                        context.push('/detail', extra: card);
                      },
                      onPickImage: () {
                        context.push('/pick_face', extra: card);
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text('載入失敗: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(cardListProvider),
                    child: const Text('重試'),
                  ),
                ],
              ),
            ),
          ),
          
          // Floating Add Button with Glass Effect
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => showAddCardBottomSheet(context),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark 
                        ? Colors.black.withValues(alpha: 0.6) 
                        : Colors.white.withValues(alpha: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Icon(
                        Icons.add_rounded,
                        color: isDark ? Colors.white70 : Colors.black54,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
