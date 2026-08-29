import 'dart:ui';
import 'package:diginiwas/features/auth/presentation/buyer_section/property_details_screen.dart';
import 'package:diginiwas/features/auth/presentation/buyer_section/save_properties_screen.dart';
import 'package:diginiwas/features/auth/presentation/buyer_section/show_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/shimmer.dart';
import 'exprole_name.dart';
import 'niwas_ai_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
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

  // ---------------------------------------------------------------------
  // TAB NAVIGATION SWITCHER
  // ---------------------------------------------------------------------
// ---------------------------------------------------------------------
  // TAB NAVIGATION SWITCHER
  // ---------------------------------------------------------------------
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
  Widget _buildTabPlaceholder(String title, Color bgColor, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64.sp, color: iconColor),
            SizedBox(height: 12.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // MAIN CONTENT (HOME TAB)
  // ---------------------------------------------------------------------
  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
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
          _buildSectionTitle('Popular in Ambala'),
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
    );
  }

  // ---------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------
  Widget _buildHeader() {
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
                  'RH',
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
                'Ambala, Haryana',
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
            'Good Morning, Rahul',
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
                '3 verified homes match your preferences',
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

  // ---------------------------------------------------------------------
  // CATEGORY CHIPS
  // ---------------------------------------------------------------------
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
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------
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
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10.sp,
                    color: const Color(0xFF007A5E),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // QUICK AI DISCOVERY
  // ---------------------------------------------------------------------
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
                    child: Icon(
                      icon,
                      color: const Color(0xFF005B48),
                      size: 18.sp,
                    ),
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

  // ---------------------------------------------------------------------
  // RECOMMENDED FOR YOU
  // ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// RECOMMENDED FOR YOU (UPDATED WITH ONTAP NAVIGATION)
// ---------------------------------------------------------------------
  Widget _buildRecommendedCards() {
    final properties = [
      {
        'name': 'Celestial Heights',
        'address': 'Bopal, Ahmedabad',
        'bhk': '2 BHK',
        'sqft': '1,240 sq.ft',
        'status': 'Ready to Move',
        'price': '₹85 L',
        'image': 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&auto=format&fit=crop&q=80',
      },
      {
        'name': 'Sunset Villa Elite',
        'address': 'Cantt Area, Ambala',
        'bhk': '4 BHK Villa',
        'sqft': '2,400 sq.ft',
        'status': 'Under Construction',
        'price': '₹1.2 Cr',
        'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&auto=format&fit=crop&q=80',
      },
      {
        'name': 'Green Valley Residency',
        'address': 'Model Town, Ambala',
        'bhk': '3 BHK',
        'sqft': '1,650 sq.ft',
        'status': 'Ready to Move',
        'price': '₹78.5 L',
        'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&auto=format&fit=crop&q=80',
      },
    ];

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PropertyDetailsScreen(property: item),
                ),
              );
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
                          item['image']!,
                          width: 278.w,
                          height: 208.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 278.w,
                            height: 208.h,
                            color: const Color(0xFFF1F6F8),
                            child: Icon(
                              Icons.home_work_rounded,
                              color: const Color(0xFF007A5E),
                              size: 34.sp,
                            ),
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
                      Positioned(
                        top: 10.h,
                        right: 10.w,
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(Icons.favorite_border_rounded, size: 16.sp, color: const Color(0xFF475569)),
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
                          item['name']!,
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
                                item['address']!,
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
                              child: Text(item['bhk']!, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6.r)),
                              child: Text(item['status']!, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          item['price']!,
                          style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.3),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7F2),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFFBCE7DA), width: 0.8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 12.sp, color: const Color(0xFF007A5E)),
                              SizedBox(width: 4.w),
                              Text(
                                'View',
                                style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF007A5E)),
                              ),
                            ],
                          ),
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
  // ---------------------------------------------------------------------
  // BOOSTED PROPERTIES
  // ---------------------------------------------------------------------
  Widget _buildBoostedSection() {
    final boostedItems = [
      {
        'title': 'Skyline Apartments',
        'image': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&auto=format&fit=crop&q=80',
        'isBrandLogo': true,
      },
      {
        'title': 'Riverside Heights',
        'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&auto=format&fit=crop&q=80',
        'isBrandLogo': false,
      },
      {
        'title': 'Grand Residency',
        'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=600&auto=format&fit=crop&q=80',
        'isBrandLogo': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.bolt_rounded,
                color: const Color(0xFFE5A000),
                size: 22.sp,
              ),
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
            itemCount: boostedItems.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = boostedItems[index];

              return Container(
                width: 240.w,
                margin: EdgeInsets.only(right: 14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(14.r),
                            ),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: const Color(0xFFF8FAFC),
                              child: item['isBrandLogo'] == true
                                  ? Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.home_work_rounded,
                                      color: const Color(0xFF00A884),
                                      size: 24.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'DIGINIWAS',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F2544),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : Image.network(
                                item['image'] as String,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Icon(
                                    Icons.apartment_rounded,
                                    color: const Color(0xFF007A5E),
                                    size: 26.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6.h,
                            left: 6.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5A000),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bolt_rounded,
                                    size: 10.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Boosted',
                                    style: GoogleFonts.poppins(
                                      fontSize: 8.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      child: Text(
                        item['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
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
    );
  }

  // ---------------------------------------------------------------------
  // EXPLORE NEAR YOU (REAL MAP + AMENITIES)
  // ---------------------------------------------------------------------
  Widget _buildExploreMap() {
    final centerLocation = const LatLng(30.3782, 76.7767);

    final amenities = [
      {'icon': Icons.school_outlined, 'color': const Color(0xFF3B82F6), 'label': 'Schools', 'distance': '1.2km'},
      {'icon': Icons.local_hospital_outlined, 'color': const Color(0xFFEF4444), 'label': 'Hospitals', 'distance': '2.5km'},
      {'icon': Icons.shopping_bag_outlined, 'color': const Color(0xFFF97316), 'label': 'Shopping', 'distance': '800m'},
      {'icon': Icons.directions_subway_outlined, 'color': const Color(0xFF8B5CF6), 'label': 'Metro Station', 'distance': '1.8km'},
      {'icon': Icons.directions_bus_outlined, 'color': const Color(0xFF06B6D4), 'label': 'Bus Stand', 'distance': '500m'},
      {'icon': Icons.park_outlined, 'color': const Color(0xFF10B981), 'label': 'Parks', 'distance': '650m'},
      {'icon': Icons.fitness_center_outlined, 'color': const Color(0xFFEC4899), 'label': 'Gym & Fitness', 'distance': '1.0km'},
      {'icon': Icons.restaurant_outlined, 'color': const Color(0xFFEAB308), 'label': 'Restaurants', 'distance': '900m'},
      {'icon': Icons.local_atm_outlined, 'color': const Color(0xFF14B8A6), 'label': 'Bank & ATM', 'distance': '350m'},
      {'icon': Icons.flight_takeoff_outlined, 'color': const Color(0xFF6366F1), 'label': 'Airport', 'distance': '12.4km'},
    ];

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
                  blurRadius: 14,
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
                      initialZoom: 13.5,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
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
                            width: 70.w,
                            height: 30.h,
                            child: _mapPriceBadge('₹78L'),
                          ),
                          Marker(
                            point: const LatLng(30.3720, 76.7900),
                            width: 80.w,
                            height: 30.h,
                            child: _mapPriceBadge('₹1.2Cr'),
                          ),
                          Marker(
                            point: const LatLng(30.3680, 76.7600),
                            width: 70.w,
                            height: 30.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007A5E),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.home_work_rounded, color: Colors.white, size: 10.sp),
                                  SizedBox(width: 3.w),
                                  Text(
                                    '₹65L',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '24 properties nearby',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'in Ambala Cantt & Model Town',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ExploreMapViewScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F2544),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'View Map',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
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

          SizedBox(height: 12.h),

          // Horizontal Amenities Chips
          SizedBox(
            height: 38.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: amenities.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final item = amenities[index];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 16.sp,
                        color: item['color'] as Color,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        item['label'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if ((item['distance'] as String).isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            item['distance'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
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

  Widget _mapPriceBadge(String label) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2544),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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

  // ---------------------------------------------------------------------
  // NEW LISTINGS (Width: 200.w | Height: 199.5.h)
  // ---------------------------------------------------------------------
  Widget _buildNewListings() {
    final listings = [
      {
        'title': 'Urban Nest',
        'time': 'Just Added',
        'isCustomCard': true,
        'image': '',
      },
      {
        'title': 'The Heights',
        'time': '2 hours ago',
        'isCustomCard': false,
        'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&auto=format&fit=crop&q=80',
      },
      {
        'title': 'Emerald Heights',
        'time': '5 hours ago',
        'isCustomCard': false,
        'image': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&auto=format&fit=crop&q=80',
      },
    ];

    return SizedBox(
      height: 199.5.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: listings.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = listings[index];
          final isCustom = item['isCustomCard'] == true;

          return Container(
            width: 200.w,
            margin: EdgeInsets.only(right: 14.w),
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
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 8.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      height: 125.h,
                      width: double.infinity,
                      color: const Color(0xFFF1F5F9),
                      child: isCustom
                          ? Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 13.r,
                                  backgroundImage: const NetworkImage(
                                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Arjun Khanna',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        'Verified Partner',
                                        style: GoogleFonts.poppins(
                                          fontSize: 8.sp,
                                          color: const Color(0xFF007A5E),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.apartment_rounded, color: const Color(0xFF007A5E), size: 16.sp),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      'Green Valley Residency',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 8.5.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F2544),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                          : Image.network(
                        item['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.home_rounded,
                            color: const Color(0xFF0F2544),
                            size: 28.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item['time'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF007A5E),
                        ),
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
  // POPULAR IN AMBALA (Width: 171.w | Height: 171.h)
  // ---------------------------------------------------------------------
  Widget _buildPopularAreas() {
    final areas = [
      {
        'name': 'Sector 7',
        'count': '120+ Properties',
        'isLogo': true,
        'image': '',
      },
      {
        'name': 'Model Town',
        'count': '85+ Properties',
        'isLogo': false,
        'image': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=600&auto=format&fit=crop&q=80',
      },
      {
        'name': 'Cantt Area',
        'count': '95+ Properties',
        'isLogo': false,
        'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&auto=format&fit=crop&q=80',
      },
    ];

    return SizedBox(
      height: 171.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: areas.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final area = areas[index];
          final isLogo = area['isLogo'] == true;

          return Container(
            width: 171.w,
            margin: EdgeInsets.only(right: 14.w),
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
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 6.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      height: 96.h,
                      width: double.infinity,
                      color: const Color(0xFFF1F5F9),
                      child: isLogo
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home_work_rounded,
                                  color: const Color(0xFF00A884),
                                  size: 22.sp,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'GINIWA',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F2544),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Digital भी , Genuine भी',
                              style: GoogleFonts.poppins(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                          : Image.network(
                        area['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.dashboard_rounded,
                            color: const Color(0xFF0F2544),
                            size: 26.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area['name'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        area['count'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF94A3B8),
                        ),
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
  // VERIFIED AGENT
  // ---------------------------------------------------------------------
  Widget _buildVerifiedAgent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: Container(
                width: 52.w,
                height: 52.w,
                color: const Color(0xFFF1F5F9),
                child: Image.network(
                  'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=200&auto=format&fit=crop&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person,
                    color: const Color(0xFF0F2544),
                    size: 26.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Arjun Khanna',
                    style: GoogleFonts.poppins(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7F2),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 11.sp,
                          color: const Color(0xFF007A5E),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Verified Partner',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF007A5E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => _showAgentProfileBottomSheet(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF007A5E),
                side: const BorderSide(color: Color(0xFF007A5E), width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              ),
              child: Text(
                'Profile',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF007A5E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // AGENT PROFILE MODAL BOTTOM SHEET
  // ---------------------------------------------------------------------
  void _showAgentProfileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 0.86.sh,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
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
                          'Verified Partner Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
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
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&auto=format&fit=crop&q=80',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: 16.w,
                            height: 16.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A884),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Arjun khanna',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Senior Property Consultant • DigiNiwas Prime Partner',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                      SizedBox(height: 14.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        alignment: WrapAlignment.center,
                        children: [
                          _tagBadge('⭐ 4.9 (128 Reviews)'),
                          _tagBadge('🏢 8+ Years Experience'),
                          _tagBadge('📍 Bopal & South Bopal Specialist'),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(child: _kpiCard('140+', 'Homes Closed')),
                          SizedBox(width: 10.w),
                          Expanded(child: _kpiCard('< 15\nmins', 'Avg. Response')),
                          SizedBox(width: 10.w),
                          Expanded(child: _kpiCard('98%', 'Positive\nFeedback')),
                        ],
                      ),
                      SizedBox(height: 22.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Listings by Arjun khanna',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'See All (6) ›',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF007A5E),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=200&auto=format&fit=crop&q=80',
                                width: 70.w,
                                height: 60.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Celestial Heights, Bopal',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '2 & 3 BHK • Ready to Move',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '₹85 L – ₹1.2 Cr',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF007A5E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        onPressed: () {},
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005B48),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Book Site Visit', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                            SizedBox(width: 6.w),
                            Icon(Icons.arrow_forward_rounded, size: 16.sp),
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
                  onTap: () => Navigator.pop(context),
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