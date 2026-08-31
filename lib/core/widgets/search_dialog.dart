import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchDialog extends StatefulWidget {
  final String initialQuery;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final String hintText;

  const SearchDialog({
    super.key,
    required this.initialQuery,
    required this.onSearch,
    required this.onClear,
    this.hintText = 'Search...',
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear();
    setState(() {});
  }

  void _submit() {
    HapticFeedback.lightImpact();
    widget.onSearch(_controller.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark 
        ? const Color(0xFF2C2C30).withValues(alpha: 0.9) 
        : Colors.white.withValues(alpha: 0.95);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final iconColor = isDark ? Colors.white60 : Colors.black54;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      spreadRadius: -4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onSubmitted: (_) => _submit(),
                  onChanged: (val) {
                    setState(() {});
                  },
                  textInputAction: TextInputAction.search,
                  cursorColor: theme.colorScheme.primary,
                  style: TextStyle(
                    fontSize: 17,
                    color: textColor,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 12),
                      child: Icon(Icons.search_rounded, color: iconColor, size: 22),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white30 : Colors.black26,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    suffixIcon: _controller.text.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white12 : Colors.black12,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close_rounded, color: iconColor, size: 14),
                              ),
                              onPressed: _handleClear,
                            ),
                          )
                        : const SizedBox(width: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
