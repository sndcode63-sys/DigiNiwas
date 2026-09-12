import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/seller_model.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/app_logger.dart';

class SellerException implements Exception {
  final String message;
  // Raw error payload from the backend (e.g. { "applicationStatus": "..." }),
  // when the failing response included one. Lets the UI react to specific
  // error shapes (like "application not approved yet") instead of just
  // showing text.
  final Map<String, dynamic>? data;
  SellerException(this.message, {this.data});

  @override
  String toString() => message;
}

class SellerRepository {
  final ApiService _apiService;

  SellerRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  // ===========================================================================
  // 1. SELLER AUTHENTICATION & LOGIN
  // ===========================================================================

  /// Send login OTP to seller email: POST /api/sellers/auth/send-login-otp
  Future<Map<String, dynamic>> sendLoginOtp({required String email}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.sendSellerLoginOtp,
        data: {'email': email},
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Could not send OTP to $email');
      return data;
    } on DioException catch (e, st) {
      AppLogger.e('Send Seller Login OTP failed', e, st);
      throw SellerException(_extractMessage(e, fallback: 'Failed to send OTP.'));
    }
  }

  /// Seller Login with OTP: POST /api/sellers/auth/login-with-otp
  Future<Map<String, dynamic>> loginWithOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.sellerLoginWithOtp,
        data: {'email': email, 'otp': otp},
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Invalid OTP or login failed.');
      final token = data['token'] ?? (data['data'] is Map ? data['data']['token'] : null);
      if (token != null && token is String && token.isNotEmpty) {
        await SecureStorageService.instance.saveAccessToken(token);
      }
      final sellerData = data['data'];
      if (sellerData is Map) {
        final mongoId = sellerData['_id'] ?? sellerData['id'];
        if (mongoId != null && mongoId is String && mongoId.isNotEmpty) {
          await SecureStorageService.instance.saveSellerMongoId(mongoId);
        }
      }
      return data;
    } on DioException catch (e, st) {
      AppLogger.e('Seller Login with OTP failed', e, st);
      throw SellerException(
        _extractMessage(e, fallback: 'Login failed. Please check OTP.'),
        data: _extractErrorData(e),
      );
    }
  }

  /// Seller Login with Password: POST /api/sellers/auth/login
  Future<Map<String, dynamic>> loginWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.sellerLogin,
        data: {'email': email, 'password': password},
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Login failed. Please check your credentials.');
      final token = data['token'] ?? (data['data'] is Map ? data['data']['token'] : null);
      if (token != null && token is String && token.isNotEmpty) {
        await SecureStorageService.instance.saveAccessToken(token);
      }
      final sellerData = data['data'];
      if (sellerData is Map) {
        final mongoId = sellerData['_id'] ?? sellerData['id'];
        if (mongoId != null && mongoId is String && mongoId.isNotEmpty) {
          await SecureStorageService.instance.saveSellerMongoId(mongoId);
        }
      }
      return data;
    } on DioException catch (e, st) {
      AppLogger.e('Seller Password Login failed', e, st);
      throw SellerException(
        _extractMessage(e, fallback: 'Invalid email or password.'),
        data: _extractErrorData(e),
      );
    }
  }

  /// Change Seller Password: PATCH /api/sellers/auth/change-password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      dynamic response;
      try {
        response = await _apiService.patch(
          ApiConstants.changeSellerPassword,
          data: {
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          },
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404 || dioErr.response?.statusCode == 405) {
          response = await _apiService.put(
            ApiConstants.changeSellerPassword,
            data: {
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            },
          );
        } else {
          rethrow;
        }
      }
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Could not change password.');
    } on DioException catch (e, st) {
      AppLogger.e('Change Seller Password failed', e, st);
      throw SellerException(_extractMessage(e, fallback: 'Password update failed.'));
    }
  }

  // ===========================================================================
  // 2. SELLER APPLICATION REGISTRATION (no KYC/ID documents per API guide)
  // ===========================================================================

  /// Create Seller Application: POST /api/v1/sellers/applications/register
  /// Body matches the API guide exactly — plain registration, no KYC/ID
  /// documents are collected or sent.
  Future<SellerApplicationModel> registerSellerApplication({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String pinCode,
    required String country,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final jsonPayload = <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'state': state,
        'pinCode': pinCode,
        'country': country,
        'latitude': latitude ?? 22.7196,
        'longitude': longitude ?? 75.8577,
      };

      final response = await _apiService.post(
        ApiConstants.registerSellerApplication,
        data: jsonPayload,
      );

      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Seller registration failed.');
      
      final resData = data['data'] is Map ? data['data'] : data;
      return SellerApplicationModel.fromJson(resData);
    } on DioException catch (e, st) {
      AppLogger.e('Register Seller Application failed', e, st);
      throw SellerException(_extractMessage(e, fallback: 'Seller application registration failed.'));
    }
  }

  /// Verify Seller Email OTP: POST /api/sellers/applications/verify-email
  Future<void> verifySellerEmailOtp({
    required String applicationId,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.verifySellerEmailOtp,
        data: {'applicationId': applicationId, 'otp': otp},
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Email OTP verification failed.');
    } on DioException catch (e, st) {
      AppLogger.e('Verify Seller Email OTP failed', e, st);
      throw SellerException(_extractMessage(e, fallback: 'Invalid Email OTP.'));
    }
  }

  /// Verify Seller Phone OTP: POST /api/sellers/applications/verify-phone
  Future<Map<String, dynamic>> verifySellerPhoneOtp({
    required String applicationId,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.verifySellerPhoneOtp,
        data: {'applicationId': applicationId, 'otp': otp},
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Phone OTP verification failed.');
      return data;
    } on DioException catch (e, st) {
      AppLogger.e('Verify Seller Phone OTP failed', e, st);
      throw SellerException(_extractMessage(e, fallback: 'Invalid Phone OTP.'));
    }
  }

  /// Resend Seller Email OTP: POST /api/sellers/applications/resend-email-otp
  Future<void> resendSellerEmailOtp({required String applicationId}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.resendSellerEmailOtp,
        data: {'applicationId': applicationId},
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Resend email OTP failed.');
    } on DioException catch (e, st) {
      AppLogger.e('Resend Seller Email OTP failed', e, st);
      throw SellerException(_extractMessage(e, fallback: 'Failed to resend email OTP.'));
    }
  }

  /// Resend Seller Phone OTP: POST /api/sellers/applications/resend-phone-otp
  Future<void> resendSellerPhoneOtp({required String applicationId}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.resendSellerPhoneOtp,
        data: {'applicationId': applicationId},
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Resend phone OTP failed.');
    } on DioException catch (e, st) {
      AppLogger.e('Resend Seller Phone OTP failed', e, st);
      throw SellerException(_extractMessage(e, fallback: 'Failed to resend phone OTP.'));
    }
  }

  // ===========================================================================
  // 3. SELLER PROFILE, SUMMARY & PROPERTIES
  // ===========================================================================

  /// Get Seller Profile by ID: GET /api/v1/sellers/:id
  Future<SellerModel> getSellerById(String id) async {
    try {
      // NOTE: ApiConstants.getSellerById / getSellerSummary / getSellerProperties
      // are methods that build the full path (they already include the id),
      // not string constants — call them as functions, don't interpolate them.
      final response = await _apiService.get(ApiConstants.getSellerById(id));
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Could not fetch seller details.');
      
      final sellerMap = (data['data'] is Map && data['data']['seller'] != null)
          ? data['data']['seller']
          : (data['data'] ?? data);
      return SellerModel.fromJson(sellerMap);
    } on DioException catch (e, st) {
      AppLogger.e('Get Seller By ID failed', e, st);
      throw SellerException(_extractMessage(e, fallback: 'Failed to fetch seller profile.'));
    }
  }

  /// Get Seller Summary Stats: GET /api/v1/sellers/:id/summary
  Future<SellerSummaryModel> getSellerSummary(String id) async {
    try {
      final response = await _apiService.get(ApiConstants.getSellerSummary(id));
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Could not fetch seller summary.');
      
      final statsMap = data['data'] is Map ? data['data'] : {};
      return SellerSummaryModel.fromJson(statsMap);
    } on DioException catch (e, st) {
      AppLogger.e('Get Seller Summary failed', e, st);
      throw SellerException(_extractMessage(e, fallback: 'Failed to load seller summary.'));
    }
  }

  /// Get Seller Properties: GET /api/v1/sellers/:id/properties
  Future<List<dynamic>> getSellerProperties(String id) async {
    try {
      final response = await _apiService.get(ApiConstants.getSellerProperties(id));
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Could not fetch seller properties.');

      final raw = data['data'];
      if (raw is List) return raw;
      // Some list endpoints in this backend nest the array one level
      // deeper, e.g. { data: { properties: [...] } }.
      if (raw is Map) {
        final nested = raw['properties'] ?? raw['results'] ?? raw['items'];
        if (nested is List) return nested;
      }
      return [];
    } on DioException catch (e, st) {
      AppLogger.e('Get Seller Properties failed', e, st);
      throw SellerException(_extractMessage(e, fallback: 'Failed to load seller properties.'));
    }
  }

  /// Get Seller Single Property Details: GET /api/v1/sellers/:sellerId/properties/:propertyId
  Future<Map<String, dynamic>> getSellerPropertyById({
    required String sellerId,
    required String propertyId,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.getSellerPropertyById(sellerId, propertyId),
      );
      final data = _asMap(response.data);
      _throwIfUnsuccessful(data, fallback: 'Could not fetch property details.');
      AppLogger.i('Seller property $propertyId fetched for seller $sellerId');
      return data['data'] is Map
          ? Map<String, dynamic>.from(data['data'])
          : data;
    } on DioException catch (e, st) {
      AppLogger.e('Get Seller Property By ID failed', e, st);
      throw SellerException(_extractMessage(e, fallback: 'Failed to load property details.'));
    }
  }

  // ===========================================================================
  // 4. SELLER HOME — SUPPORTING DATA (leads & visits for the assigned partner)
  // ===========================================================================

  /// Leads captured against the partner handling this seller's properties:
  /// GET /api/v1/leads/partner/:partnerId
  /// Returns a raw, defensively-parsed list (never throws — Seller Home
  /// treats this as supplementary and should still render without it).
  Future<List<Map<String, dynamic>>> getPartnerLeadsRaw(String partnerId) async {
    try {
      final response = await _apiService.get(ApiConstants.sellerPartnerLeads(partnerId));
      return _extractList(response.data, keys: ['leads', 'results', 'items']);
    } on DioException catch (e, st) {
      AppLogger.e('Get Partner Leads failed', e, st);
      return [];
    }
  }

  /// Visits scheduled with the partner handling this seller's properties:
  /// GET /api/v1/visits/partner/:partnerId
  Future<List<Map<String, dynamic>>> getPartnerVisitsRaw(String partnerId) async {
    try {
      final response = await _apiService.get(ApiConstants.sellerPartnerVisits(partnerId));
      return _extractList(response.data, keys: ['visits', 'results', 'items']);
    } on DioException catch (e, st) {
      AppLogger.e('Get Partner Visits failed', e, st);
      return [];
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  /// Pulls a `List` out of a response body that may put it at `data`,
  /// `data.<key>` for any of [keys], or at the root — whichever shape the
  /// backend happens to use for a given list endpoint.
  List<Map<String, dynamic>> _extractList(dynamic raw, {required List<String> keys}) {
    dynamic root = raw;
    if (root is Map && root['data'] != null) root = root['data'];

    dynamic list = root;
    if (root is Map) {
      list = null;
      for (final key in keys) {
        if (root[key] is List) {
          list = root[key];
          break;
        }
      }
    }

    if (list is! List) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _throwIfUnsuccessful(Map<String, dynamic> data, {required String fallback}) {
    if (data['success'] == false) {
      final message = data['message'];
      throw SellerException(message is String && message.isNotEmpty ? message : fallback);
    }
  }

  String _extractMessage(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    return fallback;
  }

  /// Pulls the raw error body (e.g. `{"applicationStatus": "..."}`) off a
  /// failed response so callers can branch on it (login errors include
  /// `applicationStatus` per the API guide).
  Map<String, dynamic>? _extractErrorData(DioException e) {
    final data = e.response?.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }
}
