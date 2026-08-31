import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yoyu/features/detail/domain/models/yoyu_transaction.dart';

class TransitCardWidget extends StatelessWidget {
  final TransitTransaction transaction;

  const TransitCardWidget({super.key, required this.transaction});

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

    final bool isSameTime = transaction.inTime.isAtSameMomentAs(transaction.outTime);
    
    // Adjust 0 amount color for dark mode
    Color amountColor = _getAmountColor(transaction.amount);
    if (transaction.amount == 0 && isDark) {
      amountColor = Colors.white;
    }

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
          // Left Side: Header & Journey Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Date & Partner Name
                Row(
                  children: [
                    Text(
                      dateFormat.format(transaction.inTime),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (transaction.partnerName.isNotEmpty)
                      Text(
                        transaction.partnerName,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Body: A -> B Journey
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Origin
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.inLocation,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeFormat.format(transaction.inTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    
                    // Arrow (only if different locations/times)
                    if (!isSameTime || transaction.inLocation != transaction.outLocation) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                      
                      // Destination
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.outLocation,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeFormat.format(transaction.outTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Right Side: Amount & Balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (transaction.amount > 0 ? '+' : '') + transaction.amount.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '餘 ${currencyFormat.format(transaction.balance)}',
                style: TextStyle(
                  fontSize: 12,
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
