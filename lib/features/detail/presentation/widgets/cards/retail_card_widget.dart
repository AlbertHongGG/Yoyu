import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yoyu/features/detail/domain/models/yoyu_transaction.dart';
import 'package:yoyu/core/widgets/dashed_divider.dart';

class RetailCardWidget extends StatelessWidget {
  final RetailTransaction transaction;

  const RetailCardWidget({super.key, required this.transaction});

  Color _getAmountColor(int amount) {
    if (amount > 0) return Colors.green;
    if (amount < 0) return Colors.red;
    return Colors.black; // Fallback for 0, adjusted for dark mode below
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final dateFormat = DateFormat('MM/dd');
    final timeFormat = DateFormat('HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'zh_TW', symbol: '\$', decimalDigits: 0);

    // Adjust 0 amount color for dark mode
    Color amountColor = _getAmountColor(transaction.amount);
    if (transaction.amount == 0 && isDark) {
      amountColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (票頭)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date & Partner Name
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        dateFormat.format(transaction.time),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (transaction.partnerName.isNotEmpty)
                        Flexible(
                          child: Text(
                            transaction.partnerName,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.primaryColor.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Amount & Balance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '餘 ${currencyFormat.format(transaction.balance)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      (transaction.amount > 0 ? '+' : '') + transaction.amount.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Dashed Divider (折線)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DashedDivider(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          
          // Body (票面: 絕對網格對齊)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Column 1: Graphic (固定 30px)
                SizedBox(
                  width: 30,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                
                // Column 2: Location/Description (Expanded)
                Expanded(
                  child: Text(
                    '${transaction.location} ${transaction.description}'.trim(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Column 3: Time (固定 50px)
                SizedBox(
                  width: 50,
                  child: Text(
                    timeFormat.format(transaction.time),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontFamily: 'monospace',
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
