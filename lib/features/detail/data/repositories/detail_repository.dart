import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/core/network/api_client.dart';
import 'package:yoyu/features/detail/domain/models/raw_transaction.dart';
import 'package:yoyu/features/detail/domain/models/yoyu_transaction.dart';
import 'package:yoyu/features/detail/domain/models/transaction_analysis.dart';
import 'package:yoyu/features/detail/domain/services/transaction_aggregator.dart';
import 'package:intl/intl.dart';

class DetailRepository {
  final ApiClient _apiClient;
  final TransactionAggregator _aggregator;

  DetailRepository(this._apiClient, this._aggregator);

  Future<List<YoyuTransaction>> getTransactions(String cardNo) async {
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
        final List<RawTransaction> rawList = details
            .map((e) => RawTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
        
        return _aggregator.aggregate(rawList);
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
}

final detailRepositoryProvider = Provider<DetailRepository>((ref) {
  return DetailRepository(ref.watch(apiClientProvider), TransactionAggregator());
});
