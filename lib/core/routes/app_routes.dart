/// All GetX route names live here. Navigate with `Get.toNamed` /
/// `Get.offNamed` / `Get.offAllNamed` / `Get.back` — see `app_pages.dart`
/// for how each route maps to a screen (`GetPage`).
abstract class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const chooseRole = '/choose-role';
  static const registration = '/registration';
  static const otp = '/otp';

  // Dashboards (one per role)
  static const buyerHome = '/buyer-home';
  static const sellerHome = '/seller-home';
  static const partnerDashboard = '/partner-dashboard';

  // Buyer flow
  static const propertyDetails = '/property-details';
  static const panoramaViewer = '/panorama-viewer';
  static const compareProperties = '/compare-properties';
  static const exploreMap = '/explore-map';
  static const mapView = '/map-view';

  // Seller flow
  static const sellerRegistration = '/seller-registration';
  static const sellerChangePassword = '/seller-change-password';
  static const myProperties = '/my-properties';
  static const addProperty = '/add-property';

  // Agent / partner flow
  static const agentAddProperty = '/agent-add-property';
}
