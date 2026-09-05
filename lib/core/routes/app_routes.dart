/// All go_router paths live here. Navigate with the `context.go` /
/// `context.push` / `context.pop` extensions from `go_router` — see
/// `app_router.dart` for how each path maps to a screen.
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
  static const myProperties = '/my-properties';
  static const addProperty = '/add-property';

  // Agent / partner flow
  static const agentAddProperty = '/agent-add-property';
}
