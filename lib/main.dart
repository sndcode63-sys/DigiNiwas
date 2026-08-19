import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/utils/app_logger.dart';

void main() {
  AppLogger.i('🚀 App started');

  runApp(const ProviderScope(child: MyApp()));
}
