import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/core/network/api_client.dart';
import 'package:yoyu/features/detail/domain/models/combined_transaction.dart';
import 'package:yoyu/features/detail/domain/models/transaction_analysis.dart';
import 'package:intl/intl.dart';

class DetailRepository {
  final ApiClient _apiClient;

  DetailRepository(this._apiClient);

  Future<List<CombinedTransaction>> getTransactions(String cardNo) async {
    // Determine date range (e.g., last 3 months)
    final now = DateTime.now();
    final sDate = DateTime(now.year, now.month - 3, now.day);
    final dateFormat = DateFormat('yyyy-MM-dd');

    try {
      final response = await _apiClient.post(
        'GetInquireDetail',
        data: {
          "sDate": dateFormat.format(sDate),
          "eDate": dateFormat.format(now),
          "cardNo": cardNo,
        },
      );

      final data = response.data;
      if (data['rtnCode'] == '0' && data['TranDetails'] != null) {
        final List<dynamic> details = data['TranDetails'];
        return _combineTransactions(details);
      } else {
        throw Exception(data['rtnMsg'] ?? '取得明細失敗');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionAnalysis>> getAnalysis(String cardNo) async {
    final now = DateTime.now();
    final sDate = DateTime(now.year, now.month - 3, now.day);
    final dateFormat = DateFormat('yyyy-MM-dd');

    try {
      final response = await _apiClient.post(
        'GetInquireCatalog',
        data: {
          "sDate": dateFormat.format(sDate),
          "eDate": dateFormat.format(now),
          "cardNo": cardNo,
        },
      );

      final data = response.data;
      if (data['rtnCode'] == '0' && data['TranCatalogs'] != null) {
        final List<dynamic> catalogs = data['TranCatalogs'];
        return catalogs.map((e) => TransactionAnalysis(
          scopeName: e['SCOPENAME'] ?? '',
          ptCnt: e['PTCNT'] ?? 0,
          ptAmt: e['PTAMT'] ?? 0,
          mtCnt: e['MTCNT'] ?? 0,
          mtAmt: e['MTAMT'] ?? 0,
          aptCnt: e['APTCNT'] ?? 0,
          aptAmt: e['APTAMT'] ?? 0,
        )).toList();
      } else {
        throw Exception(data['rtnMsg'] ?? '取得分析失敗');
      }
    } catch (e) {
      rethrow;
    }
  }

  List<CombinedTransaction> _combineTransactions(List<dynamic> rawDetails) {
    final List<CombinedTransaction> combined = [];
    
    // Create a mutable copy to process
    final List<Map<String, dynamic>> processList = List.from(rawDetails.map((e) => Map<String, dynamic>.from(e)));
    
    // Sort by Date descending (newest first) to easily find pairs
    processList.sort((a, b) => (b['TransactionDate'] as int).compareTo(a['TransactionDate'] as int));

    for (int i = 0; i < processList.length; i++) {
      final current = processList[i];
      if (current.containsKey('_processed')) continue;

      if (current['xtype'] == '出站') {
        // Look for the corresponding "進站"
        Map<String, dynamic>? inRecord;
        // Search backwards in time (forward in array)
        for (int j = i + 1; j < processList.length; j++) {
           final potentialIn = processList[j];
           if (!potentialIn.containsKey('_processed') && potentialIn['xtype'] == '進站') {
               inRecord = potentialIn;
               potentialIn['_processed'] = true;
               break;
           }
        }
        
        current['_processed'] = true;
        
        final amountStr = (current['AMT'] as String).replaceAll('-', '').replaceAll('+', '');
        final int amount = int.tryParse(amountStr) ?? 0;

        combined.add(CombinedTransaction(
          traceNo: current['TraceNo'] ?? '',
          transactionDate: DateTime.fromMillisecondsSinceEpoch((current['TransactionDate'] as int) * 1000),
          cardName: current['cardName'] ?? '',
          inLocation: inRecord != null ? (inRecord['LocationName'] ?? '') : '未知',
          outLocation: current['LocationName'] ?? '',
          electronicValue: (current['ElectronicValue'] ?? 0).toDouble(),
          amount: amount,
        ));
      } else if (current['xtype'] != '進站') {
        // Handle other types like "加值", "段次上車", "段次下車" directly
        current['_processed'] = true;
        final amountStr = (current['AMT'] as String).replaceAll('-', '').replaceAll('+', '');
        final int amount = int.tryParse(amountStr) ?? 0;

        combined.add(CombinedTransaction(
          traceNo: current['TraceNo'] ?? '',
          transactionDate: DateTime.fromMillisecondsSinceEpoch((current['TransactionDate'] as int) * 1000),
          cardName: current['cardName'] ?? '',
          inLocation: '',
          outLocation: current['LocationName'] ?? current['xtype'] ?? '',
          electronicValue: (current['ElectronicValue'] ?? 0).toDouble(),
          amount: amount,
        ));
      } else {
        // Unmatched "進站", shouldn't happen based on your feedback, but fallback to single display
         current['_processed'] = true;
         final amountStr = (current['AMT'] as String).replaceAll('-', '').replaceAll('+', '');
         final int amount = int.tryParse(amountStr) ?? 0;

         combined.add(CombinedTransaction(
          traceNo: current['TraceNo'] ?? '',
          transactionDate: DateTime.fromMillisecondsSinceEpoch((current['TransactionDate'] as int) * 1000),
          cardName: current['cardName'] ?? '',
          inLocation: current['LocationName'] ?? '',
          outLocation: '',
          electronicValue: (current['ElectronicValue'] ?? 0).toDouble(),
          amount: amount,
        ));
      }
    }

    return combined;
  }
}

final detailRepositoryProvider = Provider<DetailRepository>((ref) {
  return DetailRepository(ref.watch(apiClientProvider));
});
