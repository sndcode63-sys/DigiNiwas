class ApiConstants {
  ApiConstants._();

  // 🔧 Apna base URL yahan change karo
  static const String baseUrl = 'https://api.example.com';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Timeouts (ms)
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Header keys
  static const String authHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
}
