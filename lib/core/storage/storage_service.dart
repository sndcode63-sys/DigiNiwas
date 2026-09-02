import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  StorageService._();
  static final GetStorage _box = GetStorage();

  // -----------------------------------------------------------------
  // SAVE — call this right after a successful login-otp / login-password
  // / register response. Pass the `data` map from the API response.
  //
  // Matches this response shape:
  // {
  //   success: true,
  //   token: "...",
  //   data: {
  //     id, sellerId, partnerId, name, phone, role, partnerType, location
  //   }
  // }
  // -----------------------------------------------------------------
  static Future<void> saveSession({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    await _box.write(StorageKeys.token, token);
    await _box.write(StorageKeys.userId, data['id']?.toString());
    await _box.write(StorageKeys.buyerId, data['id']?.toString()); // buyer flow me userId == buyerId
    await _box.write(StorageKeys.sellerId, data['sellerId']?.toString());
    await _box.write(StorageKeys.partnerId, data['partnerId']?.toString());
    await _box.write(StorageKeys.name, data['name']?.toString());
    await _box.write(StorageKeys.phone, data['phone']?.toString());
    await _box.write(StorageKeys.role, data['role']?.toString());
    await _box.write(StorageKeys.partnerType, data['partnerType']?.toString());
    await _box.write(StorageKeys.location, data['location']);
    await _box.write(StorageKeys.isLoggedIn, true);
  }

  // -----------------------------------------------------------------
  // READ helpers
  // -----------------------------------------------------------------
  static String? get token => _box.read<String>(StorageKeys.token);
  static String? get userId => _box.read<String>(StorageKeys.userId);
  static String? get buyerId => _box.read<String>(StorageKeys.buyerId);
  static String? get sellerId => _box.read<String>(StorageKeys.sellerId);
  static String? get partnerId => _box.read<String>(StorageKeys.partnerId);
  static String? get name => _box.read<String>(StorageKeys.name);
  static String? get phone => _box.read<String>(StorageKeys.phone);
  static String? get role => _box.read<String>(StorageKeys.role);
  static String? get partnerType => _box.read<String>(StorageKeys.partnerType);
  static dynamic get location => _box.read(StorageKeys.location);
  static bool get isLoggedIn => _box.read<bool>(StorageKeys.isLoggedIn) ?? false;

  // -----------------------------------------------------------------
  // CLEAR — call this on logout
  // -----------------------------------------------------------------
  static Future<void> clearSession() async {
    await _box.remove(StorageKeys.token);
    await _box.remove(StorageKeys.userId);
    await _box.remove(StorageKeys.buyerId);
    await _box.remove(StorageKeys.sellerId);
    await _box.remove(StorageKeys.partnerId);
    await _box.remove(StorageKeys.name);
    await _box.remove(StorageKeys.phone);
    await _box.remove(StorageKeys.role);
    await _box.remove(StorageKeys.partnerType);
    await _box.remove(StorageKeys.location);
    await _box.write(StorageKeys.isLoggedIn, false);
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
}

void onLoginOtpSuccess(Map<String, dynamic> responseData) async {
  // responseData shape:
  // { success: true, message: "...", token: "...", data: {...} }

  final token = responseData['token'] as String;
  final data = responseData['data'] as Map<String, dynamic>;

  //  YE LINE ADD KARO
  await StorageService.saveSession(token: token, data: data);



  Get.offAllNamed('/home');
}

void onRegisterSuccess(Map<String, dynamic> responseData) async {
  final token = responseData['token'] as String;
  final data = responseData['data'] as Map<String, dynamic>;

  await StorageService.saveSession(token: token, data: data);

  Get.offAllNamed('/home');
}

void onLogout() async {
  await StorageService.clearSession();
  Get.offAllNamed('/login');
}