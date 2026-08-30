import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/application/auth_provider.dart';
import '../../auth/presentation/agent/home_screen.dart';
import '../../auth/presentation/buyer_section/buyer_home.dart' as buyer;
import '../../auth/presentation/buyer_section/choose_roll.dart';
import '../../auth/presentation/seller/home_seller.dart';

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

    Widget destination;
    if (session != null) {
      // Already logged in from a previous app run — skip auth entirely.
      final role = (session['role'] as String?)?.toLowerCase();
      switch (role) {
        case 'seller':
          destination = const SellerHomeScreen();
          break;
        case 'partner':
        case 'agent':
          destination = const PartnerDashboardScreen();
          break;
        case 'buyer':
          destination = const buyer.HomeScreen();
          break;
        default:
          // Unknown/missing role in the saved session — safest is to ask again.
          destination = const ChooseRoleScreen();
      }
    } else {
      destination = const ChooseRoleScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
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