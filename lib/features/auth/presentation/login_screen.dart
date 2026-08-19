import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../application/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  static const Color primaryGreen = Color(0xFF26B78B);
  static const Color darkGreen = Color(0xFF1B8262);
  static const Color loginDarkGreen = Color(0xFF0E6E52);
  static const Color titleNavy = Color(0xFF162E4A);
  static const Color bodySlate = Color(0xFF6C7E93);
  static const Color placeholderGrey = Color(0xFFA8B8CA);
  static const Color inputBorderColor = Color(0xFFE8EDF2);
  static const Color scaffoldBackground = Color(0xFFF7F9FC);

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    FocusScope.of(context).unfocus();
    ref.read(authProvider.notifier).login(
      _phoneController.text.trim(),
      _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bool isLoading = authState.status == AuthStatus.loading;

    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      if (next.status == AuthStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful ✅')),
        );
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: scaffoldBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 32.h),

                // 1. Top Logo Section
                Image.asset(
                  'assets/images/logo.png',
                  height: 90.h,
                  errorBuilder: (context, error, stackTrace) => Column(
                    children: [
                      Icon(
                        Icons.home_work_rounded,
                        size: 52.sp,
                        color: primaryGreen,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'DIGINIWAS',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: titleNavy,
                        ),
                      ),
                      Text(
                        'Digital भी , Genuine भी',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: titleNavy.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // 2. Heading & Subtitle
                Text(
                  'Welcome to DigiNiwas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: titleNavy,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "India's Trusted Digital Property Platform",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: bodySlate,
                    letterSpacing: -0.1,
                  ),
                ),
                SizedBox(height: 28.h),

                // 3. Mobile Number Field
                _buildFieldContainer(
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 19.sp,
                        color: bodySlate,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: titleNavy,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18.sp,
                        color: bodySlate,
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 1.2,
                        height: 18.h,
                        color: const Color(0xFFE0E6ED),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w500,
                            color: titleNavy,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Mobile Number',
                            hintStyle: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w500,
                              color: placeholderGrey,
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

                // 4. Full Name Field
                _buildFieldContainer(
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 20.sp,
                        color: bodySlate,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w500,
                            color: titleNavy,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            hintStyle: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w500,
                              color: placeholderGrey,
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

                // 5. Email Address Field (Optional)
                _buildFieldContainer(
                  child: Row(
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        size: 19.sp,
                        color: bodySlate,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w500,
                            color: titleNavy,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Email Address',
                            hintStyle: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w500,
                              color: placeholderGrey,
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
                          color: bodySlate.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // 6. Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoading ? darkGreen : primaryGreen,
                      disabledBackgroundColor: darkGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 15.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 19.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 22.h),

                // 7. Terms of Service & Privacy Policy
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: bodySlate,
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: '\nand '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22.h),

                // 8. Already registered? Log In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already registered? ',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: titleNavy,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: loginDarkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: inputBorderColor, width: 1.1),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}