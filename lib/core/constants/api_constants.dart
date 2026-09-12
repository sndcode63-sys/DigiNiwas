class ApiConstants {
  ApiConstants._();

  // ============================================================
  // BASE URL
  // ============================================================

  static const String baseUrl =
      'https://backend-diginiwas.onrender.com/api';


  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================

  // POST /api/auths/register
  static const String register =
      '/auths/register';

  // POST /api/auths/login-password
  static const String loginPassword =
      '/auths/login-password';

  // POST /api/auths/send-otp
  static const String sendOtp =
      '/auths/send-otp';

  // POST /api/auths/login-otp
  static const String loginOtp =
      '/auths/login-otp';


  // ============================================================
  // BUYER APP ENDPOINTS - V1
  // ============================================================

  // ------------------------------------------------------------
  // Home Feed
  // GET /api/v1/home/feed
  // ------------------------------------------------------------

  static const String homeFeed =
      '/v1/home/feed';


  // ------------------------------------------------------------
  // Dashboard Header
  // GET /api/v1/user/dashboard-header
  // ------------------------------------------------------------

  static const String dashboardHeader =
      '/v1/user/dashboard-header';


  // ------------------------------------------------------------
  // Property Categories
  // GET /api/v1/properties/categories
  // ------------------------------------------------------------

  static const String propertyCategories =
      '/v1/properties/categories';


  // ------------------------------------------------------------
  // Boosted Properties
  // GET /api/v1/properties/boosted
  // ------------------------------------------------------------

  static const String boostedProperties =
      '/v1/properties/boosted';


  // ------------------------------------------------------------
  // Explore Nearby
  // GET /api/v1/properties/explore-nearby
  // Query: propertyId, radius
  // ------------------------------------------------------------

  static const String exploreNearby =
      '/v1/properties/explore-nearby';


  // ------------------------------------------------------------
  // New Listings
  // GET /api/v1/properties/new-listings
  // ------------------------------------------------------------

  static const String newListings =
      '/v1/properties/new-listings';


  // ------------------------------------------------------------
  // Popular Locations
  // GET /api/v1/locations/popular
  // ------------------------------------------------------------

  static const String popularLocations =
      '/v1/locations/popular';


  // ------------------------------------------------------------
  // Nearby Agents
  // GET /api/v1/agents/nearby
  // ------------------------------------------------------------

  static const String nearbyAgents =
      '/v1/agents/nearby';


  // ============================================================
  // PROPERTY ENDPOINTS
  // ============================================================

  // ------------------------------------------------------------
  // Get All Properties
  // GET /api/properties
  // ------------------------------------------------------------

  static const String getProperties =
      '/properties';


  // ------------------------------------------------------------
  // Search Properties
  // GET /api/properties/search/list
  // ------------------------------------------------------------

  static const String searchProperties =
      '/properties/search/list';


  // ------------------------------------------------------------
  // Filter Properties
  // GET /api/properties/filter
  // ------------------------------------------------------------

  static const String filterProperties =
      '/properties/filter';


  // ------------------------------------------------------------
  // New Properties Filter
  // GET /api/newproperties/filter
  // ------------------------------------------------------------

  static const String newPropertiesFilter =
      '/newproperties/filter';


  // ------------------------------------------------------------
  // Get Property By ID
  // GET /api/properties/:id
  // ------------------------------------------------------------

  static const String getPropertyById =
      '/properties';


  // ------------------------------------------------------------
  // Create Property
  // POST /api/v1/properties
  // ------------------------------------------------------------

  static const String createProperty =
      '/v1/properties';


  // ------------------------------------------------------------
  // Update Property
  // PATCH /api/v1/properties/:id
  // ------------------------------------------------------------

  static String updateProperty(String propertyId) =>
      '/v1/properties/$propertyId';


  // ------------------------------------------------------------
  // Delete Property
  // DELETE /api/v1/properties/:id/delete
  // ------------------------------------------------------------

  static String deleteProperty(String propertyId) =>
      '/v1/properties/$propertyId/delete';


  // ------------------------------------------------------------
  // Update Property Status
  // PATCH /api/v1/properties/:id/status
  // ------------------------------------------------------------

  static String updatePropertyStatus(String propertyId) =>
      '/v1/properties/$propertyId/status';


  // ------------------------------------------------------------
  // Boost Property
  // PATCH /api/v1/properties/:id/boost
  // ------------------------------------------------------------

  static String boostProperty(String propertyId) =>
      '/v1/properties/$propertyId/boost';


  // ------------------------------------------------------------
  // Remove Property Boost
  // PATCH /api/v1/properties/:id/unboost
  // ------------------------------------------------------------

  static String removePropertyBoost(String propertyId) =>
      '/v1/properties/$propertyId/unboost';


  // ------------------------------------------------------------
  // Get All Properties - V1
  // GET /api/v1/properties/all
  // ------------------------------------------------------------

  static const String getAllPropertiesV1 =
      '/v1/properties/all';


  // ------------------------------------------------------------
  // Get Admin Properties
  // GET /api/v1/properties/admin
  // ------------------------------------------------------------

  static const String getAdminProperties =
      '/v1/properties/admin';


  // ------------------------------------------------------------
  // Get Boosted Properties - V1
  // GET /api/v1/properties/boosted
  // ------------------------------------------------------------

  static const String getBoostedPropertiesV1 =
      '/v1/properties/boosted';


  // ------------------------------------------------------------
  // Get New Listings - V1
  // GET /api/v1/properties/new-listings
  // ------------------------------------------------------------

  static const String getNewListingsV1 =
      '/v1/properties/new-listings';


  // ------------------------------------------------------------
  // Get Properties By Partner
  // GET /api/v1/properties/partner/:partnerId
  // ------------------------------------------------------------

  static String getPropertiesByPartner(String partnerId) =>
      '/v1/properties/partner/$partnerId';


  // ============================================================
  // SAVED PROPERTY ENDPOINTS
  // ============================================================

  // ------------------------------------------------------------
  // Save Property
  // POST /api/saved-properties
  // ------------------------------------------------------------

  static const String saveProperty =
      '/saved-properties';


  // ------------------------------------------------------------
  // Get Buyer Saved Properties
  // GET /api/saved-properties/buyer/:buyerId
  // ------------------------------------------------------------

  static String getBuyerSavedProperties(String buyerId) =>
      '/saved-properties/buyer/$buyerId';


  // ------------------------------------------------------------
  // Check Saved Property
  // GET /api/saved-properties/check/:buyerId/:propertyId
  // ------------------------------------------------------------

  static String checkSavedProperty(
      String buyerId,
      String propertyId,
      ) =>
      '/saved-properties/check/$buyerId/$propertyId';


  // ------------------------------------------------------------
  // Remove Saved Property
  // DELETE /api/saved-properties/:buyerId/:propertyId
  // ------------------------------------------------------------

  static String removeSavedProperty(
      String buyerId,
      String propertyId,
      ) =>
      '/saved-properties/$buyerId/$propertyId';


  // ============================================================
  // LEAD / ENQUIRY ENDPOINTS
  // ============================================================

  // ------------------------------------------------------------
  // Create Lead From Property
  // POST /api/leads/from-property
  // ------------------------------------------------------------

  static const String createLeadFromProperty =
      '/leads/from-property';


  // ------------------------------------------------------------
  // Get Partner Leads - V1
  // GET /api/v1/leads/partner/:partnerId
  // ------------------------------------------------------------

  static String getPartnerLeads(String partnerId) =>
      '/v1/leads/partner/$partnerId';


  // ------------------------------------------------------------
  // Get Lead By ID - V1
  // GET /api/v1/leads/:id
  // ------------------------------------------------------------

  static String getLeadById(String leadId) =>
      '/v1/leads/$leadId';


  // ============================================================
  // VISIT ENDPOINTS
  // ============================================================

  // ------------------------------------------------------------
  // Request Property Visit
  // POST /api/visits/request
  // ------------------------------------------------------------

  static const String requestVisit =
      '/visits/request';


  // ------------------------------------------------------------
  // Get Visit By ID
  // GET /api/visits/:id
  // ------------------------------------------------------------

  static String getVisitById(String visitId) =>
      '/visits/$visitId';


  // ------------------------------------------------------------
  // Get Visits By Partner - V1
  // GET /api/v1/visits/partner/:partnerId
  // ------------------------------------------------------------

  static String getVisitsByPartner(String partnerId) =>
      '/v1/visits/partner/$partnerId';


  // ------------------------------------------------------------
  // Visit Summary
  // GET /api/v1/visits/summary
  // ------------------------------------------------------------

  static const String visitSummary =
      '/v1/visits/summary';


  // ============================================================
  // SELLER ENDPOINTS - V1
  // ============================================================

  // ============================================================
  // SELLER APPLICATION / REGISTRATION
  // ============================================================

  // ------------------------------------------------------------
  // Register Seller Application
  // POST /api/v1/sellers/applications/register
  // ------------------------------------------------------------

  static const String registerSellerApplication =
      '/v1/sellers/applications/register';


  // ------------------------------------------------------------
  // Resend Seller Email OTP
  // POST /api/v1/sellers/applications/resend-email-otp
  // ------------------------------------------------------------

  static const String resendSellerEmailOtp =
      '/v1/sellers/applications/resend-email-otp';


  // ------------------------------------------------------------
  // Resend Seller Phone OTP
  // POST /api/v1/sellers/applications/resend-phone-otp
  // ------------------------------------------------------------

  static const String resendSellerPhoneOtp =
      '/v1/sellers/applications/resend-phone-otp';


  // ------------------------------------------------------------
  // Verify Seller Email OTP
  // POST /api/v1/sellers/applications/verify-email
  // ------------------------------------------------------------

  static const String verifySellerEmailOtp =
      '/v1/sellers/applications/verify-email';


  // ------------------------------------------------------------
  // Verify Seller Phone OTP
  // POST /api/v1/sellers/applications/verify-phone
  // ------------------------------------------------------------

  static const String verifySellerPhoneOtp =
      '/v1/sellers/applications/verify-phone';


  // ============================================================
  // SELLER AUTH
  // ============================================================

  // ------------------------------------------------------------
  // Seller Login
  // POST /api/v1/sellers/auth/login
  // ------------------------------------------------------------

  static const String sellerLogin =
      '/v1/sellers/auth/login';


  // ------------------------------------------------------------
  // Send Seller Login OTP
  // POST /api/v1/sellers/auth/send-login-otp
  // ------------------------------------------------------------

  static const String sendSellerLoginOtp =
      '/v1/sellers/auth/send-login-otp';


  // ------------------------------------------------------------
  // Seller Login With OTP
  // POST /api/v1/sellers/auth/login-with-otp
  // ------------------------------------------------------------

  static const String sellerLoginWithOtp =
      '/v1/sellers/auth/login-with-otp';


  // ------------------------------------------------------------
  // Change Seller Password
  // PATCH /api/v1/sellers/auth/change-password
  // ------------------------------------------------------------

  static const String changeSellerPassword =
      '/v1/sellers/auth/change-password';


  // ============================================================
  // SELLER MANAGEMENT
  // ============================================================

  // ------------------------------------------------------------
  // Get All Sellers
  // GET /api/v1/sellers
  //
  // Query:
  // $or, city, isVerified, search, verified
  // ------------------------------------------------------------

  static const String getAllSellers =
      '/v1/sellers';


  // ------------------------------------------------------------
  // Get Seller By ID
  // GET /api/v1/sellers/:id
  // ------------------------------------------------------------

  static String getSellerById(String sellerId) =>
      '/v1/sellers/$sellerId';


  // ------------------------------------------------------------
  // Get Seller Summary
  // GET /api/v1/sellers/:id/summary
  // ------------------------------------------------------------

  static String getSellerSummary(String sellerId) =>
      '/v1/sellers/$sellerId/summary';


  // ------------------------------------------------------------
  // Get Seller Properties
  // GET /api/v1/sellers/:id/properties
  // ------------------------------------------------------------

  static String getSellerProperties(String sellerId) =>
      '/v1/sellers/$sellerId/properties';


  // ------------------------------------------------------------
  // Get Seller Property By ID
  // GET /api/v1/sellers/:sellerId/properties/:propertyId
  // ------------------------------------------------------------

  static String getSellerPropertyById(
      String sellerId,
      String propertyId,
      ) =>
      '/v1/sellers/$sellerId/properties/$propertyId';


  // ============================================================
  // SELLER HOME - SUPPORTING APIs
  // ============================================================
  //
  // These are not part of the 14 Seller-specific APIs.
  // They are used by Seller Home for leads, promotions,
  // visits and partner-related information.
  // ============================================================

  // ------------------------------------------------------------
  // Seller/Partner Leads
  // GET /api/v1/leads/partner/:partnerId
  // ------------------------------------------------------------

  static String sellerPartnerLeads(String partnerId) =>
      '/v1/leads/partner/$partnerId';


  // ------------------------------------------------------------
  // Seller My Promotions
  // GET /api/v1/promotions/my
  // ------------------------------------------------------------

  static const String sellerMyPromotions =
      '/v1/promotions/my';


  // ------------------------------------------------------------
  // Seller/Partner Visits
  // GET /api/v1/visits/partner/:partnerId
  // ------------------------------------------------------------

  static String sellerPartnerVisits(String partnerId) =>
      '/v1/visits/partner/$partnerId';


  // ============================================================
  // PROPERTY PUBLISHING
  // ============================================================

  // ------------------------------------------------------------
  // Final Review Property
  // GET /api/v1/property-publishing/:id/final-review
  // Admin Bearer
  // ------------------------------------------------------------

  static String finalReviewProperty(String propertyId) =>
      '/v1/property-publishing/$propertyId/final-review';


  // ============================================================
  // TIMEOUT
  // ============================================================

  static const int connectTimeout = 60000;

  static const int receiveTimeout = 60000;

  static const int sendTimeout = 60000;


  // ============================================================
  // HEADERS
  // ============================================================

  static const String authHeader =
      'Authorization';

  static const String contentTypeHeader =
      'Content-Type';
}