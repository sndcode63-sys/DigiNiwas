import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/models/buer_dashboard_model.dart';
import '../../../../core/models/explore_property.dart';
import '../../../../core/models/home_feed_model.dart';
import '../../../../core/models/near_by_agent.dart';
import '../../../../core/models/popular_property.dart';
import '../../../../core/models/propertt_category_filter.dart';
import '../../../../core/models/property_boosted.dart';
import '../../../../core/models/property_new_listing.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../features/auth/data/home_repository.dart';

/// GetX controller for the Buyer Home screen and saved properties workflow.
class BuyerHomeController extends GetxController {
  BuyerHomeController({HomeRepository? repository})
      : _homeRepository = repository ?? HomeRepository(ApiService.instance);

  final HomeRepository _homeRepository;
  final ApiService _apiService = ApiService.instance;

  // ---------------------------------------------------------------------
  // REACTIVE STATE
  // ---------------------------------------------------------------------

  /// Primary home-feed loading flag — drives the full-screen shimmer.
  final RxBool isLoading = true.obs;

  /// Error message for the primary home-feed call (null when there's none).
  final RxnString error = RxnString();

  // Data returned by each API endpoint. `Rxn<T>` = nullable reactive value.
  final Rxn<HomeFeedModel> homeFeed = Rxn<HomeFeedModel>();
  final Rxn<BuerDashboardModel> dashboardHeader = Rxn<BuerDashboardModel>();
  final Rxn<PopularProperty> popularLocationsData = Rxn<PopularProperty>();
  final Rxn<ProperttCategoryFilter> categoryFilterData = Rxn<ProperttCategoryFilter>();
  final Rxn<PropertyBoosted> boostedData = Rxn<PropertyBoosted>();
  final Rxn<PropertyNewListing> newListingsData = Rxn<PropertyNewListing>();
  final Rxn<NearByAgent> agentsData = Rxn<NearByAgent>();
  final Rxn<ExploreNearbyData> exploreNearby = Rxn<ExploreNearbyData>();

  // Saved properties reactive state
  final RxList<dynamic> savedPropertiesList = <dynamic>[].obs;
  final RxBool savedPropertiesLoading = false.obs;

  // Independent loading flags — each secondary section loads on its own.
  final RxBool dashboardLoading = true.obs;
  final RxBool popularLoading = true.obs;
  final RxBool categoryFilterLoading = true.obs;
  final RxBool boostedLoading = true.obs;
  final RxBool newListingsLoading = true.obs;
  final RxBool agentsLoading = true.obs;
  final RxBool exploreLoading = true.obs;

  /// Buyer's first name, shown in the header greeting/avatar initials.
  final RxString buyerName = 'Guest'.obs;

  /// Selected bottom-navigation tab index.
  final RxInt bottomNavIndex = 0.obs;

  /// Currently active category chip (Buy/Rent/Plot/Commercial), or null.
  final RxnString selectedCategoryTab = RxnString();

  // ---------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _loadBuyerName();
    loadHomeFeed();
    loadAllApiSections();
  }

  // ---------------------------------------------------------------------
  // LOADERS
  // ---------------------------------------------------------------------

  /// Reads the cached user object from secure storage just to get a name
  /// to show immediately, before the dashboard-header API responds.
  Future<void> _loadBuyerName() async {
    final raw = await SecureStorageService.instance.getUserData();
    if (raw == null || raw.isEmpty) return;
    try {
      final user = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final name = (user['name'] as String?)?.trim();
      if (name != null && name.isNotEmpty) {
        buyerName.value = name.split(' ').first;
      }
    } catch (_) {
      // Ignore malformed cached user data — fall back to "Guest".
    }
  }

  /// 1. GET /api/v1/home/feed — the primary/blocking call for this screen.
  Future<void> loadHomeFeed() async {
    isLoading.value = true;
    error.value = null;
    try {
      final feed = await _homeRepository.getHomeFeed();
      homeFeed.value = feed;
      isLoading.value = false;
      loadExploreNearby();
    } on HomeFeedException catch (e) {
      error.value = e.message;
      isLoading.value = false;
    } catch (_) {
      error.value = 'Something went wrong while loading the home feed.';
      isLoading.value = false;
    }
  }

  /// Kicks off all secondary API calls independently (in parallel).
  void loadAllApiSections() {
    loadDashboardHeader();
    loadPopularLocations();
    loadCategoryFilter();
    loadBoostedProperties();
    loadNewListings();
    loadNearbyAgents();
  }

  /// 2. GET /api/v1/user/dashboard-header
  Future<void> loadDashboardHeader() async {
    dashboardLoading.value = true;
    try {
      final header = await _homeRepository.getDashboardHeader();
      dashboardHeader.value = header;
      dashboardLoading.value = false;
      if (header.user?.name != null && header.user!.name!.isNotEmpty) {
        buyerName.value = header.user!.name!.split(' ').first;
      }
    } catch (_) {
      dashboardLoading.value = false;
    }
  }

  /// 3. GET /api/v1/locations/popular
  Future<void> loadPopularLocations() async {
    popularLoading.value = true;
    try {
      popularLocationsData.value = await _homeRepository.getPopularLocations();
      popularLoading.value = false;
    } catch (_) {
      popularLoading.value = false;
    }
  }

  /// 4. GET /api/v1/properties/categories
  Future<void> loadCategoryFilter({String? tab}) async {
    categoryFilterLoading.value = true;
    selectedCategoryTab.value = tab;
    try {
      categoryFilterData.value = await _homeRepository.getPropertyCategoryFilter(tab: tab);
      categoryFilterLoading.value = false;
    } catch (_) {
      categoryFilterLoading.value = false;
    }
  }

  void clearCategoryFilter() {
    selectedCategoryTab.value = null;
  }

  /// 5. GET /api/v1/properties/boosted
  Future<void> loadBoostedProperties() async {
    boostedLoading.value = true;
    try {
      boostedData.value = await _homeRepository.getBoostedPropertiesList();
      boostedLoading.value = false;
    } catch (_) {
      boostedLoading.value = false;
    }
  }

  /// 6. GET /api/v1/properties/new-listings
  Future<void> loadNewListings() async {
    newListingsLoading.value = true;
    try {
      newListingsData.value = await _homeRepository.getNewListingsList();
      newListingsLoading.value = false;
    } catch (_) {
      newListingsLoading.value = false;
    }
  }

  /// 7. GET /api/v1/agents/nearby
  Future<void> loadNearbyAgents() async {
    agentsLoading.value = true;
    try {
      agentsData.value = await _homeRepository.getNearbyAgentsList();
      agentsLoading.value = false;
    } catch (_) {
      agentsLoading.value = false;
    }
  }

  /// 8. GET /api/v1/properties/explore-nearby?propertyId=...
  Future<void> loadExploreNearby() async {
    final propertyId = homeFeed.value?.recommendedProperties?.first.propertyId;
    if (propertyId == null || propertyId.isEmpty) {
      exploreLoading.value = false;
      return;
    }
    exploreLoading.value = true;
    try {
      exploreNearby.value = await _homeRepository.getExploreNearby(propertyId: propertyId);
      exploreLoading.value = false;
    } catch (_) {
      exploreLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------
  // SAVED PROPERTIES & WISHLIST API INTEGRATIONS
  // ---------------------------------------------------------------------

  /// GET /api/saved-properties/buyer/:buyerId[cite: 1]
  Future<void> fetchSavedProperties(String buyerId) async {
    savedPropertiesLoading.value = true;
    try {
      final response = await _apiService.get('${ApiConstants.getBuyerSavedProperties}/$buyerId');
      final data = response.data;
      if (data is Map && data['success'] == true) {
        savedPropertiesList.value = data['data'] ?? [];
      }
    } catch (_) {
      savedPropertiesList.clear();
    } finally {
      savedPropertiesLoading.value = false;
    }
  }

  /// POST /api/saved-properties[cite: 1]
  Future<void> toggleSaveProperty(String buyerId, String propertyId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.saveProperty,
        data: {
          'buyerId': buyerId,
          'propertyId': propertyId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Property saved successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF007A5E),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
        fetchSavedProperties(buyerId);
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not save property.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Pull-to-refresh: reloads the primary feed, then every secondary section.
  Future<void> refreshAll() async {
    await loadHomeFeed();
    loadAllApiSections();
  }

  // ---------------------------------------------------------------------
  // UI ACTIONS
  // ---------------------------------------------------------------------

  void changeBottomNavIndex(int index) {
    bottomNavIndex.value = index;
  }

  void onCategoryChipTap(String label) {
    if (selectedCategoryTab.value == label) {
      clearCategoryFilter();
    } else {
      loadCategoryFilter(tab: label);
    }
  }

  // ---------------------------------------------------------------------
  // PURE HELPERS
  // ---------------------------------------------------------------------

  String greetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}