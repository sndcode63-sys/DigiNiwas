import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight app-preferences store (non-sensitive data only — tokens
/// live in [SecureStorageService]). Backed by `shared_preferences`.
///
/// Matches this login/register response shape:
/// {
///   success: true,
///   token: "...",
///   data: {
///     id, sellerId, partnerId, name, phone, role, partnerType, location
///   }
/// }
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // -----------------------------------------------------------------
  // SAVE — call this right after a successful login-otp / login-password
  // / register response. Pass the `data` map from the API response.
  // -----------------------------------------------------------------
  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(StorageKeys.token, token);
    await _writeOrRemove(prefs, StorageKeys.userId, data['id']?.toString());
    // buyer flow me userId == buyerId
    await _writeOrRemove(prefs, StorageKeys.buyerId, data['id']?.toString());
    await _writeOrRemove(prefs, StorageKeys.sellerId, data['sellerId']?.toString());
    await _writeOrRemove(prefs, StorageKeys.partnerId, data['partnerId']?.toString());
    await _writeOrRemove(prefs, StorageKeys.name, data['name']?.toString());
    await _writeOrRemove(prefs, StorageKeys.phone, data['phone']?.toString());
    await _writeOrRemove(prefs, StorageKeys.role, data['role']?.toString());
    await _writeOrRemove(prefs, StorageKeys.partnerType, data['partnerType']?.toString());
    if (data['location'] != null) {
      await prefs.setString(StorageKeys.location, jsonEncode(data['location']));
    }
    await prefs.setBool(StorageKeys.isLoggedIn, true);
  }

  /// Persists the last device GPS fix (captured on login/registration via
  /// [LocationService]) so the rest of the app — e.g. "properties near
  /// me" — can reuse it without asking for permission again every time.
  Future<void> saveLastKnownCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final prefs = await _prefs;
    await prefs.setDouble(StorageKeys.lastLat, latitude);
    await prefs.setDouble(StorageKeys.lastLng, longitude);
  }

  Future<({double latitude, double longitude})?> getLastKnownCoordinates() async {
    final prefs = await _prefs;
    final lat = prefs.getDouble(StorageKeys.lastLat);
    final lng = prefs.getDouble(StorageKeys.lastLng);
    if (lat == null || lng == null) return null;
    return (latitude: lat, longitude: lng);
  }

  // -----------------------------------------------------------------
  // VISIT TRACKING — locally remembers which visit IDs belong to this
  // device/user so ScheduledVisitsScreen can look up their live status
  // one by one (no "list my visits" endpoint was provided).
  // -----------------------------------------------------------------
  Future<void> addVisitId(String visitId) async {
    if (visitId.isEmpty) return;
    final prefs = await _prefs;
    final list = prefs.getStringList(StorageKeys.visitIds) ?? <String>[];
    if (!list.contains(visitId)) {
      list.insert(0, visitId); // newest first
      await prefs.setStringList(StorageKeys.visitIds, list);
    }
  }

  Future<List<String>> getVisitIds() async {
    final prefs = await _prefs;
    return prefs.getStringList(StorageKeys.visitIds) ?? <String>[];
  }

  Future<void> removeVisitId(String visitId) async {
    final prefs = await _prefs;
    final list = prefs.getStringList(StorageKeys.visitIds) ?? <String>[];
    list.remove(visitId);
    await prefs.setStringList(StorageKeys.visitIds, list);
  }

  // -----------------------------------------------------------------
  // RECENTLY VIEWED PROPERTIES — no "recently viewed" API exists yet, so
  // this tracks property IDs locally (newest first, capped) purely from
  // in-app navigation. Call [addRecentlyViewedId] from Property Details
  // onInit; read it back for the Profile screen's "Recently Viewed" stat.
  // -----------------------------------------------------------------
  static const int _recentlyViewedCap = 50;

  Future<void> addRecentlyViewedId(String propertyId) async {
    if (propertyId.isEmpty) return;
    final prefs = await _prefs;
    final list = prefs.getStringList(StorageKeys.recentlyViewedIds) ?? <String>[];
    list.remove(propertyId); // move to front if already present
    list.insert(0, propertyId);
    if (list.length > _recentlyViewedCap) list.removeRange(_recentlyViewedCap, list.length);
    await prefs.setStringList(StorageKeys.recentlyViewedIds, list);
  }

  Future<List<String>> getRecentlyViewedIds() async {
    final prefs = await _prefs;
    return prefs.getStringList(StorageKeys.recentlyViewedIds) ?? <String>[];
  }

  // -----------------------------------------------------------------
  // MY ENQUIRIES — same idea: no "my leads/enquiries" list endpoint
  // exists yet, so this counts leads the buyer has generated in-app
  // (see LeadController.createLeadFromProperty success handlers).
  // -----------------------------------------------------------------
  Future<void> addEnquiryPropertyId(String propertyId) async {
    if (propertyId.isEmpty) return;
    final prefs = await _prefs;
    final list = prefs.getStringList(StorageKeys.enquiryIds) ?? <String>[];
    if (!list.contains(propertyId)) {
      list.insert(0, propertyId);
      await prefs.setStringList(StorageKeys.enquiryIds, list);
    }
  }

  Future<List<String>> getEnquiryIds() async {
    final prefs = await _prefs;
    return prefs.getStringList(StorageKeys.enquiryIds) ?? <String>[];
  }

  // -----------------------------------------------------------------
  // LOCAL PROFILE AVATAR — there is no "update profile photo" backend
  // endpoint in this codebase yet, so a picked photo is persisted here
  // (local file path) and shown with priority over the network avatar
  // until a real upload endpoint exists to sync it server-side.
  // -----------------------------------------------------------------
  Future<void> saveLocalAvatarPath(String path) async {
    final prefs = await _prefs;
    await prefs.setString(StorageKeys.localAvatarPath, path);
  }

  Future<String?> get localAvatarPath async => (await _prefs).getString(StorageKeys.localAvatarPath);

  // -----------------------------------------------------------------
  // READ helpers
  // -----------------------------------------------------------------
  Future<String?> get token async => (await _prefs).getString(StorageKeys.token);
  Future<String?> get userId async => (await _prefs).getString(StorageKeys.userId);
  Future<String?> get buyerId async => (await _prefs).getString(StorageKeys.buyerId);
  Future<String?> get sellerId async => (await _prefs).getString(StorageKeys.sellerId);
  Future<String?> get partnerId async => (await _prefs).getString(StorageKeys.partnerId);
  Future<String?> get name async => (await _prefs).getString(StorageKeys.name);
  Future<String?> get phone async => (await _prefs).getString(StorageKeys.phone);
  Future<String?> get role async => (await _prefs).getString(StorageKeys.role);
  Future<String?> get partnerType async => (await _prefs).getString(StorageKeys.partnerType);
  Future<bool> get isLoggedIn async => (await _prefs).getBool(StorageKeys.isLoggedIn) ?? false;

  // -----------------------------------------------------------------
  // CLEAR — call this on logout
  // -----------------------------------------------------------------
  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.buyerId);
    await prefs.remove(StorageKeys.sellerId);
    await prefs.remove(StorageKeys.partnerId);
    await prefs.remove(StorageKeys.name);
    await prefs.remove(StorageKeys.phone);
    await prefs.remove(StorageKeys.role);
    await prefs.remove(StorageKeys.partnerType);
    await prefs.remove(StorageKeys.location);
    await prefs.setBool(StorageKeys.isLoggedIn, false);
    // Deliberately keep lastLat/lastLng — still useful as a default
    // map center even after logout.
    // Deliberately keep visitIds too — visit history isn't tied to the
    // active session in this app's flows.
  }

  Future<void> _writeOrRemove(SharedPreferences prefs, String key, String? value) async {
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }
}

class StorageKeys {
  StorageKeys._();

  static const String token = 'auth_token';
  static const String userId = 'user_id';
  static const String buyerId = 'buyer_id';
  static const String sellerId = 'seller_id';
  static const String partnerId = 'partner_id';
  static const String name = 'user_name';
  static const String phone = 'user_phone';
  static const String role = 'user_role';
  static const String partnerType = 'partner_type';
  static const String location = 'user_location';
  static const String isLoggedIn = 'is_logged_in';
  static const String lastLat = 'last_lat';
  static const String lastLng = 'last_lng';
  static const String visitIds = 'visit_ids';
  static const String recentlyViewedIds = 'recently_viewed_property_ids';
  static const String enquiryIds = 'enquiry_property_ids';
  static const String localAvatarPath = 'local_avatar_path';
}