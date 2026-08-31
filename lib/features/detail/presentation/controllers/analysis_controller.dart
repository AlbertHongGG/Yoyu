import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/detail/domain/models/transaction_analysis.dart';
import 'package:yoyu/features/detail/data/repositories/detail_repository.dart';

final analysisProvider = FutureProvider.family.autoDispose<List<TransactionAnalysis>, String>((ref, arg) async {
  return ref.read(detailRepositoryProvider).getAnalysis(arg);
});
