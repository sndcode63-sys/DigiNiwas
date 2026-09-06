import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_logger.dart'; // Ensure app_logger is imported
import '../../features/auth/data/home_repository.dart';

class PropertyDetailsController extends GetxController {
  PropertyDetailsController({HomeRepository? repository})
      : _homeRepository = repository ?? HomeRepository(ApiService.instance);

  final HomeRepository _homeRepository;

  // Reactive state
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();
  final RxMap<String, dynamic> property = <String, dynamic>{}.obs;
  final RxBool isFavorite = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializePropertyData();
  }

  void _initializePropertyData() {
    final args = Get.arguments;
    AppLogger.i('PropertyDetailsController received args: $args');

    if (args is Map) {
      if (args.containsKey('property') && args['property'] is Map) {
        property.value = Map<String, dynamic>.from(args['property'] as Map);
        AppLogger.i('Loaded property data directly from arguments: ${property.value}');
        isLoading.value = false;
      } else if (args.containsKey('propertyId') || args.containsKey('id')) {
        final id = (args['propertyId'] ?? args['id']).toString();
        AppLogger.i('Property ID found in arguments: $id. Fetching from API...');
        fetchPropertyDetailsById(id);
      } else {
        AppLogger.w('Arguments map did not contain property or ID keys.');
        error.value = 'No property information provided.';
        isLoading.value = false;
      }
    } else {
      AppLogger.w('Invalid or null navigation arguments received: $args');
      error.value = 'Invalid navigation arguments.';
      isLoading.value = false;
    }
  }

  /// Backend se property ki exact details ID ke through fetch karne ke liye API call
  Future<void> fetchPropertyDetailsById(String propertyId) async {
    isLoading.value = true;
    error.value = null;
    try {
      AppLogger.i('Calling repository to fetch property details for ID: $propertyId');
      final data = await _homeRepository.getPropertyById(propertyId);

      if (data != null) {
        property.value = data;
        AppLogger.i('Successfully fetched property details from API: ${property.value}');
      } else {
        AppLogger.w('API returned null for property ID: $propertyId');
        error.value = 'Property details not found from server.';
      }
    } catch (e, st) {
      AppLogger.e('Error fetching property details by ID', e, st);
      error.value = 'Failed to load property details. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Pure API-driven getters (No hardcoded dummy strings)
  String get title => property['title'] ?? property['name'] ?? '';

  String get imageUrl {
    final images = property['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map && first['url'] != null) return first['url'].toString();
      if (first is String && first.isNotEmpty) return first;
    }
    return property['image']?.toString() ?? '';
  }

  String get address {
    final locality = property['locality'];
    final city = property['city'];
    final state = property['state'];
    final parts = [locality, city, state].where((e) => e != null && e.toString().trim().isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(', ');
    return property['address']?.toString() ?? '';
  }

  String get priceDisplay {
    final price = property['price'];
    if (price != null) return '₹ $price';
    return property['priceLabel']?.toString() ?? '';
  }

  String get bhkLabel {
    final bedrooms = property['bedrooms'];
    if (bedrooms != null) return '$bedrooms BHK';
    return property['bhk']?.toString() ?? '';
  }

  String get furnishing => property['furnishing']?.toString() ?? property['status']?.toString() ?? '';

  String get sqft {
    final area = property['sqft'] ?? property['area'] ?? property['superBuiltUpArea'];
    if (area != null) return '$area sq.ft';
    return '';
  }

  String get description => property['description']?.toString() ?? property['about']?.toString() ?? '';

  // Actions
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    Get.snackbar(
      isFavorite.value ? 'Saved' : 'Removed',
      isFavorite.value ? 'Property added to saved list!' : 'Property removed from saved list!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F2544),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void open360View() {
    Get.toNamed(
      AppRoutes.panoramaViewer,
      arguments: {
        'imageUrl': property['panorama_action'] ?? property['panorama_image'] ?? imageUrl,
        'title': title,
      },
    );
  }

  Future<void> launchWhatsApp(String phone) async {
    final String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=Hello, I am interested in $title.");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> makePhoneCall(String phone) async {
    final Uri url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> shareProperty() async {
    await Share.share(
      'Check out this verified property on DigiNiwas!\n\n'
          '🏠 $title\n'
          '📍 Location: $address\n'
          '💰 Price: $priceDisplay\n\n'
          'Download DigiNiwas App for more amazing deals.',
    );
  }
}