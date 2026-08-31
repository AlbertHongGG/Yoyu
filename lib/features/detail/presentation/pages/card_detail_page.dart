import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yoyu/features/home/domain/models/card_entity.dart';
import 'package:yoyu/features/detail/domain/models/yoyu_transaction.dart';
import 'package:yoyu/features/detail/presentation/controllers/transaction_controller.dart';
import 'package:yoyu/features/detail/presentation/controllers/analysis_controller.dart';
import 'package:yoyu/features/detail/presentation/widgets/transaction_history_tab.dart';
import 'package:yoyu/features/detail/presentation/widgets/transaction_analysis_tab.dart';
import 'package:yoyu/core/widgets/skeleton_widget.dart';
import 'package:yoyu/features/detail/presentation/providers/card_detail_filter_provider.dart';
import 'package:yoyu/core/widgets/app_bottom_sheet.dart';
import 'package:yoyu/core/widgets/search_dialog.dart';
import 'package:yoyu/features/detail/presentation/widgets/date_range_bottom_sheet.dart';

class CardDetailPage extends ConsumerStatefulWidget {
  final CardEntity card;
  const CardDetailPage({super.key, required this.card});

  @override
  ConsumerState<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends ConsumerState<CardDetailPage> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final txAsync = ref.watch(filteredTransactionProvider(widget.card.cardNo));
    final anAsync = ref.watch(analysisProvider(widget.card.cardNo));
    ref.watch(cardDetailFilterProvider);
    final filterState = ref.read(cardDetailFilterProvider.notifier).getState(widget.card.cardNo);

    Widget currentTab;
    if (_currentIndex == 0) {
      currentTab = KeyedSubtree(
        key: const ValueKey('tab0'),
        child: txAsync.when(
          data: (txs) => TransactionHistoryTab(transactions: txs),
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 80,
              child: SkeletonWidget(width: double.infinity, height: 80, borderRadius: BorderRadius.circular(16)),
            ),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      );
    } else {
      currentTab = KeyedSubtree(
        key: const ValueKey('tab1'),
        child: anAsync.when(
          data: (ans) => TransactionAnalysisTab(analysisList: ans),
          loading: () => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SkeletonWidget(width: 120, height: 20),
                const SizedBox(height: 8),
                const SkeletonWidget(width: 200, height: 40),
                const SizedBox(height: 40),
                ...List.generate(3, (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: SkeletonWidget(width: double.infinity, height: 40),
                )),
              ],
            ),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      );
    }

    final rawTxAsync = ref.watch(transactionProvider(widget.card.cardNo));
    final List<String> availablePartners = rawTxAsync.maybeWhen(
      data: (txs) => txs.map((e) => switch (e) {
        TransitTransaction t => t.partnerName,
        RetailTransaction r => r.partnerName,
      }).toSet().toList(),
      orElse: () => [],
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: _buildAppBarTitle(filterState),
        actions: _buildAppBarActions(filterState, availablePartners),
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: currentTab,
          ),
          
          // Floating Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNavItem(0, Icons.list_alt_rounded, '交易紀錄', isDark, theme.primaryColor),
                    _buildNavItem(1, Icons.pie_chart_outline_rounded, '分析', isDark, theme.primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark, Color primaryColor) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : (isDark ? Colors.white54 : Colors.black54),
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(CardDetailFilterState filterState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (filterState.searchQuery.isNotEmpty) {
      return Text(
        '搜尋: ${filterState.searchQuery}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      );
    }
    
    final df = DateFormat('yyyy/MM/dd');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          df.format(filterState.sDate),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
            height: 1.2,
          ),
        ),
        Text(
          '~ ${df.format(filterState.eDate)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions(CardDetailFilterState filterState, List<String> partners) {
    final theme = Theme.of(context);
    
    return [
      // 1. Partner Filter
      IconButton(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.filter_list_rounded),
            if (filterState.partnerFilter != null && filterState.partnerFilter!.isNotEmpty)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        onPressed: () {
          final items = [
            AppBottomSheetItemData<String?>(
              title: '全部',
              leadingIcon: Icons.all_inclusive,
              value: null,
            )
          ];
          for (final p in partners) {
            items.add(AppBottomSheetItemData(
              title: p,
              leadingIcon: Icons.directions_bus_filled_rounded,
              value: p,
            ));
          }
          AppBottomSheet.show<String?>(
            context: context,
            title: '合作夥伴過濾',
            items: items,
            selectedValue: filterState.partnerFilter,
            onItemSelected: (val) {
              ref.read(cardDetailFilterProvider.notifier).updateState(widget.card.cardNo,
                (state) => state.copyWith(partnerFilter: val)
              );
            },
          );
        },
      ),
      
      // 2. Search
      IconButton(
        icon: Icon(filterState.searchQuery.isNotEmpty ? Icons.close_rounded : Icons.search_rounded),
        onPressed: () {
          if (filterState.searchQuery.isNotEmpty) {
            ref.read(cardDetailFilterProvider.notifier).updateState(widget.card.cardNo,
              (state) => state.copyWith(searchQuery: '')
            );
          } else {
            showDialog(
              context: context,
              builder: (_) => SearchDialog(
                initialQuery: filterState.searchQuery,
                hintText: '搜尋站點、加值...',
                onSearch: (q) {
                  ref.read(cardDetailFilterProvider.notifier).updateState(widget.card.cardNo,
                    (state) => state.copyWith(searchQuery: q)
                  );
                },
                onClear: () {
                  ref.read(cardDetailFilterProvider.notifier).updateState(widget.card.cardNo,
                    (state) => state.copyWith(searchQuery: '')
                  );
                },
              ),
            );
          }
        },
      ),

      // 3. Date Range
      IconButton(
        icon: const Icon(Icons.date_range_rounded),
        onPressed: () {
          DateRangeBottomSheet.show(context, widget.card.cardNo);
        },
      ),
      const SizedBox(width: 8),
    ];
  }
}
