import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/models/seller_home_feed_model.dart';
import '../../../core/models/seller_model.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/seller_repository.dart';

/// GetX Controller for managing Seller Dashboard state & API integrations
class SellerController extends GetxController {
  final SellerRepository _repository;

  SellerController({SellerRepository? repository})
      : _repository = repository ?? SellerRepository();

  // Observable state variables
  final RxBool isLoading = false.obs;
  final RxBool isSubmittingKYC = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<SellerModel> sellerProfile = Rxn<SellerModel>();
  final Rxn<SellerSummaryModel> summaryStats = Rxn<SellerSummaryModel>();
  final RxList<dynamic> sellerProperties = <dynamic>[].obs;
  final Rxn<SellerApplicationModel> currentApplication = Rxn<SellerApplicationModel>();

  // ---------------------------------------------------------------------
  // Seller Home dashboard state (stat cards, partner card, progress
  // tracker, AI suggestion, recent updates feed).
  // ---------------------------------------------------------------------

  final RxBool isHomeLoading = false.obs;
  final RxString homeError = ''.obs;
  final RxString sellerId = ''.obs;

  final RxList<SellerPropertyBrief> properties = <SellerPropertyBrief>[].obs;
  final Rxn<SellerPropertyBrief> progressProperty = Rxn<SellerPropertyBrief>();

  final RxInt myListingsCount = 0.obs;
  final RxInt partnerReviewCount = 0.obs;
  final RxInt buyerInterestCount = 0.obs;
  final RxInt offersToReviewCount = 0.obs;

  final RxBool aiSuggestionAvailable = false.obs;
  final RxString aiSuggestionBody = ''.obs;

  final RxList<SellerUpdateItem> recentUpdates = <SellerUpdateItem>[].obs;

  /// Load complete dashboard data for a given Seller ID
  Future<void> fetchSellerDashboardData(String sellerId) async {
    if (sellerId.isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. Fetch Profile
      try {
        final profile = await _repository.getSellerById(sellerId);
        sellerProfile.value = profile;
        debugPrint('✅ Seller Profile loaded: ${profile.name} (${profile.sellerId})');
      } catch (e) {
        debugPrint('⚠️ Seller Profile fetch notice: $e');
      }

      // 2. Fetch Summary Stats
      try {
        final summary = await _repository.getSellerSummary(sellerId);
        summaryStats.value = summary;
        debugPrint('✅ Seller Summary loaded: Total=${summary.totalProperties}, Listed=${summary.listedProperties}');
      } catch (e) {
        debugPrint('⚠️ Seller Summary fetch notice: $e');
      }

      // 3. Fetch Properties
      try {
        final properties = await _repository.getSellerProperties(sellerId);
        sellerProperties.assignAll(properties);
        debugPrint('✅ Seller Properties loaded: ${properties.length} properties');
      } catch (e) {
        debugPrint('⚠️ Seller Properties fetch notice: $e');
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads everything the Seller Home screen needs, in one call:
  /// profile, stats, properties, and — for whichever partner is handling
  /// the seller's properties — their recent leads & visits (used to derive
  /// "Buyer Interest", "Offers to Review" and the updates feed).
  ///
  /// [silent] keeps the current UI on screen (no full-screen spinner) while
  /// refreshing in the background, e.g. for pull-to-refresh.
  Future<void> loadSellerHome({bool silent = false}) async {
    if (!silent) isHomeLoading.value = true;
    homeError.value = '';

    try {
      final id = await SecureStorageService.instance.getSellerMongoId();
      if (id == null || id.isEmpty) {
        homeError.value = 'Please log in again to load your dashboard.';
        return;
      }
      sellerId.value = id;

      // Profile — non-fatal if it fails, screen still renders with a
      // generic greeting.
      try {
        sellerProfile.value = await _repository.getSellerById(id);
      } catch (e) {
        debugPrint('⚠️ Seller Home: profile fetch notice: $e');
      }

      // Summary stats — best-effort, "My Listings" also falls back to the
      // property list length below if this fails.
      try {
        summaryStats.value = await _repository.getSellerSummary(id);
      } catch (e) {
        debugPrint('⚠️ Seller Home: summary fetch notice: $e');
      }

      // Properties — drives the stat cards, progress tracker and the
      // assigned-partner card.
      List<SellerPropertyBrief> parsedProperties = [];
      try {
        final raw = await _repository.getSellerProperties(id);
        sellerProperties.assignAll(raw);
        parsedProperties = raw
            .whereType<Map>()
            .map((e) => SellerPropertyBrief.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        debugPrint('⚠️ Seller Home: properties fetch notice: $e');
      }
      properties.assignAll(parsedProperties);

      myListingsCount.value = summaryStats.value?.totalProperties ?? parsedProperties.length;
      partnerReviewCount.value =
          parsedProperties.where((p) => p.stage == SellerPropertyStage.partnerReview).length;

      // Pick the property to show on the progress tracker: the most
      // recently updated one that hasn't gone live yet, else the most
      // recently updated listing overall.
      final notLive = parsedProperties.where((p) => p.stage != SellerPropertyStage.live).toList()
        ..sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));
      SellerPropertyBrief? focus = notLive.isNotEmpty ? notLive.first : null;
      if (focus == null && parsedProperties.isNotEmpty) {
        final sorted = [...parsedProperties]
          ..sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));
        focus = sorted.first;
      }
      progressProperty.value = focus;

      aiSuggestionAvailable.value = focus?.documentsPending ?? false;
      aiSuggestionBody.value = aiSuggestionAvailable.value
          ? 'Add the ownership document requested by your partner to complete verification.'
          : '';

      // Resolve the partner handling the seller's properties (prefer the
      // one on the focused property, else the first property that has one).
      String? partnerId = focus?.partnerId;
      if (partnerId == null || partnerId.isEmpty) {
        for (final p in parsedProperties) {
          if (p.partnerId != null && p.partnerId!.isNotEmpty) {
            partnerId = p.partnerId;
            break;
          }
        }
      }

      final propertyIds = parsedProperties.map((p) => p.id).where((id) => id.isNotEmpty).toSet();
      List<Map<String, dynamic>> leads = [];
      List<Map<String, dynamic>> visits = [];
      if (partnerId != null && partnerId.isNotEmpty) {
        leads = await _repository.getPartnerLeadsRaw(partnerId);
        visits = await _repository.getPartnerVisitsRaw(partnerId);
      }

      // Scope leads/visits down to this seller's own properties (the
      // partner endpoint returns everything assigned to that partner,
      // which may include other sellers' listings too).
      final myLeads = propertyIds.isEmpty
          ? leads
          : leads.where((l) => propertyIds.contains((l['propertyId'] ?? '').toString())).toList();
      final myVisits = propertyIds.isEmpty
          ? visits
          : visits.where((v) => propertyIds.contains((v['propertyId'] ?? '').toString())).toList();

      buyerInterestCount.value = myLeads.length;
      offersToReviewCount.value = myLeads.where((l) {
        final status = (l['status'] ?? '').toString().toLowerCase();
        return status.contains('offer') || status.contains('negotiat');
      }).length;

      recentUpdates.assignAll(_buildRecentUpdates(myLeads, myVisits, parsedProperties));
    } catch (e) {
      homeError.value = 'Could not load your dashboard right now.';
      debugPrint('⚠️ Seller Home: unexpected error: $e');
    } finally {
      isHomeLoading.value = false;
    }
  }

  List<SellerUpdateItem> _buildRecentUpdates(
    List<Map<String, dynamic>> leads,
    List<Map<String, dynamic>> visits,
    List<SellerPropertyBrief> properties,
  ) {
    final items = <SellerUpdateItem>[];

    for (final v in visits) {
      final when = DateTime.tryParse(
            (v['requestedVisitAt'] ?? v['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now();
      final status = (v['status'] ?? '').toString().toLowerCase();
      final who = (v['requestedBy'] is Map ? v['requestedBy']['name'] : null) ??
          (v['buyerSnapshot'] is Map ? v['buyerSnapshot']['name'] : null);
      items.add(SellerUpdateItem(
        kind: SellerUpdateKind.visit,
        title: status.contains('complet')
            ? 'Site visit completed${who != null ? ' with $who' : ''}'
            : 'Site visit requested${who != null ? ' by $who' : ''}',
        timestamp: when,
      ));
    }

    for (final l in leads) {
      final when = DateTime.tryParse((l['createdAt'] ?? '').toString()) ?? DateTime.now();
      final status = (l['status'] ?? '').toString().toLowerCase();
      final isOffer = status.contains('offer') || status.contains('negotiat');
      items.add(SellerUpdateItem(
        kind: isOffer ? SellerUpdateKind.offer : SellerUpdateKind.lead,
        title: isOffer
            ? '1 offer ready for your review'
            : 'New buyer interest${l['name'] != null ? ' from ${l['name']}' : ''}',
        timestamp: when,
      ));
    }

    for (final p in properties) {
      if (p.updatedAt == null) continue;
      items.add(SellerUpdateItem(
        kind: SellerUpdateKind.property,
        title: '${p.title} — ${stageLabel(p.stage)}',
        timestamp: p.updatedAt!,
      ));
    }

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items.take(6).toList();
  }

  /// Send Login OTP to Seller Email
  Future<bool> sendSellerLoginOtp(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _repository.sendLoginOtp(email: email);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify Login OTP and Login Seller
  Future<bool> loginWithOtp(String email, String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _repository.loginWithOtp(email: email, otp: otp);
      if (response['success'] == true && response['data'] != null) {
        sellerProfile.value = SellerModel.fromJson(response['data']);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Login Failed', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit Seller Registration Application (no KYC — plain registration
  /// per the API guide: name, email, phone, address, city, state, pinCode,
  /// country, latitude, longitude).
  Future<bool> submitRegistrationApplication({
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
      isSubmittingKYC.value = true;
      errorMessage.value = '';

      final appResult = await _repository.registerSellerApplication(
        name: name,
        email: email,
        phone: phone,
        address: address,
        city: city,
        state: state,
        pinCode: pinCode,
        country: country,
        latitude: latitude,
        longitude: longitude,
      );

      currentApplication.value = appResult;
      Get.snackbar('Success', 'Registration submitted. Please verify your email.');
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Submission Failed', errorMessage.value);
      return false;
    } finally {
      isSubmittingKYC.value = false;
    }
  }

  /// Change Seller Password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
