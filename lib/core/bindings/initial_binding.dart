import 'package:get/get.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/data/auth_repository.dart';
import '../network/api_service.dart';
import '../storage/secure_storage_service.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiService>(ApiService.instance, permanent: true);
    Get.put<SecureStorageService>(SecureStorageService.instance, permanent: true);
    Get.put<AuthRepository>(
      AuthRepository(Get.find<ApiService>(), Get.find<SecureStorageService>()),
      permanent: true,
    );
    Get.put<AuthController>(
      AuthController(Get.find<AuthRepository>()),
      permanent: true,
    );
  }
}
