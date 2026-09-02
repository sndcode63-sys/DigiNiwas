import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';
import 'core/utils/app_logger.dart';

Future<void> main() async {
  AppLogger.i('🚀 App started');
  await GetStorage.init();
  runApp(const MyApp());
}
