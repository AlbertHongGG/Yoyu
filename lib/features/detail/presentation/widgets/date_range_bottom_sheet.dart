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

  void _applyQuickTag(int monthsAgo) {
    final now = DateTime.now();
    setState(() {
      _eDate = now;
      if (monthsAgo == 0) {
        // This Week
        final diff = now.weekday - 1;
        _sDate = now.subtract(Duration(days: diff));
      } else if (monthsAgo == -1) {
        // This Month
        _sDate = DateTime(now.year, now.month, 1);
      } else {
        // Last X Months
        _sDate = DateTime(now.year, now.month - monthsAgo, now.day);
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
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              
              Text(
                '時間區段篩選',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Quick Tags
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickTag('本周', () => _applyQuickTag(0), theme, isDark),
                    const SizedBox(width: 12),
                    _buildQuickTag('本月', () => _applyQuickTag(-1), theme, isDark),
                    const SizedBox(width: 12),
                    _buildQuickTag('近三個月', () => _applyQuickTag(3), theme, isDark),
                    const SizedBox(width: 12),
                    _buildQuickTag('近半年', () => _applyQuickTag(6), theme, isDark),
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
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20),
                  ),
                  Expanded(
                    child: _buildDateInput('結束時間', _eDate, false, theme, isDark),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '套用區段',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(date),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
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
