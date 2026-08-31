import 'package:flutter/material.dart';
import 'package:yoyu/features/detail/domain/models/combined_transaction.dart';
import 'package:intl/intl.dart';

class TransactionHistoryTab extends StatelessWidget {
  final List<CombinedTransaction> transactions;

  const TransactionHistoryTab({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('無交易紀錄'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100), // padding for bottom nav
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return TransactionItemWidget(transaction: tx);
      },
    );
  }
}

class TransactionItemWidget extends StatelessWidget {
  final CombinedTransaction transaction;

  const TransactionItemWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final dateFormat = DateFormat('MM/dd\nHH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'zh_TW', symbol: '\$', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242424) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Date Column
          SizedBox(
            width: 50,
            child: Text(
              dateFormat.format(transaction.transactionDate),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
                height: 1.3,
              ),
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.white12 : Colors.black12,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          
          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.inLocation.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColor, width: 2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        transaction.inLocation,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 3, top: 4, bottom: 4),
                    width: 2,
                    height: 10,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ],
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: transaction.inLocation.isEmpty ? theme.primaryColor : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      transaction.outLocation,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Amount & Balance Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (transaction.amount > 0 ? '+' : '') + transaction.amount.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: transaction.amount > 0 ? Colors.green : (isDark ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '餘 ${currencyFormat.format(transaction.electronicValue)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
