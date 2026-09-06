import 'dart:async';

import 'package:get/get.dart';

import '../../../core/services/location_service.dart';
import '../../../core/storage/storage_service.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

/// GetX controller that replaces the old Riverpod `AuthController`.
///
/// Registered as a permanent singleton in `InitialBinding`, so any screen
/// reaches it with `Get.find<AuthController>()`:
///   - read state with `controller.state.value` (wrap in `Obx` to rebuild)
///   - call actions directly, e.g. `controller.verifyOtp(otp)`
class AuthController extends GetxController {
  AuthController(this._repository, this._locationService);

  final AuthRepository _repository;
  final LocationService _locationService;

  /// Reactive auth state — wrap reads in `Obx(() => ...)` to rebuild on
  /// change, same shape as the old `AuthState` from Riverpod.
  final Rx<AuthState> state = AuthState().obs;

  /// Last GPS fix captured on the login/registration screens (see
  /// `captureAndAttachLocation`). Any screen can watch this to build
  /// "properties near me"-style features without asking for permission
  /// again.
  final Rx<LocationResult?> lastKnownLocation = Rx<LocationResult?>(null);

  void _emit(AuthState newState) => state.value = newState;

  /// Registers the user, then immediately triggers an OTP so the app can
  /// move to the verification screen. Also opens the location permission
  /// prompt (best-effort — a denial never blocks registration) so the
  /// captured lat/lng can be sent along with the account.
  Future<bool> register({
    required String name,
    required String phone,
    String? email,
    String role = AuthState.defaultRole,
  }) async {
    _emit(state.value.copyWith(
      status: AuthStatus.loading,
      phone: phone,
      role: role,
      clearError: true,
    ));

    final location = await _captureLocation();

    try {
      await _repository.register(
        name: name,
        phone: phone,
        email: email,
        role: role,
        location: location,
      );
      await _repository.sendOtp(phone: phone, role: role);
      _emit(state.value.copyWith(status: AuthStatus.otpSent, phone: phone, role: role));
      return true;
    } catch (e) {
      _emit(state.value.copyWith(
        status: AuthStatus.error,
        phone: phone,
        role: role,
        errorMessage: _messageOf(e),
      ));
      return false;
    }
  }

  /// Sends a login OTP for an already-registered phone number. Also
  /// opens the location permission prompt so a fresh fix is ready by the
  /// time the OTP is verified.
  Future<bool> requestLoginOtp({
    required String phone,
    String role = AuthState.defaultRole,
  }) async {
    _emit(state.value.copyWith(
      status: AuthStatus.loading,
      phone: phone,
      role: role,
      clearError: true,
    ));

    await _captureLocation();

    try {
      await _repository.sendOtp(phone: phone, role: role);
      _emit(state.value.copyWith(status: AuthStatus.otpSent, phone: phone, role: role));
      return true;
    } catch (e) {
      _emit(state.value.copyWith(
        status: AuthStatus.error,
        phone: phone,
        role: role,
        errorMessage: _messageOf(e),
      ));
      return false;
    }
  }

  /// Resends the OTP for whichever phone/role is already in progress.
  Future<bool> resendOtp() async {
    final currentPhone = state.value.phone;
    if (currentPhone == null) return false;
    try {
      await _repository.sendOtp(phone: currentPhone, role: state.value.role);
      return true;
    } catch (e) {
      _emit(state.value.copyWith(errorMessage: _messageOf(e)));
      return false;
    }
  }

  /// Verifies the OTP and logs the user in. If we don't already have a
  /// location fix from `register`/`requestLoginOtp` (e.g. the user denied
  /// it earlier), this makes one last best-effort attempt before the
  /// actual login call goes out.
  Future<bool> verifyOtp(String otp) async {
    final currentPhone = state.value.phone;
    if (currentPhone == null) return false;
    _emit(state.value.copyWith(status: AuthStatus.loading, clearError: true));

    var location = state.value.location;
    location ??= await _captureLocation();

    try {
      final response = await _repository.loginWithOtp(
        phone: currentPhone,
        otp: otp,
        role: state.value.role,
        location: location,
      );
      final data = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'] as Map)
          : null;
      _emit(state.value.copyWith(status: AuthStatus.verified, userData: data));
      return true;
    } catch (e) {
      _emit(state.value.copyWith(status: AuthStatus.error, errorMessage: _messageOf(e)));
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _emit(const AuthState());
  }

  /// Public entry point the OTP screen calls to (re)try capturing location
  /// on demand — e.g. right after the user comes back from the location
  /// settings screen. Same best-effort semantics as [_captureLocation].
  Future<LocationResult?> captureLocation() => _captureLocation();

  /// Opens the system location-permission prompt and fetches a fix.
  /// Never throws — on failure it records a soft `locationError` on the
  /// state and returns null, so callers can keep going without location.
  Future<LocationResult?> _captureLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      _emit(state.value.copyWith(location: location, clearLocationError: true));
      lastKnownLocation.value = location;
      unawaited(
        Get.find<StorageService>().saveLastKnownCoordinates(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      );
      return location;
    } on LocationException catch (e) {
      _emit(state.value.copyWith(locationError: e.message));
      return null;
    } catch (_) {
      _emit(state.value.copyWith(locationError: 'Could not fetch your location.'));
      return null;
    }
  }

  String _messageOf(Object e) =>
      e is AuthException ? e.message : 'Something went wrong. Please try again.';
}
