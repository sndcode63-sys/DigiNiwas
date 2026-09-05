import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const Color primaryGreen = AppColors.primary;
  static const Color textDark = AppColors.textPrimary;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    final session = await ref.read(authRepositoryProvider).getStoredSession();

    if (!mounted) return;

    // Already logged in from a previous app run — skip auth entirely.
    // Unknown/missing role in the saved session falls back to the role
    // picker (see `dashboardRouteForRole`).
    final route = session != null
        ? dashboardRouteForRole(session['role'] as String?)
        : AppRoutes.chooseRole;

    context.go(route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD4F1F4), // Light cyan/blue top
              Color(0xFFF7FBFD), // Soft white bottom
              Colors.white,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Center Logo & Title with Animation
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Provided Brand App Logo
                        Image.asset(
                          'assets/images/app_logo.png',
                          width: 220.w,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Column(
                            children: [
                              Icon(
                                Icons.home_work_rounded,
                                size: 64.sp,
                                color: primaryGreen,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'DIGINIWAS',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                  color: textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Loader & Footer Tagline
              Positioned(
                bottom: 48.h,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    SizedBox(
                      height: 24.h,
                      width: 24.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}