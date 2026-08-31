
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_detail_filter_provider.freezed.dart';

@freezed
abstract class CardDetailFilterState with _$CardDetailFilterState {
  const CardDetailFilterState._();
  const factory CardDetailFilterState({
    required DateTime sDate,
    required DateTime eDate,
    String? partnerFilter,
    @Default('') String searchQuery,
  }) = _CardDetailFilterState;
}

class CardDetailFilterNotifier extends Notifier<Map<String, CardDetailFilterState>> {
  @override
  Map<String, CardDetailFilterState> build() {
    return {};
  }

  CardDetailFilterState getState(String cardNo) {
    if (state.containsKey(cardNo)) return state[cardNo]!;
    final now = DateTime.now();
    final sDate = DateTime(now.year, now.month - 3, now.day);
    return CardDetailFilterState(sDate: sDate, eDate: now);
  }

  void _update(String cardNo, CardDetailFilterState Function(CardDetailFilterState) cb) {
    final currentState = getState(cardNo);
    state = {...state, cardNo: cb(currentState)};
  }

  void updateState(String cardNo, CardDetailFilterState Function(CardDetailFilterState) cb) {
    _update(cardNo, cb);
  }
}

final cardDetailFilterProvider = NotifierProvider<CardDetailFilterNotifier, Map<String, CardDetailFilterState>>(CardDetailFilterNotifier.new);
