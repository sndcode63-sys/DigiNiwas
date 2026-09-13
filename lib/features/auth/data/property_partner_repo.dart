import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/models/partner_models.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/app_logger.dart';

class PartnerApiException implements Exception {
  PartnerApiException(this.message, {this.statusCode, this.data});
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Covers all 51 DigiNiwas Partner APIs (application, auth, management,
/// team, credits, leads, properties, promotions). Admin-only methods are
/// included for completeness but have no agent UI screens.
class PartnerRepository {
  PartnerRepository(this._api, [SecureStorageService? storage])
      : _storage = storage ?? SecureStorageService.instance;

  final ApiService _api;
  final SecureStorageService _storage;

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  void _ensureSuccess(Map<String, dynamic> data, {required String fallback}) {
    if (data['success'] == false) {
      final message = data['message'];
      throw PartnerApiException(
        message is String && message.isNotEmpty ? message : fallback,
      );
    }
  }

  String _extract(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map &&
        data['message'] is String &&
        (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Server is waking up. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server.';
    }
    return fallback;
  }

  PartnerApiException _exception(DioException e, {required String fallback}) {
    final raw = e.response?.data;
    Map<String, dynamic>? data;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final nested = map['data'];
      if (nested is Map) {
        data = Map<String, dynamic>.from(nested);
      } else {
        data = map;
      }
    }
    return PartnerApiException(
      _extract(e, fallback: fallback),
      statusCode: e.response?.statusCode,
      data: data,
    );
  }

  Future<void> clearPartnerSession() => _storage.clearTokens();

  Future<void> _persistSession(Map<String, dynamic> response) async {
    final token = response['token'] as String?;
    if (token != null && token.isNotEmpty) {
      await _storage.saveAccessToken(token);
    }
    final user = response['data'];
    if (user is Map) {
      final map = Map<String, dynamic>.from(user);
      map['role'] = map['role'] ?? 'Partner';
      map['mustChangePassword'] = response['mustChangePassword'] == true;
      await _storage.saveUserData(jsonEncode(map));
    }
  }

  // ---------------------------------------------------------------------------
  // 1. Partner Application APIs
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> registerPartnerApplication(
      Map<String, dynamic> payload,
      ) async {
    try {
      final data = Map<String, dynamic>.from(payload);
      // Live DigiNiwas API expects an object, not a bare boolean:
      // { accepted: true, privacyNoticeVersion: "v1" }
      final consent = data['privacyConsent'];
      if (consent is! Map) {
        data['privacyConsent'] = {
          'accepted': true,
          'privacyNoticeVersion': 'v1',
        };
      } else {
        final map = Map<String, dynamic>.from(consent);
        map['accepted'] = map['accepted'] == true || map['accepted'] == 'true';
        map['privacyNoticeVersion'] =
            asString(map['privacyNoticeVersion']) ?? 'v1';
        data['privacyConsent'] = map;
      }

      final response = await _api.post(
        ApiConstants.partnerApplicationsRegister,
        data: data,
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Registration failed.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('registerPartnerApplication failed', e, st);
      throw _exception(
        e,
        fallback: 'Could not register partner application.',
      );
    }
  }

  /// POST /partner-applications/:id/resend-otp
  /// Body + query: `{ "channel": "email" | "phone" }`
  /// Treats "already verified" responses as a soft success.
  Future<Map<String, dynamic>> resendPartnerOtp(
      String id, {
        required String channel,
      }) async {
    final normalized = channel.trim().toLowerCase();
    try {
      final response = await _api.post(
        '${ApiConstants.partnerApplications}/$id/resend-otp',
        queryParameters: {'channel': normalized},
        data: {'channel': normalized},
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not resend OTP.');
      return {
        ...body,
        'alreadyVerified': false,
        'channel': normalized,
      };
    } on DioException catch (e, st) {
      AppLogger.e('resendPartnerOtp failed', e, st);
      final message = _extract(e, fallback: 'Could not resend OTP.');
      final lower = message.toLowerCase();
      final alreadyVerified = lower.contains('already verified') ||
          lower.contains('already verify');
      if (alreadyVerified) {
        return {
          'success': true,
          'message': message,
          'alreadyVerified': true,
          'channel': normalized,
          'data': asMap(e.response?.data is Map
              ? (e.response!.data as Map)['data']
              : null),
        };
      }
      throw _exception(e, fallback: 'Could not resend OTP.');
    }
  }

  Future<Map<String, dynamic>> verifyPartnerEmail(
      String id, {
        required String otp,
      }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.partnerApplications}/$id/verify-email',
        data: {'otp': otp},
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Email verification failed.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('verifyPartnerEmail failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not verify email.'),
      );
    }
  }

  Future<Map<String, dynamic>> verifyPartnerPhone(
      String id, {
        required String otp,
      }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.partnerApplications}/$id/verify-phone',
        data: {'otp': otp},
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Phone verification failed.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('verifyPartnerPhone failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not verify phone.'),
      );
    }
  }

  /// Admin: GET /partner-applications
  Future<List<Map<String, dynamic>>> getPartnerApplications({
    String? accountType,
    String? agencyOwnerId,
    String? search,
    String? status,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.partnerApplications,
        queryParameters: {
          if (accountType != null) 'accountType': accountType,
          if (agencyOwnerId != null) 'agencyOwnerId': agencyOwnerId,
          if (search != null) 'search': search,
          if (status != null) 'status': status,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load applications.');
      return asMapList(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('getPartnerApplications failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load applications.'),
      );
    }
  }

  Future<Map<String, dynamic>> getPartnerApplicationById(String id) async {
    try {
      final response =
      await _api.get('${ApiConstants.partnerApplications}/$id');
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load application.');
      return asMap(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('getPartnerApplicationById failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load application.'),
      );
    }
  }

  Future<Map<String, dynamic>> approvePartnerApplication(String id) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.partnerApplications}/$id/approve',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Approve failed.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('approvePartnerApplication failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Could not approve.'));
    }
  }

  Future<Map<String, dynamic>> verifyPartnerApplication(String id) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.partnerApplications}/$id/verify',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Verify failed.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('verifyPartnerApplication failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Could not verify.'));
    }
  }

  Future<Map<String, dynamic>> partnerApplicationActionRequired(
      String id,
      ) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.partnerApplications}/$id/action-required',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Action required failed.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('partnerApplicationActionRequired failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not mark action required.'),
      );
    }
  }

  Future<Map<String, dynamic>> rejectPartnerApplication(String id) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.partnerApplications}/$id/reject',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Reject failed.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('rejectPartnerApplication failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Could not reject.'));
    }
  }

  // ---------------------------------------------------------------------------
  // 2. Partner Management APIs
  // ---------------------------------------------------------------------------

  Future<List<PartnerProperty>> getUnassignedProperties() async {
    try {
      final response =
      await _api.get(ApiConstants.partnersUnassignedProperties);
      final body = _asMap(response.data);
      if (body['success'] == false) return const [];
      _ensureSuccess(body, fallback: 'Could not load unassigned properties.');
      return extractDataList(body).map(PartnerProperty.new).toList();
    } on DioException catch (e, st) {
      // Partner tokens often get 403 Admin-only on this route.
      AppLogger.e('getUnassignedProperties failed', e, st);
      return const [];
    }
  }

  Future<List<Map<String, dynamic>>> getAvailablePartners({
    String? accountType,
    String? city,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.partnersAvailable,
        queryParameters: {
          if (accountType != null) 'accountType': accountType,
          if (city != null) 'city': city,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load available partners.');
      return asMapList(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('getAvailablePartners failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load available partners.'),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getApprovedNotVerifiedPartners() async {
    try {
      final response =
      await _api.get(ApiConstants.partnersApprovedNotVerified);
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load partners.');
      return asMapList(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('getApprovedNotVerifiedPartners failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load partners.'),
      );
    }
  }

  Future<Map<String, dynamic>> getPartnersAssignmentSummary() async {
    try {
      final response = await _api.get(ApiConstants.partnersSummary);
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load summary.');
      return asMap(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('getPartnersAssignmentSummary failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load summary.'),
      );
    }
  }

  Future<List<PartnerProperty>> getPartnerPropertiesAssigned({
    String? assignment,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.partnersProperties,
        queryParameters: {
          if (assignment != null) 'assignment': assignment,
        },
      );
      final body = _asMap(response.data);
      if (body['success'] == false) return const [];
      _ensureSuccess(body, fallback: 'Could not load properties.');
      return extractDataList(body).map(PartnerProperty.new).toList();
    } on DioException catch (e, st) {
      AppLogger.e('getPartnerPropertiesAssigned failed', e, st);
      return const [];
    }
  }

  Future<Map<String, dynamic>> assignPartnerToProperty(
      String propertyId, {
        required String partnerId,
      }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.partnersProperties}/$propertyId/assign',
        data: {'partnerId': partnerId},
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Assign failed.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('assignPartnerToProperty failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Could not assign.'));
    }
  }

  Future<Map<String, dynamic>> assignPartnerToPropertyAlt(
      String propertyId, {
        required String partnerId,
      }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.partnersProperties}/$propertyId/assign-partner',
        data: {'partnerId': partnerId},
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Assign failed.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('assignPartnerToPropertyAlt failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Could not assign.'));
    }
  }

  Future<Map<String, dynamic>> unassignPartnerFromProperty(
      String propertyId,
      ) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.partnersProperties}/$propertyId/unassign',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Unassign failed.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('unassignPartnerFromProperty failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Could not unassign.'));
    }
  }

  Future<List<Map<String, dynamic>>> getAllPartners({
    String? accountType,
    String? search,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.partners,
        queryParameters: {
          if (accountType != null) 'accountType': accountType,
          if (search != null) 'search': search,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load partners.');
      return asMapList(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('getAllPartners failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load partners.'),
      );
    }
  }

  Future<Map<String, dynamic>> blockPartner(
      String id, {
        required bool isBlocked,
      }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.partners}/$id/block',
        data: {'isBlocked': isBlocked},
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Block failed.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('blockPartner failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Could not update block.'));
    }
  }

  Future<void> deletePartner(String id) async {
    try {
      final response =
      await _api.delete('${ApiConstants.partnersDelete}/$id');
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Delete failed.');
    } on DioException catch (e, st) {
      AppLogger.e('deletePartner failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Could not delete.'));
    }
  }

  Future<PartnerProfile> getPartnerById(String id) async {
    try {
      final response = await _api.get('${ApiConstants.partners}/$id');
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load partner profile.');
      final data = asMap(body['data']);
      return PartnerProfile(data.isEmpty ? body : data);
    } on DioException catch (e, st) {
      AppLogger.e('getPartnerById failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Could not load partner.'));
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Partner Authentication
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> partnerLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.partnerLogin,
        data: {'email': email, 'password': password},
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Login failed.');
      await _persistSession(body);
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('partnerLogin failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Login failed.'));
    }
  }

  Future<void> changePartnerPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _api.patch(
        ApiConstants.partnerChangePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not change password.');
      await clearMustChangePasswordFlag();
    } on DioException catch (e, st) {
      AppLogger.e('changePartnerPassword failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not change password.'),
      );
    }
  }

  /// Clears the splash gate that forces Change Password on every launch.
  Future<void> clearMustChangePasswordFlag() async {
    final raw = await _storage.getUserData();
    if (raw == null || raw.isEmpty) return;
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      if (map['mustChangePassword'] == true) {
        map['mustChangePassword'] = false;
        await _storage.saveUserData(jsonEncode(map));
      }
    } catch (_) {
      // Corrupt session — ignore; caller still navigates onward.
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Team Partner APIs
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getTeamPartners() async {
    try {
      final response = await _api.get(ApiConstants.teamPartners);
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load team partners.');
      return asMapList(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('getTeamPartners failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load team partners.'),
      );
    }
  }

  Future<Map<String, dynamic>> addTeamMember(
      String ownerId,
      Map<String, dynamic> payload,
      ) async {
    try {
      final response = await _api.post(
        '${ApiConstants.teamPartners}/$ownerId/members',
        data: payload,
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not add team member.');
      return asMap(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('addTeamMember failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not add team member.'),
      );
    }
  }

  Future<Map<String, dynamic>> allocateTeamCredits({
    required String ownerId,
    required String memberId,
    required int credits,
    int approvalThreshold = 1,
  }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.teamPartners}/$ownerId/members/$memberId/allocate-credits',
        data: {
          'credits': credits,
          'approvalThreshold': approvalThreshold,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not allocate credits.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('allocateTeamCredits failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not allocate credits.'),
      );
    }
  }

  Future<Map<String, dynamic>> getTeamMemberCreditHistory({
    required String ownerId,
    required String memberId,
  }) async {
    try {
      final response = await _api.get(
        '${ApiConstants.teamPartners}/$ownerId/members/$memberId/credit-history',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load credit history.');
      return asMap(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('getTeamMemberCreditHistory failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load credit history.'),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getVerifiedTeamMembers(
      String ownerId,
      ) async {
    try {
      final response = await _api.get(
        '${ApiConstants.teamPartners}/$ownerId/verified-members',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load verified members.');
      return extractDataList(body);
    } on DioException catch (e, st) {
      AppLogger.e('getVerifiedTeamMembers failed', e, st);
      throw _exception(e, fallback: 'Could not load verified members.');
    }
  }

  Future<List<PartnerProperty>> getTeamAssignedProperties(
      String ownerId,
      ) async {
    try {
      final response = await _api.get(
        '${ApiConstants.teamPartners}/$ownerId/properties',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load team properties.');
      return extractDataList(body).map(PartnerProperty.new).toList();
    } on DioException catch (e, st) {
      AppLogger.e('getTeamAssignedProperties failed', e, st);
      throw _exception(e, fallback: 'Could not load team properties.');
    }
  }

  Future<Map<String, dynamic>> delegatePropertyToSubAgent({
    required String ownerId,
    required String propertyId,
    String? memberId,
  }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.teamPartners}/$ownerId/properties/$propertyId/delegate',
        data: {
          'ownerId': ownerId,
          'propertyId': propertyId,
          if (memberId != null) 'memberId': memberId,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not delegate property.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('delegatePropertyToSubAgent failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not delegate property.'),
      );
    }
  }

  Future<Map<String, dynamic>> removePropertyDelegation({
    required String ownerId,
    required String propertyId,
  }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.teamPartners}/$ownerId/properties/$propertyId/remove-delegation',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not remove delegation.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('removePropertyDelegation failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not remove delegation.'),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Partner Credit APIs
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getCreditsPartnersOverview({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.creditsByPartner,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load credits overview.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('getCreditsPartnersOverview failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load credits overview.'),
      );
    }
  }

  Future<PartnerCreditsSnapshot> getPartnerCreditDetails(
      String partnerId,
      ) async {
    try {
      final response = await _api.get(
        '${ApiConstants.creditsByPartner}/$partnerId',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load credit details.');
      return PartnerCreditsSnapshot.fromResponse(body);
    } on DioException catch (e, st) {
      AppLogger.e('getPartnerCreditDetails failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load credit details.'),
      );
    }
  }

  Future<PartnerCreditsSnapshot> getPartnerCredits(String partnerId) async {
    try {
      final response = await _api.get(
        '${ApiConstants.creditsPartnerWallet}/$partnerId',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load credits.');
      return PartnerCreditsSnapshot.fromResponse(body);
    } on DioException catch (e, st) {
      AppLogger.e('getPartnerCredits failed', e, st);
      try {
        return await getPartnerCreditDetails(partnerId);
      } catch (_) {
        throw PartnerApiException(
          _extract(e, fallback: 'Could not load credits.'),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> getCreditsHistory({
    String? partnerId,
    int page = 1,
    int limit = 20,
    String? direction,
    String? productCode,
    String? status,
    String? type,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.creditsHistory,
        queryParameters: {
          if (partnerId != null && partnerId.isNotEmpty) 'partnerId': partnerId,
          'page': page,
          'limit': limit,
          if (direction != null) 'direction': direction,
          if (productCode != null) 'productCode': productCode,
          if (status != null) 'status': status,
          if (type != null) 'type': type,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load credit history.');
      final data = body['data'];
      if (data is List) return asMapList(data);
      if (data is Map) {
        return asMapList(
          data['transactions'] ?? data['history'] ?? data['items'],
        );
      }
      return const [];
    } on DioException catch (e, st) {
      AppLogger.e('getCreditsHistory failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load credit history.'),
      );
    }
  }

  Future<List<CreditPack>> getCreditPacks() async {
    try {
      final response = await _api.get(ApiConstants.creditSettings);
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load credit packs.');
      final data = body['data'];
      if (data is List) {
        final packs = asMapList(data).map(CreditPack.fromMap).toList();
        return packs.isEmpty ? _fallbackCreditPacks : packs;
      }
      if (data is Map) {
        final products = asMapList(
          data['products'] ?? data['packs'] ?? data['items'],
        );
        // Live API returns unlock/boost pricing products, not wallet top-ups.
        final topUpProducts = products.where((p) {
          final target =
          (asString(p['targetType']) ?? '').toLowerCase();
          final code = (asString(p['code']) ?? '').toLowerCase();
          return target == 'wallet' ||
              target == 'credit' ||
              code.contains('pack') ||
              code.contains('topup') ||
              code.startsWith('c') && !code.contains('boost');
        }).toList();
        if (topUpProducts.isNotEmpty) {
          return topUpProducts.map(CreditPack.fromMap).toList();
        }
        final rate = asDouble(data['creditsPerRupee']) ?? 0.5;
        return _packsFromCreditsPerRupee(rate);
      }
      return _fallbackCreditPacks;
    } on DioException catch (e, st) {
      AppLogger.e('getCreditPacks failed', e, st);
      return _fallbackCreditPacks;
    }
  }

  List<CreditPack> _packsFromCreditsPerRupee(double creditsPerRupee) {
    final rupeesPerCredit =
    creditsPerRupee <= 0 ? 1.0 : (1.0 / creditsPerRupee);
    const amounts = [500, 1000, 3000, 5000];
    return [
      for (final credits in amounts)
        CreditPack(
          code: 'TOPUP_$credits',
          label: '$credits Credits',
          credits: credits,
          priceInr: (credits * rupeesPerCredit).round(),
        ),
    ];
  }

  static const List<CreditPack> _fallbackCreditPacks = [
    CreditPack(
      code: 'c500',
      label: '500 Credits (demo)',
      credits: 500,
      priceInr: 500,
      isFallback: true,
    ),
    CreditPack(
      code: 'c1000',
      label: '1,000 Credits (demo)',
      credits: 1000,
      priceInr: 1000,
      isFallback: true,
    ),
    CreditPack(
      code: 'c3000',
      label: '3,000 Credits (demo)',
      credits: 3000,
      priceInr: 3000,
      isFallback: true,
    ),
    CreditPack(
      code: 'c5000',
      label: '5,000 Credits (demo)',
      credits: 5000,
      priceInr: 5000,
      isFallback: true,
    ),
  ];

  Future<PartnerCreditsSnapshot> completeCreditPurchase({
    required String partnerId,
    required int credits,
    required int amountInRupees,
    String? paymentId,
    String? orderId,
    String? invoiceId,
    String? idempotencyKey,
    String? productCode,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.creditsPurchaseComplete,
        data: {
          'partnerId': partnerId,
          'credits': credits,
          'amountInRupees': amountInRupees,
          if (paymentId != null) 'paymentId': paymentId,
          if (orderId != null) 'orderId': orderId,
          if (invoiceId != null) 'invoiceId': invoiceId,
          'idempotencyKey':
          idempotencyKey ?? 'dn-${DateTime.now().millisecondsSinceEpoch}',
          if (productCode != null) 'productCode': productCode,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Purchase failed.');
      return PartnerCreditsSnapshot.fromResponse(body);
    } on DioException catch (e, st) {
      AppLogger.e('completeCreditPurchase failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not complete purchase.'),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 6. Partner Lead APIs
  // ---------------------------------------------------------------------------

  Future<PartnerLeadsDashboard> getLeadsDashboard() async {
    try {
      final response = await _api.get(ApiConstants.leadsDashboard);
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load leads dashboard.');
      return PartnerLeadsDashboard.fromResponse(body);
    } on DioException catch (e, st) {
      AppLogger.e('getLeadsDashboard failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load leads dashboard.'),
      );
    }
  }

  Future<List<PartnerLead>> getPartnerLeads(
      String partnerId, {
        String? status,
        int page = 1,
        int limit = 50,
      }) async {
    try {
      final response = await _api.get(
        '${ApiConstants.leadsByPartner}/$partnerId',
        queryParameters: {
          'partnerId': partnerId,
          if (status != null && status.isNotEmpty) 'status': status,
          'page': page,
          'limit': limit,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load leads.');
      final scoped = extractDataList(body).map(PartnerLead.new).toList();
      if (scoped.isNotEmpty) return scoped;

      // Some backends return an empty partner list while /leads is readable.
      // Filter to leads assigned to this partner mongo id.
      final allResponse = await _api.get(
        ApiConstants.leads,
        queryParameters: {'page': page, 'limit': limit},
      );
      final allBody = _asMap(allResponse.data);
      _ensureSuccess(allBody, fallback: 'Could not load leads.');
      return extractDataList(allBody)
          .map(PartnerLead.new)
          .where(
            (lead) =>
        lead.assignedPartnerMongoId == partnerId ||
            asString(asMap(lead.raw['assignedPartner'])['partnerCode']) ==
                partnerId,
      )
          .toList();
    } on DioException catch (e, st) {
      AppLogger.e('getPartnerLeads failed', e, st);
      throw _exception(e, fallback: 'Could not load leads.');
    }
  }

  Future<PartnerLead> getPartnerLeadById({
    required String partnerId,
    required String leadId,
  }) async {
    try {
      final response = await _api.get(
        '${ApiConstants.leadsByPartner}/$partnerId/$leadId',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load lead.');
      return PartnerLead(asMap(body['data']));
    } on DioException catch (e, st) {
      AppLogger.e('getPartnerLeadById failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Could not load lead.'));
    }
  }

  Future<Map<String, dynamic>> unlockLead(
      String leadId, {
        required String partnerId,
        String? remarks,
      }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.leads}/$leadId/unlock',
        data: {
          'partnerId': partnerId,
          if (remarks != null) 'remarks': remarks,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not unlock lead.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('unlockLead failed', e, st);
      throw PartnerApiException(_extract(e, fallback: 'Could not unlock lead.'));
    }
  }

  Future<Map<String, dynamic>> updateLeadStatus(
      String leadId, {
        required String status,
      }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.leads}/$leadId/status',
        data: {'status': status},
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not update lead status.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('updateLeadStatus failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not update lead status.'),
      );
    }
  }

  Future<void> addLeadContactHistory(
      String leadId, {
        required String note,
        String? channel,
      }) async {
    try {
      final response = await _api.post(
        '${ApiConstants.leads}/$leadId/contact-history',
        data: {
          // Postman uses `notes`; some builds accept `note`.
          'note': note,
          'notes': note,
          if (channel != null) 'channel': channel,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not save contact history.');
    } on DioException catch (e, st) {
      AppLogger.e('addLeadContactHistory failed', e, st);
      throw _exception(e, fallback: 'Could not save contact history.');
    }
  }

  // ---------------------------------------------------------------------------
  // 7. Partner Property APIs
  // ---------------------------------------------------------------------------

  Future<List<PartnerProperty>> getNewPropertiesByPartner(
      String partnerId,
      ) async {
    try {
      final response = await _api.get(
        '${ApiConstants.newPropertiesByPartner}/$partnerId',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load partner properties.');
      return extractDataList(body).map(PartnerProperty.new).toList();
    } on DioException catch (e, st) {
      AppLogger.e('getNewPropertiesByPartner failed', e, st);
      throw _exception(e, fallback: 'Could not load partner properties.');
    }
  }

  Future<Map<String, dynamic>> createNewProperty(
      Map<String, dynamic> fields, {
        List<String>? imagePaths,
        String? floorPlanPath,
        String? reraCertificatePath,
        String? videoPath,
      }) async {
    try {
      final form = FormData();
      fields.forEach((key, value) {
        if (value != null) form.fields.add(MapEntry(key, value.toString()));
      });
      if (imagePaths != null) {
        for (final path in imagePaths.take(25)) {
          form.files.add(
            MapEntry('images', await MultipartFile.fromFile(path)),
          );
        }
      }
      if (floorPlanPath != null) {
        form.files.add(
          MapEntry(
            'floorPlan',
            await MultipartFile.fromFile(floorPlanPath),
          ),
        );
      }
      if (reraCertificatePath != null) {
        form.files.add(
          MapEntry(
            'reraCertificate',
            await MultipartFile.fromFile(reraCertificatePath),
          ),
        );
      }
      if (videoPath != null) {
        form.files.add(
          MapEntry('video', await MultipartFile.fromFile(videoPath)),
        );
      }

      final hasFiles = form.files.isNotEmpty;
      final response = hasFiles
          ? await _api.postMultipart(ApiConstants.newProperties, data: form)
          : await _api.post(ApiConstants.newProperties, data: fields);
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not create property.');
      return asMap(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('createNewProperty failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not create property.'),
      );
    }
  }

  Future<Map<String, dynamic>> updateNewProperty(
      String id,
      Map<String, dynamic> fields, {
        List<String>? imagePaths,
        String? floorPlanPath,
        String? reraCertificatePath,
        String? videoPath,
      }) async {
    try {
      final form = FormData();
      fields.forEach((key, value) {
        if (value != null) form.fields.add(MapEntry(key, value.toString()));
      });
      if (imagePaths != null) {
        for (final path in imagePaths.take(25)) {
          form.files.add(
            MapEntry('images', await MultipartFile.fromFile(path)),
          );
        }
      }
      if (floorPlanPath != null) {
        form.files.add(
          MapEntry(
            'floorPlan',
            await MultipartFile.fromFile(floorPlanPath),
          ),
        );
      }
      if (reraCertificatePath != null) {
        form.files.add(
          MapEntry(
            'reraCertificate',
            await MultipartFile.fromFile(reraCertificatePath),
          ),
        );
      }
      if (videoPath != null) {
        form.files.add(
          MapEntry('video', await MultipartFile.fromFile(videoPath)),
        );
      }

      final hasFiles = form.files.isNotEmpty;
      final response = hasFiles
          ? await _api.patchMultipart(
        '${ApiConstants.newProperties}/$id',
        data: form,
      )
          : await _api.patch(
        '${ApiConstants.newProperties}/$id',
        data: fields,
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not update property.');
      return asMap(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('updateNewProperty failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not update property.'),
      );
    }
  }

  Future<Map<String, dynamic>> updatePropertyStatus(
      String id, {
        required String status,
        String? notes,
        String? rejectionReason,
      }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.newProperties}/$id/status',
        data: {
          'status': status,
          if (notes != null) 'notes': notes,
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not update status.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('updatePropertyStatus failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not update status.'),
      );
    }
  }

  Future<void> boostProperty(
      String propertyId, {
        String? boostType,
        Object? days,
      }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.newProperties}/$propertyId/boost',
        data: {
          if (boostType != null) 'boostType': boostType,
          if (days != null) 'days': days,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not boost property.');
    } on DioException catch (e, st) {
      AppLogger.e('boostProperty failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not boost property.'),
      );
    }
  }

  Future<void> unboostProperty(String propertyId) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.newProperties}/$propertyId/unboost',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not remove boost.');
    } on DioException catch (e, st) {
      AppLogger.e('unboostProperty failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not remove boost.'),
      );
    }
  }

  Future<void> deleteProperty(String propertyId) async {
    try {
      final response = await _api.delete(
        '${ApiConstants.newProperties}/$propertyId/delete',
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not delete property.');
    } on DioException catch (e, st) {
      AppLogger.e('deleteProperty failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not delete property.'),
      );
    }
  }

  Future<PublishingSummary> getPublishingSummary() async {
    try {
      final response = await _api.get(ApiConstants.propertyPublishingSummary);
      final body = _asMap(response.data);
      if (body['success'] == false) {
        return PublishingSummary(const {});
      }
      _ensureSuccess(body, fallback: 'Could not load publishing summary.');
      return PublishingSummary.fromResponse(body);
    } on DioException catch (e, st) {
      AppLogger.e('getPublishingSummary failed', e, st);
      return PublishingSummary(const {});
    }
  }

  // ---------------------------------------------------------------------------
  // 8. Promotions / Boost Operations
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> createPromotion({
    required String partnerId,
    required String propertyId,
    String? promotionType,
    String? remarks,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.promotions,
        data: {
          'partnerId': partnerId,
          'propertyId': propertyId,
          if (promotionType != null) 'promotionType': promotionType,
          if (remarks != null) 'remarks': remarks,
        },
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not create promotion.');
      return body;
    } on DioException catch (e, st) {
      AppLogger.e('createPromotion failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not create promotion.'),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPromotions({
    String? partnerId,
    String? promotionType,
    String? propertyId,
    String? search,
    String? status,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.promotions,
        queryParameters: {
          if (partnerId != null) 'partnerId': partnerId,
          if (promotionType != null) 'promotionType': promotionType,
          if (propertyId != null) 'propertyId': propertyId,
          if (search != null) 'search': search,
          if (status != null) 'status': status,
        },
      );
      final body = _asMap(response.data);
      if (body['success'] == false) return const [];
      _ensureSuccess(body, fallback: 'Could not load promotions.');
      return extractDataList(body);
    } on DioException catch (e, st) {
      AppLogger.e('getPromotions failed', e, st);
      return const [];
    }
  }

  Future<Map<String, dynamic>> getBoostOperationsDashboard({
    String? partnerId,
    String? promotionType,
    String? propertyId,
    String? search,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _api.get(
        ApiConstants.boostOperationsDashboard,
        queryParameters: {
          if (partnerId != null) 'partnerId': partnerId,
          if (promotionType != null) 'promotionType': promotionType,
          if (propertyId != null) 'propertyId': propertyId,
          if (search != null) 'search': search,
          if (status != null) 'status': status,
          'page': page,
          'limit': limit,
        },
      );
      final body = _asMap(response.data);
      if (body['success'] == false) return <String, dynamic>{};
      _ensureSuccess(body, fallback: 'Could not load boost dashboard.');
      return asMap(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('getBoostOperationsDashboard failed', e, st);
      return <String, dynamic>{};
    }
  }

  Future<Map<String, dynamic>> getBoostOperationById(String id) async {
    try {
      final response = await _api.get('${ApiConstants.boostOperations}/$id');
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load boost request.');
      return asMap(body['data']);
    } on DioException catch (e, st) {
      AppLogger.e('getBoostOperationById failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load boost request.'),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Visits (used by Tasks tab — related partner ops)
  // ---------------------------------------------------------------------------

  Future<List<PartnerVisit>> getPartnerVisits(String partnerId) async {
    try {
      final response =
      await _api.get('${ApiConstants.visitsByPartner}/$partnerId');
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load visits.');
      return extractDataList(body).map(PartnerVisit.new).toList();
    } on DioException catch (e, st) {
      AppLogger.e('getPartnerVisits failed', e, st);
      throw _exception(e, fallback: 'Could not load visits.');
    }
  }

  Future<VisitsSummary> getVisitsSummary() async {
    try {
      final response = await _api.get(ApiConstants.visitsSummary);
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not load visits summary.');
      return VisitsSummary.fromResponse(body);
    } on DioException catch (e, st) {
      AppLogger.e('getVisitsSummary failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not load visits summary.'),
      );
    }
  }

  Future<void> updateVisitStatus(
      String visitId, {
        required String status,
      }) async {
    try {
      final response = await _api.patch(
        '${ApiConstants.visits}/$visitId/status',
        data: {'status': status},
      );
      final body = _asMap(response.data);
      _ensureSuccess(body, fallback: 'Could not update visit status.');
    } on DioException catch (e, st) {
      AppLogger.e('updateVisitStatus failed', e, st);
      throw PartnerApiException(
        _extract(e, fallback: 'Could not update visit status.'),
      );
    }
  }
}
