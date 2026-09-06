import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart';
import '../application/auth_controller.dart';
import 'otp.dart';

class RegistrationScreen extends StatefulWidget {
  final String role;

  const RegistrationScreen({super.key, required this.role});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isFormValid = false;
  bool _isSubmitting = false;

  void _validateForm() {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();

    bool isValid = phone.length >= 10 && name.isNotEmpty;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_isFormValid || _isSubmitting) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final phone = _phoneController.text.trim();
    final success = await _authController.register(
      name: _nameController.text.trim(),
      phone: phone,
      email: _emailController.text.trim(),
      role: widget.role,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      AppToast.success(context, 'OTP sent to $phone');
      final locationError = _authController.state.value.locationError;
      if (locationError != null) {
        AppToast.error(context, locationError);
      }
      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          'phoneNumber': phone,
          'mode': OtpFlowMode.register,
          'role': widget.role,
        },
      );
    } else {
      _showError(
        _authController.state.value.errorMessage ?? 'Registration failed. Please try again.',
      );
    }
  }

  void _showError(String message) {
    AppToast.error(context, message);
  }

  // Method to open Login Bottom Sheet when "Log In" is clicked
  void _openLoginBottomSheet(BuildContext context) {
    final sheetPhoneController = TextEditingController();
    bool isSheetValid = false;
    bool isSheetSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.r),
                    topRight: Radius.circular(32.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textSecondary.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle Line
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Sheet Title
                    Text(
                      'Login to Your Home',
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Enter your mobile number to receive a secure OTP.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    _buildInputPill(
                      child: Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 18.sp, color: AppColors.textSecondary),
                          SizedBox(width: 8.w),
                          Text(
                            '+91',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp, color: AppColors.textSecondary),
                          SizedBox(width: 6.w),
                          Container(width: 1.2, height: 16.h, color: AppColors.border),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextField(
                              controller: sheetPhoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              autofocus: true,
                              onChanged: (value) {
                                setModalState(() {
                                  isSheetValid = value.trim().length >= 10;
                                });

                                if (value.trim().length == 10) {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'Mobile Number',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPlaceholder,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Continue CTA Button inside Bottom Sheet
                    AppButton(
                      label: 'Continue',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: isSheetSubmitting,
                      onPressed: isSheetValid
                          ? () async {
                              final phone = sheetPhoneController.text.trim();
                              setModalState(() => isSheetSubmitting = true);
                              final success = await _authController.requestLoginOtp(
                                phone: phone,
                                role: widget.role,
                              );
                              if (!context.mounted) return;
                              setModalState(() => isSheetSubmitting = false);

                              if (success) {
                                Get.back();
                                AppToast.success(this.context, 'OTP sent to $phone');
                                Get.toNamed(
                                  AppRoutes.otp,
                                  arguments: {
                                    'phoneNumber': phone,
                                    'mode': OtpFlowMode.login,
                                    'role': widget.role,
                                  },
                                );
                              } else {
                                AppToast.error(this.context, _authController.state.value.errorMessage ?? 'Could not send OTP. Please try again.');
                              }
                            }
                          : null,
                    ),
                    SizedBox(height: 16.h),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFD4F1F4), // Light cyan/blue top
                Color(0xFFF7FBFD), // Soft white middle
                Colors.white,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const DigiNiwasLogo(),
                    SizedBox(height: 20.h),

                    // Header
                    Text(
                      'Welcome to DigiNiwas',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "India's Trusted Digital Property Platform",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.softBackground,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Continuing as ${widget.role}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Phone Field
                    _buildInputPill(
                      child: Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 18.sp, color: AppColors.textSecondary),
                          SizedBox(width: 8.w),
                          Text(
                            '+91',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp, color: AppColors.textSecondary),
                          SizedBox(width: 6.w),
                          Container(width: 1.2, height: 16.h, color: AppColors.border),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              onChanged: (value) => _validateForm(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'Mobile Number',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPlaceholder,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Name Field
                    _buildInputPill(
                      child: Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 20.sp, color: AppColors.textSecondary),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              onChanged: (value) => _validateForm(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Full Name',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPlaceholder,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Email Field (Optional)
                    _buildInputPill(
                      child: Row(
                        children: [
                          Icon(Icons.mail_outline_rounded, size: 19.sp, color: AppColors.textSecondary),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Email Address',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPlaceholder,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 22.h),

                    // Action Button (Enabled only when form is valid)
                    AppButton(
                      label: 'Continue',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _isFormValid ? _handleContinue : null,
                    ),
                    SizedBox(height: 24.h),

                    // Terms & Policy
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                        children: [
                          const TextSpan(text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                          const TextSpan(text: '\nand '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Login Prompt - Opens Login Bottom Sheet on click
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already registered? ',
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openLoginBottomSheet(context),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputPill({required Widget child}) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class DigiNiwasLogo extends StatelessWidget {
  final double? height;

  const DigiNiwasLogo({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_logo.png',
      height: height ?? 95.h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.home_work_rounded,
            size: 48.sp,
            color: AppColors.primary,
          ),
          SizedBox(height: 4.h),
          Text(
            'DIGINIWAS',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}