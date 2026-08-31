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
      appBar: AppBar(
        title: const Text(
          'Yoyu 一卡通',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: theme.primaryColor, size: 20),
            ),
            onPressed: () => showAddCardBottomSheet(context),
            tooltip: '新增卡片',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: cardsAsyncValue.when(
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
                    '點擊右上角新增您的第一張一卡通',
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
              // Reload all cards logic here, e.g., mapping over current cards and refetching
              // For now we just trigger a rebuild.
              ref.invalidate(cardListProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 40),
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
    );
  }
}
