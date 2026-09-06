
// class NearByAgent {
//   bool? success;
//   String? message;
//   Data? data;
//
//   NearByAgent({this.success, this.message, this.data});
//
//   NearByAgent.fromJson(Map<String, dynamic> json) {
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

class NearByAgent {
  Location? location;
  int? count;
  List<Agents>? agents;

  NearByAgent({this.location, this.count, this.agents});

  NearByAgent.fromJson(Map<String, dynamic> json) {
    if(json["location"] is Map) {
      location = json["location"] == null ? null : Location.fromJson(json["location"]);
    }
    if(json["count"] is int) {
      count = json["count"];
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
    _data["count"] = count;
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
  Promotion? promotion;
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
      promotion = json["promotion"] == null ? null : Promotion.fromJson(json["promotion"]);
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

class Promotion {
  bool? boost;
  bool? featured;
  bool? localityTop;
  List<dynamic>? codes;
  int? score;

  Promotion({this.boost, this.featured, this.localityTop, this.codes, this.score});

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