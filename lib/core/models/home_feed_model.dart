
// class HomeFeed {
//   bool? success;
//   String? message;
//   Data? data;
//
//   HomeFeed({this.success, this.message, this.data});
//
//   HomeFeed.fromJson(Map<String, dynamic> json) {
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

class HomeFeedModel {
  Location? location;
  List<Banners>? banners;
  List<RecommendedProperties>? recommendedProperties;
  List<dynamic>? boostedProperties;
  List<NewListings>? newListings;
  List<PopularAreas>? popularAreas;
  List<Agents>? agents;

  HomeFeedModel({this.location, this.banners, this.recommendedProperties, this.boostedProperties, this.newListings, this.popularAreas, this.agents});

  HomeFeedModel.fromJson(Map<String, dynamic> json) {
    if(json["location"] is Map) {
      location = json["location"] == null ? null : Location.fromJson(json["location"]);
    }
    if(json["banners"] is List) {
      banners = json["banners"] == null ? null : (json["banners"] as List).map((e) => Banners.fromJson(e)).toList();
    }
    if(json["recommendedProperties"] is List) {
      recommendedProperties = json["recommendedProperties"] == null ? null : (json["recommendedProperties"] as List).map((e) => RecommendedProperties.fromJson(e)).toList();
    }
    if(json["boostedProperties"] is List) {
      boostedProperties = json["boostedProperties"] ?? [];
    }
    if(json["newListings"] is List) {
      newListings = json["newListings"] == null ? null : (json["newListings"] as List).map((e) => NewListings.fromJson(e)).toList();
    }
    if(json["popularAreas"] is List) {
      popularAreas = json["popularAreas"] == null ? null : (json["popularAreas"] as List).map((e) => PopularAreas.fromJson(e)).toList();
    }
    if(json["agents"] is List) {
      agents = json["agents"] == null ? null : (json["agents"] as List).map((e) => Agents.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(location != null) {
      _data["location"] = location?.toJson();
    }
    if(banners != null) {
      _data["banners"] = banners?.map((e) => e.toJson()).toList();
    }
    if(recommendedProperties != null) {
      _data["recommendedProperties"] = recommendedProperties?.map((e) => e.toJson()).toList();
    }
    if(boostedProperties != null) {
      _data["boostedProperties"] = boostedProperties;
    }
    if(newListings != null) {
      _data["newListings"] = newListings?.map((e) => e.toJson()).toList();
    }
    if(popularAreas != null) {
      _data["popularAreas"] = popularAreas?.map((e) => e.toJson()).toList();
    }
    if(agents != null) {
      _data["agents"] = agents?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Agents {
  String? id;
  String? partnerId;
  String? name;
  String? avatar;
  String? phone;
  String? email;
  String? accountType;
  String? role;
  Business? business;
  Rera? rera;
  Location1? location;
  bool? isVerified;
  Promotion2? promotion;
  dynamic distanceKm;
  bool? sameCity;
  bool? serviceLocalityMatch;
  Contact? contact;

  Agents({this.id, this.partnerId, this.name, this.avatar, this.phone, this.email, this.accountType, this.role, this.business, this.rera, this.location, this.isVerified, this.promotion, this.distanceKm, this.sameCity, this.serviceLocalityMatch, this.contact});

  Agents.fromJson(Map<String, dynamic> json) {
    if(json["_id"] is String) {
      id = json["_id"];
    }
    if(json["partnerId"] is String) {
      partnerId = json["partnerId"];
    }
    if(json["name"] is String) {
      name = json["name"];
    }
    if(json["avatar"] is String) {
      avatar = json["avatar"];
    }
    if(json["phone"] is String) {
      phone = json["phone"];
    }
    if(json["email"] is String) {
      email = json["email"];
    }
    if(json["accountType"] is String) {
      accountType = json["accountType"];
    }
    if(json["role"] is String) {
      role = json["role"];
    }
    if(json["business"] is Map) {
      business = json["business"] == null ? null : Business.fromJson(json["business"]);
    }
    if(json["rera"] is Map) {
      rera = json["rera"] == null ? null : Rera.fromJson(json["rera"]);
    }
    if(json["location"] is Map) {
      location = json["location"] == null ? null : Location1.fromJson(json["location"]);
    }
    if(json["isVerified"] is bool) {
      isVerified = json["isVerified"];
    }
    if(json["promotion"] is Map) {
      promotion = json["promotion"] == null ? null : Promotion2.fromJson(json["promotion"]);
    }
    distanceKm = json["distanceKm"];
    if(json["sameCity"] is bool) {
      sameCity = json["sameCity"];
    }
    if(json["serviceLocalityMatch"] is bool) {
      serviceLocalityMatch = json["serviceLocalityMatch"];
    }
    if(json["contact"] is Map) {
      contact = json["contact"] == null ? null : Contact.fromJson(json["contact"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["partnerId"] = partnerId;
    _data["name"] = name;
    _data["avatar"] = avatar;
    _data["phone"] = phone;
    _data["email"] = email;
    _data["accountType"] = accountType;
    _data["role"] = role;
    if(business != null) {
      _data["business"] = business?.toJson();
    }
    if(rera != null) {
      _data["rera"] = rera?.toJson();
    }
    if(location != null) {
      _data["location"] = location?.toJson();
    }
    _data["isVerified"] = isVerified;
    if(promotion != null) {
      _data["promotion"] = promotion?.toJson();
    }
    _data["distanceKm"] = distanceKm;
    _data["sameCity"] = sameCity;
    _data["serviceLocalityMatch"] = serviceLocalityMatch;
    if(contact != null) {
      _data["contact"] = contact?.toJson();
    }
    return _data;
  }
}

class Contact {
  bool? canCall;
  bool? canChat;
  String? phone;
  String? partnerMongoId;

  Contact({this.canCall, this.canChat, this.phone, this.partnerMongoId});

  Contact.fromJson(Map<String, dynamic> json) {
    if(json["canCall"] is bool) {
      canCall = json["canCall"];
    }
    if(json["canChat"] is bool) {
      canChat = json["canChat"];
    }
    if(json["phone"] is String) {
      phone = json["phone"];
    }
    if(json["partnerMongoId"] is String) {
      partnerMongoId = json["partnerMongoId"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["canCall"] = canCall;
    _data["canChat"] = canChat;
    _data["phone"] = phone;
    _data["partnerMongoId"] = partnerMongoId;
    return _data;
  }
}

class Promotion2 {
  bool? boost;
  bool? featured;
  bool? localityTop;
  List<dynamic>? codes;
  int? score;

  Promotion2({this.boost, this.featured, this.localityTop, this.codes, this.score});

  Promotion2.fromJson(Map<String, dynamic> json) {
    if(json["boost"] is bool) {
      boost = json["boost"];
    }
    if(json["featured"] is bool) {
      featured = json["featured"];
    }
    if(json["localityTop"] is bool) {
      localityTop = json["localityTop"];
    }
    if(json["codes"] is List) {
      codes = json["codes"] ?? [];
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
    if(codes != null) {
      _data["codes"] = codes;
    }
    _data["score"] = score;
    return _data;
  }
}

class Location1 {
  String? city;
  String? state;
  String? country;
  String? address;
  List<dynamic>? serviceLocalities;
  Coordinates? coordinates;

  Location1({this.city, this.state, this.country, this.address, this.serviceLocalities, this.coordinates});

  Location1.fromJson(Map<String, dynamic> json) {
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
    if(json["serviceLocalities"] is List) {
      serviceLocalities = json["serviceLocalities"] ?? [];
    }
    if(json["coordinates"] is Map) {
      coordinates = json["coordinates"] == null ? null : Coordinates.fromJson(json["coordinates"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["city"] = city;
    _data["state"] = state;
    _data["country"] = country;
    _data["address"] = address;
    if(serviceLocalities != null) {
      _data["serviceLocalities"] = serviceLocalities;
    }
    if(coordinates != null) {
      _data["coordinates"] = coordinates?.toJson();
    }
    return _data;
  }
}

class Coordinates {
  String? type;
  List<int>? coordinates;

  Coordinates({this.type, this.coordinates});

  Coordinates.fromJson(Map<String, dynamic> json) {
    if(json["type"] is String) {
      type = json["type"];
    }
    if(json["coordinates"] is List) {
      coordinates = json["coordinates"] == null ? null : List<int>.from(json["coordinates"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["type"] = type;
    if(coordinates != null) {
      _data["coordinates"] = coordinates;
    }
    return _data;
  }
}

class Rera {
  bool? applicable;
  String? state;
  String? verificationStatus;
  String? registrationNumber;
  String? certificateUrl;
  dynamic expiryDate;

  Rera({this.applicable, this.state, this.verificationStatus, this.registrationNumber, this.certificateUrl, this.expiryDate});

  Rera.fromJson(Map<String, dynamic> json) {
    if(json["applicable"] is bool) {
      applicable = json["applicable"];
    }
    if(json["state"] is String) {
      state = json["state"];
    }
    if(json["verificationStatus"] is String) {
      verificationStatus = json["verificationStatus"];
    }
    if(json["registrationNumber"] is String) {
      registrationNumber = json["registrationNumber"];
    }
    if(json["certificateUrl"] is String) {
      certificateUrl = json["certificateUrl"];
    }
    expiryDate = json["expiryDate"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["applicable"] = applicable;
    _data["state"] = state;
    _data["verificationStatus"] = verificationStatus;
    _data["registrationNumber"] = registrationNumber;
    _data["certificateUrl"] = certificateUrl;
    _data["expiryDate"] = expiryDate;
    return _data;
  }
}

class Business {
  String? businessName;
  String? businessType;
  String? gstin;
  String? registrationNumber;
  String? officeAddress;

  Business({this.businessName, this.businessType, this.gstin, this.registrationNumber, this.officeAddress});

  Business.fromJson(Map<String, dynamic> json) {
    if(json["businessName"] is String) {
      businessName = json["businessName"];
    }
    if(json["businessType"] is String) {
      businessType = json["businessType"];
    }
    if(json["gstin"] is String) {
      gstin = json["gstin"];
    }
    if(json["registrationNumber"] is String) {
      registrationNumber = json["registrationNumber"];
    }
    if(json["officeAddress"] is String) {
      officeAddress = json["officeAddress"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["businessName"] = businessName;
    _data["businessType"] = businessType;
    _data["gstin"] = gstin;
    _data["registrationNumber"] = registrationNumber;
    _data["officeAddress"] = officeAddress;
    return _data;
  }
}

class PopularAreas {
  String? city;
  String? locality;
  int? propertyCount;
  String? image;

  PopularAreas({this.city, this.locality, this.propertyCount, this.image});

  PopularAreas.fromJson(Map<String, dynamic> json) {
    if(json["city"] is String) {
      city = json["city"];
    }
    if(json["locality"] is String) {
      locality = json["locality"];
    }
    if(json["propertyCount"] is int) {
      propertyCount = json["propertyCount"];
    }
    if(json["image"] is String) {
      image = json["image"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["city"] = city;
    _data["locality"] = locality;
    _data["propertyCount"] = propertyCount;
    _data["image"] = image;
    return _data;
  }
}

class NewListings {
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
  List<Images1>? images;
  String? createdAt;
  Promotion1? promotion;
  dynamic distanceKm;
  bool? sameCity;

  NewListings({this.id, this.propertyId, this.title, this.transactionType, this.category, this.price, this.pricePerSqft, this.city, this.locality, this.address, this.latitude, this.longitude, this.bedrooms, this.bathrooms, this.furnishing, this.images, this.createdAt, this.promotion, this.distanceKm, this.sameCity});

  NewListings.fromJson(Map<String, dynamic> json) {
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
      images = json["images"] == null ? null : (json["images"] as List).map((e) => Images1.fromJson(e)).toList();
    }
    if(json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
    if(json["promotion"] is Map) {
      promotion = json["promotion"] == null ? null : Promotion1.fromJson(json["promotion"]);
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

class Promotion1 {
  bool? boost;
  bool? featured;
  bool? localityTop;
  bool? sponsored;
  int? score;

  Promotion1({this.boost, this.featured, this.localityTop, this.sponsored, this.score});

  Promotion1.fromJson(Map<String, dynamic> json) {
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

class Images1 {
  String? url;
  String? publicId;
  String? id;

  Images1({this.url, this.publicId, this.id});

  Images1.fromJson(Map<String, dynamic> json) {
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

class RecommendedProperties {
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

  RecommendedProperties({this.id, this.propertyId, this.title, this.transactionType, this.category, this.price, this.pricePerSqft, this.city, this.locality, this.address, this.latitude, this.longitude, this.bedrooms, this.bathrooms, this.furnishing, this.images, this.createdAt, this.promotion, this.distanceKm, this.sameCity});

  RecommendedProperties.fromJson(Map<String, dynamic> json) {
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

class Banners {
  String? type;
  String? image;

  Banners({this.type, this.image});

  Banners.fromJson(Map<String, dynamic> json) {
    if(json["type"] is String) {
      type = json["type"];
    }
    if(json["image"] is String) {
      image = json["image"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["type"] = type;
    _data["image"] = image;
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