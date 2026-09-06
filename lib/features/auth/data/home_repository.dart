import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/models/buer_dashboard_model.dart';
import '../../../core/models/explore_property.dart';
import '../../../core/models/home_feed_model.dart';
import '../../../core/models/near_by_agent.dart';
import '../../../core/models/popular_property.dart';
import '../../../core/models/propertt_category_filter.dart';
import '../../../core/models/property_boosted.dart';
import '../../../core/models/property_new_listing.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/app_logger.dart';

/// Thrown by [HomeRepository] so the UI can show a friendly message.
class HomeFeedException implements Exception {
  HomeFeedException(this.message);
  final String message;

  @override
  String toString() => message;
}

class HomeRepository {
  HomeRepository(this._apiService);

  final ApiService _apiService;

  /// GET /api/v1/home/feed
  Future<HomeFeedModel> getHomeFeed({
    double? latitude,
    double? longitude,
    String? city,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.homeFeed,
        queryParameters: {
          if (latitude != null) 'lat': latitude,
          if (longitude != null) 'lng': longitude,
          if (city != null && city.isNotEmpty) 'city': city,
        },
      );
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        final message = data is Map ? data['message'] : null;
        throw HomeFeedException(
          message is String && message.isNotEmpty ? message : 'Could not load home feed.',
        );
      }
      AppLogger.i('Home feed loaded');
      return HomeFeedModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e, st) {
      AppLogger.e('Home feed request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  /// GET /api/v1/user/dashboard-header
  Future<BuerDashboardModel> getDashboardHeader() async {
    try {
      final response = await _apiService.get(ApiConstants.dashboardHeader);
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        throw HomeFeedException(_messageOrFallback(data, 'Could not load dashboard header.'));
      }
      final innerData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : Map<String, dynamic>.from(data);
      return BuerDashboardModel.fromJson(innerData);
    } on DioException catch (e, st) {
      AppLogger.e('Dashboard header request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  /// GET /api/v1/locations/popular
  Future<PopularProperty> getPopularLocations() async {
    try {
      final response = await _apiService.get(ApiConstants.popularLocations);
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        throw HomeFeedException(_messageOrFallback(data, 'Could not load popular locations.'));
      }
      final innerData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : Map<String, dynamic>.from(data);
      return PopularProperty.fromJson(innerData);
    } on DioException catch (e, st) {
      AppLogger.e('Popular locations request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  /// GET /api/v1/properties/categories
  Future<ProperttCategoryFilter> getPropertyCategoryFilter({
    String? tab,
    String? category,
    double? lat,
    double? lng,
    String? city,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.propertyCategories,
        queryParameters: {
          if (tab != null && tab.isNotEmpty) 'tab': tab,
          if (category != null && category.isNotEmpty) 'category': category,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          if (city != null && city.isNotEmpty) 'city': city,
        },
      );
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        throw HomeFeedException(_messageOrFallback(data, 'Could not load categories.'));
      }
      final innerData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : Map<String, dynamic>.from(data);
      return ProperttCategoryFilter.fromJson(innerData);
    } on DioException catch (e, st) {
      AppLogger.e('Property categories request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  /// GET /api/v1/properties/boosted
  Future<PropertyBoosted> getBoostedPropertiesList() async {
    try {
      final response = await _apiService.get(ApiConstants.boostedProperties);
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        throw HomeFeedException(_messageOrFallback(data, 'Could not load boosted properties.'));
      }
      final innerData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : Map<String, dynamic>.from(data);
      return PropertyBoosted.fromJson(innerData);
    } on DioException catch (e, st) {
      AppLogger.e('Boosted properties request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  /// GET /api/v1/properties/new-listings
  Future<PropertyNewListing> getNewListingsList() async {
    try {
      final response = await _apiService.get(ApiConstants.newListings);
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        throw HomeFeedException(_messageOrFallback(data, 'Could not load new listings.'));
      }
      final innerData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : Map<String, dynamic>.from(data);
      return PropertyNewListing.fromJson(innerData);
    } on DioException catch (e, st) {
      AppLogger.e('New listings request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  /// GET /api/v1/agents/nearby
  Future<NearByAgent> getNearbyAgentsList() async {
    try {
      final response = await _apiService.get(ApiConstants.nearbyAgents);
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        throw HomeFeedException(_messageOrFallback(data, 'Could not load nearby agents.'));
      }
      final innerData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : Map<String, dynamic>.from(data);
      return NearByAgent.fromJson(innerData);
    } on DioException catch (e, st) {
      AppLogger.e('Nearby agents request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  /// GET /api/v1/properties/explore-nearby?propertyId=...&radius=...
  Future<ExploreNearbyData> getExploreNearby({
    required String propertyId,
    int? radius,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.exploreNearby,
        queryParameters: {
          'propertyId': propertyId,
          if (radius != null) 'radius': radius,
        },
      );
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        throw HomeFeedException(_messageOrFallback(data, 'Could not load nearby places.'));
      }
      return ExploreNearbyData.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e, st) {
      AppLogger.e('Explore nearby request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  String _messageOrFallback(dynamic data, String fallback) {
    final message = data is Map ? data['message'] : null;
    return message is String && message.isNotEmpty ? message : fallback;
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    if (e.response?.statusCode == 401) {
      return 'Session expired. Please log in again.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Server is taking longer than usual to respond. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server. Please check your internet connection.';
    }
    return 'Could not load data. Please try again.';
  }
}