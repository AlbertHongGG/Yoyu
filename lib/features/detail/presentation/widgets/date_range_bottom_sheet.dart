import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yoyu/core/widgets/pickers/premium_calendar_picker.dart';
import 'package:yoyu/features/detail/presentation/providers/card_detail_filter_provider.dart';

class DateRangeBottomSheet extends ConsumerStatefulWidget {
  final String cardNo;

  const DateRangeBottomSheet({super.key, required this.cardNo});

  static void show(BuildContext context, String cardNo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DateRangeBottomSheet(cardNo: cardNo),
    );
  }

  @override
  ConsumerState<DateRangeBottomSheet> createState() => _DateRangeBottomSheetState();
}

enum DateQuickTag {
  last7Days,
  lastMonth,
  last3Months,
  prev3Months,
  q1,
  q2,
  q3,
  q4,
}

class _DateRangeBottomSheetState extends ConsumerState<DateRangeBottomSheet> {
  late DateTime _sDate;
  late DateTime _eDate;

  @override
  void initState() {
    super.initState();
    final filterState = ref.read(cardDetailFilterProvider.notifier).getState(widget.cardNo);
    _sDate = filterState.sDate;
    _eDate = filterState.eDate;
  }

  void _applyQuickTag(DateQuickTag tag) {
    final now = DateTime.now();
    setState(() {
      switch (tag) {
        case DateQuickTag.last7Days:
          _eDate = now;
          _sDate = now.subtract(const Duration(days: 7));
          break;
        case DateQuickTag.lastMonth:
          _eDate = now;
          _sDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case DateQuickTag.last3Months:
          _eDate = now;
          _sDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case DateQuickTag.prev3Months:
          _eDate = DateTime(now.year, now.month - 3, now.day);
          _sDate = DateTime(now.year, now.month - 6, now.day);
          break;
        case DateQuickTag.q1:
          _sDate = DateTime(now.year, 1, 1);
          _eDate = DateTime(now.year, 3, 31);
          break;
        case DateQuickTag.q2:
          _sDate = DateTime(now.year, 4, 1);
          _eDate = DateTime(now.year, 6, 30);
          break;
        case DateQuickTag.q3:
          _sDate = DateTime(now.year, 7, 1);
          _eDate = DateTime(now.year, 9, 30);
          break;
        case DateQuickTag.q4:
          _sDate = DateTime(now.year, 10, 1);
          _eDate = DateTime(now.year, 12, 31);
          break;
      }
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart ? _sDate : _eDate;
    final selected = await showPremiumCalendarPicker(
      context: context,
      initialDate: initialDate,
      title: isStart ? '選擇起始時間' : '選擇結束時間',
    );
    if (selected != null) {
      setState(() {
        if (isStart) {
          _sDate = selected;
          if (_sDate.isAfter(_eDate)) _eDate = _sDate;
        } else {
          _eDate = selected;
          if (_eDate.isBefore(_sDate)) _sDate = _eDate;
        }
      });
    }
  }

  void _submit() {
    ref.read(cardDetailFilterProvider.notifier).updateState(widget.cardNo,
      (state) => state.copyWith(sDate: _sDate, eDate: _eDate)
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final backgroundColor = isDark 
        ? const Color(0xFF1E1E1E).withValues(alpha: 0.9) 
        : Colors.white.withValues(alpha: 0.95);


    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Placeholder to keep title perfectly centered
                  const SizedBox(width: 48),
                  
                  // Header Title
                  Text(
                    '時間區段篩選',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),

                  // Done Button (Icon)
                  IconButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _submit();
                    },
                    icon: const Icon(Icons.check_circle_rounded),
                    color: theme.primaryColor,
                    iconSize: 28,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Tags
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickTag('近七天', () => _applyQuickTag(DateQuickTag.last7Days), theme, isDark),
                    const SizedBox(width: 12),
                    _buildQuickTag('近一個月', () => _applyQuickTag(DateQuickTag.lastMonth), theme, isDark),
                    const SizedBox(width: 12),
                    _buildQuickTag('近三個月', () => _applyQuickTag(DateQuickTag.last3Months), theme, isDark),
                    const SizedBox(width: 12),
                    _buildQuickTag('上個三個月', () => _applyQuickTag(DateQuickTag.prev3Months), theme, isDark),
                    const SizedBox(width: 12),
                    _buildQuickTag('Q1', () => _applyQuickTag(DateQuickTag.q1), theme, isDark),
                    const SizedBox(width: 12),
                    _buildQuickTag('Q2', () => _applyQuickTag(DateQuickTag.q2), theme, isDark),
                    const SizedBox(width: 12),
                    _buildQuickTag('Q3', () => _applyQuickTag(DateQuickTag.q3), theme, isDark),
                    const SizedBox(width: 12),
                    _buildQuickTag('Q4', () => _applyQuickTag(DateQuickTag.q4), theme, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Date Inputs
              Row(
                children: [
                  Expanded(
                    child: _buildDateInput('起始時間', _sDate, true, theme, isDark),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20),
                  ),
                  Expanded(
                    child: _buildDateInput('結束時間', _eDate, false, theme, isDark),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTag(String label, VoidCallback onTap, ThemeData theme, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDateInput(String label, DateTime date, bool isStart, ThemeData theme, bool isDark) {
    final dateFormat = DateFormat('yyyy/MM/dd');
    return GestureDetector(
      onTap: () => _pickDate(isStart),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: theme.primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      dateFormat.format(date),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
