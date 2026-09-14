import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../features/partner/models/partner_models.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';
import '../data/partner_repository.dart';

const Color _kNavy = Color(0xFF14213D);
const Color _kGreen = Color(0xFF0A5C4B);
const Color _kTeal = Color(0xFF0E9C87);
const Color _kMint = Color(0xFFE8F7F4);
const Color _kBg = Color(0xFFF5F7F9);
const Color _kBorder = Color(0xFFE3E6EA);
const Color _kGrey = Color(0xFF8A93A6);

/// Partner self-registration — UI aligned to DigiNiwas KYC designs.
/// API: POST /partner-applications/register
class PartnerApplicationScreen extends StatefulWidget {
  const PartnerApplicationScreen({super.key});

  @override
  State<PartnerApplicationScreen> createState() =>
      _PartnerApplicationScreenState();
}

class _PartnerApplicationScreenState extends State<PartnerApplicationScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _business = TextEditingController();
  final _officeAddress = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController(text: 'Haryana');
  final _localityInput = TextEditingController();
  final _rera = TextEditingController();
  final _pan = TextEditingController();
  final _aadhaar = TextEditingController();
  final _emailOtp = TextEditingController();
  final _phoneOtp = TextEditingController();
  final _manualApplicationId = TextEditingController();

  String _accountType = 'single';
  String _businessType = 'Individual';
  String _docTab = 'Aadhaar';
  bool _consent = true;
  bool _loading = false;
  String? _applicationId;
  String? _partnerCode;
  String? _registerWarning;
  bool _emailVerified = false;
  bool _phoneVerified = false;

  /// 0 contact, 1 identity, 2 selfie, 3 agency, 4 otp
  int _step = 0;

  final _picker = ImagePicker();
  String? _panFileLabel;
  String? _aadhaarFileLabel;
  String? _selfieLabel;
  final List<String> _localities = [];
  bool _hasPendingApplication = false;

  @override
  void initState() {
    super.initState();
    _loadPendingFlag();
  }

  Future<void> _loadPendingFlag() async {
    final pending =
        await StorageService.instance.getPendingPartnerApplication();
    final id = asString(pending?['applicationId']);
    if (!mounted) return;
    setState(() => _hasPendingApplication = id != null && id.isNotEmpty);
  }

  Future<void> _resumePendingOtp() async {
    final pending =
        await StorageService.instance.getPendingPartnerApplication();
    final id = asString(pending?['applicationId']);
    if (id == null || id.isEmpty) {
      Get.snackbar('None', 'No pending application on this device.');
      return;
    }
    setState(() {
      _applicationId = id;
      _partnerCode = asString(pending?['partnerId']);
      final email = asString(pending?['email']);
      final phone = asString(pending?['phone']);
      if (email != null && email.isNotEmpty) _email.text = email;
      if (phone != null && phone.isNotEmpty) _phone.text = phone;
      _registerWarning =
          'Resuming verification. Tap Resend if you did not get the OTP.';
      _step = 4;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _business.dispose();
    _officeAddress.dispose();
    _city.dispose();
    _state.dispose();
    _localityInput.dispose();
    _rera.dispose();
    _pan.dispose();
    _aadhaar.dispose();
    _emailOtp.dispose();
    _phoneOtp.dispose();
    _manualApplicationId.dispose();
    super.dispose();
  }

  String _maskAadhaar(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return raw.trim();
    return 'XXXX-XXXX-${digits.substring(digits.length - 4)}';
  }

  Future<void> _pickImage({
    required ImageSource source,
    required void Function(String name) onPicked,
  }) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    if (file == null) return;
    setState(() => onPicked(file.name));
  }

  Map<String, dynamic> _buildPayload() {
    final businessName = _business.text.trim().isEmpty
        ? _name.text.trim()
        : _business.text.trim();
    final address = _officeAddress.text.trim().isEmpty
        ? _city.text.trim()
        : _officeAddress.text.trim();
    final city = _city.text.trim().isEmpty ? 'Unknown' : _city.text.trim();
    final state = _state.text.trim().isEmpty ? 'India' : _state.text.trim();
    final pan = _pan.text.trim().toUpperCase();
    final aadhaar = _aadhaar.text.trim();

    return {
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'accountType': _accountType,
      'business': {
        'businessName': businessName,
        'businessType': _businessType,
        'gstin': '',
        'registrationNumber': '',
        'officeAddress': address,
      },
      'location': {
        'address': address,
        'city': city,
        'state': state,
        'country': 'India',
        'serviceLocalities':
            _localities.isEmpty ? <String>[city] : List<String>.from(_localities),
      },
      'rera': {
        'applicable': _rera.text.trim().isNotEmpty,
        'state': state,
        'registrationNumber': _rera.text.trim(),
        'certificateUrl': '',
        'expiryDate':
            _rera.text.trim().isEmpty ? '' : '2028-12-31',
      },
      'identityDocuments': [
        {
          'documentType': 'AADHAAR',
          'frontUrl': 'https://example.com/aadhaar-front.jpg',
          'backUrl': 'https://example.com/aadhaar-back.jpg',
          'numberMasked':
              aadhaar.isEmpty ? 'XXXX-XXXX-0000' : _maskAadhaar(aadhaar),
          'status': 'Pending',
          'remarks': _aadhaarFileLabel ?? '',
        },
        {
          'documentType': 'PAN',
          'frontUrl': 'https://example.com/pan-front.jpg',
          'backUrl': 'https://example.com/pan-back.jpg',
          'numberMasked': pan.isEmpty ? 'ABCDE1234F' : pan,
          'status': 'Pending',
          'remarks': _panFileLabel ?? (_selfieLabel ?? ''),
        },
      ],
      'privacyConsent': {
        'accepted': _consent,
        'privacyNoticeVersion': 'v1',
      },
    };
  }

  Future<void> _register() async {
    if (_loading) return;
    if (!_consent) {
      Get.snackbar('Required', 'Please accept privacy consent');
      return;
    }
    final name = _name.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim().replaceAll(RegExp(r'\D'), '');
    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      Get.snackbar('Required', 'Name, email and phone are required');
      setState(() => _step = 0);
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Invalid', 'Enter a valid email address');
      setState(() => _step = 0);
      return;
    }
    if (phone.length != 10) {
      Get.snackbar('Invalid', 'Enter a valid 10-digit phone number');
      setState(() => _step = 0);
      return;
    }
    _phone.text = phone;

    setState(() => _loading = true);
    try {
      final body =
          await Get.find<PartnerRepository>().registerPartnerApplication(
        _buildPayload(),
      );
      await _openVerifyFromRegisterResponse(
        body,
        email: email,
        phone: phone,
      );
    } catch (e) {
      await _handleRegisterError(e, email: email, phone: phone);
    } finally {
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  /// Uses mongoId / applicationId from register API and opens OTP screen
  /// immediately (do not wait on SMTP resend).
  Future<void> _openVerifyFromRegisterResponse(
    Map<String, dynamic> body, {
    required String email,
    required String phone,
  }) async {
    final data = asMap(body['data']);
    final applicationId = asString(data['mongoId']) ??
        asString(data['applicationId']) ??
        asString(data['_id']) ??
        asString(data['id']);
    final partnerId = asString(data['partnerId']);
    final delivery = asMap(data['emailDelivery']);
    final deliveryErr = asMap(delivery['error']);
    final emailFailed = data['emailOtpSent'] == false ||
        asString(delivery['status'])?.toUpperCase() == 'FAILED';
    var warning =
        asString(data['warning']) ?? asString(deliveryErr['message']);

    if (applicationId == null || applicationId.isEmpty) {
      Get.snackbar(
        'Submitted',
        asString(body['message']) ?? 'Application submitted.',
      );
      Get.offAllNamed(AppRoutes.partnerLogin);
      return;
    }

    await StorageService.instance.savePendingPartnerApplication({
      'applicationId': applicationId,
      'partnerId': partnerId,
      'email': email,
      'phone': phone,
    });

    if (!mounted) return;
    setState(() {
      _applicationId = applicationId;
      _partnerCode = partnerId;
      _emailVerified = false;
      _phoneVerified = false;
      _registerWarning = warning ??
          asString(body['message']) ??
          'Verify email OTP, then phone OTP.';
      _loading = false;
      _hasPendingApplication = true;
      _step = 4; // verify page
    });

    Get.snackbar(
      'Application saved',
      _registerWarning!,
      duration: const Duration(seconds: 4),
    );

    // Resend in background — never block opening the verify page.
    if (emailFailed) {
      // ignore: unawaited_futures
      Get.find<PartnerRepository>()
          .resendPartnerOtp(applicationId, channel: 'email')
          .then((_) {
        if (!mounted) return;
        setState(() {
          _registerWarning =
              'Email OTP resent — check inbox/spam, then tap Verify email.';
        });
      }).catchError((_) {
        if (!mounted) return;
        setState(() {
          _registerWarning =
              'Email OTP not delivered by server. Tap Resend email OTP.';
        });
      });
    }
  }

  Future<void> _goToVerifyPage({
    required String applicationId,
    String? partnerId,
    String? warning,
  }) async {
    await StorageService.instance.savePendingPartnerApplication({
      'applicationId': applicationId,
      'partnerId': partnerId,
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
    });
    if (!mounted) return;
    setState(() {
      _applicationId = applicationId;
      _partnerCode = partnerId;
      _emailVerified = false;
      _phoneVerified = false;
      _registerWarning = warning ??
          'Continue OTP verification. Tap Resend if needed.';
      _hasPendingApplication = true;
      _step = 4;
    });
  }

  Future<void> _handleRegisterError(
    Object e, {
    required String email,
    required String phone,
  }) async {
    final msg = e.toString();
    final isConflict = (e is PartnerApiException && e.statusCode == 409) ||
        msg.toLowerCase().contains('already registered');

    if (!isConflict) {
      Get.snackbar('Error', msg);
      return;
    }

    // Prefer applicationId from error payload if backend ever returns it.
    String? fromError;
    if (e is PartnerApiException) {
      fromError = asString(e.data?['applicationId']) ??
          asString(e.data?['mongoId']) ??
          asString(e.data?['id']);
    }

    final pending =
        await StorageService.instance.getPendingPartnerApplication();
    final pendingId = asString(pending?['applicationId']);
    final pendingEmail = asString(pending?['email'])?.toLowerCase();
    final pendingPhone = asString(pending?['phone']);
    final matchesPending = pendingId != null &&
        pendingId.isNotEmpty &&
        ((pendingEmail != null && pendingEmail == email.toLowerCase()) ||
            (pendingPhone != null && pendingPhone == phone));

    final resumeId = fromError ??
        (matchesPending ? pendingId : null) ??
        (pendingId != null && pendingId.isNotEmpty ? pendingId : null);

    if (resumeId != null && resumeId.isNotEmpty) {
      await _goToVerifyPage(
        applicationId: resumeId,
        partnerId: asString(pending?['partnerId']),
        warning:
            'Already registered — continuing OTP for application $resumeId.',
      );
      return;
    }

    // No stored id — still open verify UI and ask only for Application ID there.
    if (!mounted) return;
    setState(() {
      _applicationId = null;
      _registerWarning =
          'Already registered. Paste Application ID below, then verify OTP.';
      _step = 4;
    });
  }

  Future<void> _verifyEmail() async {
    final id = _applicationId;
    if (id == null) {
      Get.snackbar('Required', 'Missing application ID');
      return;
    }
    final otp = _emailOtp.text.trim();
    if (otp.length < 4) {
      Get.snackbar('Required', 'Enter the email OTP');
      return;
    }
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await Get.find<PartnerRepository>()
          .verifyPartnerEmail(id, otp: otp);
      if (!mounted) return;
      setState(() => _emailVerified = true);
      Get.snackbar(
        'Email verified',
        'Next: tap Resend phone OTP, then enter the SMS code.',
      );
      // Phone OTP unlocks after email verify — request it via resend API.
      try {
        final resent = await Get.find<PartnerRepository>()
            .resendPartnerOtp(id, channel: 'phone');
        if (resent['alreadyVerified'] == true) {
          await StorageService.instance.clearPendingPartnerApplication();
          if (!mounted) return;
          setState(() => _phoneVerified = true);
          Get.snackbar(
            'Done',
            asString(resent['message']) ??
                'Mobile is already verified. You can sign in after approval.',
          );
          Get.offAllNamed(AppRoutes.partnerLogin);
        } else {
          Get.snackbar('Phone OTP', 'Phone OTP sent — check SMS.');
        }
      } catch (_) {
        Get.snackbar(
          'Phone OTP',
          'Could not send phone OTP automatically. Tap Resend phone OTP.',
        );
      }
    } catch (e) {
      Get.snackbar('Email OTP failed', e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyPhone() async {
    final id = _applicationId;
    if (id == null) return;
    if (!_emailVerified) {
      Get.snackbar('Order', 'Verify email OTP first');
      return;
    }
    final otp = _phoneOtp.text.trim();
    if (otp.length < 4) {
      Get.snackbar('Required', 'Enter the phone OTP');
      return;
    }
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await Get.find<PartnerRepository>()
          .verifyPartnerPhone(id, otp: otp);
      await StorageService.instance.clearPendingPartnerApplication();
      if (!mounted) return;
      setState(() => _phoneVerified = true);
      Get.snackbar(
        'Verified',
        'Email and phone verified. Sign in after admin approval.',
      );
      Get.offAllNamed(AppRoutes.partnerLogin);
    } catch (e) {
      Get.snackbar('Phone OTP failed', e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend(String channel) async {
    final id = _applicationId;
    if (id == null) {
      Get.snackbar('Required', 'Missing application ID');
      return;
    }
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final result = await Get.find<PartnerRepository>()
          .resendPartnerOtp(id, channel: channel);
      if (result['alreadyVerified'] == true) {
        if (channel == 'email') {
          setState(() => _emailVerified = true);
          Get.snackbar(
            'Email already verified',
            asString(result['message']) ?? 'Continue with phone OTP.',
          );
          try {
            final phoneResult = await Get.find<PartnerRepository>()
                .resendPartnerOtp(id, channel: 'phone');
            if (phoneResult['alreadyVerified'] == true) {
              await StorageService.instance.clearPendingPartnerApplication();
              if (!mounted) return;
              setState(() {
                _emailVerified = true;
                _phoneVerified = true;
              });
              Get.snackbar(
                'Done',
                asString(phoneResult['message']) ??
                    'Mobile is already verified.',
              );
              Get.offAllNamed(AppRoutes.partnerLogin);
            } else {
              Get.snackbar('Phone OTP', 'Phone OTP sent — check SMS.');
            }
          } catch (e) {
            Get.snackbar('Phone OTP', e.toString());
          }
        } else {
          await StorageService.instance.clearPendingPartnerApplication();
          if (!mounted) return;
          setState(() {
            _emailVerified = true;
            _phoneVerified = true;
          });
          Get.snackbar(
            'Mobile already verified',
            asString(result['message']) ?? 'Verification complete.',
          );
          Get.offAllNamed(AppRoutes.partnerLogin);
        }
        return;
      }
      Get.snackbar(
        'Sent',
        channel == 'email'
            ? 'Email OTP resent — check inbox and spam.'
            : 'Phone OTP resent — check SMS.',
      );
    } catch (e) {
      Get.snackbar(
        'Resend failed',
        e.toString(),
        duration: const Duration(seconds: 5),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addLocality() {
    final v = _localityInput.text.trim();
    if (v.isEmpty) return;
    if (!_localities.contains(v)) {
      setState(() {
        _localities.add(v);
        _localityInput.clear();
      });
    }
  }

  void _goNext() {
    if (_step == 0) {
      final name = _name.text.trim();
      final email = _email.text.trim();
      final phone = _phone.text.trim().replaceAll(RegExp(r'\D'), '');
      if (name.isEmpty || email.isEmpty || phone.isEmpty) {
        Get.snackbar('Required', 'Name, email and phone are required');
        return;
      }
      if (!GetUtils.isEmail(email)) {
        Get.snackbar('Invalid', 'Enter a valid email address');
        return;
      }
      if (phone.length != 10) {
        Get.snackbar('Invalid', 'Enter a valid 10-digit phone number');
        return;
      }
      _phone.text = phone;
      setState(() => _step = 1);
      return;
    }
    if (_step < 3) {
      setState(() => _step += 1);
      return;
    }
    _register();
  }

  void _goBack() {
    if (_step == 0 || _step == 4) {
      Get.back();
      return;
    }
    setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  8.h,
                  16.w,
                  (_step >= 1 && _step <= 3) ? 100.h : 24.h,
                ),
                child: switch (_step) {
                  0 => _buildContact(),
                  1 => _buildIdentity(),
                  2 => _buildSelfie(),
                  3 => _buildAgency(),
                  _ => _buildOtp(),
                },
              ),
            ),
            if (_step >= 1 && _step <= 3) _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    final titles = [
      'Partner Application',
      'Agent KYC Verification',
      'Agent KYC Verification',
      'Agent KYC Verification',
      'Verify OTP',
    ];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back, color: _kNavy),
          ),
          Expanded(
            child: Text(
              titles[_step.clamp(0, 4)],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kycHeader({required int activeIndex}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agent KYC Verification',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: _kNavy,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Complete your profile to unlock partner benefits.',
          style: TextStyle(fontSize: 12.sp, color: _kGrey),
        ),
        SizedBox(height: 16.h),
        _stepper(activeIndex),
        SizedBox(height: 14.h),
        _badgeBanner(),
      ],
    );
  }

  /// activeIndex: 0 Identity, 1 Selfie, 2 Agency
  Widget _stepper(int activeIndex) {
    const labels = ['Identity', 'Selfie', 'Agency'];
    return Row(
      children: List.generate(3, (i) {
        final done = i < activeIndex;
        final current = i == activeIndex;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: done || current
                            ? _kTeal.withValues(alpha: 0.5)
                            : _kBorder,
                      ),
                    ),
                  Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? _kGreen
                          : current
                              ? Colors.white
                              : Colors.white,
                      border: Border.all(
                        color: done || current ? _kGreen : _kBorder,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: done
                          ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: current ? _kGreen : _kGrey,
                              ),
                            ),
                    ),
                  ),
                  if (i < 2)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: done ? _kTeal.withValues(alpha: 0.5) : _kBorder,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                  color: current ? _kNavy : _kGrey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _badgeBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _kMint,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _kTeal.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_outlined,
                color: _kTeal, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified DigiNiwas Partner Badge',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Completing your KYC grants you a verified badge, increasing lead trust and priority listing visibility.',
                  style: TextStyle(fontSize: 11.sp, color: _kGrey, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String title, {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: _kGreen),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _numberedTitle(int n, String title) {
    return Row(
      children: [
        Container(
          width: 26.w,
          height: 26.w,
          decoration: const BoxDecoration(
            color: _kGreen,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$n',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: _kNavy,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Steps
  // ---------------------------------------------------------------------------

  Widget _buildContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apply as DigiNiwas Partner',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: _kNavy,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Start with your contact details, then complete KYC.',
          style: TextStyle(fontSize: 12.sp, color: _kGrey),
        ),
        SizedBox(height: 16.h),
        _card(
          child: Column(
            children: [
              _labeledField(_name, 'Full name', 'Your legal name'),
              _labeledField(_email, 'Email', 'name@example.com',
                  keyboard: TextInputType.emailAddress),
              _labeledField(_phone, 'Phone', '10-digit mobile',
                  keyboard: TextInputType.phone),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Account type',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: _kNavy)),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _segChip(
                      'Individual',
                      _accountType == 'single',
                      () => setState(() {
                        _accountType = 'single';
                        _businessType = 'Individual';
                      }),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _segChip(
                      'Agency',
                      _accountType == 'agency',
                      () => setState(() {
                        _accountType = 'agency';
                        _businessType = 'Company';
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        _solidButton('Continue to KYC', _goNext),
        Center(
          child: TextButton(
            onPressed: _showResumeByApplicationId,
            child: const Text(
              'Already applied? Enter Application ID',
              style: TextStyle(color: _kTeal, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (_hasPendingApplication)
          Center(
            child: TextButton(
              onPressed: _resumePendingOtp,
              child: const Text(
                'Continue pending OTP verification',
                style: TextStyle(color: _kTeal, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        Center(
          child: TextButton(
            onPressed: () => Get.offNamed(AppRoutes.partnerLogin),
            child: const Text(
              'Already approved? Sign in',
              style: TextStyle(color: _kGreen, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showResumeByApplicationId() async {
    final idCtrl = TextEditingController();
    final id = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Continue verification'),
        content: TextField(
          controller: idCtrl,
          decoration: const InputDecoration(
            labelText: 'Application ID (mongoId)',
            hintText: 'Paste from register API response',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: idCtrl.text.trim()),
            child: const Text('Open OTP'),
          ),
        ],
      ),
    );
    if (id == null || id.isEmpty || !mounted) return;
    await StorageService.instance.savePendingPartnerApplication({
      'applicationId': id,
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
    });
    setState(() {
      _applicationId = id;
      _hasPendingApplication = true;
      _registerWarning =
          'Tap Resend email OTP (server email delivery often fails).';
      _step = 4;
    });
  }

  Widget _buildIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kycHeader(activeIndex: 0),
        SizedBox(height: 14.h),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(Icons.badge_outlined, 'Identity Proof'),
              SizedBox(height: 14.h),
              _labeledField(_pan, 'PAN Number', 'ABCDE1234F'),
              if (_panFileLabel != null)
                _fileChip(_panFileLabel!, () {
                  setState(() => _panFileLabel = null);
                })
              else
                _dashedUpload(
                  title: 'Upload PAN Card',
                  subtitle: 'JPEG, PNG or PDF (Max 5MB)',
                  onTap: () => _pickImage(
                    source: ImageSource.gallery,
                    onPicked: (n) => _panFileLabel = n,
                  ),
                ),
              SizedBox(height: 14.h),
              _labeledField(_aadhaar, 'Aadhaar Number', 'Enter 12 digit number',
                  keyboard: TextInputType.number),
              if (_aadhaarFileLabel != null)
                _fileChip(_aadhaarFileLabel!, () {
                  setState(() => _aadhaarFileLabel = null);
                })
              else
                _dashedUpload(
                  title: 'Upload Aadhaar Card',
                  subtitle: 'JPEG, PNG or PDF (Max 5MB)',
                  onTap: () => _pickImage(
                    source: ImageSource.gallery,
                    onPicked: (n) => _aadhaarFileLabel = n,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelfie() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kycHeader(activeIndex: 1),
        SizedBox(height: 14.h),
        _card(
          child: Column(
            children: [
              _sectionTitle(
                Icons.sentiment_satisfied_alt_outlined,
                'Live Selfie',
                trailing: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _kMint,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'ACTIVE STEP',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: _kGreen,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kMint.withValues(alpha: 0.35),
                ),
                child: CustomPaint(
                  painter: _DashedCirclePainter(
                    color: _kTeal.withValues(alpha: 0.55),
                  ),
                  child: Center(
                    child: _selfieLabel == null
                        ? Icon(Icons.camera_alt_outlined,
                            size: 36.sp, color: _kTeal)
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  color: _kTeal, size: 36.sp),
                              SizedBox(height: 4.h),
                              Text('Captured',
                                  style: TextStyle(
                                      fontSize: 11.sp, color: _kGreen)),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Take a live photo',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Ensure you are in a well-lit area and your face is clearly visible without accessories.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: _kGrey, height: 1.35),
              ),
              SizedBox(height: 16.h),
              _solidButton(
                'Open Camera',
                () => _pickImage(
                  source: ImageSource.camera,
                  onPicked: (n) => _selfieLabel = n,
                ),
                icon: Icons.camera_alt_outlined,
              ),
              SizedBox(height: 8.h),
              TextButton.icon(
                onPressed: () => _pickImage(
                  source: ImageSource.gallery,
                  onPicked: (n) => _selfieLabel = n,
                ),
                icon: const Icon(Icons.photo_outlined, size: 16),
                label: const Text('Choose from Gallery'),
                style: TextButton.styleFrom(foregroundColor: _kGreen),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgency() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kycHeader(activeIndex: 2),
        SizedBox(height: 14.h),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _numberedTitle(1, 'Government Identity Proof'),
              SizedBox(height: 10.h),
              Row(
                children: [
                  for (final t in ['Aadhaar', 'PAN', 'RERA']) ...[
                    _pillTab(t, _docTab == t, () => setState(() => _docTab = t)),
                    SizedBox(width: 8.w),
                  ],
                ],
              ),
              SizedBox(height: 10.h),
              if (_docTab == 'Aadhaar')
                _labeledField(_aadhaar, 'Aadhaar Number', 'XXXX-XXXX-XXXX',
                    keyboard: TextInputType.number)
              else if (_docTab == 'PAN')
                _labeledField(_pan, 'PAN Number', 'ABCDE1234F')
              else
                _labeledField(_rera, 'RERA Number', 'Optional'),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _card(
          child: Column(
            children: [
              _numberedTitle(2, 'Partner Profile Photo'),
              SizedBox(height: 14.h),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 96.w,
                    height: 96.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kMint,
                      border: Border.all(color: _kTeal, width: 2),
                    ),
                    child: Icon(
                      _selfieLabel == null
                          ? Icons.person_outline
                          : Icons.check,
                      size: 40.sp,
                      color: _kTeal,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _pickImage(
                      source: ImageSource.camera,
                      onPicked: (n) => _selfieLabel = n,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: _kGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt,
                          size: 14.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Ensure your face is clearly visible in good lighting.',
                style: TextStyle(fontSize: 11.sp, color: _kGrey),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => _pickImage(
                      source: ImageSource.camera,
                      onPicked: (n) => _selfieLabel = n,
                    ),
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: const Text('Take Photo'),
                    style: TextButton.styleFrom(foregroundColor: _kGreen),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(
                      source: ImageSource.gallery,
                      onPicked: (n) => _selfieLabel = n,
                    ),
                    icon: const Icon(Icons.image_outlined, size: 16),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kNavy,
                      side: const BorderSide(color: _kBorder),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _numberedTitle(3, 'Business & Agency Details'),
              SizedBox(height: 12.h),
              _labeledField(
                _business,
                'Agency Name',
                'e.g. Sharma Real Estate',
                prefix: Icons.apartment_outlined,
              ),
              Text('Type',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _kNavy)),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1F8),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _segChip(
                        'Individual',
                        _businessType == 'Individual',
                        () => setState(() {
                          _businessType = 'Individual';
                          _accountType = 'single';
                        }),
                        filled: true,
                      ),
                    ),
                    Expanded(
                      child: _segChip(
                        'Company',
                        _businessType == 'Company',
                        () => setState(() {
                          _businessType = 'Company';
                          _accountType = 'agency';
                        }),
                        filled: true,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              _labeledField(
                _officeAddress,
                'Office Address',
                'Enter complete office address',
                prefix: Icons.location_on_outlined,
              ),
              _labeledField(_city, 'City', 'City'),
              _labeledField(_state, 'State', 'State'),
              Text('Operating Localities',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _kNavy)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final loc in _localities)
                    Chip(
                      label: Text(loc, style: TextStyle(fontSize: 11.sp)),
                      deleteIcon: Icon(Icons.close, size: 14.sp),
                      onDeleted: () =>
                          setState(() => _localities.remove(loc)),
                      backgroundColor: _kMint,
                      side: BorderSide.none,
                    ),
                  ActionChip(
                    avatar: Icon(Icons.add, size: 16.sp, color: _kTeal),
                    label: const Text('Add', style: TextStyle(color: _kTeal)),
                    onPressed: () => _showAddLocalitySheet(),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: _kTeal.withValues(alpha: 0.4)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Text('RERA Number',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _kNavy)),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'FAST-TRACK',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              _plainField(_rera, 'Optional'),
              SizedBox(height: 8.h),
              CheckboxListTile(
                value: _consent,
                onChanged: (v) => setState(() => _consent = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: _kGreen,
                title: RichText(
                  text: TextSpan(
                    text: 'I agree to DigiNiwas ',
                    style: TextStyle(fontSize: 12.sp, color: _kNavy),
                    children: [
                      TextSpan(
                        text: 'privacy policy (v1)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _kGreen,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.toNamed(AppRoutes.privacyPolicy),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 16.sp, color: const Color(0xFF1565C0)),
              SizedBox(width: 8.w),
              Text(
                'Your data is securely 256-bit encrypted',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF1565C0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify your application',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: _kNavy,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Order: 1) Email OTP  →  2) Phone OTP',
          style: TextStyle(fontSize: 12.sp, color: _kGrey),
        ),
        if (_partnerCode != null) ...[
          SizedBox(height: 8.h),
          Text('Partner ID: $_partnerCode',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: _kGreen)),
        ],
        if (_applicationId != null) ...[
          SizedBox(height: 4.h),
          Text(
            'Application ID: $_applicationId',
            style: TextStyle(fontSize: 11.sp, color: _kGrey),
          ),
        ] else ...[
          SizedBox(height: 10.h),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paste Application ID from register response',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _manualApplicationId,
                  decoration: InputDecoration(
                    hintText: 'mongoId / applicationId',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () async {
                    final id = _manualApplicationId.text.trim();
                    if (id.isEmpty) {
                      Get.snackbar('Required', 'Enter Application ID');
                      return;
                    }
                    await _goToVerifyPage(applicationId: id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Use this Application ID'),
                ),
              ],
            ),
          ),
        ],
        if (_email.text.trim().isNotEmpty || _phone.text.trim().isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            [
              if (_email.text.trim().isNotEmpty) _email.text.trim(),
              if (_phone.text.trim().isNotEmpty) _phone.text.trim(),
            ].join('  ·  '),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _kNavy),
          ),
        ],
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1) Resend + enter Email OTP  →  2) Resend + enter Phone OTP.\n'
                'Server email SMTP often fails (500). Phone OTP unlocks only after email is verified.',
                style: TextStyle(fontSize: 11.sp, color: Colors.brown.shade800),
              ),
              if (_registerWarning != null && _registerWarning!.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  _registerWarning!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown.shade900,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 14.h),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _emailVerified ? Icons.check_circle : Icons.mark_email_unread_outlined,
                    color: _emailVerified ? _kGreen : _kGrey,
                    size: 18,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    _emailVerified ? '1. Email verified' : '1. Verify email OTP',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      color: _kNavy,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _labeledField(_emailOtp, 'Email OTP', '6-digit code',
                  keyboard: TextInputType.number),
              Row(
                children: [
                  TextButton(
                    onPressed: _loading || _emailVerified
                        ? null
                        : () => _resend('email'),
                    child: const Text('Resend email OTP'),
                  ),
                  const Spacer(),
                  if (!_emailVerified)
                    ElevatedButton(
                      onPressed: _loading ? null : _verifyEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Verify email'),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              Opacity(
                opacity: _emailVerified ? 1 : 0.45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _phoneVerified
                              ? Icons.check_circle
                              : Icons.sms_outlined,
                          color: _phoneVerified ? _kGreen : _kGrey,
                          size: 18,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _phoneVerified
                              ? '2. Phone verified'
                              : '2. Verify phone OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                            color: _kNavy,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _labeledField(_phoneOtp, 'Phone OTP', '6-digit code',
                        keyboard: TextInputType.number),
                    Row(
                      children: [
                        TextButton(
                          onPressed: (!_emailVerified || _loading)
                              ? null
                              : () => _resend('phone'),
                          child: const Text('Resend phone OTP'),
                        ),
                        const Spacer(),
                        if (_emailVerified && !_phoneVerified)
                          ElevatedButton(
                            onPressed: _loading ? null : _verifyPhone,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kGreen,
                              foregroundColor: Colors.white,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Verify phone'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () => Get.offAllNamed(AppRoutes.partnerLogin),
            child: const Text('Back to Partner Login'),
          ),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    final isAgency = _step == 3;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: _kBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!isAgency)
              TextButton(
                onPressed: _loading
                    ? null
                    : () => Get.snackbar(
                          'Draft',
                          'Continue later from Partner Login → Apply.',
                        ),
                child: Text(
                  'Save as Draft',
                  style: TextStyle(
                    color: _kGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              )
            else
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading
                      ? null
                      : () => Get.snackbar(
                            'Draft',
                            'Continue later from Partner Login → Apply.',
                          ),
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Save Draft'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kNavy,
                    side: const BorderSide(color: _kBorder),
                    minimumSize: Size.fromHeight(46.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            if (isAgency) SizedBox(width: 10.w),
            if (!isAgency) const Spacer(),
            Expanded(
              flex: isAgency ? 2 : 0,
              child: isAgency
                  ? _solidButton(
                      'Submit Verification',
                      _loading ? () {} : _register,
                      icon: Icons.check,
                      loading: _loading,
                    )
                  : ElevatedButton(
                      onPressed: _loading ? null : _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _step == 1
                                ? 'Continue to Selfie'
                                : 'Continue to Agency',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLocalitySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            MediaQuery.of(ctx).viewInsets.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add locality',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 12.h),
              TextField(
                controller: _localityInput,
                decoration: InputDecoration(
                  hintText: 'e.g. Model Town, Ambala',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onSubmitted: (_) {
                  _addLocality();
                  Navigator.pop(ctx);
                },
              ),
              SizedBox(height: 12.h),
              _solidButton('Add', () {
                _addLocality();
                Navigator.pop(ctx);
              }),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Shared widgets
  // ---------------------------------------------------------------------------

  Widget _labeledField(
    TextEditingController c,
    String label,
    String hint, {
    TextInputType? keyboard,
    IconData? prefix,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _kNavy)),
          SizedBox(height: 6.h),
          _plainField(c, hint, keyboard: keyboard, prefix: prefix),
        ],
      ),
    );
  }

  Widget _plainField(
    TextEditingController c,
    String hint, {
    TextInputType? keyboard,
    IconData? prefix,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
        prefixIcon: prefix == null ? null : Icon(prefix, color: _kGrey, size: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _kTeal),
        ),
      ),
    );
  }

  Widget _dashedUpload({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: CustomPaint(
        painter: _DashedRectPainter(color: _kBorder),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined, color: _kTeal, size: 28.sp),
              SizedBox(height: 6.h),
              Text(title,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _kNavy)),
              SizedBox(height: 2.h),
              Text(subtitle,
                  style: TextStyle(fontSize: 11.sp, color: _kGrey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fileChip(String name, VoidCallback onRemove) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FC),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: const Color(0xFF1565C0), size: 22.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: _kNavy)),
                Text('Uploaded',
                    style: TextStyle(fontSize: 10.sp, color: _kGrey)),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
          ),
        ],
      ),
    );
  }

  Widget _pillTab(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? _kMint : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: selected ? _kTeal : _kBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? _kGreen : _kGrey,
          ),
        ),
      ),
    );
  }

  Widget _segChip(
    String label,
    bool selected,
    VoidCallback onTap, {
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: selected
              ? (filled ? Colors.white : _kGreen)
              : (filled ? Colors.transparent : Colors.white),
          borderRadius: BorderRadius.circular(8.r),
          border: filled
              ? null
              : Border.all(color: selected ? _kGreen : _kBorder),
          boxShadow: selected && filled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: selected
                ? (filled ? _kNavy : Colors.white)
                : _kGrey,
          ),
        ),
      ),
    );
  }

  Widget _solidButton(
    String text,
    VoidCallback onTap, {
    IconData? icon,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _kGreen.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 4.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(12),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = dist + dash;
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const dash = 0.12;
    const gap = 0.08;
    var start = 0.0;
    while (start < 6.2832) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dash,
        false,
        paint,
      );
      start += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
