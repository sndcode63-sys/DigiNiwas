/// Lightweight helpers for DigiNiwas partner API payloads.
/// Backend shapes vary; screens read via typed getters with safe fallbacks.
library;

int? asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.replaceAll(',', ''));
  return null;
}

double? asDouble(dynamic v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.replaceAll(',', ''));
  return null;
}

String? asString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}

Map<String, dynamic> asMap(dynamic v) {
  if (v is Map) return Map<String, dynamic>.from(v);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asMapList(dynamic v) {
  if (v is! List) return const [];
  return v
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

class PartnerProfile {
  PartnerProfile(this.raw);
  final Map<String, dynamic> raw;

  String get id =>
      asString(raw['_id']) ?? asString(raw['id']) ?? '';

  String get partnerCode =>
      asString(raw['partnerId']) ?? asString(raw['partnerCode']) ?? '';

  String get name =>
      asString(raw['name']) ?? asString(raw['fullName']) ?? 'Partner';

  String get email => asString(raw['email']) ?? '';

  String get phone => asString(raw['phone']) ?? '';

  String get accountType => asString(raw['accountType']) ?? 'partner';

  bool get isVerified =>
      raw['isVerified'] == true ||
      asString(raw['status'])?.toLowerCase() == 'verified';
}

class PartnerCreditWallet {
  PartnerCreditWallet(this.raw);
  final Map<String, dynamic> raw;

  int get balance =>
      asInt(raw['balance']) ??
      asInt(raw['credits']) ??
      asInt(raw['availableBalance']) ??
      0;

  int get totalPurchased => asInt(raw['totalPurchased']) ?? 0;

  int get totalSpent => asInt(raw['totalSpent']) ?? 0;
}

class PartnerCreditsSnapshot {
  PartnerCreditsSnapshot({
    required this.wallet,
    this.partner,
    this.recentTransactions = const [],
    this.raw = const {},
  });

  final PartnerCreditWallet wallet;
  final PartnerProfile? partner;
  final List<Map<String, dynamic>> recentTransactions;
  final Map<String, dynamic> raw;

  factory PartnerCreditsSnapshot.fromResponse(Map<String, dynamic> body) {
    final data = asMap(body['data'] ?? body);
    final walletMap = asMap(
      data['wallet'] ??
          data['creditWallet'] ??
          asMap(data['partner'])['creditWallet'] ??
          data,
    );
    final partnerMap = asMap(data['partner']);
    final tx = asMapList(
      data['recentTransactions'] ?? data['transactions'] ?? body['data'],
    );
    return PartnerCreditsSnapshot(
      wallet: PartnerCreditWallet(walletMap),
      partner: partnerMap.isEmpty ? null : PartnerProfile(partnerMap),
      recentTransactions: tx,
      raw: data,
    );
  }
}

class PartnerLeadsDashboard {
  PartnerLeadsDashboard(this.raw);
  final Map<String, dynamic> raw;

  factory PartnerLeadsDashboard.fromResponse(Map<String, dynamic> body) {
    final dash = asMap(body['dashboard'] ?? body['data'] ?? body);
    return PartnerLeadsDashboard(dash);
  }

  int get totalLeads => asInt(raw['totalLeads']) ?? asInt(raw['total']) ?? 0;

  int get unlocked => asInt(raw['unlocked']) ?? 0;

  int get available =>
      asInt(raw['available']) ??
      asInt(raw['unassigned']) ??
      (totalLeads - unlocked).clamp(0, totalLeads);

  int get assigned => asInt(raw['assigned']) ?? 0;

  int get followUp =>
      asInt(raw['followUp']) ?? asInt(raw['follow_up']) ?? 0;

  int get visitPlanned =>
      asInt(raw['visitPlanned']) ??
      asInt(raw['visitsPlanned']) ??
      asInt(raw['visit_planned']) ??
      0;

  int get converted => asInt(raw['convertedLeads']) ?? 0;
}

class PartnerLead {
  PartnerLead(this.raw);
  final Map<String, dynamic> raw;

  String get id => asString(raw['_id']) ?? asString(raw['id']) ?? '';

  String get buyerName =>
      asString(raw['buyerName']) ??
      asString(asMap(raw['buyer'])['name']) ??
      asString(raw['name']) ??
      'Buyer';

  String get phone =>
      asString(raw['phone']) ??
      asString(asMap(raw['buyer'])['phone']) ??
      asString(raw['maskedPhone']) ??
      '';

  String get status => asString(raw['status']) ?? 'Available';

  String get propertyTitle =>
      asString(raw['propertyTitle']) ??
      asString(asMap(raw['property'])['title']) ??
      asString(asMap(raw['property'])['name']) ??
      'Property';

  String get location =>
      asString(raw['location']) ??
      asString(raw['city']) ??
      asString(asMap(raw['property'])['city']) ??
      asString(asMap(raw['buyer'])['city']) ??
      '';

  bool get isUnlocked =>
      raw['isUnlockedByPartner'] == true ||
      raw['isUnlocked'] == true ||
      asString(raw['unlockStatus'])?.toLowerCase() == 'unlocked' ||
      asString(raw['status'])?.toLowerCase().contains('viewed') == true;

  int get unlockCost =>
      asInt(raw['unlockCost']) ??
      asInt(raw['creditCost']) ??
      asInt(asMap(raw['unlockCredit'])['creditsCharged']) ??
      25;

  String get budget {
    final direct = asString(raw['budget']) ?? asString(raw['budgetRange']);
    if (direct != null && direct.isNotEmpty) return direct;
    final value = asInt(raw['estimatedValue']) ??
        asInt(asMap(raw['property'])['price']);
    if (value == null || value <= 0) return '';
    return '₹$value';
  }

  String? get assignedPartnerMongoId =>
      asString(asMap(raw['assignedPartner'])['partnerMongoId']) ??
      asString(asMap(raw['assignedPartner'])['_id']);
}

class PartnerProperty {
  PartnerProperty(this.raw);
  final Map<String, dynamic> raw;

  String get id => asString(raw['_id']) ?? asString(raw['id']) ?? '';

  String get title =>
      asString(raw['title']) ??
      asString(raw['propertyTitle']) ??
      asString(raw['name']) ??
      'Property';

  String get status =>
      asString(raw['status']) ??
      asString(raw['listingStatus']) ??
      'Draft';

  String get city =>
      asString(raw['city']) ??
      asString(asMap(raw['location'])['city']) ??
      '';

  String get address =>
      asString(raw['address']) ??
      asString(asMap(raw['location'])['address']) ??
      city;

  String? get imageUrl {
    final images = raw['images'] ?? raw['photos'] ?? raw['media'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is String) return first;
      if (first is Map) {
        return asString(first['url']) ?? asString(first['path']);
      }
    }
    return asString(raw['coverImage']) ??
        asString(raw['thumbnail']) ??
        asString(asMap(raw['propertySnapshot'])['image']);
  }

  String get priceLabel {
    final price = raw['price'] ?? raw['expectedPrice'] ?? raw['amount'];
    if (price == null) return '';
    return '₹$price';
  }

  bool get isBoosted =>
      raw['isBoosted'] == true || raw['boosted'] == true;
}

class PartnerVisit {
  PartnerVisit(this.raw);
  final Map<String, dynamic> raw;

  String get id => asString(raw['_id']) ?? asString(raw['id']) ?? '';

  String get status => asString(raw['status']) ?? 'Requested';

  Map<String, dynamic> get _propertyMap {
    final nested = asMap(raw['propertyId']);
    if (nested.isNotEmpty) return nested;
    final snap = asMap(raw['propertySnapshot']);
    if (snap.isNotEmpty) return snap;
    return asMap(raw['property']);
  }

  Map<String, dynamic> get _buyerMap {
    final snap = asMap(raw['buyerSnapshot']);
    if (snap.isNotEmpty) return snap;
    return asMap(raw['buyer']);
  }

  String get propertyTitle =>
      asString(raw['propertyTitle']) ??
      asString(_propertyMap['title']) ??
      asString(asMap(raw['propertySnapshot'])['title']) ??
      'Property visit';

  String get buyerName =>
      asString(raw['buyerName']) ??
      asString(_buyerMap['name']) ??
      'Buyer';

  String get scheduledAt =>
      asString(raw['scheduledAt']) ??
      asString(raw['requestedVisitAt']) ??
      asString(raw['approvedVisitAt']) ??
      asString(raw['visitDate']) ??
      asString(raw['preferredDate']) ??
      '';
}

class PublishingSummary {
  PublishingSummary(this.raw);
  final Map<String, dynamic> raw;

  factory PublishingSummary.fromResponse(Map<String, dynamic> body) {
    return PublishingSummary(asMap(body['data'] ?? body));
  }

  int get live => asInt(raw['live']) ?? 0;

  int get readyForFinalReview => asInt(raw['readyForFinalReview']) ?? 0;

  int get totalVerified => asInt(raw['totalVerified']) ?? 0;

  int get draft => asInt(raw['draft']) ?? 0;

  int get assigned => asInt(raw['assigned']) ?? totalVerified;
}

class VisitsSummary {
  VisitsSummary(this.raw);
  final Map<String, dynamic> raw;

  factory VisitsSummary.fromResponse(Map<String, dynamic> body) {
    return VisitsSummary(asMap(body['data'] ?? body));
  }

  int get total => asInt(raw['total']) ?? 0;

  int get requested => asInt(raw['requested']) ?? 0;

  int get upcoming => asInt(raw['upcoming']) ?? 0;

  int get completed => asInt(raw['completed']) ?? 0;

  int get followUp => asInt(raw['followUp']) ?? 0;

  int get pendingApproval => asInt(raw['pendingApproval']) ?? 0;
}

class CreditPack {
  const CreditPack({
    required this.code,
    required this.label,
    required this.credits,
    required this.priceInr,
    this.isFallback = false,
  });

  final String code;
  final String label;
  final int credits;
  final int priceInr;
  final bool isFallback;

  factory CreditPack.fromMap(Map<String, dynamic> m) {
    return CreditPack(
      code: asString(m['code']) ?? asString(m['productCode']) ?? 'pack',
      label: asString(m['label']) ?? asString(m['name']) ?? 'Credits',
      credits: asInt(m['credits']) ?? asInt(m['quantity']) ?? 0,
      priceInr: asInt(m['price']) ??
          asInt(m['priceInr']) ??
          asInt(m['amount']) ??
          0,
    );
  }
}

/// Extracts list payloads from varied DigiNiwas envelope shapes.
List<Map<String, dynamic>> extractDataList(Map<String, dynamic> body) {
  final data = body['data'];
  if (data is List) return asMapList(data);
  if (data is Map) {
    final nested = asMapList(
      data['items'] ??
          data['leads'] ??
          data['properties'] ??
          data['visits'] ??
          data['results'] ??
          data['data'] ??
          data['members'] ??
          data['transactions'] ??
          data['history'],
    );
    if (nested.isNotEmpty) return nested;
  }
  for (final key in [
    'leads',
    'properties',
    'visits',
    'items',
    'results',
    'members',
  ]) {
    final list = asMapList(body[key]);
    if (list.isNotEmpty) return list;
  }
  return const [];
}
