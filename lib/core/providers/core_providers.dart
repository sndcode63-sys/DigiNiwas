import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../network/api_service.dart';
import '../services/location_service.dart';
import '../storage/secure_storage_service.dart';
import '../storage/storage_service.dart';

/// Riverpod replacement for the old `InitialBinding` (GetX). Every screen
/// reaches these through `ref.read` / `ref.watch` instead of `Get.find`.

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService.instance;
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.instance;
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiServiceProvider),
    ref.watch(secureStorageServiceProvider),
  );
});

/// Last GPS fix captured on the login/registration screens (see
/// `AuthController.captureAndAttachLocation`). Any screen can watch this to
/// build "properties near me"-style features without asking for
/// permission again.
final lastKnownLocationProvider = StateProvider<LocationResult?>((ref) => null);
