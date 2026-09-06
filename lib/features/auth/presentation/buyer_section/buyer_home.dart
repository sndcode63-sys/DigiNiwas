import 'dart:convert';

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
import '../../../../core/utils/shimmer.dart';
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
    setState(() => _categoryFilterLoading = true);
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
      body: _isLoading ? const HomeShimmer() : _buildBody(),
      bottomNavigationBar: _isLoading ? null : _buildBottomNav(),
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
            _buildSectionTitle('Recommended For You', showViewAll: true),
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: items.map((item) {
          final (icon, label, iconColor, bgColor) = item;
          return Expanded(
            child: GestureDetector(
              onTap: () => _loadCategoryFilter(tab: label),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                height: 78.h,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16.r),
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
    final properties = _homeFeed?.recommendedProperties ?? [];
    if (properties.isEmpty) {
      return _buildEmptySectionMessage('No recommended properties available.');
    }

    return SizedBox(
      height: 380.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: properties.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = properties[index];

          return GestureDetector(
            onTap: () {
              context.push(AppRoutes.propertyDetails, extra: {'property': item.toJson()});
            },
            child: Container(
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
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                        child: Image.network(
                          item.images?.isNotEmpty == true ? item.images!.first.url ?? '' : '',
                          width: 278.w,
                          height: 208.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 278.w,
                            height: 208.h,
                            color: const Color(0xFFF1F6F8),
                            child: Icon(Icons.home_work_rounded, color: const Color(0xFF007A5E), size: 34.sp),
                          ),
                        ),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? 'Property',
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
                                '${item.locality ?? ''}, ${item.city ?? ''}',
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
                              child: Text('${item.bedrooms ?? '0'} BHK', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6.r)),
                              child: Text(item.furnishing ?? 'Ready', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '₹ ${item.price ?? 0}',
                          style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.3),
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

  Widget _buildHorizontalSectionShimmer({required double height}) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Container(
          width: 180.w,
          margin: EdgeInsets.only(right: 14.w),
          child: ShimmerWidget.box(borderRadius: 16, height: height),
        ),
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
      return _buildHorizontalSectionShimmer(height: 130.h);
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
          height: 130.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: properties.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = properties[index];
              return Container(
                width: 240.w,
                margin: EdgeInsets.only(right: 14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
                ),
                child: Center(child: Text(item.toString())),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExploreMap() {
    // Agarexplore data load ho raha hai ya nahi hai, toh shimmer ya placeholder dikhayein
    if (_exploreLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ShimmerWidget.box(borderRadius: 20, height: 190.h),
      );
    }

    final explore = _exploreNearby;
    final mapDetails = explore?.map;

    // Backend se center coordinates lein, warna default set karein
    final centerLocation = mapDetails?.center != null
        ? LatLng(mapDetails!.center!.latitude ?? 22.7533, mapDetails.center!.longitude ?? 75.8937)
        : const LatLng(22.7533, 75.8937);

    // Map markers ko FlutterMap ke markers mein convert karna
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
                  // Marker click par aap yahan info dialog ya bottom sheet dikha sakte hain
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
                  // Bottom overlay info on map
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
                              // Full screen map view par navigate karne ke liye
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
      return _buildHorizontalSectionShimmer(height: 199.5.h);
    }
    final listings = _newListingsData?.properties ?? [];
    if (listings.isEmpty) {
      return _buildEmptySectionMessage('No new listings near you yet.');
    }

    return SizedBox(
      height: 199.5.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: listings.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = listings[index];
          return Container(
            width: 200.w,
            margin: EdgeInsets.only(right: 14.w),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title ?? '', maxLines: 1, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                SizedBox(height: 4.h),
                Text(item.listedAgo ?? '', style: GoogleFonts.poppins(color: const Color(0xFF007A5E))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularAreas() {
    if (_popularLoading) {
      return _buildHorizontalSectionShimmer(height: 171.h);
    }
    final areas = _popularLocationsData?.areas ?? [];
    if (areas.isEmpty) {
      return _buildEmptySectionMessage('No popular areas available.');
    }

    return SizedBox(
      height: 171.h,
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
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(area.locality ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                SizedBox(height: 4.h),
                Text('${area.propertyCount ?? 0} Properties', style: GoogleFonts.poppins(color: const Color(0xFF94A3B8))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerifiedAgent() {
    if (_agentsLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ShimmerWidget.box(borderRadius: 20, height: 82.h),
      );
    }
    final agents = _agentsData?.agents ?? [];
    if (agents.isEmpty) {
      return _buildEmptySectionMessage('No verified agents found near you yet.');
    }

    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        physics: const BouncingScrollPhysics(),
        itemCount: agents.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final agent = agents[index];
          return Container(
            width: 300.w,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
            ),
            child: Row(
              children: [
                CircleAvatar(child: Text(agent.name?.substring(0, 1) ?? 'A')),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(agent.name ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                      Text(agent.role ?? '', style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF007A5E))),
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

  Widget _buildFutureEcosystem() {
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
          Text(
            'Future Ecosystem Coming Soon',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

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
        ],
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required int index}) {
    final isSelected = _bottomNavIndex == index;
    return InkWell(
      onTap: () => setState(() => _bottomNavIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF007A5E) : const Color(0xFF7D8C99)),
          Text(label, style: GoogleFonts.poppins(fontSize: 10.sp, color: isSelected ? const Color(0xFF007A5E) : const Color(0xFF7D8C99))),
        ],
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
