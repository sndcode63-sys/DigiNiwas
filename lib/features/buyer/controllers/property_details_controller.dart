import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../data/home_repository.dart';

class PropertyDetailsController extends GetxController {
  PropertyDetailsController({HomeRepository? repository})
      : _homeRepository = repository ?? HomeRepository(ApiService.instance);

  final HomeRepository _homeRepository;

  // Reactive state
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();
  final RxMap<String, dynamic> property = <String, dynamic>{}.obs;
  final RxBool isFavorite = false.obs;
  // Reactive list for similar properties
  final RxList<Map<String, dynamic>> similarProperties = <Map<String, dynamic>>[].obs;
  final RxBool isSimilarLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializePropertyData();
    fetchSimilarProperties();
  }

  void _initializePropertyData() {
    final args = Get.arguments;
    AppLogger.i('PropertyDetailsController received args: $args');

    String? id;

    if (args is Map) {
      if (args.containsKey('property') && args['property'] is Map) {
        property.assignAll(Map<String, dynamic>.from(args['property'] as Map));
        AppLogger.i('Loaded property data directly from arguments: $property');
        isLoading.value = false;
        _recordRecentlyViewed();
        id = property['_id']?.toString() ??
            property['mongoId']?.toString() ??
            property['propertyId']?.toString() ??
            property['propertyCode']?.toString() ??
            property['id']?.toString();
      } else if (args.containsKey('propertyId') || args.containsKey('id')) {
        id = (args['propertyId'] ?? args['id']).toString();
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

    if (id != null && id.isNotEmpty) {
      // Fetch full property details in background or foreground
      fetchPropertyDetailsById(id, silent: property.isNotEmpty);
    }
  }

  /// Locally tracks this property as "recently viewed" (no backend
  /// endpoint exists for this yet — see StorageService.addRecentlyViewedId)
  /// so the Profile screen's "Recently Viewed" stat reflects real
  /// in-app activity instead of a hardcoded number.
  void _recordRecentlyViewed() {
    final id = property['_id']?.toString() ??
        property['propertyId']?.toString() ??
        property['propertyCode']?.toString() ??
        property['id']?.toString() ??
        '';
    if (id.isNotEmpty) {
      StorageService.instance.addRecentlyViewedId(id);
    }
  }

  // Property details load hone ke baad ya onInit mein ise call karein
  Future<void> fetchSimilarProperties() async {
    try {
      isSimilarLoading.value = true;
      final category = property['category']?.toString();
      final city = property['city']?.toString();
      final currentId = property['_id']?.toString() ?? property['propertyId']?.toString() ?? '';

      final results = await _homeRepository.getSimilarProperties(
        category: category,
        city: city,
        currentPropertyId: currentId,
      );

      similarProperties.value = results;
    } catch (e) {
      AppLogger.e('Error loading similar properties: $e');
    } finally {
      isSimilarLoading.value = false;
    }
  }

  /// Backend se property ki exact details ID ke through fetch karne ke liye API call
  Future<void> fetchPropertyDetailsById(String propertyId, {bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
      error.value = null;
    }
    try {
      AppLogger.i('Calling repository to fetch property details for ID: $propertyId');
      final data = await _homeRepository.getPropertyById(propertyId);

      if (data != null && data.isNotEmpty) {
        property.addAll(data);
        AppLogger.i('Successfully fetched property details from API: $property');
        _recordRecentlyViewed();
      } else if (!silent) {
        AppLogger.w('API returned null for property ID: $propertyId');
        error.value = 'Property details not found from server.';
      }
    } catch (e, st) {
      AppLogger.e('Error fetching property details by ID', e, st);
      if (!silent) {
        error.value = 'Failed to load property details. Please try again.';
      }
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
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
    final area = property['sqft'] ?? property['area'] ?? property['superBuiltUpArea'] ?? property['superBuiltupArea'] ?? property['carpetArea'];
    if (area != null) return '$area sq.ft';
    return '';
  }

  String get description => property['description']?.toString() ?? property['about']?.toString() ?? '';

  // Status (e.g. Ready to Move, Under Construction, Active)
  String get status {
    for (final k in ['possessionStatus', 'status', 'constructionStatus', 'propertyStatus', 'verificationStatus']) {
      final s = property[k]?.toString().trim();
      if (s != null && s.isNotEmpty && s.toLowerCase() != 'null') return s;
    }
    return 'Ready to Move';
  }

  bool get hasStatus => status.isNotEmpty;

  // Video Tour (checks multiple possible backend keys)
  String get videoUrl {
    for (final k in ['video', 'videoUrl', 'video_url', 'videoLink', 'videolink', 'video_link']) {
      final v = property[k]?.toString().trim();
      if (v != null && v.isNotEmpty && v.toLowerCase() != 'null') return v;
    }
    return '';
  }

  bool get hasVideo => videoUrl.isNotEmpty;

  // Floor Plan (Image or PDF)
  String get floorPlanUrl {
    for (final k in ['floorPlan', 'floor_plan', 'floorPlanUrl', 'floorplan', 'floorPlanImage']) {
      final fp = property[k]?.toString().trim();
      if (fp != null && fp.isNotEmpty && fp.toLowerCase() != 'null') return fp;
    }
    return '';
  }

  bool get hasFloorPlan => floorPlanUrl.isNotEmpty;

  // RERA Legal Verification
  String get reraCertificateUrl {
    for (final k in ['reraCertificate', 'rera_certificate', 'reraCert', 'reraDoc', 'reraCertificateUrl']) {
      final rc = property[k]?.toString().trim();
      if (rc != null && rc.isNotEmpty && rc.toLowerCase() != 'null') return rc;
    }
    return '';
  }

  String get reraNumber {
    for (final k in ['reraNumber', 'rera_number', 'reraId', 'rera_id', 'reraCode']) {
      final rn = property[k]?.toString().trim();
      if (rn != null && rn.isNotEmpty && rn.toLowerCase() != 'null') return rn;
    }
    return '';
  }

  bool get hasRera => reraCertificateUrl.isNotEmpty || reraNumber.isNotEmpty;

  // Amenities
  List<String> get amenities {
    final raw = property['amenities'];
    if (raw is List) {
      return raw
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
          .toList();
    }
    return [];
  }

  bool get hasAmenities => amenities.isNotEmpty;

  // Coordinates with smart fallback for Google Map container
  double get latitude {
    for (final k in ['latitude', 'lat', 'latLocation']) {
      final v = property[k];
      if (v is num && v != 0) return v.toDouble();
      if (v is String && v.isNotEmpty && v != '0') {
        final d = double.tryParse(v);
        if (d != null && d != 0) return d;
      }
    }
    return _fallbackCityLat();
  }

  double get longitude {
    for (final k in ['longitude', 'lng', 'lon', 'lngLocation']) {
      final v = property[k];
      if (v is num && v != 0) return v.toDouble();
      if (v is String && v.isNotEmpty && v != '0') {
        final d = double.tryParse(v);
        if (d != null && d != 0) return d;
      }
    }
    return _fallbackCityLng();
  }

  double _fallbackCityLat() {
    final c = '${property['city']} ${property['locality']} ${property['address']}'.toLowerCase();
    if (c.contains('ahmedabad')) return 23.0225;
    if (c.contains('mumbai')) return 19.0760;
    if (c.contains('pune')) return 18.5204;
    if (c.contains('bengaluru') || c.contains('bangalore')) return 12.9716;
    if (c.contains('delhi') || c.contains('noida') || c.contains('gurgaon')) return 28.6139;
    if (c.contains('bhopal')) return 23.2599;
    return 22.7196; // Default to Indore
  }

  double _fallbackCityLng() {
    final c = '${property['city']} ${property['locality']} ${property['address']}'.toLowerCase();
    if (c.contains('ahmedabad')) return 72.5714;
    if (c.contains('mumbai')) return 72.8777;
    if (c.contains('pune')) return 73.8567;
    if (c.contains('bengaluru') || c.contains('bangalore')) return 77.5946;
    if (c.contains('delhi') || c.contains('noida') || c.contains('gurgaon')) return 77.2090;
    if (c.contains('bhopal')) return 77.4126;
    return 75.8577; // Default to Indore
  }

  bool get hasCoordinates => true;

  // Tags
  List<String> get tags {
    final raw = property['tags'];
    if (raw is List) {
      return raw
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  bool get hasTags => tags.isNotEmpty;

  // Detailed Specifications (strictly filtered for non-empty values)
  Map<String, String> get specifications {
    final Map<String, String> specs = {};

    void addIfPresent(String label, dynamic value) {
      if (value == null) return;
      final str = value.toString().trim();
      if (str.isNotEmpty && str.toLowerCase() != 'null' && str != '0') {
        specs[label] = str;
      }
    }

    addIfPresent('Status', status);
    addIfPresent('Project', property['projectName']);
    addIfPresent('Developer', property['developerName']);

    final carpet = property['carpetArea'];
    if (carpet != null && carpet.toString().trim() != '0' && carpet.toString().trim().isNotEmpty) {
      specs['Carpet Area'] = '$carpet sq.ft';
    }

    final superBuilt = property['superBuiltupArea'] ?? property['superBuiltUpArea'];
    if (superBuilt != null && superBuilt.toString().trim() != '0' && superBuilt.toString().trim().isNotEmpty) {
      specs['Super Built-up'] = '$superBuilt sq.ft';
    }

    addIfPresent('Bedrooms', property['bedrooms']);
    addIfPresent('Bathrooms', property['bathrooms']);
    addIfPresent('Balconies', property['balconies']);
    addIfPresent('Facing', property['facing']);
    addIfPresent('Furnishing', property['furnishing']);
    addIfPresent('Parking', property['parking']);

    final floor = property['floorNo'];
    final totalFloors = property['totalFloors'];
    if (floor != null && totalFloors != null && totalFloors.toString() != '0') {
      specs['Floor'] = '$floor of $totalFloors';
    } else if (floor != null && floor.toString() != '0') {
      specs['Floor'] = '$floor';
    }

    final maintenance = property['maintenance'];
    if (maintenance != null && maintenance.toString().trim() != '0' && maintenance.toString().trim().isNotEmpty) {
      specs['Maintenance'] = '₹ $maintenance / mo';
    }

    final booking = property['bookingAmount'];
    if (booking != null && booking.toString().trim() != '0' && booking.toString().trim().isNotEmpty) {
      specs['Booking Amount'] = '₹ $booking';
    }

    final ppsf = property['pricePerSqft'];
    if (ppsf != null && ppsf.toString().trim() != '0' && ppsf.toString().trim().isNotEmpty) {
      specs['Price / Sq.Ft'] = '₹ $ppsf';
    }

    return specs;
  }

  bool get hasSpecifications => specifications.isNotEmpty;

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

  Future<void> openExternalUrl(String url) async {
    if (url.trim().isEmpty) return;
    final Uri uri = Uri.parse(url.trim());
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Notice', 'Could not open link', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      AppLogger.e('Failed to launch URL: $url, error: $e');
    }
  }

  Future<void> openGoogleMaps() async {
    if (!hasCoordinates) return;
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      AppLogger.e('Failed to launch maps: $e');
    }
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
    await SharePlus.instance.share(
      ShareParams(
        text: 'Check out this verified property on DigiNiwas!\n\n'
            '🏠 $title\n'
            '📍 Location: $address\n'
            '💰 Price: $priceDisplay\n\n'
            'Download DigiNiwas App for more amazing deals.',
        subject: 'Verified Property on DigiNiwas',
      ),
    );
  }
}