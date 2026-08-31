import 'package:flutter/material.dart';
import 'package:yoyu/features/detail/domain/models/yoyu_transaction.dart';
import 'package:yoyu/features/detail/presentation/widgets/cards/transit_card_widget.dart';
import 'package:yoyu/features/detail/presentation/widgets/cards/retail_card_widget.dart';

class TransactionHistoryTab extends StatelessWidget {
  final List<YoyuTransaction> transactions;

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
        return tx.map(
          transit: (t) => TransitCardWidget(transaction: t),
          retail: (r) => RetailCardWidget(transaction: r),
        );
      },
    );
  }
}

