/// Models for `GET /api/v1/home/feed` — the buyer home screen feed.
/// Backend source: DigiNiwas Frontend API Integration doc, section 2 (Home Feed).
class HomeFeedResponse {
  final HomeLocation? location;
  final int bannersCount;
  final int recommendedPropertiesCount;
  final int boostedPropertiesCount;
  final int newListingsCount;
  final int popularAreasCount;
  final int agentsCount;
  final HomeProperty? firstRecommendedProperty;
  final List<HomePopularArea> popularAreas;

  HomeFeedResponse({
    this.location,
    this.bannersCount = 0,
    this.recommendedPropertiesCount = 0,
    this.boostedPropertiesCount = 0,
    this.newListingsCount = 0,
    this.popularAreasCount = 0,
    this.agentsCount = 0,
    this.firstRecommendedProperty,
    this.popularAreas = const [],
  });

  factory HomeFeedResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?) ?? const {};
    return HomeFeedResponse(
      location: data['location'] != null
          ? HomeLocation.fromJson(Map<String, dynamic>.from(data['location'] as Map))
          : null,
      bannersCount: (data['bannersCount'] as num?)?.toInt() ?? 0,
      recommendedPropertiesCount: (data['recommendedPropertiesCount'] as num?)?.toInt() ?? 0,
      boostedPropertiesCount: (data['boostedPropertiesCount'] as num?)?.toInt() ?? 0,
      newListingsCount: (data['newListingsCount'] as num?)?.toInt() ?? 0,
      popularAreasCount: (data['popularAreasCount'] as num?)?.toInt() ?? 0,
      agentsCount: (data['agentsCount'] as num?)?.toInt() ?? 0,
      firstRecommendedProperty: data['firstRecommendedProperty'] != null
          ? HomeProperty.fromJson(Map<String, dynamic>.from(data['firstRecommendedProperty'] as Map))
          : null,
      popularAreas: data['popularAreas'] != null
          ? List<HomePopularArea>.from(
              (data['popularAreas'] as List)
                  .map((x) => HomePopularArea.fromJson(Map<String, dynamic>.from(x as Map))))
          : const [],
    );
  }
}

class HomeLocation {
  final String? source;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? country;
  final String? address;

  HomeLocation({
    this.source,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.country,
    this.address,
  });

  factory HomeLocation.fromJson(Map<String, dynamic> json) {
    return HomeLocation(
      source: json['source'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      address: json['address'] as String?,
    );
  }

  /// e.g. "Andheri West, Mumbai" — falls back gracefully if some parts
  /// are missing.
  String get displayLabel {
    final parts = [city, state].where((e) => e != null && e.isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(', ');
    return address ?? '';
  }
}

class HomePropertyImage {
  final String? url;
  final String? publicId;

  HomePropertyImage({this.url, this.publicId});

  factory HomePropertyImage.fromJson(Map<String, dynamic> json) {
    return HomePropertyImage(
      url: json['url'] as String?,
      publicId: json['public_id'] as String?,
    );
  }
}

class HomeProperty {
  final String? id;
  final String? propertyId;
  final String? title;
  final String? transactionType;
  final String? category;
  final num? price;
  final num? pricePerSqft;
  final String? city;
  final String? locality;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? bedrooms;
  final String? bathrooms;
  final String? furnishing;
  final List<HomePropertyImage> images;
  final double? distanceKm;
  final bool? sameCity;
  final String? listedAgo;

  HomeProperty({
    this.id,
    this.propertyId,
    this.title,
    this.transactionType,
    this.category,
    this.price,
    this.pricePerSqft,
    this.city,
    this.locality,
    this.address,
    this.latitude,
    this.longitude,
    this.bedrooms,
    this.bathrooms,
    this.furnishing,
    this.images = const [],
    this.distanceKm,
    this.sameCity,
    this.listedAgo,
  });

  factory HomeProperty.fromJson(Map<String, dynamic> json) {
    return HomeProperty(
      id: json['_id'] as String?,
      propertyId: json['propertyId'] as String?,
      title: json['title'] as String?,
      transactionType: json['transactionType'] as String?,
      category: json['category'] as String?,
      price: json['price'] as num?,
      pricePerSqft: json['pricePerSqft'] as num?,
      city: json['city'] as String?,
      locality: json['locality'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      bedrooms: json['bedrooms']?.toString(),
      bathrooms: json['bathrooms']?.toString(),
      furnishing: json['furnishing'] as String?,
      images: json['images'] != null
          ? List<HomePropertyImage>.from(
              (json['images'] as List).map((x) => HomePropertyImage.fromJson(Map<String, dynamic>.from(x as Map))))
          : const [],
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      sameCity: json['sameCity'] as bool?,
      listedAgo: json['listedAgo'] as String?,
    );
  }

  String get thumbnailUrl => images.isNotEmpty ? (images.first.url ?? '') : '';

  String get bhkLabel {
    if (bedrooms == null || bedrooms!.isEmpty) return '';
    final lower = (category ?? '').toLowerCase();
    if (lower.contains('residential')) return '$bedrooms BHK';
    return '$bedrooms Bed';
  }

  String get displayAddress {
    final parts = [locality, city].where((e) => e != null && e.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : (address ?? '');
  }

  String get formattedPrice {
    final p = price;
    if (p == null) return '';
    if (p >= 10000000) return '₹${(p / 10000000).toStringAsFixed(p % 10000000 == 0 ? 0 : 2)} Cr';
    if (p >= 100000) return '₹${(p / 100000).toStringAsFixed(p % 100000 == 0 ? 0 : 2)} L';
    return '₹$p';
  }

  String get statusLabel => transactionType == 'Rent' ? 'For Rent' : 'Ready to Move';
}

class HomePopularAreaProperty {
  final String? mongoId;
  final String? propertyId;
  final String? title;
  final num? price;

  HomePopularAreaProperty({this.mongoId, this.propertyId, this.title, this.price});

  factory HomePopularAreaProperty.fromJson(Map<String, dynamic> json) {
    return HomePopularAreaProperty(
      mongoId: (json['mongoId'] ?? json['_id']) as String?,
      propertyId: json['propertyId'] as String?,
      title: json['title'] as String?,
      price: json['price'] as num?,
    );
  }
}

class HomePopularArea {
  final String? city;
  final String? locality;
  final int propertyCount;
  final String? image;
  final List<HomePopularAreaProperty> properties;

  HomePopularArea({
    this.city,
    this.locality,
    this.propertyCount = 0,
    this.image,
    this.properties = const [],
  });

  factory HomePopularArea.fromJson(Map<String, dynamic> json) {
    return HomePopularArea(
      city: json['city'] as String?,
      locality: json['locality'] as String?,
      propertyCount: (json['propertyCount'] as num?)?.toInt() ?? 0,
      image: json['image'] as String?,
      properties: json['properties'] != null
          ? List<HomePopularAreaProperty>.from(
              (json['properties'] as List)
                  .map((x) => HomePopularAreaProperty.fromJson(Map<String, dynamic>.from(x as Map))))
          : const [],
    );
  }

  String get label => [locality, city].where((e) => e != null && e.isNotEmpty).join(', ');
}

/// GET /api/v1/properties/boosted -> data.properties
/// GET /api/v1/properties/new-listings -> data.properties (each item also
/// carries `listedAgo`, already modeled on [HomeProperty]).
List<HomeProperty> parsePropertyList(Map<String, dynamic> json) {
  final data = (json['data'] as Map?) ?? const {};
  final list = data['properties'];
  if (list is! List) return const [];
  return list
      .map((x) => HomeProperty.fromJson(Map<String, dynamic>.from(x as Map)))
      .toList();
}

/// GET /api/v1/agents/nearby -> data.agents[]
class NearbyAgent {
  final String? id;
  final String? partnerId;
  final String? name;
  final String? accountType;
  final String? role;
  final String? city;
  final String? state;
  final bool? isVerified;
  final double? distanceKm;
  final bool? sameCity;
  final bool boost;
  final bool featured;

  NearbyAgent({
    this.id,
    this.partnerId,
    this.name,
    this.accountType,
    this.role,
    this.city,
    this.state,
    this.isVerified,
    this.distanceKm,
    this.sameCity,
    this.boost = false,
    this.featured = false,
  });

  factory NearbyAgent.fromJson(Map<String, dynamic> json) {
    final location = (json['location'] as Map?) ?? const {};
    final promotion = (json['promotion'] as Map?) ?? const {};
    return NearbyAgent(
      id: json['_id'] as String?,
      partnerId: json['partnerId'] as String?,
      name: json['name'] as String?,
      accountType: json['accountType'] as String?,
      role: json['role'] as String?,
      city: location['city'] as String?,
      state: location['state'] as String?,
      isVerified: json['isVerified'] as bool?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      sameCity: json['sameCity'] as bool?,
      boost: promotion['boost'] == true,
      featured: promotion['featured'] == true,
    );
  }

  String get displayLocation =>
      [city, state].where((e) => e != null && e.isNotEmpty).join(', ');

  /// e.g. "Agency Owner", "Sub Agent", "Partner" from raw snake/camel values.
  String get roleLabel {
    final source = (accountType ?? role ?? '').replaceAll('_', ' ').trim();
    if (source.isEmpty) return 'Agent';
    return source
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

List<NearbyAgent> parseNearbyAgents(Map<String, dynamic> json) {
  final data = (json['data'] as Map?) ?? const {};
  final list = data['agents'];
  if (list is! List) return const [];
  return list
      .map((x) => NearbyAgent.fromJson(Map<String, dynamic>.from(x as Map)))
      .toList();
}

/// GET /api/v1/properties/explore-nearby -> data.map.markers[]
class ExploreMarker {
  final String? id;
  final String? markerType;
  final String? name;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final String? mapUrl;
  final String? directionsUrl;

  ExploreMarker({
    this.id,
    this.markerType,
    this.name,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    this.mapUrl,
    this.directionsUrl,
  });

  factory ExploreMarker.fromJson(Map<String, dynamic> json) {
    return ExploreMarker(
      id: json['id'] as String?,
      markerType: json['markerType'] as String?,
      name: json['name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      mapUrl: json['mapUrl'] as String?,
      directionsUrl: json['directionsUrl'] as String?,
    );
  }
}

/// GET /api/v1/properties/explore-nearby -> full response
class ExploreNearbyResponse {
  final double centerLatitude;
  final double centerLongitude;
  final double zoom;
  final int markerCount;
  final List<ExploreMarker> markers;
  final Map<String, int> amenityCounts;
  final String? propertyTitle;
  final String? propertyLocality;
  final String? propertyCity;

  ExploreNearbyResponse({
    required this.centerLatitude,
    required this.centerLongitude,
    this.zoom = 14,
    this.markerCount = 0,
    this.markers = const [],
    this.amenityCounts = const {},
    this.propertyTitle,
    this.propertyLocality,
    this.propertyCity,
  });

  factory ExploreNearbyResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?) ?? const {};
    final property = (data['property'] as Map?) ?? const {};
    final map = (data['map'] as Map?) ?? const {};
    final center = (map['center'] as Map?) ?? const {};
    final markersList = map['markers'];
    final amenityCountsRaw = (data['amenityCounts'] as Map?) ?? const {};
    return ExploreNearbyResponse(
      centerLatitude: (center['latitude'] as num?)?.toDouble() ??
          (property['latitude'] as num?)?.toDouble() ??
          0,
      centerLongitude: (center['longitude'] as num?)?.toDouble() ??
          (property['longitude'] as num?)?.toDouble() ??
          0,
      zoom: (map['zoom'] as num?)?.toDouble() ?? 14,
      markerCount: (map['markerCount'] as num?)?.toInt() ?? 0,
      markers: markersList is List
          ? markersList
              .map((x) => ExploreMarker.fromJson(Map<String, dynamic>.from(x as Map)))
              .toList()
          : const [],
      amenityCounts: amenityCountsRaw.map((k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0)),
      propertyTitle: property['title'] as String?,
      propertyLocality: property['locality'] as String?,
      propertyCity: property['city'] as String?,
    );
  }

  String get areaLabel =>
      [propertyLocality, propertyCity].where((e) => e != null && e.isNotEmpty).join(' & ');
}

/// GET /api/v1/properties/categories -> tabs + category counts (used for
/// the Buy/Rent/Plot/Commercial chips).
class PropertyCategoryCount {
  final String? name;
  final int count;
  PropertyCategoryCount({this.name, this.count = 0});

  factory PropertyCategoryCount.fromJson(Map<String, dynamic> json) {
    return PropertyCategoryCount(
      name: json['name'] as String?,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class PropertyCategoriesResponse {
  final List<String> tabs;
  final List<PropertyCategoryCount> categories;
  final List<HomeProperty> properties;

  PropertyCategoriesResponse({
    this.tabs = const [],
    this.categories = const [],
    this.properties = const [],
  });

  factory PropertyCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?) ?? const {};
    final tabsList = data['tabs'];
    final categoriesList = data['categories'];
    final propertiesList = data['properties'];
    return PropertyCategoriesResponse(
      tabs: tabsList is List ? tabsList.map((e) => e.toString()).toList() : const [],
      categories: categoriesList is List
          ? categoriesList
              .map((x) => PropertyCategoryCount.fromJson(Map<String, dynamic>.from(x as Map)))
              .toList()
          : const [],
      properties: propertiesList is List
          ? propertiesList
              .map((x) => HomeProperty.fromJson(Map<String, dynamic>.from(x as Map)))
              .toList()
          : const [],
    );
  }
}
