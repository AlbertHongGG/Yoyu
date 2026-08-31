import 'package:yoyu/features/detail/domain/models/raw_transaction.dart';
import 'package:yoyu/features/detail/domain/models/yoyu_transaction.dart';
import 'package:yoyu/features/detail/domain/services/transaction_parser.dart';

class TransactionAggregator {
  final TransactionParser _transitParser = TransitParser();
  final TransactionParser _retailParser = RetailParser();

  List<YoyuTransaction> aggregate(List<RawTransaction> rawTransactions) {
    final Map<String, List<RawTransaction>> grouped = {};
    
    // Group by DataSource
    for (final raw in rawTransactions) {
      if (!grouped.containsKey(raw.dataSource)) {
        grouped[raw.dataSource] = [];
      }
      grouped[raw.dataSource]!.add(raw);
    }

    final List<YoyuTransaction> allTransactions = [];

    // Parse each group
    grouped.forEach((dataSource, list) {
      // F: MRT, 6: Train, 2: Bus - all transit types
      if (dataSource == 'F' || dataSource == '6' || dataSource == '2') {
        allTransactions.addAll(_transitParser.parse(list));
      } else {
        // 4: YouBike, 5: MRT Add Value, 8: Store Add Value, etc.
        allTransactions.addAll(_retailParser.parse(list));
      }
    });

    // Sort all by time descending (newest first). 
    // For TransitTransaction, we sort by outTime (or time if retail)
    allTransactions.sort((a, b) {
      final aTime = a.map(
        transit: (t) => t.outTime,
        retail: (r) => r.time,
      );
      final bTime = b.map(
        transit: (t) => t.outTime,
        retail: (r) => r.time,
      );
      return bTime.compareTo(aTime);
    });

    return allTransactions;
  }
}
