import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/models/lead_model.dart';
import '../../../core/network/api_service.dart';

/// POST {ApiConstants.baseUrl}{ApiConstants.createLeadFromProperty}
/// i.e. https://backend-diginiwas.onrender.com/api/leads/from-property
///
/// Fired from the Property Details "Connect with DigiNiwas Partner" sheet
/// (WhatsApp / Call / Instant Callback) so every buyer contact-intent on a
/// property is captured as a lead for the assigned partner to follow up on.
class LeadRepository {
  LeadRepository(this._api);

  final ApiService _api;

  Future<LeadModel> createLeadFromProperty({
    required String propertyId,
    String? buyerId,
    String? partnerId,
    required String name,
    required String phone,
    String? email,
    String? message,
    // Backend `source` field is a strict enum whose allowed values aren't
    // documented anywhere in this repo — sending an unrecognized value
    // (we tried 'app') throws "Lead validation failed: source: ... is not
    // a valid enum value". Safer to omit it entirely and let the schema's
    // own default apply, unless the caller explicitly knows a valid value.
    String? source,
    // 'whatsapp' | 'call' | 'callback'
    required String contactPreference,
  }) async {
    final Response response = await _api.post(
      ApiConstants.createLeadFromProperty,
      data: {
        'propertyId': propertyId,
        if (buyerId != null && buyerId.isNotEmpty) 'buyerId': buyerId,
        if (partnerId != null && partnerId.isNotEmpty) 'partnerId': partnerId,
        'name': name.trim(),
        'phone': phone.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
        if (source != null && source.trim().isNotEmpty) 'source': source.trim(),
        'contactPreference': contactPreference,
      },
    );
    return LeadModel.fromJson(_asMap(response.data));
  }

  /// Normalizes Dio's decoded `response.data` into a Map<String, dynamic>
  /// so LeadModel always gets the right shape.
  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException('Unexpected response shape from ApiService — expected a JSON object.');
  }
}