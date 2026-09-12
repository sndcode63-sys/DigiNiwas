import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/seller_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../seller/controller/seller_controller.dart';
import '../../../seller/data/seller_repository.dart';

class SellerRegistrationScreen extends StatefulWidget {
  const SellerRegistrationScreen({super.key});

  @override
  State<SellerRegistrationScreen> createState() => _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  final SellerController _controller = Get.put(SellerController());
  final SellerRepository _repository = SellerRepository();

  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Indore');
  final _stateController = TextEditingController(text: 'Madhya Pradesh');
  final _pinCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');

  double? _latitude;
  double? _longitude;
  bool _isFetchingLocation = false;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // If registration was interrupted (app closed mid-OTP), offer to resume
    // instead of forcing the seller to fill out the whole form again.
    // Otherwise, ask for location right away so the address fields can be
    // auto-filled before the seller starts typing.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hadPendingApplication = await _checkForPendingApplication();
      if (!hadPendingApplication && mounted) {
        _useCurrentLocation();
      }
    });
  }

  /// Returns true if an unfinished registration was found (and the resume
  /// dialog was shown), false otherwise.
  Future<bool> _checkForPendingApplication() async {
    final pending = await SecureStorageService.instance.getPendingSellerApplication();
    final applicationId = pending['applicationId'];
    final step = pending['step'];
    if (applicationId == null || applicationId.isEmpty || step == null) return false;
    if (!mounted) return false;

    _emailController.text = pending['email'] ?? '';
    _phoneController.text = pending['phone'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.hourglass_top_rounded, color: AppColors.primary, size: 24.sp),
            SizedBox(width: 8.w),
            Text('Resume Registration?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15.sp)),
          ],
        ),
        content: Text(
          'You have an unfinished seller registration for ${pending['email'] ?? 'your account'}. '
          'Would you like to continue verifying it?',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await SecureStorageService.instance.clearPendingSellerApplication();
              if (!mounted) return;
              Navigator.pop(ctx);
              // Fresh start — go ahead and prompt for location now.
              _useCurrentLocation();
            },
            child: Text('Start Fresh', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (step == 'VERIFY_PHONE') {
                _showPhoneOtpDialog(applicationId);
              } else {
                _showEmailOtpDialog(applicationId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('Continue', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
    return true;
  }

  /// Pops the native "Allow location access?" permission dialog, then
  /// reverse-geocodes the fix into address/city/state/country/pinCode and
  /// fills the form. Every field stays editable afterwards — this is just
  /// a shortcut, manual entry always works too.
  Future<void> _useCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final location = await LocationService().getCurrentLocation();
      if (!mounted) return;

      setState(() {
        _latitude = location.latitude;
        _longitude = location.longitude;
        if (location.address.isNotEmpty) _addressController.text = location.address;
        if (location.city.isNotEmpty) _cityController.text = location.city;
        if (location.state.isNotEmpty) _stateController.text = location.state;
        if (location.country.isNotEmpty) _countryController.text = location.country;
        if (location.pinCode.isNotEmpty) _pinCodeController.text = location.pinCode;
      });

      Get.snackbar(
        'Location Captured',
        'Address fields have been auto-filled. You can still edit them manually.',
        backgroundColor: const Color(0xFFEAF5F1),
        colorText: AppColors.primary,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on LocationException catch (e) {
      Get.snackbar('Location Unavailable', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Location Unavailable', 'Could not fetch your location. Please enter address manually.');
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final appResult = await _repository.registerSellerApplication(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
        country: _countryController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
      );

      _controller.currentApplication.value = appResult;

      // Persist so the flow can resume if the app is closed before the
      // seller finishes the email/phone OTP steps.
      await SecureStorageService.instance.savePendingSellerApplication(
        applicationId: appResult.applicationId,
        step: 'VERIFY_EMAIL',
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      // Open Email Verification Step
      _showEmailOtpDialog(appResult.applicationId);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Get.snackbar('Registration Failed', e.toString());
    }
  }

  void _showEmailOtpDialog(String applicationId) {
    final otpController = TextEditingController();
    bool isVerifying = false;
    bool isResending = false;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF5F1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.email_outlined, color: AppColors.primary, size: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verify Email Address',
                            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Step 1 of 2',
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'An OTP has been sent to ${_emailController.text.trim()}. Please enter it below:',
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit OTP (e.g. 123456)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      counterText: '',
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: isVerifying
                          ? null
                          : () async {
                              final otp = otpController.text.trim();
                              if (otp.isEmpty) return;

                              setModalState(() => isVerifying = true);
                              try {
                                await _repository.verifySellerEmailOtp(
                                  applicationId: applicationId,
                                  otp: otp,
                                );
                                await SecureStorageService.instance.savePendingSellerApplication(
                                  applicationId: applicationId,
                                  step: 'VERIFY_PHONE',
                                  email: _emailController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                );
                                if (!mounted) return;
                                Navigator.pop(ctx);
                                _showPhoneOtpDialog(applicationId);
                              } catch (e) {
                                setModalState(() => isVerifying = false);
                                Get.snackbar('Error', e.toString());
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: isVerifying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Verify Email & Next', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Center(
                    child: TextButton(
                      onPressed: isResending
                          ? null
                          : () async {
                              setModalState(() => isResending = true);
                              try {
                                await _repository.resendSellerEmailOtp(applicationId: applicationId);
                                Get.snackbar('OTP Resent', 'A fresh OTP has been sent to your email.');
                              } catch (e) {
                                Get.snackbar('Resend Failed', e.toString());
                              } finally {
                                setModalState(() => isResending = false);
                              }
                            },
                      child: Text(
                        isResending ? 'Resending...' : 'Resend Email OTP',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPhoneOtpDialog(String applicationId) {
    final otpController = TextEditingController();
    bool isVerifying = false;
    bool isResending = false;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF5F1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.phone_android_rounded, color: AppColors.primary, size: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verify Phone Number',
                            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Step 2 of 2',
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'An OTP has been sent to ${_phoneController.text.trim()}. Enter it to finalize registration:',
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit OTP (e.g. 123456)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      counterText: '',
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: isVerifying
                          ? null
                          : () async {
                              final otp = otpController.text.trim();
                              if (otp.isEmpty) return;

                              setModalState(() => isVerifying = true);
                              try {
                                final res = await _repository.verifySellerPhoneOtp(
                                  applicationId: applicationId,
                                  otp: otp,
                                );
                                // Registration is complete — no need to resume anymore.
                                await SecureStorageService.instance.clearPendingSellerApplication();
                                if (!mounted) return;
                                Navigator.pop(ctx);
                                final data = res['data'] is Map ? res['data'] as Map<String, dynamic> : <String, dynamic>{};
                                final credentialsSent = data['credentialsEmailSent'] == true;
                                _showSuccessDialog(credentialsSent);
                              } catch (e) {
                                setModalState(() => isVerifying = false);
                                Get.snackbar('Error', e.toString());
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: isVerifying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Complete Verification', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Center(
                    child: TextButton(
                      onPressed: isResending
                          ? null
                          : () async {
                              setModalState(() => isResending = true);
                              try {
                                await _repository.resendSellerPhoneOtp(applicationId: applicationId);
                                Get.snackbar('OTP Resent', 'A fresh OTP has been sent to your phone.');
                              } catch (e) {
                                Get.snackbar('Resend Failed', e.toString());
                              } finally {
                                setModalState(() => isResending = false);
                              }
                            },
                      child: Text(
                        isResending ? 'Resending...' : 'Resend Phone OTP',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(bool credentialsEmailSent) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 28.sp),
            SizedBox(width: 8.w),
            Text('Account Active!', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          credentialsEmailSent
              ? 'Your seller account has been approved and activated! Your temporary login password has been sent to your registered email address.'
              : 'Your seller account is approved and activated! You can now log in using Email OTP or contact support if you need your password.',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSellerLoginBottomSheet();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('Login to Account', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Seller Registration',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('1. Personal Information', Icons.person_outline_rounded),
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'e.g. Rahul Sharma',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your full name' : null,
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'e.g. rahul@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email address' : null,
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'e.g. 9876543210',
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Enter valid 10-digit number' : null,
                ),
                SizedBox(height: 24.h),

                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 4.h,
                  children: [
                    _buildSectionHeader('2. Address & Location', Icons.location_on_outlined),
                    TextButton.icon(
                      onPressed: _isFetchingLocation ? null : _useCurrentLocation,
                      icon: _isFetchingLocation
                          ? SizedBox(
                              width: 14.w,
                              height: 14.h,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.my_location_rounded, size: 16.sp, color: AppColors.primary),
                      label: Text(
                        _isFetchingLocation ? 'Locating...' : 'Use Current Location',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Tap "Use Current Location" to auto-fill the fields below, or enter your address manually.',
                  style: GoogleFonts.poppins(fontSize: 10.5.sp, color: AppColors.textSecondary),
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: _addressController,
                  label: 'Street Address',
                  hint: 'e.g. Scheme No 54, Vijay Nagar',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your street address' : null,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        hint: 'Indore',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField(
                        controller: _stateController,
                        label: 'State',
                        hint: 'Madhya Pradesh',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _pinCodeController,
                        label: 'PIN Code',
                        hint: '452010',
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().length < 6) ? 'Enter 6 digits' : null,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField(
                        controller: _countryController,
                        label: 'Country',
                        hint: 'India',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Register as Seller',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Already Registered Quick Login Option
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already registered as a Seller? ',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showSellerLoginBottomSheet,
                        child: Text(
                          'Login Here',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSellerLoginBottomSheet() {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    final passCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    bool isOtpMode = false;
    bool isOtpSent = false;
    bool isActionLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 20.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Seller Direct Login',
                        style: GoogleFonts.poppins(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            isOtpMode = !isOtpMode;
                            isOtpSent = false;
                          });
                        },
                        child: Text(
                          isOtpMode ? 'Use Password' : 'Use OTP',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(fontSize: 13.sp),
                    decoration: InputDecoration(
                      labelText: 'Registered Email',
                      labelStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (isOtpMode) ...[
                    if (isOtpSent) ...[
                      TextField(
                        controller: otpCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: GoogleFonts.poppins(fontSize: 13.sp),
                        decoration: InputDecoration(
                          labelText: 'Enter 6-digit OTP',
                          hintText: '123456',
                          labelStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          counterText: '',
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ] else ...[
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      style: GoogleFonts.poppins(fontSize: 13.sp),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: isActionLoading
                          ? null
                          : () async {
                              final email = emailCtrl.text.trim();
                              if (email.isEmpty || !email.contains('@')) {
                                Get.snackbar('Input Error', 'Please enter a valid email address');
                                return;
                              }

                              setSheetState(() => isActionLoading = true);

                              try {
                                if (isOtpMode) {
                                  if (!isOtpSent) {
                                    // Send Login OTP
                                    await _repository.sendLoginOtp(email: email);
                                    setSheetState(() {
                                      isOtpSent = true;
                                      isActionLoading = false;
                                    });
                                    Get.snackbar('OTP Sent', 'Login OTP has been sent to $email');
                                    return;
                                  } else {
                                    // Verify Login OTP
                                    final otp = otpCtrl.text.trim();
                                    if (otp.isEmpty) {
                                      setSheetState(() => isActionLoading = false);
                                      Get.snackbar('Input Error', 'Please enter OTP');
                                      return;
                                    }
                                    final res = await _repository.loginWithOtp(email: email, otp: otp);
                                    bool mustChange = false;
                                    if (res['data'] is Map) {
                                      _controller.sellerProfile.value = SellerModel.fromJson(res['data']);
                                      mustChange = res['data']['mustChangePassword'] == true;
                                    }
                                    if (!mounted) return;
                                    Navigator.pop(ctx);
                                    if (mustChange) {
                                      Get.offAllNamed(
                                        AppRoutes.sellerChangePassword,
                                        arguments: {'isMandatory': true},
                                      );
                                    } else {
                                      Get.offAllNamed(AppRoutes.sellerHome);
                                    }
                                  }
                                } else {
                                  // Password Login
                                  final password = passCtrl.text.trim();
                                  if (password.isEmpty) {
                                    setSheetState(() => isActionLoading = false);
                                    Get.snackbar('Input Error', 'Please enter your password');
                                    return;
                                  }
                                  final res = await _repository.loginWithPassword(email: email, password: password);
                                  bool mustChange = false;
                                  if (res['data'] is Map) {
                                    _controller.sellerProfile.value = SellerModel.fromJson(res['data']);
                                    mustChange = res['data']['mustChangePassword'] == true;
                                  }
                                  if (!mounted) return;
                                  Navigator.pop(ctx);
                                  if (mustChange) {
                                    Get.offAllNamed(
                                      AppRoutes.sellerChangePassword,
                                      arguments: {'isMandatory': true},
                                    );
                                  } else {
                                    Get.offAllNamed(AppRoutes.sellerHome);
                                  }
                                }
                              } on SellerException catch (e) {
                                setSheetState(() => isActionLoading = false);
                                final status = e.data?['applicationStatus'];
                                if (status is String && status.isNotEmpty && status != 'APPROVED') {
                                  // Seller account isn't fully verified/approved yet —
                                  // offer to resume the OTP flow instead of a dead end.
                                  final pending = await SecureStorageService.instance
                                      .getPendingSellerApplication();
                                  final applicationId = pending['applicationId'];
                                  Navigator.pop(ctx);
                                  if (applicationId != null && applicationId.isNotEmpty) {
                                    if (status == 'EMAIL_VERIFICATION_PENDING') {
                                      _showEmailOtpDialog(applicationId);
                                    } else if (status == 'PHONE_VERIFICATION_PENDING') {
                                      _showPhoneOtpDialog(applicationId);
                                    } else {
                                      Get.snackbar('Login Failed', e.message);
                                    }
                                  } else {
                                    Get.snackbar('Login Failed', e.message);
                                  }
                                } else {
                                  Get.snackbar('Login Failed', e.message);
                                }
                              } catch (e) {
                                setSheetState(() => isActionLoading = false);
                                Get.snackbar('Login Failed', e.toString());
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: isActionLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isOtpMode
                                  ? (isOtpSent ? 'Verify & Login' : 'Send Login OTP')
                                  : 'Login with Password',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textPlaceholder),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
