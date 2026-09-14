/// Models that power the Seller Home dashboard screen.
///
/// The backend doesn't document an exact shape for a property returned by
/// `GET /v1/sellers/:id/properties`, a lead returned by
/// `GET /v1/leads/partner/:partnerId`, or a visit returned by
/// `GET /v1/visits/partner/:partnerId` — so, matching the defensive-parsing
/// convention already used across this codebase (see `agent_repo.dart`,
/// `lead_model.dart`), every field here is read with several fallback key
/// names and never throws on a missing/renamed field.
library seller_home_feed_model;

/// Normalized property review stages shown on the Seller Home progress
/// tracker (Submitted → Partner Review → Verified → Live).
enum SellerPropertyStage { submitted, partnerReview, verified, live }

SellerPropertyStage _stageFromRaw(String? raw) {
  final value = (raw ?? '').toLowerCase().trim();
  if (value.contains('live') ||
      value.contains('publish') ||
      value.contains('active') ||
      value.contains('listed')) {
    return SellerPropertyStage.live;
  }
  if (value.contains('verified') || value.contains('approved')) {
    return SellerPropertyStage.verified;
  }
  if (value.contains('review') || value.contains('progress')) {
    return SellerPropertyStage.partnerReview;
  }
  return SellerPropertyStage.submitted;
}

String stageLabel(SellerPropertyStage stage) {
  switch (stage) {
    case SellerPropertyStage.submitted:
      return 'Submitted';
    case SellerPropertyStage.partnerReview:
      return 'Partner Review';
    case SellerPropertyStage.verified:
      return 'Verified';
    case SellerPropertyStage.live:
      return 'Live';
  }
}

/// A lightweight view of one seller property, enough to drive the Home
/// screen's stat cards, progress tracker, and assigned-partner section.
class SellerPropertyBrief {
  final String id;
  final String title;
  final String? imageUrl;
  final String rawStatus;
  final SellerPropertyStage stage;
  final DateTime? updatedAt;
  final bool documentsPending;

  final String? partnerId;
  final String? partnerName;
  final String? partnerAvatarUrl;
  final String? partnerPhone;
  final String? partnerLocality;
  final bool partnerVerified;
  final bool? partnerOnline;

  // ---------------------------------------------------------------------
  // Listing details — used by "My Properties" cards & Seller Insights.
  // Field names aren't documented anywhere for this endpoint either, so
  // every value below is parsed defensively from the same key aliases
  // used across the rest of this codebase (see property_new_listing.dart /
  // property_filter_model.dart) and simply comes back null/0 if the
  // backend doesn't send it — screens must render gracefully either way.
  // ---------------------------------------------------------------------
  final num? price;
  final String? bedrooms;
  final String? bathrooms;
  final String? area; // formatted, e.g. "1,850 sq.ft"
  final String? category;
  final String? transactionType;
  final String? city;
  final String? locality;
  final String? verificationStatus;

  /// Best-effort engagement counters straight off the property document,
  /// if the backend includes them (e.g. `views`, `viewsCount`, `saves`,
  /// `savedCount`). Defaults to 0 — screens should treat 0 as "no data
  /// yet", not necessarily "zero views".
  final int views;
  final int saves;

  SellerPropertyBrief({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.rawStatus,
    required this.stage,
    this.updatedAt,
    this.documentsPending = false,
    this.partnerId,
    this.partnerName,
    this.partnerAvatarUrl,
    this.partnerPhone,
    this.partnerLocality,
    this.partnerVerified = false,
    this.partnerOnline,
    this.price,
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.category,
    this.transactionType,
    this.city,
    this.locality,
    this.verificationStatus,
    this.views = 0,
    this.saves = 0,
  });

  /// "3 BHK" style label, or null if bedrooms weren't returned.
  String? get bhkLabel {
    if (bedrooms == null || bedrooms!.trim().isEmpty) return null;
    final trimmed = bedrooms!.trim();
    return trimmed.toUpperCase().contains('BHK') ? trimmed : '$trimmed BHK';
  }

  /// "Model Town, Ambala" style address label built from whatever
  /// locality/city fields are present.
  String? get addressLabel {
    final parts = [locality, city].where((p) => p != null && p.trim().isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  bool get isVerifiedListing {
    final v = (verificationStatus ?? '').toLowerCase();
    return v.contains('verified') || v.contains('approved');
  }

  /// One line shown under the progress tracker.
  String get statusNote {
    switch (stage) {
      case SellerPropertyStage.submitted:
        return 'Your submission is queued for partner review.';
      case SellerPropertyStage.partnerReview:
        return '${partnerName ?? 'Your DigiNiwas Partner'} is reviewing your property details.';
      case SellerPropertyStage.verified:
        return 'Verified! Your listing is being prepared to go live.';
      case SellerPropertyStage.live:
        return 'Your property is live and visible to buyers.';
    }
  }

  factory SellerPropertyBrief.fromJson(Map<String, dynamic> json) {
    final partnerMap = _extractPartnerMap(json);

    final rawStatus = (json['status'] ??
        json['propertyStatus'] ??
        json['applicationStatus'] ??
        json['reviewStatus'] ??
        json['stage'] ??
        'Submitted')
        .toString();

    final images = json['images'];
    String? imageUrl;
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map) {
        imageUrl = (first['url'] ?? first['secure_url'])?.toString();
      } else if (first is String) {
        imageUrl = first;
      }
    }
    imageUrl ??= (json['image'] ?? json['coverImage'] ?? json['thumbnail'])?.toString();

    final area = json['superBuiltupArea'] ??
        json['carpetArea'] ??
        json['builtUpArea'] ??
        json['area'] ??
        json['sqft'];

    return SellerPropertyBrief(
      id: (json['_id'] ?? json['id'] ?? json['propertyId'] ?? '').toString(),
      title: (json['title'] ?? json['projectName'] ?? json['name'] ?? 'Untitled Property')
          .toString(),
      imageUrl: imageUrl,
      rawStatus: rawStatus,
      stage: _stageFromRaw(rawStatus),
      updatedAt: _parseDate(json['updatedAt'] ?? json['createdAt']),
      documentsPending: _computeDocumentsPending(json),
      partnerId: (json['partnerId'] ?? partnerMap?['_id'] ?? partnerMap?['id'])?.toString(),
      partnerName: partnerMap?['name']?.toString(),
      partnerAvatarUrl: (partnerMap?['avatar'] ?? partnerMap?['photo'])?.toString(),
      partnerPhone: (partnerMap?['phone'] ??
          (partnerMap?['contact'] is Map ? (partnerMap!['contact'] as Map)['phone'] : null))
          ?.toString(),
      partnerLocality: _partnerLocality(partnerMap),
      partnerVerified: partnerMap?['isVerified'] == true,
      partnerOnline: partnerMap?['isOnline'] is bool ? partnerMap!['isOnline'] as bool : null,
      price: _toNum(json['price'] ?? json['expectedPrice'] ?? json['amount']),
      bedrooms: (json['bedrooms'] ?? json['bhk'])?.toString(),
      bathrooms: json['bathrooms']?.toString(),
      area: area != null ? '$area sq.ft' : null,
      category: (json['category'] ?? json['propertyType'])?.toString(),
      transactionType: json['transactionType']?.toString(),
      city: json['city']?.toString(),
      locality: (json['locality'] ?? json['address'])?.toString(),
      verificationStatus: (json['propertyVerificationStatus'] ?? json['verificationStatus'])?.toString(),
      views: _toInt(json['views'] ?? json['viewsCount'] ?? json['viewCount'] ?? json['totalViews']),
      saves: _toInt(json['saves'] ?? json['savesCount'] ?? json['savedCount'] ?? json['wishlistCount']),
    );
  }

  static num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static Map<String, dynamic>? _extractPartnerMap(Map<String, dynamic> json) {
    for (final key in ['partner', 'assignedPartner', 'partnerDetails', 'partnerSnapshot', 'agent']) {
      final v = json[key];
      if (v is Map) return Map<String, dynamic>.from(v);
    }
    return null;
  }

  static String? _partnerLocality(Map<String, dynamic>? partnerMap) {
    if (partnerMap == null) return null;
    final location = partnerMap['location'];
    if (location is Map) {
      return (location['city'] ?? location['address'])?.toString();
    }
    return partnerMap['city']?.toString();
  }

  static bool _computeDocumentsPending(Map<String, dynamic> json) {
    final docs = json['documents'];
    if (docs is List && docs.isEmpty) return true;
    final verification = (json['verificationStatus'] ?? json['kycStatus'])?.toString().toLowerCase();
    if (verification != null &&
        (verification.contains('pending') ||
            verification.contains('missing') ||
            verification.contains('required'))) {
      return true;
    }
    final pendingDocs = json['pendingDocuments'] ?? json['missingDocuments'];
    if (pendingDocs is List && pendingDocs.isNotEmpty) return true;
    return false;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

/// Kind of item in the "Recent Partner Updates" feed — decides which icon
/// is shown in the UI.
enum SellerUpdateKind { visit, lead, offer, property, generic }

class SellerUpdateItem {
  final SellerUpdateKind kind;
  final String title;
  final DateTime timestamp;

  SellerUpdateItem({
    required this.kind,
    required this.title,
    required this.timestamp,
  });
}

/// "Today" / "2 hours ago" / "Yesterday" / "12 Sep" style label, matching
/// the design's relative-time formatting.
String timeAgoLabel(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
  if (diff.inHours < 24 && now.day == time.day) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }
  final yesterday = now.subtract(const Duration(days: 1));
  if (time.year == yesterday.year && time.month == yesterday.month && time.day == yesterday.day) {
    return 'Yesterday';
  }
  if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${time.day} ${months[time.month - 1]}';
}

/// "8 Aug, 11:00 AM" style label for an upcoming/appointment date-time,
/// used by the My Partner screen's "Next appointment" notice.
String formatVisitDateTime(DateTime time) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final hour24 = time.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final ampm = hour24 >= 12 ? 'PM' : 'AM';
  return '${time.day} ${months[time.month - 1]}, $hour12:$minute $ampm';
}