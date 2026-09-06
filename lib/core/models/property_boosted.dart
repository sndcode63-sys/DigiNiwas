
// class PropertyBoosted {
//   bool? success;
//   String? message;
//   Data? data;
//
//   PropertyBoosted({this.success, this.message, this.data});
//
//   PropertyBoosted.fromJson(Map<String, dynamic> json) {
//     if(json["success"] is bool) {
//       success = json["success"];
//     }
//     if(json["message"] is String) {
//       message = json["message"];
//     }
//     if(json["data"] is Map) {
//       data = json["data"] == null ? null : Data.fromJson(json["data"]);
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> _data = <String, dynamic>{};
//     _data["success"] = success;
//     _data["message"] = message;
//     if(data != null) {
//       _data["data"] = data?.toJson();
//     }
//     return _data;
//   }
// }

class PropertyBoosted {
  Location? location;
  int? count;
  List<BoostedPropertyItem>? properties;

  PropertyBoosted({this.location, this.count, this.properties});

  PropertyBoosted.fromJson(Map<String, dynamic> json) {
    if(json["location"] is Map) {
      location = json["location"] == null ? null : Location.fromJson(json["location"]);
    }
    if(json["count"] is int) {
      count = json["count"];
    }
    if(json["properties"] is List) {
      properties = (json["properties"] as List)
          .whereType<Map>()
          .map((e) => BoostedPropertyItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(location != null) {
      _data["location"] = location?.toJson();
    }
    _data["count"] = count;
    if(properties != null) {
      _data["properties"] = properties?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class BoostedPropertyItem {
  String? id;
  String? propertyId;
  String? title;
  String? transactionType;
  String? category;
  int? price;
  int? pricePerSqft;
  String? city;
  String? locality;
  String? address;
  double? latitude;
  double? longitude;
  String? bedrooms;
  String? bathrooms;
  String? furnishing;
  List<BoostedImage>? images;
  String? createdAt;
  BoostedPromotion? promotion;
  dynamic distanceKm;
  bool? sameCity;

  BoostedPropertyItem({
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
    this.images,
    this.createdAt,
    this.promotion,
    this.distanceKm,
    this.sameCity,
  });

  BoostedPropertyItem.fromJson(Map<String, dynamic> json) {
    if(json["_id"] is String) {
      id = json["_id"];
    }
    if(json["propertyId"] is String) {
      propertyId = json["propertyId"];
    }
    if(json["title"] is String) {
      title = json["title"];
    }
    if(json["transactionType"] is String) {
      transactionType = json["transactionType"];
    }
    if(json["category"] is String) {
      category = json["category"];
    }
    price = json["price"] is int ? json["price"] : (json["price"] is double ? (json["price"] as double).toInt() : null);
    pricePerSqft = json["pricePerSqft"] is int
        ? json["pricePerSqft"]
        : (json["pricePerSqft"] is double ? (json["pricePerSqft"] as double).toInt() : null);
    if(json["city"] is String) {
      city = json["city"];
    }
    if(json["locality"] is String) {
      locality = json["locality"];
    }
    if(json["address"] is String) {
      address = json["address"];
    }
    latitude = json["latitude"] is num ? (json["latitude"] as num).toDouble() : null;
    longitude = json["longitude"] is num ? (json["longitude"] as num).toDouble() : null;
    bedrooms = json["bedrooms"]?.toString();
    bathrooms = json["bathrooms"]?.toString();
    if(json["furnishing"] is String) {
      furnishing = json["furnishing"];
    }
    if(json["images"] is List) {
      images = (json["images"] as List)
          .whereType<Map>()
          .map((e) => BoostedImage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if(json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
    if(json["promotion"] is Map) {
      promotion = BoostedPromotion.fromJson(Map<String, dynamic>.from(json["promotion"]));
    }
    distanceKm = json["distanceKm"];
    if(json["sameCity"] is bool) {
      sameCity = json["sameCity"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["propertyId"] = propertyId;
    _data["title"] = title;
    _data["transactionType"] = transactionType;
    _data["category"] = category;
    _data["price"] = price;
    _data["pricePerSqft"] = pricePerSqft;
    _data["city"] = city;
    _data["locality"] = locality;
    _data["address"] = address;
    _data["latitude"] = latitude;
    _data["longitude"] = longitude;
    _data["bedrooms"] = bedrooms;
    _data["bathrooms"] = bathrooms;
    _data["furnishing"] = furnishing;
    if(images != null) {
      _data["images"] = images?.map((e) => e.toJson()).toList();
    }
    _data["createdAt"] = createdAt;
    if(promotion != null) {
      _data["promotion"] = promotion?.toJson();
    }
    _data["distanceKm"] = distanceKm;
    _data["sameCity"] = sameCity;
    return _data;
  }
}

class BoostedImage {
  String? url;
  String? publicId;
  String? id;

  BoostedImage({this.url, this.publicId, this.id});

  BoostedImage.fromJson(Map<String, dynamic> json) {
    if(json["url"] is String) {
      url = json["url"];
    }
    if(json["public_id"] is String) {
      publicId = json["public_id"];
    }
    if(json["_id"] is String) {
      id = json["_id"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["url"] = url;
    _data["public_id"] = publicId;
    _data["_id"] = id;
    return _data;
  }
}

class BoostedPromotion {
  bool? boost;
  bool? featured;
  bool? localityTop;
  bool? sponsored;
  int? score;

  BoostedPromotion({this.boost, this.featured, this.localityTop, this.sponsored, this.score});

  BoostedPromotion.fromJson(Map<String, dynamic> json) {
    if(json["boost"] is bool) {
      boost = json["boost"];
    }
    if(json["featured"] is bool) {
      featured = json["featured"];
    }
    if(json["localityTop"] is bool) {
      localityTop = json["localityTop"];
    }
    if(json["sponsored"] is bool) {
      sponsored = json["sponsored"];
    }
    if(json["score"] is int) {
      score = json["score"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["boost"] = boost;
    _data["featured"] = featured;
    _data["localityTop"] = localityTop;
    _data["sponsored"] = sponsored;
    _data["score"] = score;
    return _data;
  }
}

class Location {
  String? source;
  dynamic latitude;
  dynamic longitude;
  String? city;
  String? state;
  String? country;
  String? address;

  Location({this.source, this.latitude, this.longitude, this.city, this.state, this.country, this.address});

  Location.fromJson(Map<String, dynamic> json) {
    if(json["source"] is String) {
      source = json["source"];
    }
    latitude = json["latitude"];
    longitude = json["longitude"];
    if(json["city"] is String) {
      city = json["city"];
    }
    if(json["state"] is String) {
      state = json["state"];
    }
    if(json["country"] is String) {
      country = json["country"];
    }
    if(json["address"] is String) {
      address = json["address"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["source"] = source;
    _data["latitude"] = latitude;
    _data["longitude"] = longitude;
    _data["city"] = city;
    _data["state"] = state;
    _data["country"] = country;
    _data["address"] = address;
    return _data;
  }
}