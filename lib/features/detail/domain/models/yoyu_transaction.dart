import 'package:freezed_annotation/freezed_annotation.dart';

part 'yoyu_transaction.freezed.dart';

@freezed
sealed class YoyuTransaction with _$YoyuTransaction {
  // TransitTransaction for MRT, Train, Bus
  const factory YoyuTransaction.transit({
    required String traceNo,
    required String partnerName,
    required int amount,
    required double balance,
    required DateTime inTime,
    required DateTime outTime,
    required String inLocation,
    required String outLocation,
  }) = TransitTransaction;

  // RetailTransaction for YouBike, Convenience stores, Add value etc.
  const factory YoyuTransaction.retail({
    required String traceNo,
    required String partnerName,
    required int amount,
    required double balance,
    required DateTime time,
    required String location,
    required String description,
  }) = RetailTransaction;
}
