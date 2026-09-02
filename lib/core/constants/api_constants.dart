class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://backend-diginiwas.onrender.com/api';

  // ==================== Auth Endpoints ====================
  // Backend source: routes/authRoutes.js -> controllers/authController.js
  static const String register = '/auths/register';
  static const String loginPassword = '/auths/login-password';
  static const String sendOtp = '/auths/send-otp';
  static const String loginOtp = '/auths/login-otp';

  // ==================== Buyer Endpoints ====================

  // Fetch all buyers
  // GET /buyers
  static const String getBuyers = '/buyers';

  // Fetch buyer by ID
  // GET /buyers/:id
  static const String getBuyerById = '/buyers';

  // Fetch buyer dashboard
  // GET /buyers/:id/dashboard
  static const String getBuyerDashboard = '/buyers';

  // ==================== Property Endpoints ====================

  // Fetch all properties
  // GET /properties
  static const String getProperties = '/properties';

  // Search properties
  // GET /properties/search/list?keyword=value
  static const String searchProperties = '/properties/search/list';

  // Filter properties
  // GET /properties/filter
  static const String filterProperties = '/properties/filter';

  // Fetch property by ID
  // GET /properties/:id
  static const String getPropertyById = '/properties';

  // ==================== Saved Property Endpoints ====================

  // Save property
  // POST /saved-properties
  static const String saveProperty = '/saved-properties';

  // Get buyer saved properties
  // GET /saved-properties/buyer/:buyerId
  static const String getBuyerSavedProperties =
      '/saved-properties/buyer';

  // Check whether property is saved
  // GET /saved-properties/check/:buyerId/:propertyId
  static const String checkSavedProperty =
      '/saved-properties/check';

  // Remove saved property
  // DELETE /saved-properties/:buyerId/:propertyId
  static const String removeSavedProperty =
      '/saved-properties';

  // ==================== Lead / Enquiry Endpoints ====================

  // Create enquiry/lead from property
  // POST /leads/from-property
  static const String createLeadFromProperty =
      '/leads/from-property';

  // ==================== Visit Endpoints ====================

  // Request property visit
  // POST /visits/request
  static const String requestVisit =
      '/visits/request';

  // Fetch visit by ID
  // GET /visits/:id
  static const String getVisitById =
      '/visits';

  // ==================== Timeout ====================
  static const int connectTimeout = 60000;
  static const int receiveTimeout = 60000;
  static const int sendTimeout = 60000;

  // ==================== Headers ====================
  static const String authHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
}