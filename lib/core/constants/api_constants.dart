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

  // ==================== Buyer App Endpoints (V1) ====================
  // Backend source: DigiNiwas Frontend API Integration doc (buyer app).
  // Every endpoint below requires: Authorization: Bearer <BUYER_JWT_TOKEN>

  // 2. Home Feed
  // GET /api/v1/home/feed
  // Loads home page content using saved buyer location when current
  // lat/lng aren't passed. Optional query params: lat, lng, city.
  static const String homeFeed = '/v1/home/feed';

  // 3. Dashboard Header
  // GET /api/v1/user/dashboard-header
  // Returns greeting, buyer summary, saved/current location and
  // notifications.
  static const String dashboardHeader = '/v1/user/dashboard-header';

  // 4. Property Categories
  // GET /api/v1/properties/categories
  // Returns category counts and Live/Verified properties.
  // Optional query params: tab (Buy|Rent|Plot|Commercial), category,
  // lat, lng, city.
  static const String propertyCategories = '/v1/properties/categories';

  // 5. Boosted Properties
  // GET /api/v1/properties/boosted
  // Returns active promoted properties.
  static const String boostedProperties = '/v1/properties/boosted';

  // 6. Explore Nearby - Map Ready
  // GET /api/v1/properties/explore-nearby
  // Required query param: propertyId. Optional: radius (meters).
  // Returns property location, map center, property/amenity markers,
  // distance, Google Maps links and categorized amenity arrays.
  static const String exploreNearby = '/v1/properties/explore-nearby';

  // 7. New Listings
  // GET /api/v1/properties/new-listings
  // Returns latest Live + Verified property cards with `listedAgo`.
  static const String newListings = '/v1/properties/new-listings';

  // 8. Popular Locations
  // GET /api/v1/locations/popular
  // Returns popular city/locality groups plus each property's Mongo
  // `_id` and custom `propertyId`.
  static const String popularLocations = '/v1/locations/popular';

  // 9. Nearby Agents
  // GET /api/v1/agents/nearby
  // Returns verified agents ranked by location/service-locality/
  // promotion logic.
  static const String nearbyAgents = '/v1/agents/nearby';

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