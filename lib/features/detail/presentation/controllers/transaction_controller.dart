import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/detail/domain/models/combined_transaction.dart';
import 'package:yoyu/features/detail/data/repositories/detail_repository.dart';

final transactionProvider = FutureProvider.family.autoDispose<List<CombinedTransaction>, String>((ref, arg) async {
  return ref.read(detailRepositoryProvider).getTransactions(arg);
});
