import 'package:yoyu/features/detail/domain/models/raw_transaction.dart';
import 'package:yoyu/features/detail/domain/models/yoyu_transaction.dart';

abstract class TransactionParser {
  List<YoyuTransaction> parse(List<RawTransaction> rawTransactions);
}

class TransitParser implements TransactionParser {
  @override
  List<YoyuTransaction> parse(List<RawTransaction> rawTransactions) {
    final List<YoyuTransaction> result = [];
    final List<RawTransaction> processList = List.from(rawTransactions);
    
    // Sort descending by date
    processList.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    
    final Set<String> processedTraceNos = {};

    for (int i = 0; i < processList.length; i++) {
      final current = processList[i];
      if (processedTraceNos.contains(current.traceNo)) continue;

      if (current.xtype == '出站' || current.xtype == '段次下車') {
        RawTransaction? inRecord;
        // Search backwards in time (forward in the descending array)
        for (int j = i + 1; j < processList.length; j++) {
          final potentialIn = processList[j];
          if (!processedTraceNos.contains(potentialIn.traceNo) && 
              (potentialIn.xtype == '進站' || potentialIn.xtype == '段次上車')) {
            inRecord = potentialIn;
            processedTraceNos.add(potentialIn.traceNo);
            break;
          }
        }
        
        processedTraceNos.add(current.traceNo);
        
        // Sum the amounts from both in and out records
        final outAmount = _parseAmount(current.amt);
        final inAmount = inRecord != null ? _parseAmount(inRecord.amt) : 0;
        final totalAmount = outAmount + inAmount;
        
        final outTime = DateTime.fromMillisecondsSinceEpoch(current.transactionDate * 1000);
        final inTime = inRecord != null 
            ? DateTime.fromMillisecondsSinceEpoch(inRecord.transactionDate * 1000)
            : outTime; 
        
        result.add(YoyuTransaction.transit(
          traceNo: current.traceNo,
          partnerName: current.partnerName,
          amount: totalAmount,
          balance: current.electronicValue,
          inTime: inTime,
          outTime: outTime,
          inLocation: inRecord != null ? inRecord.locationName : '',
          outLocation: current.locationName,
        ));
      }
      // Removed all dirty fallbacks for unexpected or unmatched single-tap scenarios
    }
    return result;
  }

  int _parseAmount(String amtStr) {
    // API returns "-20", "+500", "20" etc.
    final cleanStr = amtStr.trim();
    if (cleanStr.isEmpty) return 0;
    return int.tryParse(cleanStr) ?? 0;
  }
}

class RetailParser implements TransactionParser {
  @override
  List<YoyuTransaction> parse(List<RawTransaction> rawTransactions) {
    return rawTransactions.map((raw) {
      final amount = _parseAmount(raw.amt);
      final time = DateTime.fromMillisecondsSinceEpoch(raw.transactionDate * 1000);
      return YoyuTransaction.retail(
        traceNo: raw.traceNo,
        partnerName: raw.partnerName,
        amount: amount,
        balance: raw.electronicValue,
        time: time,
        location: raw.locationName,
        description: raw.xtype,
      );
    }).toList();
  }

  int _parseAmount(String amtStr) {
    final cleanStr = amtStr.trim();
    if (cleanStr.isEmpty) return 0;
    return int.tryParse(cleanStr) ?? 0;
  }
}
