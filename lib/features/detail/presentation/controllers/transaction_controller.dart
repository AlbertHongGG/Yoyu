import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/detail/domain/models/yoyu_transaction.dart';
import 'package:yoyu/features/detail/data/repositories/detail_repository.dart';
import 'package:yoyu/features/detail/presentation/providers/card_detail_filter_provider.dart';

final transactionProvider = FutureProvider.family.autoDispose<List<YoyuTransaction>, String>((ref, cardNo) async {
  ref.watch(cardDetailFilterProvider);
  final filterState = ref.read(cardDetailFilterProvider.notifier).getState(cardNo);
  
  return ref.read(detailRepositoryProvider).getTransactions(
    cardNo: cardNo, 
    sDate: filterState.sDate, 
    eDate: filterState.eDate
  );
});

final filteredTransactionProvider = Provider.family.autoDispose<AsyncValue<List<YoyuTransaction>>, String>((ref, cardNo) {
  final txAsync = ref.watch(transactionProvider(cardNo));
  ref.watch(cardDetailFilterProvider);
  final filterState = ref.read(cardDetailFilterProvider.notifier).getState(cardNo);

  return txAsync.whenData((transactions) {
    var filtered = transactions;
    
    if (filterState.partnerFilter != null && filterState.partnerFilter!.isNotEmpty) {
      filtered = filtered.where((tx) {
        return switch (tx) {
          TransitTransaction t => t.partnerName == filterState.partnerFilter,
          RetailTransaction r => r.partnerName == filterState.partnerFilter,
        };
      }).toList();
    }
    
    if (filterState.searchQuery.isNotEmpty) {
      final q = filterState.searchQuery.toLowerCase();
      filtered = filtered.where((tx) {
        return switch (tx) {
          TransitTransaction t => 
            t.partnerName.toLowerCase().contains(q) ||
            t.inLocation.toLowerCase().contains(q) ||
            t.outLocation.toLowerCase().contains(q),
          RetailTransaction r => 
            r.partnerName.toLowerCase().contains(q) ||
            r.location.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q),
        };
      }).toList();
    }
    
    return filtered;
  });
});
