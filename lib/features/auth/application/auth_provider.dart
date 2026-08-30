import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(apiServiceProvider),
    ref.read(secureStorageProvider),
  );
});

enum AuthStatus { idle, loading, otpSent, verified, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.phone,
    this.role = AuthRepository.defaultRole,
    this.userData,
  });

  final AuthStatus status;
  final String? errorMessage;
  final String? phone;
  final String role;
  final Map<String, dynamic>? userData;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  /// Registers the user, then immediately triggers an OTP so the app can
  /// move to the verification screen.
  Future<bool> register({
    required String name,
    required String phone,
    String? email,
    String role = AuthRepository.defaultRole,
  }) async {
    state = AuthState(status: AuthStatus.loading, phone: phone, role: role);
    try {
      await _repository.register(name: name, phone: phone, email: email, role: role);
      await _repository.sendOtp(phone: phone, role: role);
      state = AuthState(status: AuthStatus.otpSent, phone: phone, role: role);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        phone: phone,
        role: role,
        errorMessage: _messageOf(e),
      );
      return false;
    }
  }

  /// Sends a login OTP for an already-registered phone number.
  Future<bool> requestLoginOtp({
    required String phone,
    String role = AuthRepository.defaultRole,
  }) async {
    state = AuthState(status: AuthStatus.loading, phone: phone, role: role);
    try {
      await _repository.sendOtp(phone: phone, role: role);
      state = AuthState(status: AuthStatus.otpSent, phone: phone, role: role);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        phone: phone,
        role: role,
        errorMessage: _messageOf(e),
      );
      return false;
    }
  }

  /// Resends the OTP for whichever phone/role is already in progress.
  Future<bool> resendOtp() async {
    final phone = state.phone;
    if (phone == null) return false;
    try {
      await _repository.sendOtp(phone: phone, role: state.role);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        phone: phone,
        role: state.role,
        errorMessage: _messageOf(e),
      );
      return false;
    }
  }

  /// Verifies the OTP and logs the user in.
  Future<bool> verifyOtp(String otp) async {
    final phone = state.phone;
    if (phone == null) return false;
    state = AuthState(status: AuthStatus.loading, phone: phone, role: state.role);
    try {
      final response = await _repository.loginWithOtp(phone: phone, otp: otp, role: state.role);
      final data = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'] as Map)
          : null;
      state = AuthState(
        status: AuthStatus.verified,
        phone: phone,
        role: state.role,
        userData: data,
      );
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        phone: phone,
        role: state.role,
        errorMessage: _messageOf(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  String _messageOf(Object e) =>
      e is AuthException ? e.message : 'Something went wrong. Please try again.';
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
