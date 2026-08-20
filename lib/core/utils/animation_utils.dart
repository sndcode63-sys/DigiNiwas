import 'package:flutter/material.dart';

class AppAnimations {
  // 1. Fade Transition Wrapper
  static Widget fadeIn({
    required Widget child,
    required AnimationController controller,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    final Animation<double> fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }

  // 2. Slide Up Transition (Jaise Bottom Sheet ya Cards niche se upar aate hain)
  static Widget slideUp({
    required Widget child,
    required AnimationController controller,
    Offset beginOffset = const Offset(0, 0.15),
  }) {
    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: child,
    );
  }

  // 3. Scale Animation (Buttons ya Icons ke liye pop effect)
  static Widget scale({
    required Widget child,
    required AnimationController controller,
    double beginScale = 0.85,
  }) {
    final Animation<double> scaleAnimation = Tween<double>(
      begin: beginScale,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
    );

    return ScaleTransition(
      scale: scaleAnimation,
      child: child,
    );
  }
}