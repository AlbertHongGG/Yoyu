import 'package:flutter/material.dart';

class SplashTitle extends StatelessWidget {
  final Animation<double> unfoldAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const SplashTitle({
    super.key,
    required this.unfoldAnimation,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: unfoldAnimation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: unfoldAnimation.value,
            child: child,
          ),
        );
      },
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Elegant expanding line
              AnimatedBuilder(
                animation: fadeAnimation,
                builder: (context, child) {
                  return Container(
                    width: 120 * fadeAnimation.value, // Line grows from center
                    height: 1,
                    color: const Color(0xFF1D1D1F).withValues(alpha: 0.3),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Y O Y U',
                style: TextStyle(
                  fontFamily: 'Outfit', // Or any elegant serif font if available
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D1D1F),
                  letterSpacing: 8.0, // Increased spacing for more elegance
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'iPASS 一卡通',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF86868B),
                  letterSpacing: 4.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
