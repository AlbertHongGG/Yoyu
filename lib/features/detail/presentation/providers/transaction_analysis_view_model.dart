import 'package:flutter/material.dart';
import 'package:yoyu/features/detail/domain/models/transaction_analysis.dart';
// --- UI Models ---

enum AnalysisDataType { expense, topUp, autoTopUp }

class CategoryUIModel {
  final String scopeName;
  final int amount;
  final int count;
  final IconData icon;

  CategoryUIModel({
    required this.scopeName,
    required this.amount,
    required this.count,
    required this.icon,
  });
}

class AnalysisUIState {
  final AnalysisDataType currentType;
  final int totalExpense;
  final int totalTopUp;
  final int totalAutoTopUp;
  
  final List<CategoryUIModel> currentCategories;
  final int currentTotalAmount;

  AnalysisUIState({
    required this.currentType,
    required this.totalExpense,
    required this.totalTopUp,
    required this.totalAutoTopUp,
    required this.currentCategories,
    required this.currentTotalAmount,
  });

  AnalysisUIState copyWith({
    AnalysisDataType? currentType,
    int? totalExpense,
    int? totalTopUp,
    int? totalAutoTopUp,
    List<CategoryUIModel>? currentCategories,
    int? currentTotalAmount,
  }) {
    return AnalysisUIState(
      currentType: currentType ?? this.currentType,
      totalExpense: totalExpense ?? this.totalExpense,
      totalTopUp: totalTopUp ?? this.totalTopUp,
      totalAutoTopUp: totalAutoTopUp ?? this.totalAutoTopUp,
      currentCategories: currentCategories ?? this.currentCategories,
      currentTotalAmount: currentTotalAmount ?? this.currentTotalAmount,
    );
  }
}

// --- Strategies ---

abstract class AnalysisCalculator {
  int calculateTotal(List<TransactionAnalysis> data);
  List<CategoryUIModel> extractCategories(List<TransactionAnalysis> data);

  IconData getIconForScope(String scopeName) {
    switch (scopeName) {
      case '市區公車':
        return Icons.directions_bus_filled_rounded;
      case '捷運':
        return Icons.subway_rounded;
      case '小額消費':
      case '便利商店':
        return Icons.storefront_rounded;
      case '臺鐵':
        return Icons.train_rounded;
      case '高鐵':
        return Icons.directions_railway_rounded;
      case 'YouBike':
        return Icons.pedal_bike_rounded;
      case '客運':
        return Icons.directions_bus_rounded;
      case '停車場':
        return Icons.local_parking_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

class ExpenseCalculator extends AnalysisCalculator {
  @override
  int calculateTotal(List<TransactionAnalysis> data) {
    return data.fold<int>(0, (sum, item) => sum + item.mtAmt);
  }

  @override
  List<CategoryUIModel> extractCategories(List<TransactionAnalysis> data) {
    final filtered = data.where((item) => item.mtAmt > 0).map((item) => CategoryUIModel(
      scopeName: item.scopeName,
      amount: item.mtAmt,
      count: item.mtCnt,
      icon: getIconForScope(item.scopeName),
    )).toList();
    
    filtered.sort((a, b) => b.amount.compareTo(a.amount));
    return filtered;
  }
}

class TopUpCalculator extends AnalysisCalculator {
  @override
  int calculateTotal(List<TransactionAnalysis> data) {
    return data.fold<int>(0, (sum, item) => sum + item.ptAmt);
  }

  @override
  List<CategoryUIModel> extractCategories(List<TransactionAnalysis> data) {
    final filtered = data.where((item) => item.ptAmt > 0).map((item) => CategoryUIModel(
      scopeName: item.scopeName,
      amount: item.ptAmt,
      count: item.ptCnt,
      icon: getIconForScope(item.scopeName),
    )).toList();
    
    filtered.sort((a, b) => b.amount.compareTo(a.amount));
    return filtered;
  }
}

class AutoTopUpCalculator extends AnalysisCalculator {
  @override
  int calculateTotal(List<TransactionAnalysis> data) {
    return data.fold<int>(0, (sum, item) => sum + item.aptAmt);
  }

  @override
  List<CategoryUIModel> extractCategories(List<TransactionAnalysis> data) {
    final filtered = data.where((item) => item.aptAmt > 0).map((item) => CategoryUIModel(
      scopeName: item.scopeName,
      amount: item.aptAmt,
      count: item.aptCnt,
      icon: getIconForScope(item.scopeName),
    )).toList();
    
    filtered.sort((a, b) => b.amount.compareTo(a.amount));
    return filtered;
  }
}

// --- ViewModel ---

class TransactionAnalysisViewModel extends ChangeNotifier {
  final List<TransactionAnalysis> rawData;
  late AnalysisUIState state;

  final ExpenseCalculator _expenseCalc = ExpenseCalculator();
  final TopUpCalculator _topUpCalc = TopUpCalculator();
  final AutoTopUpCalculator _autoTopUpCalc = AutoTopUpCalculator();

  TransactionAnalysisViewModel(this.rawData) {
    state = AnalysisUIState(
      currentType: AnalysisDataType.expense,
      totalExpense: _expenseCalc.calculateTotal(rawData),
      totalTopUp: _topUpCalc.calculateTotal(rawData),
      totalAutoTopUp: _autoTopUpCalc.calculateTotal(rawData),
      currentCategories: _expenseCalc.extractCategories(rawData),
      currentTotalAmount: _expenseCalc.calculateTotal(rawData),
    );
  }

  void setType(AnalysisDataType type) {
    if (state.currentType == type) return;

    List<CategoryUIModel> newCategories;
    int newTotalAmount;

    switch (type) {
      case AnalysisDataType.expense:
        newCategories = _expenseCalc.extractCategories(rawData);
        newTotalAmount = _expenseCalc.calculateTotal(rawData);
        break;
      case AnalysisDataType.topUp:
        newCategories = _topUpCalc.extractCategories(rawData);
        newTotalAmount = _topUpCalc.calculateTotal(rawData);
        break;
      case AnalysisDataType.autoTopUp:
        newCategories = _autoTopUpCalc.extractCategories(rawData);
        newTotalAmount = _autoTopUpCalc.calculateTotal(rawData);
        break;
    }

    state = state.copyWith(
      currentType: type,
      currentCategories: newCategories,
      currentTotalAmount: newTotalAmount,
    );
    notifyListeners();
  }
}
