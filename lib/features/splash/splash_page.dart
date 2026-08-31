import 'package:flutter/material.dart';

import 'widgets/splash_logo.dart';
import 'widgets/splash_title.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback? onInitializationComplete;

  const SplashPage({
    super.key,
    this.onInitializationComplete,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Logo animations
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  // Title animations
  late final Animation<double> _titleUnfold;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;

  bool _isAnimationDone = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _setupAnimations();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimationDone = true;
        _checkCompletion();
      }
    });

    _startPipeline();
  }

  Future<void> _startPipeline() async {
    // 1. Start Animation (non-blocking UI task)
    _controller.forward();
  }

  void _checkCompletion() {
    if (_isAnimationDone) {
      _navigateToHome();
    }
  }

  void _setupAnimations() {
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _titleUnfold = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
    );
    
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(_titleUnfold);

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  void _navigateToHome() {
    if (mounted && widget.onInitializationComplete != null) {
      widget.onInitializationComplete!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SplashLogo(
              fadeAnimation: _logoFade,
              scaleAnimation: _logoScale,
            ),
            SplashTitle(
              unfoldAnimation: _titleUnfold,
              slideAnimation: _titleSlide,
              fadeAnimation: _titleFade,
            ),
          ],
        ),
      ),
    );
  }
}
