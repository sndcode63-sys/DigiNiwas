class requestVisitModel {
  bool? success;
  String? message;
  Data? data;

  requestVisitModel({this.success, this.message, this.data});

  requestVisitModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? visitId;
  String? propertyId;
  String? buyerId;
  String? partnerId;
  Null? leadId;
  BuyerSnapshot? buyerSnapshot;
  PropertySnapshot? propertySnapshot;
  PartnerSnapshot? partnerSnapshot;
  String? requestedVisitAt;
  Null? approvedVisitAt;
  Null? completedAt;
  String? requestSource;
  Null? teamOwnerId;
  String? teamApprovalStatus;
  String? teamRemarks;
  String? forwardedToAdminAt;
  String? approvalStatus;
  String? status;
  String? outcome;
  String? requestNotes;
  String? adminRemarks;
  String? partnerRemarks;
  Null? followUpAt;
  String? rescheduleReason;
  String? cancellationReason;
  RequestedBy? requestedBy;
  ApprovedBy? approvedBy;
  List<History>? history;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.visitId,
        this.propertyId,
        this.buyerId,
        this.partnerId,
        this.leadId,
        this.buyerSnapshot,
        this.propertySnapshot,
        this.partnerSnapshot,
        this.requestedVisitAt,
        this.approvedVisitAt,
        this.completedAt,
        this.requestSource,
        this.teamOwnerId,
        this.teamApprovalStatus,
        this.teamRemarks,
        this.forwardedToAdminAt,
        this.approvalStatus,
        this.status,
        this.outcome,
        this.requestNotes,
        this.adminRemarks,
        this.partnerRemarks,
        this.followUpAt,
        this.rescheduleReason,
        this.cancellationReason,
        this.requestedBy,
        this.approvedBy,
        this.history,
        this.sId,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    visitId = json['visitId'];
    propertyId = json['propertyId'];
    buyerId = json['buyerId'];
    partnerId = json['partnerId'];
    leadId = json['leadId'];
    buyerSnapshot = json['buyerSnapshot'] != null
        ? new BuyerSnapshot.fromJson(json['buyerSnapshot'])
        : null;
    propertySnapshot = json['propertySnapshot'] != null
        ? new PropertySnapshot.fromJson(json['propertySnapshot'])
        : null;
    partnerSnapshot = json['partnerSnapshot'] != null
        ? new PartnerSnapshot.fromJson(json['partnerSnapshot'])
        : null;
    requestedVisitAt = json['requestedVisitAt'];
    approvedVisitAt = json['approvedVisitAt'];
    completedAt = json['completedAt'];
    requestSource = json['requestSource'];
    teamOwnerId = json['teamOwnerId'];
    teamApprovalStatus = json['teamApprovalStatus'];
    teamRemarks = json['teamRemarks'];
    forwardedToAdminAt = json['forwardedToAdminAt'];
    approvalStatus = json['approvalStatus'];
    status = json['status'];
    outcome = json['outcome'];
    requestNotes = json['requestNotes'];
    adminRemarks = json['adminRemarks'];
    partnerRemarks = json['partnerRemarks'];
    followUpAt = json['followUpAt'];
    rescheduleReason = json['rescheduleReason'];
    cancellationReason = json['cancellationReason'];
    requestedBy = json['requestedBy'] != null
        ? new RequestedBy.fromJson(json['requestedBy'])
        : null;
    approvedBy = json['approvedBy'] != null
        ? new ApprovedBy.fromJson(json['approvedBy'])
        : null;
    if (json['history'] != null) {
      history = <History>[];
      json['history'].forEach((v) {
        history!.add(new History.fromJson(v));
      });
    }
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['visitId'] = this.visitId;
    data['propertyId'] = this.propertyId;
    data['buyerId'] = this.buyerId;
    data['partnerId'] = this.partnerId;
    data['leadId'] = this.leadId;
    if (this.buyerSnapshot != null) {
      data['buyerSnapshot'] = this.buyerSnapshot!.toJson();
    }
    if (this.propertySnapshot != null) {
      data['propertySnapshot'] = this.propertySnapshot!.toJson();
    }
    if (this.partnerSnapshot != null) {
      data['partnerSnapshot'] = this.partnerSnapshot!.toJson();
    }
    data['requestedVisitAt'] = this.requestedVisitAt;
    data['approvedVisitAt'] = this.approvedVisitAt;
    data['completedAt'] = this.completedAt;
    data['requestSource'] = this.requestSource;
    data['teamOwnerId'] = this.teamOwnerId;
    data['teamApprovalStatus'] = this.teamApprovalStatus;
    data['teamRemarks'] = this.teamRemarks;
    data['forwardedToAdminAt'] = this.forwardedToAdminAt;
    data['approvalStatus'] = this.approvalStatus;
    data['status'] = this.status;
    data['outcome'] = this.outcome;
    data['requestNotes'] = this.requestNotes;
    data['adminRemarks'] = this.adminRemarks;
    data['partnerRemarks'] = this.partnerRemarks;
    data['followUpAt'] = this.followUpAt;
    data['rescheduleReason'] = this.rescheduleReason;
    data['cancellationReason'] = this.cancellationReason;
    if (this.requestedBy != null) {
      data['requestedBy'] = this.requestedBy!.toJson();
    }
    if (this.approvedBy != null) {
      data['approvedBy'] = this.approvedBy!.toJson();
    }
    if (this.history != null) {
      data['history'] = this.history!.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class BuyerSnapshot {
  String? buyerCode;
  String? name;
  String? phone;
  String? email;
  String? city;

  BuyerSnapshot({this.buyerCode, this.name, this.phone, this.email, this.city});

  BuyerSnapshot.fromJson(Map<String, dynamic> json) {
    buyerCode = json['buyerCode'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['buyerCode'] = this.buyerCode;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['city'] = this.city;
    return data;
  }
}

class PropertySnapshot {
  String? propertyCode;
  String? title;
  String? projectName;
  String? category;
  String? city;
  String? locality;
  String? address;
  String? image;
  double? latitude;
  double? longitude;

  PropertySnapshot(
      {this.propertyCode,
        this.title,
        this.projectName,
        this.category,
        this.city,
        this.locality,
        this.address,
        this.image,
        this.latitude,
        this.longitude});

  PropertySnapshot.fromJson(Map<String, dynamic> json) {
    propertyCode = json['propertyCode'];
    title = json['title'];
    projectName = json['projectName'];
    category = json['category'];
    city = json['city'];
    locality = json['locality'];
    address = json['address'];
    image = json['image'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['propertyCode'] = this.propertyCode;
    data['title'] = this.title;
    data['projectName'] = this.projectName;
    data['category'] = this.category;
    data['city'] = this.city;
    data['locality'] = this.locality;
    data['address'] = this.address;
    data['image'] = this.image;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}

class PartnerSnapshot {
  String? partnerCode;
  String? name;
  String? phone;
  String? email;
  String? partnerType;

  PartnerSnapshot(
      {this.partnerCode, this.name, this.phone, this.email, this.partnerType});

  PartnerSnapshot.fromJson(Map<String, dynamic> json) {
    partnerCode = json['partnerCode'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    partnerType = json['partnerType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['partnerCode'] = this.partnerCode;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['partnerType'] = this.partnerType;
    return data;
  }
}

class RequestedBy {
  String? userId;
  String? name;
  String? role;

  RequestedBy({this.userId, this.name, this.role});

  RequestedBy.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['role'] = this.role;
    return data;
  }
}

class ApprovedBy {
  Null? userId;
  String? name;
  String? role;
  Null? approvedAt;

  ApprovedBy({this.userId, this.name, this.role, this.approvedAt});

  ApprovedBy.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    role = json['role'];
    approvedAt = json['approvedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['role'] = this.role;
    data['approvedAt'] = this.approvedAt;
    return data;
  }
}

class History {
  String? action;
  String? fromStatus;
  String? toStatus;
  String? remarks;
  RequestedBy? updatedBy;
  String? sId;
  String? updatedAt;

  History(
      {this.action,
        this.fromStatus,
        this.toStatus,
        this.remarks,
        this.updatedBy,
        this.sId,
        this.updatedAt});

  History.fromJson(Map<String, dynamic> json) {
    action = json['action'];
    fromStatus = json['fromStatus'];
    toStatus = json['toStatus'];
    remarks = json['remarks'];
    updatedBy = json['updatedBy'] != null
        ? new RequestedBy.fromJson(json['updatedBy'])
        : null;
    sId = json['_id'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['action'] = this.action;
    data['fromStatus'] = this.fromStatus;
    data['toStatus'] = this.toStatus;
    data['remarks'] = this.remarks;
    if (this.updatedBy != null) {
      data['updatedBy'] = this.updatedBy!.toJson();
    }
    data['_id'] = this.sId;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
