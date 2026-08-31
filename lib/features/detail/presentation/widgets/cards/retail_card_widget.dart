import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yoyu/features/detail/domain/models/yoyu_transaction.dart';

class RetailCardWidget extends StatelessWidget {
  final RetailTransaction transaction;

  const RetailCardWidget({super.key, required this.transaction});

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
              dateFormat.format(transaction.time),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (transaction.partnerName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      transaction.partnerName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: transaction.amount > 0 ? Colors.green : theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${transaction.location} ${transaction.description}'.trim(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (transaction.amount > 0 ? '+' : '') + transaction.amount.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: transaction.amount > 0 
                      ? Colors.green 
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '餘 ${currencyFormat.format(transaction.balance)}',
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
