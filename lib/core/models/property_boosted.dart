
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
  List<dynamic>? properties;

  PropertyBoosted({this.location, this.count, this.properties});

  PropertyBoosted.fromJson(Map<String, dynamic> json) {
    if(json["location"] is Map) {
      location = json["location"] == null ? null : Location.fromJson(json["location"]);
    }
    if(json["count"] is int) {
      count = json["count"];
    }
    if(json["properties"] is List) {
      properties = json["properties"] ?? [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(location != null) {
      _data["location"] = location?.toJson();
    }
    _data["count"] = count;
    if(properties != null) {
      _data["properties"] = properties;
    }
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