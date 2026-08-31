import 'package:freezed_annotation/freezed_annotation.dart';

part 'combined_transaction.freezed.dart';
part 'combined_transaction.g.dart';

@freezed
abstract class CombinedTransaction with _$CombinedTransaction {
  const factory CombinedTransaction({
    required String traceNo,
    required DateTime transactionDate,
    required String cardName,
    required String inLocation,
    required String outLocation,
    required double electronicValue,
    required int amount,
  }) = _CombinedTransaction;

  factory CombinedTransaction.fromJson(Map<String, dynamic> json) => _$CombinedTransactionFromJson(json);
}
