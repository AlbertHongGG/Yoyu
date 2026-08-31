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
        
        final amount = _parseAmount(current.amt);
        final inTime = inRecord != null 
            ? DateTime.fromMillisecondsSinceEpoch(inRecord.transactionDate * 1000)
            : DateTime.fromMillisecondsSinceEpoch(current.transactionDate * 1000);
        final outTime = DateTime.fromMillisecondsSinceEpoch(current.transactionDate * 1000);
        
        result.add(YoyuTransaction.transit(
          traceNo: current.traceNo,
          partnerName: current.partnerName,
          amount: amount,
          balance: current.electronicValue,
          inTime: inTime,
          outTime: outTime,
          inLocation: inRecord != null ? inRecord.locationName : '未知起點',
          outLocation: current.locationName,
        ));
      } else if (current.xtype == '進站' || current.xtype == '段次上車') {
        // Unmatched in-record
        processedTraceNos.add(current.traceNo);
        final amount = _parseAmount(current.amt);
        final time = DateTime.fromMillisecondsSinceEpoch(current.transactionDate * 1000);
        
        result.add(YoyuTransaction.transit(
          traceNo: current.traceNo,
          partnerName: current.partnerName,
          amount: amount,
          balance: current.electronicValue,
          inTime: time,
          outTime: time, // Both same if no out record
          inLocation: current.locationName,
          outLocation: '未知終點',
        ));
      } else {
        // Fallback for unexpected transit types
        processedTraceNos.add(current.traceNo);
        final amount = _parseAmount(current.amt);
        final time = DateTime.fromMillisecondsSinceEpoch(current.transactionDate * 1000);
        
        result.add(YoyuTransaction.retail(
          traceNo: current.traceNo,
          partnerName: current.partnerName,
          amount: amount,
          balance: current.electronicValue,
          time: time,
          location: current.locationName,
          description: current.xtype,
        ));
      }
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
