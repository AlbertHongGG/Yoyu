import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/detail/domain/models/transaction_analysis.dart';
import 'package:yoyu/features/detail/data/repositories/detail_repository.dart';
import 'package:yoyu/features/detail/presentation/providers/card_detail_filter_provider.dart';

final analysisProvider = FutureProvider.family.autoDispose<List<TransactionAnalysis>, String>((ref, cardNo) async {
  ref.watch(cardDetailFilterProvider);
  final filterState = ref.read(cardDetailFilterProvider.notifier).getState(cardNo);
  
  return ref.read(detailRepositoryProvider).getAnalysis(
    cardNo: cardNo, 
    sDate: filterState.sDate, 
    eDate: filterState.eDate
  );
});
