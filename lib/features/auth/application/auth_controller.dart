import 'package:get/get.dart';

import '../data/auth_repository.dart';

enum AuthStatus { idle, loading, otpSent, verified, error }

/// GetX controller that replaces the old Riverpod `AuthNotifier` /
/// `StateNotifier<AuthState>`. Register it once (see `InitialBinding`) and
/// grab it anywhere with `Get.find<AuthController>()`.
class AuthController extends GetxController {
  AuthController(this._repository);

  final AuthRepository _repository;

  final Rx<AuthStatus> status = AuthStatus.idle.obs;
  final RxnString errorMessage = RxnString();
  final RxnString phone = RxnString();
  final RxString role = AuthRepository.defaultRole.obs;
  final Rx<Map<String, dynamic>?> userData = Rx<Map<String, dynamic>?>(null);

  void _reset({
    required AuthStatus newStatus,
    String? phoneValue,
    String? roleValue,
    String? error,
    Map<String, dynamic>? user,
  }) {
    status.value = newStatus;
    if (phoneValue != null) phone.value = phoneValue;
    if (roleValue != null) role.value = roleValue;
    errorMessage.value = error;
    userData.value = user;
  }

  /// Registers the user, then immediately triggers an OTP so the app can
  /// move to the verification screen.
  Future<bool> register({
    required String name,
    required String phone,
    String? email,
    String role = AuthRepository.defaultRole,
  }) async {
    _reset(newStatus: AuthStatus.loading, phoneValue: phone, roleValue: role);
    try {
      await _repository.register(name: name, phone: phone, email: email, role: role);
      await _repository.sendOtp(phone: phone, role: role);
      _reset(newStatus: AuthStatus.otpSent, phoneValue: phone, roleValue: role);
      return true;
    } catch (e) {
      _reset(
        newStatus: AuthStatus.error,
        phoneValue: phone,
        roleValue: role,
        error: _messageOf(e),
      );
      return false;
    }
  }

  /// Sends a login OTP for an already-registered phone number.
  Future<bool> requestLoginOtp({
    required String phone,
    String role = AuthRepository.defaultRole,
  }) async {
    _reset(newStatus: AuthStatus.loading, phoneValue: phone, roleValue: role);
    try {
      await _repository.sendOtp(phone: phone, role: role);
      _reset(newStatus: AuthStatus.otpSent, phoneValue: phone, roleValue: role);
      return true;
    } catch (e) {
      _reset(
        newStatus: AuthStatus.error,
        phoneValue: phone,
        roleValue: role,
        error: _messageOf(e),
      );
      return false;
    }
  }

  /// Resends the OTP for whichever phone/role is already in progress.
  Future<bool> resendOtp() async {
    final currentPhone = phone.value;
    if (currentPhone == null) return false;
    try {
      await _repository.sendOtp(phone: currentPhone, role: role.value);
      return true;
    } catch (e) {
      errorMessage.value = _messageOf(e);
      return false;
    }
  }

  /// Verifies the OTP and logs the user in.
  Future<bool> verifyOtp(String otp) async {
    final currentPhone = phone.value;
    if (currentPhone == null) return false;
    _reset(newStatus: AuthStatus.loading, phoneValue: currentPhone, roleValue: role.value);
    try {
      final response =
          await _repository.loginWithOtp(phone: currentPhone, otp: otp, role: role.value);
      final data = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'] as Map)
          : null;
      _reset(
        newStatus: AuthStatus.verified,
        phoneValue: currentPhone,
        roleValue: role.value,
        user: data,
      );
      return true;
    } catch (e) {
      _reset(
        newStatus: AuthStatus.error,
        phoneValue: currentPhone,
        roleValue: role.value,
        error: _messageOf(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _reset(newStatus: AuthStatus.idle);
    phone.value = null;
    role.value = AuthRepository.defaultRole;
  }

  String _messageOf(Object e) =>
      e is AuthException ? e.message : 'Something went wrong. Please try again.';
}
