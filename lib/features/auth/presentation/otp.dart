import 'dart:async';
import 'package:diginiwas/features/auth/presentation/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_pages.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart'; // <-- Yeh AppToast wali file import hai
import '../application/auth_controller.dart';

/// What the "location required" dialog's button should trigger next.
enum _LocationDialogAction { retry, openLocationSettings, openAppSettings, cancel }

/// Whether this OTP screen is verifying a brand-new registration
/// or logging an existing user back in.
enum OtpFlowMode { register, login }

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final OtpFlowMode mode;

  /// 'Buyer' / 'Seller' / 'Partner' — chosen on [ChooseRoleScreen] before
  /// this screen, and needed to know which dashboard to open once OTP is
  /// verified.
  final String role;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.role,
    this.mode = OtpFlowMode.register,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  static const int _resendSeconds = 30;
  int _secondsRemaining = _resendSeconds;
  Timer? _timer;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = _resendSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Handles auto-fill or full-string pasting (e.g. 6-digit SMS code)
  void _onOtpChanged(String val, int index) {
    if (val.length > 1) {
      final cleanedVal = val.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < 6; i++) {
        if (i < cleanedVal.length) {
          _controllers[i].text = cleanedVal[i];
        }
      }
      if (cleanedVal.length >= 6) {
        FocusScope.of(context).unfocus();
        _verifyOtp();
      } else if (cleanedVal.isNotEmpty) {
        _focusNodes[cleanedVal.length < 6 ? cleanedVal.length : 5]
            .requestFocus();
      }
      return;
    }

    if (val.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (val.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    } else if (val.isNotEmpty && index == 5) {
      FocusScope.of(context).unfocus();
      _verifyOtp();
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending || _secondsRemaining > 0) return;
    setState(() => _isResending = true);
    final success = await _authController.resendOtp();
    if (!mounted) return;
    setState(() => _isResending = false);

    if (success) {
      _startTimer();
      AppToast.success(context, 'OTP resent successfully.');
    } else {
      final backendError = _authController.state.value.errorMessage;
      AppToast.error(context, backendError ?? 'Could not resend OTP.');
    }
  }

  Future<void> _verifyOtp() async {
    // Plain `print` — bypasses the logger package entirely, so even if
    // something is wrong with AppLogger's config this still shows up in
    // `flutter run`'s console. If this single line doesn't appear the
    // moment you tap the button, the button isn't reaching this method.
    print('🟢 _verifyOtp() called');

    if (_isVerifying) {
      print('🟡 _verifyOtp() aborted: already verifying');
      return;
    }

    final otp = _controllers.map((c) => c.text.trim()).join();
    print('🟢 otp entered: "$otp" (length ${otp.length})');
    if (otp.length != 6) {
      AppToast.error(context, 'Please enter the complete 6-digit OTP.');
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      // Location is mandatory at OTP time — keep the user here (with a
      // clear reason + a way to fix it) until we actually have a GPS fix,
      // instead of silently letting login through without one.
      print('🟢 calling _ensureLocationCaptured()...');
      final hasLocation = await _ensureLocationCaptured();
      print('🟢 _ensureLocationCaptured() returned $hasLocation');
      if (!mounted || !hasLocation) return;

      setState(() => _isVerifying = true);

      final success = await _authController.verifyOtp(otp);
      print('🟢 verifyOtp() controller call returned $success');

      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (!success) {
        final backendError = _authController.state.value.errorMessage;
        AppToast.error(context, backendError ?? 'Invalid OTP.');
        return;
      }

      AppToast.success(
        context,
        widget.mode == OtpFlowMode.register
            ? 'Registration successful!'
            : 'Login successful!',
      );

      Get.offAllNamed(dashboardRouteForRole(widget.role));
    } catch (e, st) {
      // Anything thrown in here was previously vanishing silently (no
      // toast, no console line) — surface it loudly instead.
      print('🔴 _verifyOtp() threw: $e');
      print(st);
      if (mounted) {
        setState(() => _isVerifying = false);
        AppToast.error(context, 'Something went wrong: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DigiNiwasLogo(),
                  SizedBox(height: 24.h),

                  // Title & Subtitle
                  Text(
                    'Verify Your Mobile Number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Enter the 6-digit OTP sent to your\nregistered mobile number.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Mobile preview card
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400.w),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color:
                            AppColors.textSecondary.withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: const BoxDecoration(
                              color: AppColors.softBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.phone_android_rounded,
                                size: 20.sp, color: AppColors.primaryDark),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '+91 ${widget.phoneNumber}',
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'REGISTERED NUMBER',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: AppColors.textPlaceholder,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.edit_outlined,
                                color: AppColors.primaryDark, size: 20.sp),
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // 6-digit OTP Inputs (Centered Container wrapper)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 360.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        List.generate(6, (index) => _buildOtpBox(index)),
                      ),
                    ),
                  ),
                  SizedBox(height: 26.h),

                  // Resend Timer / Resend action
                  _secondsRemaining > 0
                      ? RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: 'Resend OTP in '),
                        TextSpan(
                          text:
                          '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                      : GestureDetector(
                    onTap: _resendOtp,
                    child: _isResending
                        ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2.2),
                    )
                        : Text(
                      'Resend OTP',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Verify OTP CTA
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400.w),
                    child: AppButton(
                      label: 'Verify OTP',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: _isVerifying,
                      onPressed: _isVerifying ? null : _verifyOtp,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Bottom Secure Label
                  Text(
                    'Secure verification by DigiNiwas Cloud',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Blocks OTP verification until a GPS fix is captured, retrying
  /// through the system prompts as many times as the user is willing to.
  /// Returns false only if the user explicitly cancels.
  Future<bool> _ensureLocationCaptured() async {
    final notifier = _authController;

    // Already have a fix from the previous screen (register/send-otp).
    if (_authController.state.value.location != null) {
      print('🟢 location already captured earlier, skipping prompt.');
      return true;
    }

    while (mounted) {
      print('🟢 attempting to capture location...');
      final result = await notifier.captureLocation();
      if (result != null) {
        print('🟢 location captured -> $result');
        return true;
      }

      final error = _authController.state.value.locationError ??
          'Could not fetch your location.';
      print('🔴 location capture failed -> $error');
      if (!mounted) return false;

      final action = await _showLocationRequiredDialog(error);
      print('🟢 user picked $action on location dialog.');
      switch (action) {
        case _LocationDialogAction.openLocationSettings:
          await Geolocator.openLocationSettings();
          continue;
        case _LocationDialogAction.openAppSettings:
          await Geolocator.openAppSettings();
          continue;
        case _LocationDialogAction.retry:
          continue;
        case _LocationDialogAction.cancel:
        case null:
          return false;
      }
    }
    return false;
  }

  Future<_LocationDialogAction?> _showLocationRequiredDialog(String message) {
    final isServiceOff = message.contains('services are turned off');
    final isPermanentlyDenied = message.contains('permanently denied');

    return showDialog<_LocationDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Required'),
        content: Text(
          '$message\n\nDigiNiwas needs your location to show relevant listings on your home screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, _LocationDialogAction.cancel),
            child: const Text('Cancel'),
          ),
          // Always offer a direct path to Settings — even if we guessed the
          // wrong primary action below, the user is never stuck with only
          // a "retry" button that can never succeed (e.g. permission was
          // never declared in the installed build, so retry alone would
          // loop forever with no way out).
          TextButton(
            onPressed: () => Navigator.pop(ctx, _LocationDialogAction.openAppSettings),
            child: const Text('App Settings'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              ctx,
              isPermanentlyDenied
                  ? _LocationDialogAction.openAppSettings
                  : isServiceOff
                  ? _LocationDialogAction.openLocationSettings
                  : _LocationDialogAction.retry,
            ),
            child: Text(
              isPermanentlyDenied
                  ? 'Open App Settings'
                  : isServiceOff
                  ? 'Turn On Location'
                  : 'Allow Location',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 46.w,
      height: 52.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        maxLength: 6,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) => _onOtpChanged(val, index),
      ),
    );
  }
}