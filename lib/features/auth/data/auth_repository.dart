import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/app_logger.dart';

class AuthRepository {
  AuthRepository(this._apiService, this._storage);

  final ApiService _apiService;
  final SecureStorageService _storage;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['access_token'] as String?;
      final refreshToken = response.data['refresh_token'] as String?;

      if (accessToken != null) {
        await _storage.saveAccessToken(accessToken);
      }
      if (refreshToken != null) {
        await _storage.saveRefreshToken(refreshToken);
      }
      AppLogger.i('Login successful for $email');
      return accessToken != null;
    } on DioException catch (e, st) {
      AppLogger.e('Login failed for $email', e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearTokens();
  }
}
