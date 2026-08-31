import 'package:flutter/material.dart';
import 'package:yoyu/features/detail/domain/models/transaction_analysis.dart';
import 'package:intl/intl.dart';

class TransactionAnalysisTab extends StatelessWidget {
  final List<TransactionAnalysis> analysisList;

  const TransactionAnalysisTab({super.key, required this.analysisList});

  @override
  Widget build(BuildContext context) {
    if (analysisList.isEmpty) {
      return const Center(child: Text('無分析資料'));
    }

    final totalSpent = analysisList.fold<int>(0, (sum, item) => sum + item.mtAmt);
    final currencyFormat = NumberFormat.currency(locale: 'zh_TW', symbol: '\$', decimalDigits: 0);

    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 100),
      children: [
        // Total Spent Header
        Center(
          child: Column(
            children: [
              Text(
                '近三個月總支出',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(totalSpent),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        
        // Bars
        ...analysisList.map((item) {
          if (item.mtAmt == 0 && item.ptAmt == 0) return const SizedBox.shrink();
          
          final percentage = totalSpent > 0 ? (item.mtAmt / totalSpent) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _AnalysisBar(
              title: item.scopeName,
              amount: item.mtAmt,
              count: item.mtCnt,
              percentage: percentage,
            ),
          );
        }),
      ],
    );
  }
}

class _AnalysisBar extends StatelessWidget {
  final String title;
  final int amount;
  final int count;
  final double percentage;

  const _AnalysisBar({
    required this.title,
    required this.amount,
    required this.count,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'zh_TW', symbol: '\$', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$count 次',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                ),
              ],
            ),
            Text(
              currencyFormat.format(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
