
// class PropertyCateforyFiter {
//   bool? success;
//   String? message;
//   Data? data;
//
//   PropertyCateforyFiter({this.success, this.message, this.data});
//
//   PropertyCateforyFiter.fromJson(Map<String, dynamic> json) {
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

class ProperttCategoryFilter {
  Location? location;
  List<String>? tabs;
  List<Categories>? categories;
  Selected? selected;
  List<Properties>? properties;

  ProperttCategoryFilter({this.location, this.tabs, this.categories, this.selected, this.properties});

  ProperttCategoryFilter.fromJson(Map<String, dynamic> json) {
    if(json["location"] is Map) {
      location = json["location"] == null ? null : Location.fromJson(json["location"]);
    }
    if(json["tabs"] is List) {
      tabs = json["tabs"] == null ? null : List<String>.from(json["tabs"]);
    }
    if(json["categories"] is List) {
      categories = json["categories"] == null ? null : (json["categories"] as List).map((e) => Categories.fromJson(e)).toList();
    }
    if(json["selected"] is Map) {
      selected = json["selected"] == null ? null : Selected.fromJson(json["selected"]);
    }
    if(json["properties"] is List) {
      properties = json["properties"] == null ? null : (json["properties"] as List).map((e) => Properties.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(location != null) {
      _data["location"] = location?.toJson();
    }
    if(tabs != null) {
      _data["tabs"] = tabs;
    }
    if(categories != null) {
      _data["categories"] = categories?.map((e) => e.toJson()).toList();
    }
    if(selected != null) {
      _data["selected"] = selected?.toJson();
    }
    if(properties != null) {
      _data["properties"] = properties?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Properties {
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
  List<Images>? images;
  String? createdAt;
  Promotion? promotion;
  dynamic distanceKm;
  bool? sameCity;

  Properties({this.id, this.propertyId, this.title, this.transactionType, this.category, this.price, this.pricePerSqft, this.city, this.locality, this.address, this.latitude, this.longitude, this.bedrooms, this.bathrooms, this.furnishing, this.images, this.createdAt, this.promotion, this.distanceKm, this.sameCity});

  Properties.fromJson(Map<String, dynamic> json) {
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
    if(json["price"] is int) {
      price = json["price"];
    }
    if(json["pricePerSqft"] is int) {
      pricePerSqft = json["pricePerSqft"];
    }
    if(json["city"] is String) {
      city = json["city"];
    }
    if(json["locality"] is String) {
      locality = json["locality"];
    }
    if(json["address"] is String) {
      address = json["address"];
    }
    if(json["latitude"] is double) {
      latitude = json["latitude"];
    }
    if(json["longitude"] is double) {
      longitude = json["longitude"];
    }
    if(json["bedrooms"] is String) {
      bedrooms = json["bedrooms"];
    }
    if(json["bathrooms"] is String) {
      bathrooms = json["bathrooms"];
    }
    if(json["furnishing"] is String) {
      furnishing = json["furnishing"];
    }
    if(json["images"] is List) {
      images = json["images"] == null ? null : (json["images"] as List).map((e) => Images.fromJson(e)).toList();
    }
    if(json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
    if(json["promotion"] is Map) {
      promotion = json["promotion"] == null ? null : Promotion.fromJson(json["promotion"]);
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

class Promotion {
  bool? boost;
  bool? featured;
  bool? localityTop;
  bool? sponsored;
  int? score;

  Promotion({this.boost, this.featured, this.localityTop, this.sponsored, this.score});

  Promotion.fromJson(Map<String, dynamic> json) {
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

class Images {
  String? url;
  String? publicId;
  String? id;

  Images({this.url, this.publicId, this.id});

  Images.fromJson(Map<String, dynamic> json) {
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

class Selected {
  dynamic tab;
  dynamic category;

  Selected({this.tab, this.category});

  Selected.fromJson(Map<String, dynamic> json) {
    tab = json["tab"];
    category = json["category"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["tab"] = tab;
    _data["category"] = category;
    return _data;
  }
}

class Categories {
  String? name;
  int? count;

  Categories({this.name, this.count});

  Categories.fromJson(Map<String, dynamic> json) {
    if(json["name"] is String) {
      name = json["name"];
    }
    if(json["count"] is int) {
      count = json["count"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["name"] = name;
    _data["count"] = count;
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