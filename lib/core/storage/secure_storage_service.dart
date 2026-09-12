import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);


  Future<void> saveUserData(String userJson) =>
      _storage.write(key: _userDataKey, value: userJson);

  Future<String?> getUserData() => _storage.read(key: _userDataKey);

  static const _sellerMongoIdKey = 'seller_mongo_id';

  Future<void> saveSellerMongoId(String id) =>
      _storage.write(key: _sellerMongoIdKey, value: id);

  Future<String?> getSellerMongoId() => _storage.read(key: _sellerMongoIdKey);

  // -------------------------------------------------------------------------
  // Pending seller KYC registration (so the flow survives an app restart).
  // Per the API guide: "Persist data.applicationId. It is required in every
  // registration verification and resend request."
  // -------------------------------------------------------------------------
  static const _pendingApplicationIdKey = 'pending_seller_application_id';
  static const _pendingApplicationStepKey = 'pending_seller_application_step';
  static const _pendingApplicationEmailKey = 'pending_seller_application_email';
  static const _pendingApplicationPhoneKey = 'pending_seller_application_phone';

  /// [step] should be one of: 'VERIFY_EMAIL', 'VERIFY_PHONE'.
  Future<void> savePendingSellerApplication({
    required String applicationId,
    required String step,
    String? email,
    String? phone,
  }) async {
    await _storage.write(key: _pendingApplicationIdKey, value: applicationId);
    await _storage.write(key: _pendingApplicationStepKey, value: step);
    if (email != null) {
      await _storage.write(key: _pendingApplicationEmailKey, value: email);
    }
    if (phone != null) {
      await _storage.write(key: _pendingApplicationPhoneKey, value: phone);
    }
  }

  Future<Map<String, String?>> getPendingSellerApplication() async {
    return {
      'applicationId': await _storage.read(key: _pendingApplicationIdKey),
      'step': await _storage.read(key: _pendingApplicationStepKey),
      'email': await _storage.read(key: _pendingApplicationEmailKey),
      'phone': await _storage.read(key: _pendingApplicationPhoneKey),
    };
  }

  Future<void> clearPendingSellerApplication() async {
    await _storage.delete(key: _pendingApplicationIdKey);
    await _storage.delete(key: _pendingApplicationStepKey);
    await _storage.delete(key: _pendingApplicationEmailKey);
    await _storage.delete(key: _pendingApplicationPhoneKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
    await _storage.delete(key: _sellerMongoIdKey);
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
