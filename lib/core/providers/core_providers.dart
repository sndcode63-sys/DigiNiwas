import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_service.dart';
import '../storage/secure_storage_service.dart';

/// App me kahin bhi ref.read(apiServiceProvider) se API service mil jaayega
final apiServiceProvider = Provider<ApiService>((ref) => ApiService.instance);

final secureStorageProvider =
    Provider<SecureStorageService>((ref) => SecureStorageService.instance);
