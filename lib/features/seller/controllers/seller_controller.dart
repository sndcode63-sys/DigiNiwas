import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/seller_home_feed_model.dart';
import '../models/seller_model.dart';
import '../../../core/services/location_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_service.dart';
import '../data/seller_repository.dart';

/// GetX Controller for managing Seller Dashboard state & API integrations
class SellerController extends GetxController {
  final SellerRepository _repository;

  SellerController({SellerRepository? repository})
      : _repository = repository ?? SellerRepository();

  @override
  void onInit() {
    super.onInit();
    loadSellerAvatar();
    fetchSellerLocation();
  }

  // Observable state variables
  final RxBool isLoading = false.obs;
  final RxBool isSubmittingKYC = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<SellerModel> sellerProfile = Rxn<SellerModel>();
  final Rxn<SellerSummaryModel> summaryStats = Rxn<SellerSummaryModel>();
  final RxList<dynamic> sellerProperties = <dynamic>[].obs;
  final Rxn<SellerApplicationModel> currentApplication = Rxn<SellerApplicationModel>();

  // ---------------------------------------------------------------------
  // Profile avatar management & sync
  // ---------------------------------------------------------------------
  final RxString sellerAvatarLocalPath = ''.obs;
  final RxString sellerAvatarNetworkUrl = ''.obs;

  Future<void> loadSellerAvatar() async {
    final local = await StorageService.instance.sellerLocalAvatarPath;
    if (local != null && local.isNotEmpty && File(local).existsSync()) {
      sellerAvatarLocalPath.value = local;
    }
    final net = sellerProfile.value?.avatar;
    if (net != null && net.isNotEmpty) {
      sellerAvatarNetworkUrl.value = net;
    }
  }

  Future<void> updateSellerAvatar(String newPath) async {
    sellerAvatarLocalPath.value = newPath;
    await StorageService.instance.saveSellerLocalAvatarPath(newPath);
  }

  // ---------------------------------------------------------------------
  // Seller Location state & GPS capture
  // ---------------------------------------------------------------------
  final RxString sellerLocation = 'Fetching location...'.obs;
  final RxBool isLocationLoading = false.obs;

  Future<void> fetchSellerLocation() async {
    // 1. Check seller profile location
    final locMap = sellerProfile.value?.location;
    if (locMap != null) {
      final city = locMap['city']?.toString() ?? '';
      final locality = locMap['locality']?.toString() ?? '';
      final state = locMap['state']?.toString() ?? '';
      if (locality.isNotEmpty && city.isNotEmpty) {
        sellerLocation.value = '$locality, $city';
        return;
      } else if (city.isNotEmpty) {
        sellerLocation.value = state.isNotEmpty ? '$city, $state' : city;
        return;
      }
    }

    // 2. Check locally stored location
    try {
      final stored = await StorageService.instance.location;
      if (stored != null && stored['city'] != null && stored['city'].toString().isNotEmpty) {
        final city = stored['city'].toString();
        final state = stored['state']?.toString() ?? '';
        sellerLocation.value = state.isNotEmpty ? '$city, $state' : city;
        return;
      }
    } catch (_) {}

    // 3. Try live device location via LocationService
    try {
      isLocationLoading.value = true;
      final result = await LocationService().getCurrentLocation();
      if (result.city.isNotEmpty) {
        sellerLocation.value = result.state.isNotEmpty
            ? '${result.city}, ${result.state}'
            : result.city;
        return;
      }
    } catch (_) {
    } finally {
      isLocationLoading.value = false;
    }

    if (sellerLocation.value == 'Fetching location...') {
      sellerLocation.value = 'Ahmedabad, Gujarat';
    }
  }

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

  // Used by the "My Partner" and "Seller Profile" screens (Site Visits stat
  // card + the onboarding progress card's "Next appointment" notice).
  final RxInt siteVisitsCount = 0.obs;
  final Rxn<DateTime> nextVisitAt = Rxn<DateTime>();

  // Raw leads/visits scoped to this seller's own properties (already
  // filtered down from the assigned partner's full lists inside
  // loadSellerHome). Exposed so screens like Seller Insights can compute
  // their own aggregates (weekly buckets, per-property breakdowns, trend
  // deltas) straight from live data without re-fetching.
  final RxList<Map<String, dynamic>> sellerLeads = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> sellerVisits = <Map<String, dynamic>>[].obs;

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
        loadSellerAvatar();
        fetchSellerLocation();
      } catch (e) {
        debugPrint('⚠️ Seller Home: profile fetch notice: $e');
        loadSellerAvatar();
        fetchSellerLocation();
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

      siteVisitsCount.value = myVisits.length;
      sellerLeads.assignAll(myLeads);
      sellerVisits.assignAll(myVisits);

      // Earliest upcoming (not completed/cancelled/rejected) visit across
      // this seller's properties, used for the "Next appointment" notice.
      DateTime? upcoming;
      for (final v in myVisits) {
        final status =
        (v['status'] ?? v['approvalStatus'] ?? '').toString().toLowerCase();
        if (status.contains('cancel') ||
            status.contains('complet') ||
            status.contains('reject')) {
          continue;
        }
        final when = DateTime.tryParse(
          (v['approvedVisitAt'] ?? v['requestedVisitAt'] ?? '').toString(),
        );
        if (when == null) continue;
        if (upcoming == null || when.isBefore(upcoming)) upcoming = when;
      }
      nextVisitAt.value = upcoming;

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

  // ---------------------------------------------------------------------
  // Add Property flow — submits the new listing to POST /api/newproperties.
  // ---------------------------------------------------------------------

  final RxBool isSubmittingProperty = false.obs;
  final RxString submitPropertyError = ''.obs;
  final Rxn<Map<String, dynamic>> submittedProperty = Rxn<Map<String, dynamic>>();

  /// Submits a new property listing on behalf of the logged-in seller.
  /// Returns the created property map on success, null on failure (with
  /// [submitPropertyError] set and a snackbar already shown).
  Future<Map<String, dynamic>?> submitNewProperty({
    required Map<String, dynamic> fields,
    List<File> images = const [],
    File? floorPlan,
    File? reraCertificate,
    File? video,
  }) async {
    try {
      isSubmittingProperty.value = true;
      submitPropertyError.value = '';

      // Attach the logged-in seller's identity as the listing creator, per
      // the API guide's creatorId/creatorRole/creatorName/creatorEmail/
      // creatorPhone fields — falls back gracefully if any piece is
      // unavailable rather than blocking submission.
      final id = await SecureStorageService.instance.getSellerMongoId();
      var profile = sellerProfile.value;
      if (profile == null && id != null && id.isNotEmpty) {
        try {
          profile = await _repository.getSellerById(id);
          sellerProfile.value = profile;
        } catch (e) {
          debugPrint('⚠️ submitNewProperty: could not load seller profile: $e');
        }
      }
      final creatorFields = <String, dynamic>{
        if (id != null && id.isNotEmpty) 'creatorId': id,
        'creatorRole': 'Seller',
        if (profile?.name.isNotEmpty ?? false) 'creatorName': profile!.name,
        if (profile?.email.isNotEmpty ?? false) 'creatorEmail': profile!.email,
        if (profile?.phone.isNotEmpty ?? false) 'creatorPhone': profile!.phone,
      };

      final result = await _repository.createProperty(
        fields: {...fields, ...creatorFields},
        images: images,
        floorPlan: floorPlan,
        reraCertificate: reraCertificate,
        video: video,
      );

      submittedProperty.value = result;
      return result;
    } catch (e) {
      submitPropertyError.value = e.toString();
      return null;
    } finally {
      isSubmittingProperty.value = false;
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