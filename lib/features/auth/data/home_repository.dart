import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/models/home_feed_model.dart';
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
  /// The Bearer token is attached automatically by [ApiService]'s
  /// interceptor (it reads whatever was saved at login) — no need to
  /// pass it manually here.
  ///
  /// If [latitude]/[longitude] are omitted, the backend falls back to
  /// the buyer's saved location.
  Future<HomeFeedResponse> getHomeFeed({
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
      return HomeFeedResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e, st) {
      AppLogger.e('Home feed request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  /// GET /api/v1/properties/boosted
  Future<List<HomeProperty>> getBoostedProperties() =>
      _getPropertyList(ApiConstants.boostedProperties, fallback: 'Could not load boosted properties.');

  /// GET /api/v1/properties/new-listings
  Future<List<HomeProperty>> getNewListings() =>
      _getPropertyList(ApiConstants.newListings, fallback: 'Could not load new listings.');

  /// GET /api/v1/agents/nearby
  Future<List<NearbyAgent>> getNearbyAgents() async {
    try {
      final response = await _apiService.get(ApiConstants.nearbyAgents);
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        throw HomeFeedException(_messageOrFallback(data, 'Could not load nearby agents.'));
      }
      return parseNearbyAgents(Map<String, dynamic>.from(data));
    } on DioException catch (e, st) {
      AppLogger.e('Nearby agents request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  /// GET /api/v1/properties/explore-nearby?propertyId=...&radius=...
  Future<ExploreNearbyResponse> getExploreNearby({
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
      return ExploreNearbyResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e, st) {
      AppLogger.e('Explore nearby request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  /// GET /api/v1/properties/categories?tab=Buy|Rent|Plot|Commercial
  Future<PropertyCategoriesResponse> getPropertyCategories({String? tab}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.propertyCategories,
        queryParameters: {if (tab != null && tab.isNotEmpty) 'tab': tab},
      );
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        throw HomeFeedException(_messageOrFallback(data, 'Could not load categories.'));
      }
      return PropertyCategoriesResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e, st) {
      AppLogger.e('Property categories request failed', e, st);
      throw HomeFeedException(_extractMessage(e));
    }
  }

  Future<List<HomeProperty>> _getPropertyList(String path, {required String fallback}) async {
    try {
      final response = await _apiService.get(path);
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        throw HomeFeedException(_messageOrFallback(data, fallback));
      }
      return parsePropertyList(Map<String, dynamic>.from(data));
    } on DioException catch (e, st) {
      AppLogger.e('$path request failed', e, st);
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
    return 'Could not load home feed. Please try again.';
  }
}
