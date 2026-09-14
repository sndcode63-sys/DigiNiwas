import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:geocoding/geocoding.dart';
import '../models/buyer_dashboard_model.dart';
import '../models/explore_property.dart';
import '../models/home_feed_model.dart';
import '../models/property_category_filter.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/constants/api_constants.dart';
import '../data/home_repository.dart';
import '../models/property_filter_model.dart';
import '../../../core/storage/storage_service.dart';

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
  final Rxn<ProperttCategoryFilter> categoryFilterData = Rxn<ProperttCategoryFilter>();
  final Rxn<ExploreNearbyData> exploreNearby = Rxn<ExploreNearbyData>();

  // Saved properties reactive state
  final RxList<dynamic> savedPropertiesList = <dynamic>[].obs;
  final RxBool savedPropertiesLoading = false.obs;
  // Saved property IDs ka track rakhne ke liye set
  final RxSet<String> savedPropertyIds = <String>{}.obs;

  // Independent loading flags — each secondary section loads on its own.
  final RxBool dashboardLoading = true.obs;
  final RxBool categoryFilterLoading = true.obs;
  final RxBool exploreLoading = true.obs;

  // NOTE: boosted / newListings / popularAreas / agents — ye alag APIs se
  // nahi, sirf `/home/feed` (loadHomeFeed -> homeFeed) se aate hain. UI in
  // sections ke liye `isLoading` (home-feed ka loading state) use karti hai.

  /// Search radius (in meters) used for the Explore Nearby map. Changing
  /// this from the full-screen map re-fetches markers at the new radius.
  final RxInt exploreRadius = 3000.obs;

  // Search reactive state
  final RxList<dynamic> searchResultsList = <dynamic>[].obs;
  final RxBool searchLoading = false.obs;

  // Filter reactive state (GET /api/newproperties/filter)
  final RxList<PfPropertyData> filteredResultsList = <PfPropertyData>[].obs;
  final RxBool filterLoading = false.obs;
  final RxBool isFilterApplied = false.obs;
  final Rxn<PfAppliedFilters> currentAppliedFilters = Rxn<PfAppliedFilters>();
  final RxnString filterError = RxnString();

  /// Buyer's first name, shown in the header greeting/avatar initials.
  final RxString buyerName = 'Guest'.obs;

  /// Selected bottom-navigation tab index.
  final RxInt bottomNavIndex = 0.obs;

  /// Currently active category chip (Buy/Rent/Plot/Commercial), or null.
  final RxnString selectedCategoryTab = RxnString();

  /// Real-time or detected user location for the home header.
  final RxString userCurrentLocation = 'Fetching location...'.obs;

  // Notifications reactive state
  final RxList<dynamic> notificationsList = <dynamic>[].obs;
  final RxInt unreadNotificationsCount = 0.obs;
  final RxBool notificationsLoading = false.obs;

  // User Profile Avatar reactive state (synced across Home and Profile screens)
  final RxString userAvatarLocalPath = ''.obs;
  final RxString userAvatarNetworkUrl = ''.obs;

  // ---------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _loadBuyerNameAndSavedProperties();
    fetchUserLocation();
    loadUserAvatar();
    fetchNotifications();

    // Non-blocking background call for instantaneous smooth UI rendering
    Future.microtask(() {
      loadHomeFeed();
      loadAllApiSections();
    });
  }

  /// GET /properties/search/list?keyword=value
  Future<void> searchProperties(String keyword) async {
    // Agar search box khali ya clear ho gaya hai, toh turant list clear karo
    if (keyword.trim().isEmpty) {
      searchResultsList.clear();
      searchLoading.value = false;
      return;
    }

    searchLoading.value = true;
    try {
      final response = await _apiService.get(
        ApiConstants.searchProperties,
        queryParameters: {'keyword': keyword},
      );
      final data = response.data;
      if (data is Map && data['success'] == true) {
        searchResultsList.value = data['data'] ?? data['properties'] ?? [];
      } else {
        searchResultsList.clear();
      }
    } catch (_) {
      searchResultsList.clear();
    } finally {
      searchLoading.value = false;
    }
  }

  /// GET /api/newproperties/filter
  Future<void> applyPropertyFilters({
    String? city,
    String? category,
    String? transactionType,
    String? status,
    String? propertyVerificationStatus,
    num? minPrice,
    num? maxPrice,
  }) async {
    filterLoading.value = true;
    filterError.value = null;
    try {
      final result = await _homeRepository.getNewPropertiesFilter(
        city: city,
        category: category,
        transactionType: transactionType,
        status: status,
        propertyVerificationStatus: propertyVerificationStatus,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      filteredResultsList.value = result.data ?? result.properties ?? [];
      currentAppliedFilters.value = result.appliedFilters;
      isFilterApplied.value = true;
    } on HomeFeedException catch (e) {
      filteredResultsList.clear();
      filterError.value = e.message;
    } catch (_) {
      filteredResultsList.clear();
      filterError.value = 'Could not apply filters. Try again.';
    } finally {
      filterLoading.value = false;
    }
  }

  /// Clears active filters and returns the screen to its default state.
  void clearPropertyFilters() {
    filteredResultsList.clear();
    currentAppliedFilters.value = null;
    isFilterApplied.value = false;
    filterError.value = null;
  }

  Future<void> _loadBuyerNameAndSavedProperties() async {
    await _loadBuyerName();

    // Buyer ID fetch karke saved properties load karo
    String? buyerId = await StorageService.instance.buyerId;
    if (buyerId == null || buyerId.isEmpty) {
      buyerId = await StorageService.instance.userId;
    }
    if (buyerId == null || buyerId.isEmpty) {
      final raw = await SecureStorageService.instance.getUserData();
      if (raw != null && raw.isNotEmpty) {
        try {
          final user = Map<String, dynamic>.from(jsonDecode(raw) as Map);
          buyerId = user['id']?.toString() ?? user['_id']?.toString() ?? user['buyerId']?.toString();
        } catch (_) {}
      }
    }
    if (buyerId != null && buyerId.isNotEmpty) {
      await fetchSavedProperties(buyerId);
    }
  }

  /// Fetches the user's current city/state from header, feed, local storage,
  /// or live device GPS via [LocationService].
  Future<void> fetchUserLocation() async {
    // 1. Check if dashboardHeader has city
    final headerCity = dashboardHeader.value?.location?.city;
    if (headerCity != null && headerCity.isNotEmpty) {
      final state = dashboardHeader.value?.location?.state ?? '';
      userCurrentLocation.value = state.isNotEmpty ? '$headerCity, $state' : headerCity;
      return;
    }

    // 2. Check if homeFeed has city
    final feedCity = homeFeed.value?.location?.city;
    if (feedCity != null && feedCity.isNotEmpty) {
      final state = homeFeed.value?.location?.state ?? '';
      userCurrentLocation.value = state.isNotEmpty ? '$feedCity, $state' : feedCity;
      return;
    }

    // 3. Check locally persisted location
    try {
      final loc = await StorageService.instance.location;
      if (loc != null && loc['city'] != null && loc['city'].toString().isNotEmpty) {
        final city = loc['city'].toString();
        final state = loc['state']?.toString() ?? '';
        userCurrentLocation.value = state.isNotEmpty ? '$city, $state' : city;
        return;
      }
    } catch (_) {}

    // 4. Try live GPS capture via LocationService
    try {
      final locResult = await LocationService().getCurrentLocation();
      if (locResult.city.isNotEmpty) {
        userCurrentLocation.value = locResult.state.isNotEmpty
            ? '${locResult.city}, ${locResult.state}'
            : locResult.city;
        return;
      }
    } catch (_) {
      // 5. Fallback to last known coordinates
      try {
        final coords = await StorageService.instance.getLastKnownCoordinates();
        if (coords != null) {
          final placemarks = await Geocoding().placemarkFromCoordinates(coords.latitude, coords.longitude);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final city = p.locality ?? p.subAdministrativeArea ?? '';
            final state = p.administrativeArea ?? '';
            if (city.isNotEmpty) {
              userCurrentLocation.value = state.isNotEmpty ? '$city, $state' : city;
              return;
            }
          }
        }
      } catch (_) {}
    }

    // 6. Default fallback if still unresolved
    if (userCurrentLocation.value == 'Fetching location...') {
      userCurrentLocation.value = 'India';
    }
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
    if (homeFeed.value == null) {
      isLoading.value = true;
    }
    error.value = null;
    try {
      final feed = await _homeRepository.getHomeFeed();
      homeFeed.value = feed;
      isLoading.value = false;
      if (userCurrentLocation.value == 'Fetching location...' || userCurrentLocation.value == 'India') {
        final loc = feed.location;
        if (loc?.city != null && loc!.city!.isNotEmpty) {
          userCurrentLocation.value = loc.state?.isNotEmpty == true ? '${loc.city}, ${loc.state}' : loc.city!;
        }
      }
      loadExploreNearby();
    } on HomeFeedException catch (e) {
      error.value = e.message;
      isLoading.value = false;
    } catch (_) {
      error.value = 'Something went wrong while loading the home feed.';
      isLoading.value = false;
    }
  }

  /// Kicks off remaining secondary API calls independently (in parallel).
  /// Boosted / new-listings / popular-areas / nearby-agents ab is function
  /// se call nahi hote — woh sab `homeFeed` (loadHomeFeed) se hi milte hain,
  /// taaki UI aur terminal ka data hamesha same/single-source rahe.
  void loadAllApiSections() {
    loadDashboardHeader();
    loadCategoryFilter();
  }

  /// 2. GET /api/v1/user/dashboard-header
  Future<void> loadDashboardHeader() async {
    dashboardLoading.value = true;
    try {
      final header = await _homeRepository.getDashboardHeader();
      dashboardHeader.value = header;
      dashboardLoading.value = false;
      if (header.location?.city != null && header.location!.city!.isNotEmpty) {
        final loc = header.location!;
        userCurrentLocation.value = loc.state?.isNotEmpty == true ? '${loc.city}, ${loc.state}' : loc.city!;
      }
      if (header.user?.name != null && header.user!.name!.isNotEmpty) {
        buyerName.value = header.user!.name!.split(' ').first;
      }
      if (header.unreadNotificationsCount != null) {
        unreadNotificationsCount.value = header.unreadNotificationsCount!;
      }
      if (header.notifications != null && header.notifications!.isNotEmpty && notificationsList.isEmpty) {
        notificationsList.value = header.notifications!;
      }
      if (header.user?.avatar != null && header.user!.avatar!.isNotEmpty) {
        userAvatarNetworkUrl.value = header.user!.avatar!;
      }
    } catch (_) {
      dashboardLoading.value = false;
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

  /// 8. GET /api/v1/properties/explore-nearby?propertyId=...&radius=...
  /// Pass [radius] (meters) to change the search radius — used by the
  /// full-screen Explore Map's radius chips. Defaults to [exploreRadius].
  Future<void> loadExploreNearby({int? radius}) async {
    final propertyId = homeFeed.value?.recommendedProperties?.first.propertyId;
    if (propertyId == null || propertyId.isEmpty) {
      exploreLoading.value = false;
      return;
    }
    if (radius != null) {
      exploreRadius.value = radius;
    }
    exploreLoading.value = true;
    try {
      exploreNearby.value = await _homeRepository.getExploreNearby(
        propertyId: propertyId,
        radius: exploreRadius.value,
      );
      exploreLoading.value = false;

      // 👇 Yahan call kar dein taaki data aate hi terminal par print ho jaye
      await debugCheckExploreNearby();

    } catch (_) {
      exploreLoading.value = false;
    }
  }
  /// Change the search radius (meters) on the full-screen Explore Map and
  /// re-fetch nearby markers for the currently loaded property.
  Future<void> changeExploreRadius(int radiusMeters) async {
    if (exploreRadius.value == radiusMeters && exploreNearby.value != null) return;
    await loadExploreNearby(radius: radiusMeters);
  }

  // ---------------------------------------------------------------------
  // SAVED PROPERTIES & WISHLIST API INTEGRATIONS
  // ---------------------------------------------------------------------

  /// GET /api/saved-properties/buyer/:buyerId
  Future<void> fetchSavedProperties(String buyerId) async {
    savedPropertiesLoading.value = true;
    try {
      final endpoint = ApiConstants.getBuyerSavedProperties(buyerId);
      final response = await _apiService.get(endpoint);

      final data = response.data;
      if (data is Map && data['success'] == true) {
        final list = data['data'] ?? [];
        savedPropertiesList.value = list;

        savedPropertyIds.clear();
        for (var item in list) {
          final p = item is Map ? item : null;
          if (p == null) continue;
          final propObj = p['property'] is Map ? p['property'] : null;
          final snapObj = p['propertySnapshot'] is Map ? p['propertySnapshot'] : null;

          final candidateIds = [
            propObj?['_id']?.toString(),
            propObj?['id']?.toString(),
            propObj?['propertyId']?.toString(),
            propObj?['propertyCode']?.toString(),
            snapObj?['propertyId']?.toString(),
            snapObj?['_id']?.toString(),
            snapObj?['id']?.toString(),
            snapObj?['propertyCode']?.toString(),
            p['propertyId']?.toString(),
            p['propertyCode']?.toString(),
            p['_id']?.toString(),
            p['id']?.toString(),
          ];

          for (final cid in candidateIds) {
            if (cid != null && cid.isNotEmpty) {
              savedPropertyIds.add(cid);
            }
          }
        }
      }
    } catch (_) {
      savedPropertiesList.clear();
      savedPropertyIds.clear();
    } finally {
      savedPropertiesLoading.value = false;
    }
  }

  /// Toggle save / remove property with instant optimistic UI update
  Future<void> toggleSaveProperty(String buyerId, String propertyId) async {
    final isAlreadySaved = savedPropertyIds.contains(propertyId);

    // 1. OPTIMISTIC UI UPDATE (Makhan jaisa fast)
    if (isAlreadySaved) {
      savedPropertyIds.remove(propertyId);
      savedPropertiesList.removeWhere((item) {
        final pData = (item is Map && item['propertySnapshot'] != null)
            ? item['propertySnapshot']
            : (item is Map && item['property'] != null ? item['property'] : item);
        final pId = pData['propertyId']?.toString() ?? pData['_id']?.toString() ?? item['propertyId']?.toString() ?? '';
        return pId == propertyId;
      });
    } else {
      savedPropertyIds.add(propertyId);
    }

    // 2. Background API Call
    if (isAlreadySaved) {
      try {
        final response = await _apiService.delete(
          ApiConstants.removeSavedProperty(buyerId, propertyId),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar(
            'Removed',
            'Property removed from saved items.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE53935),
            colorText: Colors.white,
            duration: const Duration(seconds: 1),
          );
        }
      } catch (_) {
        await fetchSavedProperties(buyerId);
      }
    } else {
      try {
        final response = await _apiService.post(
          ApiConstants.saveProperty,
          data: {'buyerId': buyerId, 'propertyId': propertyId},
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
        }
        await fetchSavedProperties(buyerId);
      } catch (_) {
        await fetchSavedProperties(buyerId);
      }
    }
  }

  Future<void> savePropertyCall(String buyerId, String propertyId) async {
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
        await fetchSavedProperties(buyerId);
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not save property.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeSavedPropertyCall(String buyerId, String propertyId) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.removeSavedProperty(buyerId, propertyId),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Removed',
          'Property removed from saved items.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
        await fetchSavedProperties(buyerId);
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not remove saved property.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 🧪 Explore Nearby API data ko console par debug / check karne ke liye test method
  Future<void> debugCheckExploreNearby() async {
    debugPrint('EXPLORE_DEBUG: -----------------------------------------');
    debugPrint('EXPLORE_DEBUG: exploreLoading value -> ${exploreLoading.value}');

    final explore = exploreNearby.value;
    if (explore == null) {
      debugPrint('EXPLORE_DEBUG: exploreNearby data is currently NULL or empty.');
    } else {
      debugPrint('EXPLORE_DEBUG: Property Title -> ${explore.property?.title}');
      debugPrint('EXPLORE_DEBUG: Map Center Lat -> ${explore.map?.center?.latitude}');
      debugPrint('EXPLORE_DEBUG: Map Center Lng -> ${explore.map?.center?.longitude}');

      final markers = explore.map?.markers ?? [];
      debugPrint('EXPLORE_DEBUG: Total Markers found -> ${markers.length}');

      for (int i = 0; i < markers.length; i++) {
        final m = markers[i];
        debugPrint('EXPLORE_DEBUG: Marker [$i] -> Name: ${m.name}, Type: ${m.markerType}, Lat: ${m.latitude}, Lng: ${m.longitude}');
      }
    }
    debugPrint('EXPLORE_DEBUG: -----------------------------------------');
  }

  /// Pull-to-refresh: reloads the primary feed, then every secondary section.
  Future<void> refreshAll() async {
    fetchUserLocation();
    loadUserAvatar();
    fetchNotifications();
    await loadHomeFeed();
    loadAllApiSections();
    String? buyerId = await StorageService.instance.buyerId;
    if (buyerId == null || buyerId.isEmpty) {
      buyerId = await StorageService.instance.userId;
    }
    if (buyerId != null && buyerId.isNotEmpty) {
      await fetchSavedProperties(buyerId);
    }
  }

  // ---------------------------------------------------------------------
  // NOTIFICATIONS API INTEGRATIONS
  // ---------------------------------------------------------------------

  Future<void> fetchNotifications() async {
    notificationsLoading.value = true;
    try {
      String? buyerId = await StorageService.instance.buyerId;
      if (buyerId == null || buyerId.isEmpty) {
        buyerId = await StorageService.instance.userId;
      }
      final endpoint = (buyerId != null && buyerId.isNotEmpty)
          ? ApiConstants.userNotifications(buyerId)
          : ApiConstants.notifications;

      try {
        final res = await _apiService.get(endpoint);
        if (res.data is Map && res.data['success'] == true) {
          final list = res.data['data'] ?? res.data['notifications'] ?? [];
          if (list is List) {
            notificationsList.value = list;
            unreadNotificationsCount.value = (res.data['unreadCount'] as num?)?.toInt() ??
                list.where((item) => item is Map && item['isRead'] != true && item['read'] != true).length;
            return;
          }
        }
      } catch (_) {
        try {
          final res = await _apiService.get(ApiConstants.notifications);
          if (res.data is Map && res.data['success'] == true) {
            final list = res.data['data'] ?? res.data['notifications'] ?? [];
            if (list is List) {
              notificationsList.value = list;
              unreadNotificationsCount.value = (res.data['unreadCount'] as num?)?.toInt() ??
                  list.where((item) => item is Map && item['isRead'] != true && item['read'] != true).length;
              return;
            }
          }
        } catch (_) {}
      }

      // Fallback to dashboardHeader notifications
      final dashNotifs = dashboardHeader.value?.notifications;
      if (dashNotifs != null && dashNotifs.isNotEmpty) {
        notificationsList.value = dashNotifs;
        unreadNotificationsCount.value = dashboardHeader.value?.unreadNotificationsCount ??
            dashNotifs.where((item) => item is Map && item['isRead'] != true && item['read'] != true).length;
      }
    } finally {
      notificationsLoading.value = false;
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    for (int i = 0; i < notificationsList.length; i++) {
      if (notificationsList[i] is Map && notificationsList[i]['_id']?.toString() == id) {
        final updated = Map<String, dynamic>.from(notificationsList[i] as Map);
        updated['isRead'] = true;
        updated['read'] = true;
        notificationsList[i] = updated;
        break;
      }
    }
    if (unreadNotificationsCount.value > 0) {
      unreadNotificationsCount.value--;
    }
    try {
      await _apiService.patch(ApiConstants.markNotificationRead(id));
    } catch (_) {}
  }

  Future<void> markAllNotificationsAsRead() async {
    for (int i = 0; i < notificationsList.length; i++) {
      if (notificationsList[i] is Map) {
        final updated = Map<String, dynamic>.from(notificationsList[i] as Map);
        updated['isRead'] = true;
        updated['read'] = true;
        notificationsList[i] = updated;
      }
    }
    unreadNotificationsCount.value = 0;
    try {
      await _apiService.post(ApiConstants.markAllNotificationsRead);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------
  // PROFILE AVATAR MANAGEMENT & SYNC
  // ---------------------------------------------------------------------

  Future<void> loadUserAvatar() async {
    final local = await StorageService.instance.localAvatarPath;
    if (local != null && local.isNotEmpty && File(local).existsSync()) {
      userAvatarLocalPath.value = local;
    }
    final net = dashboardHeader.value?.user?.avatar;
    if (net != null && net.isNotEmpty) {
      userAvatarNetworkUrl.value = net;
    }
  }

  Future<void> updateProfileAvatar(String newPath) async {
    userAvatarLocalPath.value = newPath;
    await StorageService.instance.saveLocalAvatarPath(newPath);
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