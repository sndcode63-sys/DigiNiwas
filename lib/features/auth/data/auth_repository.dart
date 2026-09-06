import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/app_logger.dart';

/// Friendly error thrown by [AuthRepository] so the UI can show
/// the exact message the backend sent (or a safe fallback).
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._apiService, this._storage);

  final ApiService _apiService;
  final SecureStorageService _storage;

  /// The app currently only collects phone/name/email on its auth screens
  /// (no role picker before OTP), so every call defaults to "Buyer" unless
  /// a screen explicitly passes a different role.
  static const String defaultRole = 'Buyer';

  /// POST /auths/register
  /// Creates the account. The backend requires a password even though the
  /// app is OTP-only end-to-end, so we generate one silently — the user
  /// never sees or needs it because every login afterwards goes through OTP.
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    String? email,
    String role = defaultRole,
    LocationResult? location,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'name': name,
          'phone': phone,
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          'password': _generatePassword(phone),
          'role': role,
          // Backend expects: { "location": { "longitude": ..., "latitude": ... } }
          if (location != null) 'location': location.toLocationPayload(),
        },
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Registration failed. Please try again.');
      AppLogger.i('Registration successful for $phone');
      return data;
    } on DioException catch (e, st) {
      AppLogger.e('Registration failed for $phone', e, st);
      throw AuthException(_extractMessage(e, fallback: 'Registration failed. Please try again.'));
    }
  }

  /// POST /auths/send-otp
  /// Used both to verify a phone right after registration and to kick off
  /// an OTP login for an existing user.
  Future<void> sendOtp({required String phone, String role = defaultRole}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.sendOtp,
        data: {'phone': phone, 'role': role},
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(
        data,
        fallback: 'This number is not registered as a $role. Please check the number or role.',
      );
      AppLogger.i('OTP sent to $phone');
    } on DioException catch (e, st) {
      AppLogger.e('Send OTP failed for $phone', e, st);
      throw AuthException(_extractMessage(e, fallback: 'Could not send OTP. Please try again.'));
    }
  }

  /// POST /auths/login-otp
  /// Verifies the OTP and logs the user in, saving the returned token and
  /// user profile so the session survives an app restart.
  Future<Map<String, dynamic>> loginWithOtp({
    required String phone,
    required String otp,
    String role = defaultRole,
    LocationResult? location,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.loginOtp,
        data: {
          'phone': phone,
          'otp': otp,
          'role': role,
          // Backend expects: { "location": { "longitude": ..., "latitude": ... } }
          if (location != null) 'location': location.toLocationPayload(),
        },
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Invalid or expired OTP. Please try again.');
      await _persistSession(data);
      AppLogger.i('OTP login successful for $phone');
      return data;
    } on DioException catch (e, st) {
      AppLogger.e('OTP login failed for $phone', e, st);
      throw AuthException(_extractMessage(e, fallback: 'Invalid or expired OTP. Please try again.'));
    }
  }

  /// POST /auths/login-password
  /// Kept for completeness (documented by the backend) even though no
  /// current screen collects a password from the user.
  Future<Map<String, dynamic>> loginWithPassword({
    required String phone,
    required String password,
    String role = defaultRole,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.loginPassword,
        data: {'phone': phone, 'password': password, 'role': role},
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Login failed. Please check your credentials.');
      await _persistSession(data);
      AppLogger.i('Password login successful for $phone');
      return data;
    } on DioException catch (e, st) {
      AppLogger.e('Password login failed for $phone', e, st);
      throw AuthException(_extractMessage(e, fallback: 'Login failed. Please check your credentials.'));
    }
  }

  /// Restores whatever we saved at login, if any — used by the splash
  /// screen to decide whether to skip straight to a dashboard.
  Future<Map<String, dynamic>?> getStoredSession() async {
    final hasToken = await _storage.hasToken();
    if (!hasToken) return null;
    final raw = await _storage.getUserData();
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.clearTokens();
  }

  Future<void> _persistSession(Map<String, dynamic> response) async {
    final token = response['token'] as String?;
    if (token != null && token.isNotEmpty) {
      await _storage.saveAccessToken(token);
    }
    final user = response['data'];
    if (user is Map) {
      await _storage.saveUserData(jsonEncode(user));
    }
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  /// The backend sometimes answers with HTTP 200 but `success: false`
  /// (e.g. phone not registered under the chosen role) — Dio doesn't treat
  /// that as an error, so we have to check the body ourselves and surface
  /// the message instead of silently pretending it worked.
  void _throwIfUnsuccessful(Map<String, dynamic> data, {required String fallback}) {
    if (data['success'] == false) {
      final message = data['message'];
      throw AuthException(message is String && message.isNotEmpty ? message : fallback);
    }
  }

  String _generatePassword(String phone) {
    final rand = Random.secure();
    final suffix = List.generate(8, (_) => rand.nextInt(10)).join();
    return 'Dn#$phone#$suffix';
  }

  String _extractMessage(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Server is taking longer than usual to respond (it may be waking up). Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server. Please check your internet connection.';
    }
    return fallback;
  }
}