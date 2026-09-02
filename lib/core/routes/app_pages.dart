import 'package:get/get.dart';

import '../../features/auth/presentation/agent/home_screen.dart';
import '../../features/auth/presentation/agent/property_details.dart';
import '../../features/auth/presentation/buyer_section/buyer_home.dart' as buyer;
import '../../features/auth/presentation/buyer_section/choose_roll.dart';
import '../../features/auth/presentation/buyer_section/compare_properties_detials_screen.dart';
import '../../features/auth/presentation/buyer_section/map_view.dart';
import '../../features/auth/presentation/buyer_section/property_details_screen.dart';
import '../../features/auth/presentation/otp.dart';
import '../../features/auth/presentation/registration_screen.dart';
import '../../features/auth/presentation/seller/add_property_flow_screen.dart';
import '../../features/auth/presentation/seller/home_seller.dart';
import '../../features/auth/presentation/seller/my_property_seller.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.chooseRole, page: () => const ChooseRoleScreen()),
    GetPage(
      name: AppRoutes.registration,
      page: () => RegistrationScreen(role: _arg('role', 'Buyer')),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => OtpVerificationScreen(
        phoneNumber: _arg('phoneNumber', ''),
        role: _arg('role', 'Buyer'),
        mode: _arg('mode', OtpFlowMode.register),
      ),
    ),

    // Dashboards
    GetPage(name: AppRoutes.buyerHome, page: () => const buyer.HomeScreen()),
    GetPage(name: AppRoutes.sellerHome, page: () => const SellerHomeScreen()),
    GetPage(name: AppRoutes.partnerDashboard, page: () => const PartnerDashboardScreen()),

    // Buyer flow
    GetPage(
      name: AppRoutes.propertyDetails,
      page: () => PropertyDetailsScreen(property: _arg('property', const {})),
    ),
    GetPage(
      name: AppRoutes.panoramaViewer,
      page: () => PanoramaViewerScreen(
        imageUrl: _arg('imageUrl', ''),
        title: _arg('title', ''),
      ),
    ),
    GetPage(
      name: AppRoutes.compareProperties,
      page: () => ComparePropertiesScreen(
        comparedProperties: _arg('comparedProperties', const []),
      ),
    ),
    GetPage(name: AppRoutes.exploreMap, page: () => const buyer.ExploreMapViewScreen()),
    GetPage(name: AppRoutes.mapView, page: () => const MapViewScreen()),

    // Seller flow
    GetPage(name: AppRoutes.myProperties, page: () => const MyPropertiesScreen()),
    GetPage(name: AppRoutes.addProperty, page: () => const AddPropertyFlowScreen()),

    // Agent / partner flow
    GetPage(name: AppRoutes.agentAddProperty, page: () => const AgentAddPropertyFlowScreen()),
  ];

  static T _arg<T>(String key, T fallback) {
    final args = Get.arguments;
    if (args is Map && args.containsKey(key)) {
      return args[key] as T;
    }
    return fallback;
  }
}
