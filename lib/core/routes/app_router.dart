import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

/// go_router replacement for the old GetX `AppPages`. Screens that need
/// arguments read them off `state.extra` (see the small `_arg` helper
/// below) instead of `Get.arguments`.
///
/// Navigate with:
///   context.push(AppRoutes.otp, extra: {'phoneNumber': phone, ...});   // like Get.to
///   context.pop();                                                     // like Get.back
///   context.go(AppRoutes.buyerHome);                                   // like Get.offAll
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.chooseRole,
        builder: (context, state) => const ChooseRoleScreen(),
      ),
      GoRoute(
        path: AppRoutes.registration,
        builder: (context, state) => RegistrationScreen(
          role: _arg<String>(state, 'role', 'Buyer'),
        ),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => OtpVerificationScreen(
          phoneNumber: _arg<String>(state, 'phoneNumber', ''),
          role: _arg<String>(state, 'role', 'Buyer'),
          mode: _arg<OtpFlowMode>(state, 'mode', OtpFlowMode.register),
        ),
      ),

      // Dashboards
      GoRoute(
        path: AppRoutes.buyerHome,
        builder: (context, state) => const buyer.HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.sellerHome,
        builder: (context, state) => const SellerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.partnerDashboard,
        builder: (context, state) => const PartnerDashboardScreen(),
      ),

      // Buyer flow
      GoRoute(
        path: AppRoutes.propertyDetails,
        builder: (context, state) => PropertyDetailsScreen(
          property: _arg<Map<String, dynamic>>(state, 'property', const {}),
        ),
      ),
      GoRoute(
        path: AppRoutes.panoramaViewer,
        builder: (context, state) => PanoramaViewerScreen(
          imageUrl: _arg<String>(state, 'imageUrl', ''),
          title: _arg<String>(state, 'title', ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.compareProperties,
        builder: (context, state) => ComparePropertiesScreen(
          comparedProperties:
              _arg<List<Map<String, dynamic>>>(state, 'comparedProperties', const []),
        ),
      ),
      GoRoute(
        path: AppRoutes.exploreMap,
        builder: (context, state) => const buyer.ExploreMapViewScreen(),
      ),
      GoRoute(
        path: AppRoutes.mapView,
        builder: (context, state) => const MapViewScreen(),
      ),

      // Seller flow
      GoRoute(
        path: AppRoutes.myProperties,
        builder: (context, state) => const MyPropertiesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addProperty,
        builder: (context, state) => const AddPropertyFlowScreen(),
      ),

      // Agent / partner flow
      GoRoute(
        path: AppRoutes.agentAddProperty,
        builder: (context, state) => const AgentAddPropertyFlowScreen(),
      ),
    ],
  );
});

/// Reads a single value out of `state.extra` (expected to be a `Map`),
/// falling back to [fallback] when it's missing — mirrors the old
/// `AppPages._arg` helper that used to read `Get.arguments`.
T _arg<T>(GoRouterState state, String key, T fallback) {
  final args = state.extra;
  if (args is Map && args.containsKey(key)) {
    return args[key] as T;
  }
  return fallback;
}

/// Returns the dashboard route for a given backend role string
/// ('Buyer' / 'Seller' / 'Partner' / 'Agent'), defaulting to the role
/// picker when the role is missing or unrecognised.
String dashboardRouteForRole(String? role) {
  switch (role?.toLowerCase()) {
    case 'seller':
      return AppRoutes.sellerHome;
    case 'partner':
    case 'agent':
      return AppRoutes.partnerDashboard;
    case 'buyer':
      return AppRoutes.buyerHome;
    default:
      return AppRoutes.chooseRole;
  }
}
