import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_analysis.freezed.dart';
part 'transaction_analysis.g.dart';

@freezed
abstract class TransactionAnalysis with _$TransactionAnalysis {
  const factory TransactionAnalysis({
    required String scopeName,
    required int ptCnt,
    required int ptAmt,
    required int mtCnt,
    required int mtAmt,
    required int aptCnt,
    required int aptAmt,
  }) = _TransactionAnalysis;

  factory TransactionAnalysis.fromJson(Map<String, dynamic> json) => _$TransactionAnalysisFromJson(json);
}
