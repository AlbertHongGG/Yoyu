import 'package:flutter/material.dart';

class ShimmerImageCard extends StatefulWidget {
  const ShimmerImageCard({super.key});

  @override
  State<ShimmerImageCard> createState() => _ShimmerImageCardState();
}

class _ShimmerImageCardState extends State<ShimmerImageCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _colorAnim = ColorTween(
      begin: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
      end: isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.15),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _colorAnim.value,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
