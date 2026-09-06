import 'package:flutter/material.dart';

import 'app.dart';
import 'core/utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.i('🚀 App started');
  runApp(const MyApp());
}
