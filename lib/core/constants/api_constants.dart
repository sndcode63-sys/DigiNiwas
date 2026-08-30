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
  static const String getBuyers = '/buyers';

  // Fetch buyer by ID
  static const String getBuyerById = '/buyers';

  // Fetch buyer dashboard
  static const String getBuyerDashboard = '/buyers';

  // ==================== Saved Property Endpoints ====================
  static const String saveProperty = '/saved-properties';

  static const String getBuyerSavedProperties =
      '/saved-properties/buyer';

  static const String checkSavedProperty =
      '/saved-properties/check';

  static const String removeSavedProperty =
      '/saved-properties';

  // ==================== Timeout ====================
  static const int connectTimeout = 60000;
  static const int receiveTimeout = 60000;
  static const int sendTimeout = 60000;

  // ==================== Headers ====================
  static const String authHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
}