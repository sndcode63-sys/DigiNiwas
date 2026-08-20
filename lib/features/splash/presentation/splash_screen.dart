import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/login_screen.dart';

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
  static const Color subtitleGrey = AppColors.textSecondary;

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
    // 2.5 seconds wait for smooth animation
    await Future.delayed(const Duration(milliseconds: 2500));

    final hasToken = await ref.read(secureStorageProvider).hasToken();

    if (!mounted) return;

    if (hasToken) {
      // 🔧 Agar token ho toh HomeScreen par redirect karein
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
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
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                      // App Logo
                      Image.asset(
                        'assets/images/logo.png',
                        height: 110.h,
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
                      SizedBox(height: 16.h),

                      // Title
                      Text(
                        'DigiNiwas',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 6.h),

                      // Tagline
                      Text(
                        "India's Trusted Digital Property Platform",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: subtitleGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Loader & Footer
            Positioned(
              bottom: 32.h,
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
                  SizedBox(height: 16.h),
                  Text(
                    'Digital भी, Genuine भी',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: textDark.withOpacity(0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}