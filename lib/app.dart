import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/bindings/initial_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'DigiNiwas',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.turquoise,
              primary: AppColors.turquoise,
              secondary: AppColors.green,
              surface: AppColors.white,
              error: AppColors.error,
            ),
            scaffoldBackgroundColor: AppColors.background,
            useMaterial3: true,
            fontFamily: GoogleFonts.poppins().fontFamily,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          initialBinding: InitialBinding(),
          initialRoute: AppRoutes.splash,
          getPages: AppPages.routes,
        );
      },
    );
  }
}