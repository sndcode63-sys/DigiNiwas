class BuyerResponseModel {
  final bool? success;
  final int? count;
  final List<BuyerModel>? data;

  BuyerResponseModel({
    this.success,
    this.count,
    this.data,
  });

  factory BuyerResponseModel.fromJson(Map<String, dynamic> json) {
    return BuyerResponseModel(
      success: json['success'],
      count: json['count'],
      data: json['data'] != null
          ? List<BuyerModel>.from(json['data'].map((x) => BuyerModel.fromJson(x)))
          : null,
    );
  }
}

class BuyerModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? avatar;
  final LocationModel? location;
  final String? status;
  final PrivacyModel? privacy;
  final bool? isPhoneVerified;
  final String? createdAt;
  final String? updatedAt;
  final String? buyerId;
  final int? v;
  final int? inquiries;
  final int? leads;
  final int? visits;
  final int? savedProperties;

  BuyerModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.avatar,
    this.location,
    this.status,
    this.privacy,
    this.isPhoneVerified,
    this.createdAt,
    this.updatedAt,
    this.buyerId,
    this.v,
    this.inquiries,
    this.leads,
    this.visits,
    this.savedProperties,
  });

  factory BuyerModel.fromJson(Map<String, dynamic> json) {
    return BuyerModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      avatar: json['avatar'],
      location: json['location'] != null ? LocationModel.fromJson(json['location']) : null,
      status: json['status'],
      privacy: json['privacy'] != null ? PrivacyModel.fromJson(json['privacy']) : null,
      isPhoneVerified: json['isPhoneVerified'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      buyerId: json['buyerId'],
      v: json['__v'],
      inquiries: json['inquiries'],
      leads: json['leads'],
      visits: json['visits'],
      savedProperties: json['savedProperties'],
    );
  }
}

class LocationModel {
  final String? city;
  final String? state;
  final String? country;
  final String? address;
  final CoordinatesModel? coordinates;

  LocationModel({
    this.city,
    this.state,
    this.country,
    this.address,
    this.coordinates,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      city: json['city'],
      state: json['state'],
      country: json['country'],
      address: json['address'],
      coordinates: json['coordinates'] != null ? CoordinatesModel.fromJson(json['coordinates']) : null,
    );
  }
}

class CoordinatesModel {
  final String? type;
  final List<double>? coordinates;

  CoordinatesModel({this.type, this.coordinates});

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) {
    return CoordinatesModel(
      type: json['type'],
      coordinates: json['coordinates'] != null ? List<double>.from(json['coordinates'].map((x) => x.toDouble())) : null,
    );
  }
}

class PrivacyModel {
  final bool? contactSharingConsent;
  final bool? privacyNoticeAccepted;
  final String? privacyNoticeAcceptedAt;

  PrivacyModel({
    this.contactSharingConsent,
    this.privacyNoticeAccepted,
    this.privacyNoticeAcceptedAt,
  });

  factory PrivacyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyModel(
      contactSharingConsent: json['contactSharingConsent'],
      privacyNoticeAccepted: json['privacyNoticeAccepted'],
      privacyNoticeAcceptedAt: json['privacyNoticeAcceptedAt'],
    );
  }
}