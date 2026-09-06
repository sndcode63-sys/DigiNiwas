import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:diginiwas/features/auth/presentation/buyer_section/property_details_screen.dart';
import 'package:diginiwas/features/auth/presentation/buyer_section/save_properties_screen.dart';
import 'package:diginiwas/features/auth/presentation/buyer_section/show_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/models/buer_dashboard_model.dart';
import '../../../../core/models/explore_property.dart';
import '../../../../core/models/near_by_agent.dart';
import '../../../../core/models/popular_property.dart';
import '../../../../core/models/propertt_category_filter.dart';
import '../../../../core/models/property_boosted.dart';
import '../../../../core/models/property_new_listing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/models/home_feed_model.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/home_repository.dart';
import 'exprole_name.dart';
import 'niwas_ai_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _homeRepository = HomeRepository(ApiService.instance);

  bool _isLoading = true;
  String? _error;

  // Model states for all API endpoints
  HomeFeedModel? _homeFeed;
  BuerDashboardModel? _dashboardHeader;
  PopularProperty? _popularLocationsData;
  ProperttCategoryFilter? _categoryFilterData;
  PropertyBoosted? _boostedData;
  PropertyNewListing? _newListingsData;
  NearByAgent? _agentsData;
  ExploreNearbyData? _exploreNearby;

  // Independent loading flags for secondary sections
  bool _dashboardLoading = true;
  bool _popularLoading = true;
  bool _categoryFilterLoading = true;
  bool _boostedLoading = true;
  bool _newListingsLoading = true;
  bool _agentsLoading = true;
  bool _exploreLoading = true;

  String _buyerName = 'Guest';
  int _bottomNavIndex = 0;
  String? _selectedCategoryTab;

  @override
  void initState() {
    super.initState();
    _loadBuyerName();
    _loadHomeFeed();
    _loadAllApiSections();
  }

  Future<void> _loadBuyerName() async {
    final raw = await SecureStorageService.instance.getUserData();
    if (raw == null || raw.isEmpty || !mounted) return;
    try {
      final user = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final name = (user['name'] as String?)?.trim();
      if (name != null && name.isNotEmpty) {
        setState(() => _buyerName = name.split(' ').first);
      }
    } catch (_) {}
  }

  /// 1. GET /api/v1/home/feed
  Future<void> _loadHomeFeed() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final feed = await _homeRepository.getHomeFeed();
      if (!mounted) return;
      setState(() {
        _homeFeed = feed;
        _isLoading = false;
      });
      // Trigger explore nearby once we have the recommended property anchor
      _loadExploreNearby();
    } on HomeFeedException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong while loading the home feed.';
        _isLoading = false;
      });
    }
  }

  /// Kicks off all secondary API calls independently in parallel.
  void _loadAllApiSections() {
    _loadDashboardHeader();
    _loadPopularLocations();
    _loadCategoryFilter();
    _loadBoostedProperties();
    _loadNewListings();
    _loadNearbyAgents();
  }

  /// 2. GET /api/v1/user/dashboard-header
  Future<void> _loadDashboardHeader() async {
    setState(() => _dashboardLoading = true);
    try {
      final header = await _homeRepository.getDashboardHeader();
      if (!mounted) return;
      setState(() {
        _dashboardHeader = header;
        _dashboardLoading = false;
        if (header.user?.name != null && header.user!.name!.isNotEmpty) {
          _buyerName = header.user!.name!.split(' ').first;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _dashboardLoading = false);
    }
  }

  /// 3. GET /api/v1/locations/popular
  Future<void> _loadPopularLocations() async {
    setState(() => _popularLoading = true);
    try {
      final popular = await _homeRepository.getPopularLocations();
      if (!mounted) return;
      setState(() {
        _popularLocationsData = popular;
        _popularLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _popularLoading = false);
    }
  }

  /// 4. GET /api/v1/properties/categories
  Future<void> _loadCategoryFilter({String? tab}) async {
    setState(() {
      _categoryFilterLoading = true;
      _selectedCategoryTab = tab;
    });
    try {
      final filter = await _homeRepository.getPropertyCategoryFilter(tab: tab);
      if (!mounted) return;
      setState(() {
        _categoryFilterData = filter;
        _categoryFilterLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _categoryFilterLoading = false);
    }
  }

  /// 5. GET /api/v1/properties/boosted
  Future<void> _loadBoostedProperties() async {
    setState(() => _boostedLoading = true);
    try {
      final boosted = await _homeRepository.getBoostedPropertiesList();
      if (!mounted) return;
      setState(() {
        _boostedData = boosted;
        _boostedLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _boostedLoading = false);
    }
  }

  /// 6. GET /api/v1/properties/new-listings
  Future<void> _loadNewListings() async {
    setState(() => _newListingsLoading = true);
    try {
      final listings = await _homeRepository.getNewListingsList();
      if (!mounted) return;
      setState(() {
        _newListingsData = listings;
        _newListingsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _newListingsLoading = false);
    }
  }

  /// 7. GET /api/v1/agents/nearby
  Future<void> _loadNearbyAgents() async {
    setState(() => _agentsLoading = true);
    try {
      final agents = await _homeRepository.getNearbyAgentsList();
      if (!mounted) return;
      setState(() {
        _agentsData = agents;
        _agentsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _agentsLoading = false);
    }
  }

  /// 8. GET /api/v1/properties/explore-nearby?propertyId=...
  Future<void> _loadExploreNearby() async {
    final propertyId = _homeFeed?.recommendedProperties?.first.propertyId;
    if (propertyId == null || propertyId.isEmpty) {
      if (mounted) setState(() => _exploreLoading = false);
      return;
    }
    setState(() => _exploreLoading = true);
    try {
      final result = await _homeRepository.getExploreNearby(propertyId: propertyId);
      if (!mounted) return;
      setState(() {
        _exploreNearby = result;
        _exploreLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _exploreLoading = false);
    }
  }

  Future<void> _refreshAll() async {
    await _loadHomeFeed();
    _loadAllApiSections();
  }

  String _greetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: _isLoading ? _buildLoadingView() : _buildBody(),
      bottomNavigationBar: _isLoading ? null : _buildBottomNav(),
    );
  }

  /// Simple, non-shimmer loading state shown while the primary home feed loads.
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF007A5E),
      ),
    );
  }

  /// Small inline loader used for secondary sections that load independently.
  Widget _sectionLoader({double height = 120}) {
    return SizedBox(
      height: height.h,
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF007A5E)),
        ),
      ),
    );
  }

  /// Fully dynamic, cached network image with graceful loading + error states.
  /// Every property/agent/area image on this screen goes through this so
  /// caching behaviour stays consistent everywhere.
  Widget _cachedImage(
      String? url, {
        required double width,
        required double height,
        BoxFit fit = BoxFit.cover,
        IconData fallbackIcon = Icons.home_work_rounded,
        BorderRadius? borderRadius,
      }) {
    Widget image;
    if (url == null || url.trim().isEmpty) {
      image = _imageFallback(width: width, height: height, icon: fallbackIcon);
    } else {
      image = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, _) => Container(
          width: width,
          height: height,
          color: const Color(0xFFF1F6F8),
          alignment: Alignment.center,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF007A5E).withOpacity(0.6)),
          ),
        ),
        errorWidget: (context, _, __) => _imageFallback(width: width, height: height, icon: fallbackIcon),
      );
    }
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: image);
    }
    return image;
  }

  Widget _imageFallback({required double width, required double height, required IconData icon}) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF1F6F8),
      alignment: Alignment.center,
      child: Icon(icon, color: const Color(0xFF007A5E), size: (height * 0.18).clamp(18, 40).toDouble()),
    );
  }

  Widget _buildBody() {
    switch (_bottomNavIndex) {
      case 0:
        return _buildContent();
      case 1:
        return ExproleName();
      case 2:
        return const NiwasAiScreen();
      case 3:
        return const SavedPropertiesScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildContent();
    }
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      color: const Color(0xFF007A5E),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_error != null) _buildFeedErrorBanner(),
            SizedBox(height: 14.h),
            _buildCategoryChips(),
            SizedBox(height: 14.h),
            _buildSectionTitle('Quick AI Discovery'),
            SizedBox(height: 8.h),
            _buildQuickAiGrid(),
            SizedBox(height: 14.h),
            _buildSectionTitle(
              _selectedCategoryTab != null ? '${_selectedCategoryTab!} Properties' : 'Recommended For You',
              showViewAll: _selectedCategoryTab == null,
            ),
            SizedBox(height: 8.h),
            _buildRecommendedCards(),
            SizedBox(height: 18.h),
            _buildBoostedSection(),
            SizedBox(height: 18.h),
            _buildSectionTitle('Explore Near You'),
            SizedBox(height: 8.h),
            _buildExploreMap(),
            SizedBox(height: 18.h),
            _buildSectionTitle('New Listings', showViewAll: true),
            SizedBox(height: 8.h),
            _buildNewListings(),
            SizedBox(height: 18.h),
            _buildSectionTitle(
              _homeFeed?.location?.city != null && _homeFeed!.location!.city!.isNotEmpty
                  ? 'Popular near ${_homeFeed!.location!.city}'
                  : 'Popular Near You',
            ),
            SizedBox(height: 8.h),
            _buildPopularAreas(),
            SizedBox(height: 18.h),
            _buildSectionTitle('Verified Agents Near You'),
            SizedBox(height: 8.h),
            _buildVerifiedAgent(),
            SizedBox(height: 22.h),
            _buildFutureEcosystem(),
            SizedBox(height: 110.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedErrorBanner() {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF5B5B5)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: const Color(0xFFC62828), size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _error ?? 'Could not load home feed.',
              style: GoogleFonts.poppins(fontSize: 11.5.sp, color: const Color(0xFFC62828)),
            ),
          ),
          TextButton(
            onPressed: _loadHomeFeed,
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFFC62828)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final locationLabel = _dashboardHeader?.location?.city?.isNotEmpty == true
        ? '${_dashboardHeader!.location!.city}, ${_dashboardHeader!.location!.state ?? ''}'
        : (_homeFeed?.location?.city?.isNotEmpty == true
        ? '${_homeFeed!.location!.city}, ${_homeFeed!.location!.state ?? ''}'
        : 'Fetching location...');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 44.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2544),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_work_rounded, color: const Color(0xFF00A884), size: 18.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'DIGINIWAS',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F2544),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20.sp),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 10.w,
                    child: Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFA8E6CF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _buyerName.isNotEmpty ? _buyerName.substring(0, 2).toUpperCase() : 'RH',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0F2544),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_outlined, color: const Color(0xFF4EE1A0), size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                locationLabel,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 16.sp),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            _dashboardHeader?.greeting ?? '${_greetingByTime()}, $_buyerName',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: const Color(0xFF4EE1A0), size: 14.sp),
              SizedBox(width: 6.w),
              Text(
                'Verified homes match your preferences',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFB0C3D9),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: const Color(0xFF8C9BAE), size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Search locality, property or budget',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF9AA8B8),
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(Icons.auto_awesome, color: const Color(0xFF007A5E), size: 18.sp),
                SizedBox(width: 10.w),
                Container(
                  height: 16.h,
                  width: 1.w,
                  color: Colors.grey.shade300,
                ),
                SizedBox(width: 10.w),
                Icon(Icons.mic_none_rounded, color: const Color(0xFF8C9BAE), size: 20.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final items = [
      (Icons.real_estate_agent_outlined, 'Buy', const Color(0xFF007A5E), const Color(0xFFEFF8F5)),
      (Icons.key_outlined, 'Rent', const Color(0xFF2F70F2), const Color(0xFFEEF4FE)),
      (Icons.landscape_outlined, 'Plot', const Color(0xFF00966B), const Color(0xFFEEF8F4)),
      (Icons.apartment_outlined, 'Commercial', const Color(0xFF8E54E9), const Color(0xFFF5EEFD)),
    ];

    // Dynamic counts coming straight from the categories filter API.
    final apiCategories = _categoryFilterData?.categories ?? [];
    int? countFor(String label) {
      for (final c in apiCategories) {
        if ((c.name ?? '').toLowerCase() == label.toLowerCase()) return c.count;
      }
      return null;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: items.map((item) {
          final (icon, label, iconColor, bgColor) = item;
          final isSelected = _selectedCategoryTab == label;
          final count = countFor(label);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (isSelected) {
                  // Tap again to clear the active filter.
                  setState(() => _selectedCategoryTab = null);
                } else {
                  _loadCategoryFilter(tab: label);
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                height: 78.h,
                decoration: BoxDecoration(
                  color: isSelected ? iconColor.withOpacity(0.14) : bgColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: isSelected ? Border.all(color: iconColor, width: 1.4) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, color: iconColor, size: 24.sp),
                    SizedBox(height: 6.h),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F2544),
                      ),
                    ),
                    if (isSelected && count != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        '$count found',
                        style: GoogleFonts.poppins(fontSize: 8.5.sp, fontWeight: FontWeight.w500, color: iconColor),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showViewAll = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          if (showViewAll)
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF007A5E),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10.sp, color: const Color(0xFF007A5E)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAiGrid() {
    final items = [
      (Icons.auto_awesome, 'Find My Home', 'AI-matched'),
      (Icons.compare_arrows_rounded, 'Compare Homes', 'Side-by-side'),
      (Icons.travel_explore_rounded, 'Explore Locality', 'Insights'),
      (Icons.calculate_outlined, 'Budget & EMI', 'Smart planning'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1.45,
        ),
        itemBuilder: (context, index) {
          final (icon, title, subtitle) = items[index];
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6F2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, color: const Color(0xFF005B48), size: 18.sp),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F2544),
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF7A8B99),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedCards() {
    // When a category chip (Buy/Rent/Plot/Commercial) is active, this section
    // swaps to show that filter's results instead of the default home-feed
    // recommendations — tapping a tab changes what's shown right here.
    if (_selectedCategoryTab != null) {
      if (_categoryFilterLoading) {
        return _sectionLoader(height: 380);
      }
      final filtered = _categoryFilterData?.properties ?? [];
      if (filtered.isEmpty) {
        return _buildEmptySectionMessage('No ${_selectedCategoryTab!} properties found near you.');
      }
      return _recommendedCardsList(
        count: filtered.length,
        titleAt: (i) => filtered[i].title,
        localityAt: (i) => filtered[i].locality,
        cityAt: (i) => filtered[i].city,
        bedroomsAt: (i) => filtered[i].bedrooms,
        furnishingAt: (i) => filtered[i].furnishing,
        priceAt: (i) => filtered[i].price,
        imageUrlAt: (i) => filtered[i].images?.isNotEmpty == true ? filtered[i].images!.first.url : null,
        jsonAt: (i) => filtered[i].toJson(),
      );
    }

    final properties = _homeFeed?.recommendedProperties ?? [];
    if (properties.isEmpty) {
      return _buildEmptySectionMessage('No recommended properties available.');
    }
    return _recommendedCardsList(
      count: properties.length,
      titleAt: (i) => properties[i].title,
      localityAt: (i) => properties[i].locality,
      cityAt: (i) => properties[i].city,
      bedroomsAt: (i) => properties[i].bedrooms,
      furnishingAt: (i) => properties[i].furnishing,
      priceAt: (i) => properties[i].price,
      imageUrlAt: (i) => properties[i].images?.isNotEmpty == true ? properties[i].images!.first.url : null,
      jsonAt: (i) => properties[i].toJson(),
    );
  }

  /// Shared card list UI — used for both the default recommended feed and
  /// the active category-filter results, so the look stays identical.
  Widget _recommendedCardsList({
    required int count,
    required String? Function(int) titleAt,
    required String? Function(int) localityAt,
    required String? Function(int) cityAt,
    required String? Function(int) bedroomsAt,
    required String? Function(int) furnishingAt,
    required int? Function(int) priceAt,
    required String? Function(int) imageUrlAt,
    required Map<String, dynamic> Function(int) jsonAt,
  }) {
    return SizedBox(
      height: 380.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: count,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            width: 280.w,
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tapping the image/top area also opens details
                GestureDetector(
                  onTap: () {
                    context.push(
                      AppRoutes.propertyDetails,
                      extra: {'property': jsonAt(index)},
                    );
                  },
                  child: Stack(
                    children: [
                      _cachedImage(
                        imageUrlAt(index),
                        width: 278.w,
                        height: 208.h,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                      ),
                      Positioned(
                        top: 10.h,
                        left: 10.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 12.sp, color: const Color(0xFF007A5E)),
                              SizedBox(width: 4.w),
                              Text(
                                'Verified',
                                style: GoogleFonts.poppins(fontSize: 9.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF007A5E)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleAt(index) ?? 'Property',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 14.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12.sp, color: const Color(0xFF64748B)),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              '${localityAt(index) ?? ''}, ${cityAt(index) ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 10.5.sp, color: const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6.r)),
                            child: Text('${bedroomsAt(index) ?? '0'} BHK', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6.r)),
                            child: Text(furnishingAt(index) ?? 'Ready', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '₹ ${priceAt(index) ?? 0}',
                        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.3),
                      ),
                    ],
                  ),
                ),

                // VIEW button — uses jsonAt(index), NOT `item`
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: const Color(0xFFA7F3D0),
                      borderRadius: BorderRadius.circular(10.r),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        onTap: () {
                          context.push(
                            AppRoutes.propertyDetails,
                            extra: {'property': jsonAt(index)},
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Center(
                            child: Text(
                              'VIEW',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F2544),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildEmptySectionMessage(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFEDF2F7)),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _buildBoostedSection() {
    if (_boostedLoading) {
      return _sectionLoader(height: 190);
    }
    final properties = _boostedData?.properties ?? [];
    if (properties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.bolt_rounded, color: const Color(0xFFE5A000), size: 22.sp),
              SizedBox(width: 4.w),
              Text(
                'Boosted Properties',
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 190.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: properties.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = properties[index];
              return GestureDetector(
                onTap: () => context.push(AppRoutes.propertyDetails, extra: {'property': item.toJson()}),
                child: Container(
                  width: 230.w,
                  margin: EdgeInsets.only(right: 14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          _cachedImage(
                            item.images?.isNotEmpty == true ? item.images!.first.url : null,
                            width: 228.w,
                            height: 110.h,
                            fallbackIcon: Icons.bolt_rounded,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                          ),
                          Positioned(
                            top: 8.h,
                            left: 8.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5A000),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded, size: 11.sp, color: Colors.white),
                                  SizedBox(width: 2.w),
                                  Text('Boosted', style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title ?? 'Property',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${item.locality ?? ''}, ${item.city ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 9.5.sp, color: const Color(0xFF64748B)),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '₹ ${item.price ?? 0}',
                              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExploreMap() {
    if (_exploreLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: _sectionLoader(height: 190),
      );
    }

    final explore = _exploreNearby;
    final mapDetails = explore?.map;

    final centerLocation = mapDetails?.center != null
        ? LatLng(mapDetails!.center!.latitude ?? 22.7533, mapDetails.center!.longitude ?? 75.8937)
        : const LatLng(22.7533, 75.8937);

    final List<Marker> mapMarkers = [];
    if (mapDetails?.markers != null) {
      for (var m in mapDetails!.markers!) {
        if (m.latitude != null && m.longitude != null) {
          final isProperty = m.markerType == 'PROPERTY';
          mapMarkers.add(
            Marker(
              point: LatLng(m.latitude!, m.longitude!),
              width: isProperty ? 36.w : 28.w,
              height: isProperty ? 36.w : 28.w,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${m.name ?? "Location"} (${m.markerType})'))
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isProperty ? const Color(0xFF007A5E) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isProperty ? Colors.white : _amenityColor(m.markerType),
                      width: 2.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isProperty ? Icons.home_rounded : _amenityIcon(m.markerType),
                    color: isProperty ? Colors.white : _amenityColor(m.markerType),
                    size: isProperty ? 18.sp : 14.sp,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Container(
            height: 190.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: centerLocation,
                      initialZoom: mapDetails?.zoom?.toDouble() ?? 14.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.diginiwas',
                      ),
                      MarkerLayer(markers: mapMarkers),
                    ],
                  ),
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                explore?.property?.title ?? 'Explore Nearby Places',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${mapMarkers.length} markers loaded on map',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              context.push(AppRoutes.exploreMap);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F2544),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'View Map',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _amenityColor(String? markerType) {
    switch (markerType) {
      case 'EDUCATION':
        return const Color(0xFF3B82F6);
      case 'HEALTHCARE':
        return const Color(0xFFEF4444);
      case 'FOOD':
        return const Color(0xFFEAB308);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _amenityIcon(String? markerType) {
    switch (markerType) {
      case 'EDUCATION':
        return Icons.school_outlined;
      case 'HEALTHCARE':
        return Icons.local_hospital_outlined;
      case 'FOOD':
        return Icons.restaurant_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  Widget _buildNewListings() {
    if (_newListingsLoading) {
      return _sectionLoader(height: 240);
    }
    final listings = _newListingsData?.properties ?? [];
    if (listings.isEmpty) {
      return _buildEmptySectionMessage('No new listings near you yet.');
    }

    return SizedBox(
      height: 205.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: listings.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = listings[index];
          return GestureDetector(
            onTap: () => context.push(AppRoutes.propertyDetails, extra: {'property': item.toJson()}),
            child: Container(
              width: 200.w,
              margin: EdgeInsets.only(right: 14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _cachedImage(
                        item.images?.isNotEmpty == true ? item.images!.first.url : null,
                        width: 198.w,
                        height: 120.h,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                      ),
                      if ((item.listedAgo ?? '').isNotEmpty)
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007A5E),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              item.listedAgo!,
                              style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? 'Property',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '${item.locality ?? ''}, ${item.city ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF64748B)),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '₹ ${item.price ?? 0}',
                          style: GoogleFonts.poppins(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularAreas() {
    if (_popularLoading) {
      return _sectionLoader(height: 171);
    }
    final areas = _popularLocationsData?.areas ?? [];
    if (areas.isEmpty) {
      return _buildEmptySectionMessage('No popular areas available.');
    }

    return SizedBox(
      height: 150.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: areas.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final area = areas[index];
          return Container(
            width: 171.w,
            margin: EdgeInsets.only(right: 14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _cachedImage(
                      area.sampleImage,
                      width: 169.w,
                      height: 90.h,
                      fallbackIcon: Icons.location_city_rounded,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                    ),
                    if ((area.promotedCount ?? 0) > 0)
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2544),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${area.promotedCount} Promoted',
                            style: GoogleFonts.poppins(fontSize: 8.sp, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.locality ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12.sp, color: const Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${area.propertyCount ?? 0} Properties',
                        style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 10.5.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // VERIFIED AGENTS — card + bottom sheet with the actual agent's data
  // ---------------------------------------------------------------------
  Widget _buildVerifiedAgent() {
    if (_agentsLoading) {
      return _sectionLoader(height: 100);
    }
    final agents = _agentsData?.agents ?? [];
    if (agents.isEmpty) {
      return _buildEmptySectionMessage('No verified agents found near you yet.');
    }

    return SizedBox(
      height: 112.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        physics: const BouncingScrollPhysics(),
        itemCount: agents.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final agent = agents[index];
          final initial = (agent.name?.trim().isNotEmpty == true) ? agent.name!.trim().substring(0, 1).toUpperCase() : 'A';
          final distance = agent.distanceKm;
          final subtitle = agent.business?.businessName?.isNotEmpty == true
              ? agent.business!.businessName!
              : (agent.role ?? 'Real Estate Agent');
          final canCall = agent.contact?.canCall == true && (agent.contact?.phone ?? agent.phone)?.isNotEmpty == true;

          return GestureDetector(
            // Tap anywhere on the card -> open bottom sheet with THIS agent's data
            onTap: () => _showAgentProfileBottomSheet(context, agent),
            child: Container(
              width: 300.w,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: (agent.avatar?.isNotEmpty == true)
                            ? _cachedImage(agent.avatar, width: 48.w, height: 48.w, fallbackIcon: Icons.person)
                            : CircleAvatar(
                          radius: 24.r,
                          backgroundColor: const Color(0xFFA8E6CF),
                          child: Text(initial, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF0F2544))),
                        ),
                      ),
                      if (agent.isVerified == true)
                        Positioned(
                          bottom: -1,
                          right: -1,
                          child: Container(
                            padding: EdgeInsets.all(1.5.w),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(Icons.verified_rounded, size: 13.sp, color: const Color(0xFF007A5E)),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          agent.name ?? 'Agent',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12.5.sp),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 10.5.sp, color: const Color(0xFF007A5E)),
                        ),
                        if (distance != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            '${distance is double ? distance.toStringAsFixed(1) : distance} km away',
                            style: GoogleFonts.poppins(fontSize: 9.5.sp, color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (canCall)
                    GestureDetector(
                      // Stop the tap from bubbling up to the card's onTap (which opens the sheet)
                      onTap: () {
                        final phone = agent.contact?.phone ?? agent.phone;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling $phone...')),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(color: const Color(0xFFEFF8F5), shape: BoxShape.circle),
                        child: Icon(Icons.call_rounded, size: 16.sp, color: const Color(0xFF007A5E)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Bottom sheet showing the tapped agent's real data (name, avatar,
  /// business, role, distance, verification, contact) — pulled straight
  /// from the NearByAgent API response, no hardcoded/demo values.
  void _showAgentProfileBottomSheet(BuildContext context, dynamic agent) {
    final name = agent.name ?? 'Agent';
    final initial = name.trim().isNotEmpty ? name.trim().substring(0, 1).toUpperCase() : 'A';
    final businessName = agent.business?.businessName;
    final role = agent.role ?? 'Real Estate Agent';
    final subtitle = (businessName != null && businessName.isNotEmpty) ? businessName : role;
    final distance = agent.distanceKm;
    final isVerified = agent.isVerified == true;
    final phone = agent.contact?.phone ?? agent.phone;
    final canCall = agent.contact?.canCall == true && (phone != null && phone.toString().isNotEmpty);
    final email = agent.contact?.email ?? agent.email;
    final experienceYears = agent.experienceYears ?? agent.yearsOfExperience;
    final rating = agent.rating;
    final reviewCount = agent.reviewCount ?? agent.reviewsCount;
    final listingsCount = agent.listingsCount ?? agent.activeListingsCount;
    final serviceAreas = agent.serviceAreas ?? agent.areasCovered;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                children: [
                  // Handle + header
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 16.w, 8.h),
                    child: Column(
                      children: [
                        Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Agent Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: Icon(Icons.close_rounded, size: 22.sp, color: const Color(0xFF64748B)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        children: [
                          // Avatar
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40.r),
                                child: (agent.avatar?.isNotEmpty == true)
                                    ? _cachedImage(agent.avatar, width: 80.w, height: 80.w, fallbackIcon: Icons.person)
                                    : Container(
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFA8E6CF),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initial,
                                    style: GoogleFonts.poppins(
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F2544),
                                    ),
                                  ),
                                ),
                              ),
                              if (isVerified)
                                Container(
                                  width: 20.w,
                                  height: 20.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                  ),
                                  child: Icon(Icons.verified_rounded, color: const Color(0xFF00A884), size: 18.sp),
                                ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isVerified) ...[
                            SizedBox(height: 10.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7F2),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: const Color(0xFFBCE7DA), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_user_outlined, size: 13.sp, color: const Color(0xFF007A5E)),
                                  SizedBox(width: 5.w),
                                  Text(
                                    'DigiNiwas Verified Partner',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF007A5E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Dynamic tag chips — only shown when data actually exists
                          if (distance != null || (rating != null) || experienceYears != null) ...[
                            SizedBox(height: 14.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              alignment: WrapAlignment.center,
                              children: [
                                if (rating != null) _tagBadge('⭐ $rating${reviewCount != null ? ' ($reviewCount reviews)' : ''}'),
                                if (experienceYears != null) _tagBadge('🏢 $experienceYears+ yrs experience'),
                                if (distance != null)
                                  _tagBadge('📍 ${distance is double ? distance.toStringAsFixed(1) : distance} km away'),
                              ],
                            ),
                          ],

                          if (serviceAreas != null && (serviceAreas as List).isNotEmpty) ...[
                            SizedBox(height: 14.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Service Areas',
                                style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: serviceAreas.map<Widget>((a) => _tagBadge('$a')).toList(),
                            ),
                          ],

                          if (listingsCount != null) ...[
                            SizedBox(height: 20.h),
                            Row(
                              children: [
                                Expanded(child: _kpiCard('$listingsCount', 'Active Listings')),
                                if (email != null) ...[
                                  SizedBox(width: 10.w),
                                  Expanded(child: _kpiCard(isVerified ? 'Yes' : 'No', 'Verified')),
                                ],
                              ],
                            ),
                          ],

                          if (phone != null && phone.toString().isNotEmpty) ...[
                            SizedBox(height: 18.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: const Color(0xFFEDF2F7)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.phone_outlined, size: 16.sp, color: const Color(0xFF007A5E)),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      '$phone',
                                      style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (email != null && email.toString().isNotEmpty) ...[
                            SizedBox(height: 10.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: const Color(0xFFEDF2F7)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.email_outlined, size: 16.sp, color: const Color(0xFF007A5E)),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      '$email',
                                      style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(content: Text('Message $name')),
                              );
                            },
                            icon: Icon(Icons.chat_bubble_outline_rounded, size: 16.sp),
                            label: Text('Message', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF007A5E),
                              side: const BorderSide(color: Color(0xFF007A5E), width: 1.4),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: canCall
                                ? () {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(content: Text('Calling $phone...')),
                              );
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005B48),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Call Agent', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                                SizedBox(width: 6.w),
                                Icon(Icons.call_rounded, size: 16.sp),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _tagBadge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _kpiCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF007A5E),
              height: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: const Color(0xFF64748B),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // FUTURE ECOSYSTEM
  // ---------------------------------------------------------------------
  Widget _buildFutureEcosystem() {
    final services = [
      (Icons.plumbing, 'Plumbing', 'Find trusted plumbing\nservices near you.'),
      (Icons.shopping_cart_outlined, 'Groceries', 'Get daily groceries\ndelivered to your home.'),
      (Icons.videocam_outlined, 'Video Editing', 'Professional\nvideo editing.'),
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.turquoise.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hub_outlined, size: 13.sp, color: AppColors.turquoise),
                SizedBox(width: 6.w),
                Text(
                  'FUTURE ECOSYSTEM',
                  style: GoogleFonts.poppins(
                    color: AppColors.turquoise,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Beyond Properties, Endless\nPossibilities.',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 21.sp,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'DigiNiwas is building an ecosystem that makes life easier for customers and helps businesses grow together.',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12.5.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 18.h),
          SizedBox(
            height: 160.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: services.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final (icon, title, desc) = services[index];
                return Container(
                  width: 150.w,
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: AppColors.turquoise, size: 22.sp),
                      SizedBox(height: 10.h),
                      Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4.h),
                      Text(desc, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10.5.sp, height: 1.3)),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.turquoise.withOpacity(0.5)),
                        ),
                        child: Center(
                          child: Text(
                            'Coming Soon',
                            style: GoogleFonts.poppins(color: AppColors.turquoise, fontSize: 10.5.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // FLOATING FROSTED GLASS BOTTOM NAVIGATION BAR
  // ---------------------------------------------------------------------
  Widget _buildBottomNav() {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 64.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(26.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(icon: Icons.home_outlined, label: 'Home', index: 0),
                _navItem(icon: Icons.explore_outlined, label: 'Explore', index: 1),
                SizedBox(width: 52.w),
                _navItem(icon: Icons.favorite_border_rounded, label: 'Saved', index: 3),
                _navItem(icon: Icons.person_outline_rounded, label: 'Profile', index: 4),
              ],
            ),
          ),
          Positioned(
            top: -20.h,
            child: GestureDetector(
              onTap: () => setState(() => _bottomNavIndex = 2),
              child: Container(
                width: 58.w,
                height: 58.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF004D40),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4.w),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF004D40).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(Icons.smart_toy_outlined, color: Colors.white, size: 26.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required int index}) {
    final isSelected = _bottomNavIndex == index;
    const activeColor = Color(0xFF007A5E);
    const inactiveColor = Color(0xFF7D8C99);

    return InkWell(
      onTap: () => setState(() => _bottomNavIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? activeColor : inactiveColor, size: 22.sp),
            SizedBox(height: 3.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10.5.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// FULL-SCREEN EXPLORE MAP VIEW SCREEN
// =====================================================================
class ExploreMapViewScreen extends StatelessWidget {
  const ExploreMapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final centerLocation = const LatLng(30.3782, 76.7767);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: centerLocation,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.diginiwas',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(30.3850, 76.7680),
                    width: 75.w,
                    height: 32.h,
                    child: _buildPin('₹78L'),
                  ),
                  Marker(
                    point: const LatLng(30.3720, 76.7900),
                    width: 85.w,
                    height: 32.h,
                    child: _buildPin('₹1.2Cr'),
                  ),
                  Marker(
                    point: const LatLng(30.3680, 76.7600),
                    width: 75.w,
                    height: 32.h,
                    child: _buildGreenPin('₹65L'),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 48.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.arrow_back, color: const Color(0xFF0F2544), size: 20.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: const Color(0xFF007A5E), size: 18.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'Ambala Cantt Properties',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F2544),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPin(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2544),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildGreenPin(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF007A5E),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_rounded, color: Colors.white, size: 10.sp),
          SizedBox(width: 3.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
