import 'package:freezed_annotation/freezed_annotation.dart';

part 'raw_transaction.freezed.dart';
part 'raw_transaction.g.dart';

@freezed
abstract class RawTransaction with _$RawTransaction {
  const factory RawTransaction({
    @JsonKey(name: 'TraceNo') required String traceNo,
    @JsonKey(name: 'TransactionDate') required int transactionDate,
    @JsonKey(name: 'xtype') required String xtype,
    @JsonKey(name: 'PartnerName') required String partnerName,
    @JsonKey(name: 'ElectronicValue') required double electronicValue,
    @JsonKey(name: 'LocationName') required String locationName,
    @JsonKey(name: 'DataSource') required String dataSource,
    @JsonKey(name: 'AMT') required String amt,
  }) = _RawTransaction;

  factory RawTransaction.fromJson(Map<String, dynamic> json) =>
      _$RawTransactionFromJson(json);
}
