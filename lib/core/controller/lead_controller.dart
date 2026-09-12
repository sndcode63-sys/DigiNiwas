import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../features/auth/data/lead_repository.dart';
import '../models/lead_model.dart';

/// GetX controller for the "Connect with DigiNiwas Partner" lead-capture
/// flow on Property Details. Register lazily the same way VisitController
/// is (see PropertyDetailsScreen._visitController), no InitialBinding
/// change needed:
///   Get.put(LeadController(LeadRepository(ApiService.instance)));
class LeadController extends GetxController {
  LeadController(this._repository);

  final LeadRepository _repository;

  final RxBool isSubmitting = false.obs;
  final RxnString submitError = RxnString();
  final Rx<LeadData?> lastLead = Rx<LeadData?>(null);

  /// Returns true on success; on failure [submitError] holds a message
  /// (prefers the backend's own validation message when available).
  Future<bool> createLeadFromProperty({
    required String propertyId,
    String? buyerId,
    String? partnerId,
    required String name,
    required String phone,
    String? email,
    String? message,
    String? source,
    required String contactPreference,
  }) async {
    isSubmitting.value = true;
    submitError.value = null;
    try {
      final result = await _repository.createLeadFromProperty(
        propertyId: propertyId,
        buyerId: buyerId,
        partnerId: partnerId,
        name: name,
        phone: phone,
        email: email,
        message: message,
        source: source,
        contactPreference: contactPreference,
      );

      lastLead.value = result.data;
      if (result.success == false) {
        submitError.value = result.message ?? 'Could not send your request. Please try again.';
        return false;
      }
      return true;
    } on DioException catch (e) {
      submitError.value = _extractServerMessage(e) ?? 'Could not send your request. Please try again.';
      return false;
    } catch (_) {
      submitError.value = 'Something went wrong. Please try again.';
      return false;
    } finally {

      isSubmitting.value = false;
    }
  }

  String? _extractServerMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    return null;
  }
}