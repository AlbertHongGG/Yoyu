import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yoyu/features/detail/domain/models/transaction_analysis.dart';
import 'package:yoyu/features/detail/presentation/providers/transaction_analysis_view_model.dart';

class TransactionAnalysisTab extends StatefulWidget {
  final List<TransactionAnalysis> analysisList;

  const TransactionAnalysisTab({
    super.key,
    required this.analysisList,
  });

  @override
  State<TransactionAnalysisTab> createState() => _TransactionAnalysisTabState();
}

class _TransactionAnalysisTabState extends State<TransactionAnalysisTab> {
  late final TransactionAnalysisViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TransactionAnalysisViewModel(widget.analysisList);
  }

  @override
  void didUpdateWidget(TransactionAnalysisTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.analysisList != oldWidget.analysisList) {
      // Re-initialize if data changes
      _viewModel.dispose();
      _viewModel = TransactionAnalysisViewModel(widget.analysisList);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;
        final currencyFormat = NumberFormat.currency(locale: 'zh_TW', symbol: '\$', decimalDigits: 0);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Column(
          children: [
            // Top Overview Area (No Date anymore)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _OverviewCard(
                      title: '總支出',
                      amount: state.totalExpense,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(width: 12),
                    _OverviewCard(
                      title: '總加值',
                      amount: state.totalTopUp,
                      color: Colors.blue.shade400,
                    ),
                    const SizedBox(width: 12),
                    _OverviewCard(
                      title: '總自動加值',
                      amount: state.totalAutoTopUp,
                      color: Colors.orange.shade400,
                    ),
                  ],
                ),
              ),
            ),

            // Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildSegment(context, state.currentType, AnalysisDataType.expense, '支出', _viewModel),
                    _buildSegment(context, state.currentType, AnalysisDataType.topUp, '加值', _viewModel),
                    _buildSegment(context, state.currentType, AnalysisDataType.autoTopUp, '自動加值', _viewModel),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List Area
            Expanded(
              child: _buildListArea(context, state, currencyFormat),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListArea(BuildContext context, AnalysisUIState state, NumberFormat currencyFormat) {
    if (state.currentCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(
              '此區間無資料',
              style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    Color barColor;
    switch (state.currentType) {
      case AnalysisDataType.expense:
        barColor = Colors.red.shade400;
        break;
      case AnalysisDataType.topUp:
        barColor = Colors.blue.shade400;
        break;
      case AnalysisDataType.autoTopUp:
        barColor = Colors.orange.shade400;
        break;
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
      itemCount: state.currentCategories.length,
      itemBuilder: (context, index) {
        final item = state.currentCategories[index];
        final percentage = state.currentTotalAmount > 0 
            ? (item.amount / state.currentTotalAmount) 
            : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _CategoryRow(
            data: item,
            percentage: percentage,
            barColor: barColor,
            currencyFormat: currencyFormat,
          ),
        );
      },
    );
  }

  Widget _buildSegment(BuildContext context, AnalysisDataType currentType, AnalysisDataType targetType, String label, TransactionAnalysisViewModel viewModel) {
    final isSelected = currentType == targetType;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.setType(targetType),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
              ? (isDark ? Colors.white24 : Colors.white) 
              : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black87)
                  : (isDark ? Colors.white54 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final int amount;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'zh_TW', symbol: '\$', decimalDigits: 0);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryUIModel data;
  final double percentage;
  final Color barColor;
  final NumberFormat currencyFormat;

  const _CategoryRow({
    required this.data,
    required this.percentage,
    required this.barColor,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: barColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(data.icon, color: barColor, size: 24),
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        data.scopeName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${data.count} 次',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currencyFormat.format(data.amount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
