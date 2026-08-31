import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/home/domain/models/card_entity.dart';
import 'package:yoyu/features/detail/presentation/controllers/transaction_controller.dart';
import 'package:yoyu/features/detail/presentation/controllers/analysis_controller.dart';
import 'package:yoyu/features/detail/presentation/widgets/transaction_history_tab.dart';
import 'package:yoyu/features/detail/presentation/widgets/transaction_analysis_tab.dart';
import 'package:yoyu/core/widgets/skeleton_widget.dart';

class CardDetailPage extends ConsumerStatefulWidget {
  final CardEntity card;
  const CardDetailPage({super.key, required this.card});

  @override
  ConsumerState<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends ConsumerState<CardDetailPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final txAsync = ref.watch(transactionProvider(widget.card.cardNo));
    final anAsync = ref.watch(analysisProvider(widget.card.cardNo));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.card.cardNo,
          style: const TextStyle(fontFamily: 'monospace', letterSpacing: 1.5, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: [
              // Tab 1: History
              txAsync.when(
                data: (txs) => TransactionHistoryTab(transactions: txs),
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 80,
                    child: SkeletonWidget(width: double.infinity, height: 80, borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              // Tab 2: Analysis
              anAsync.when(
                data: (ans) => TransactionAnalysisTab(analysisList: ans),
                loading: () => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SkeletonWidget(width: 120, height: 20),
                      const SizedBox(height: 8),
                      const SkeletonWidget(width: 200, height: 40),
                      const SizedBox(height: 40),
                      ...List.generate(3, (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: SkeletonWidget(width: double.infinity, height: 40),
                      )),
                    ],
                  ),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
          
          // Floating Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
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
                  children: [
                    _buildNavItem(0, Icons.list_alt_rounded, '交易紀錄', isDark, theme.primaryColor),
                    _buildNavItem(1, Icons.pie_chart_outline_rounded, '分析', isDark, theme.primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark, Color primaryColor) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : (isDark ? Colors.white54 : Colors.black54),
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
