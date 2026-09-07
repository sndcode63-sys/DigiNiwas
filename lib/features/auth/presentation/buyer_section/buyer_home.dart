import 'dart:async';
import 'dart:convert';

import 'package:diginiwas/features/auth/presentation/buyer_section/property_details_screen.dart';
import 'package:diginiwas/features/auth/presentation/buyer_section/save_properties_screen.dart';
import 'package:diginiwas/features/auth/presentation/buyer_section/show_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/controller/buyer_home_controller.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/shimmer.dart';
import '../../../../core/widgets/app_image.dart';
import 'exprole_name.dart';
import 'niwas_ai_section.dart';

// ---------------------------------------------------------------------
// SHARED AMENITY MARKER STYLING
// Top-level so both HomeScreen's inline map and the full-screen
// ExploreMapViewScreen render markers identically.
// ---------------------------------------------------------------------
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

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});


  final BuyerHomeController controller = Get.put(BuyerHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,

      body: Obx(() {
        return controller.isLoading.value
            ? _buildLoadingView()
            : _buildBody(context);
      }),
      bottomNavigationBar: Obx(() {
        return controller.isLoading.value
            ? const SizedBox.shrink()
            : _buildBottomNav();
      }),
    );
  }

  /// Lightweight shimmer skeleton shown while the primary home feed loads —
  /// mirrors the real layout (header, chips, cards, map, etc.) so the
  /// screen doesn't jump once data arrives.
  Widget _buildLoadingView() {
    return const HomeShimmer();
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

  /// Thin wrapper around the shared [ImageCase] widget — kept so every
  /// existing call site on this screen (`_cachedImage(url, width: ..., ...)`)
  /// didn't need to change, while the actual image/placeholder/error
  /// handling now lives in one reusable place used across the whole app.
  Widget _cachedImage(
      String? url, {
        required double width,
        required double height,
        BoxFit fit = BoxFit.cover,
        IconData fallbackIcon = Icons.home_work_rounded,
        BorderRadius? borderRadius,
      }) {
    return ImageCase(
      url: url,
      width: width,
      height: height,
      fit: fit,
      fallbackIcon: fallbackIcon,
      borderRadius: borderRadius,
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (controller.bottomNavIndex.value) {
      case 0:
        return _buildContent(context);
      case 1:
        return ExproleName();
      case 2:
        return const NiwasAiScreen();
      case 3:
        return  SavedPropertiesScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildContent(context);
    }
  }

  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshAll,

      color: const Color(0xFF007A5E),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (controller.error.value != null) _buildFeedErrorBanner(),
            SizedBox(height: 14.h),
            _buildCategoryChips(),
            SizedBox(height: 14.h),
            _buildSectionTitle('Quick AI Discovery'),
            SizedBox(height: 8.h),
            _buildQuickAiGrid(),
            SizedBox(height: 14.h),
            _buildSectionTitle(
              controller.selectedCategoryTab.value != null ? '${controller.selectedCategoryTab.value!} Properties' : 'Recommended For You',
              showViewAll: controller.selectedCategoryTab.value == null,
            ),
            SizedBox(height: 8.h),
            _buildRecommendedCards(),
            SizedBox(height: 18.h),
            _buildBoostedSection(),
            SizedBox(height: 18.h),
            _buildSectionTitle('Explore Near You'),
            SizedBox(height: 8.h),
            _buildExploreMap(context),
            SizedBox(height: 18.h),
            _buildSectionTitle('New Listings', showViewAll: true),
            SizedBox(height: 8.h),
            _buildNewListings(),
            SizedBox(height: 18.h),
            _buildSectionTitle(
              controller.homeFeed.value?.location?.city != null && controller.homeFeed.value!.location!.city!.isNotEmpty
                  ? 'Popular near ${controller.homeFeed.value!.location!.city}'
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
              controller.error.value ?? 'Could not load home feed.',
              style: GoogleFonts.poppins(fontSize: 11.5.sp, color: const Color(0xFFC62828)),
            ),
          ),
          TextButton(
            onPressed: controller.loadHomeFeed,
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
    final locationLabel = controller.dashboardHeader.value?.location?.city?.isNotEmpty == true
        ? '${controller.dashboardHeader.value!.location!.city}, ${controller.dashboardHeader.value!.location!.state ?? ''}'
        : (controller.homeFeed.value?.location?.city?.isNotEmpty == true
        ? '${controller.homeFeed.value!.location!.city}, ${controller.homeFeed.value!.location!.state ?? ''}'
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
                  controller.buyerName.value.isNotEmpty ? controller.buyerName.value.substring(0, 2).toUpperCase() : 'RH',
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
            controller.dashboardHeader.value?.greeting ?? '${controller.greetingByTime()}, ${controller.buyerName.value}',
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
          GestureDetector(
            onTap: () {
              // Click karte hi Search Screen open ho jayegi
              Get.to(() => ExproleName());
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
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
                  Container(height: 16.h, width: 1.w, color: Colors.grey.shade300),
                  SizedBox(width: 10.w),
                  Icon(Icons.mic_none_rounded, color: const Color(0xFF8C9BAE), size: 20.sp),
                ],
              ),
            ),
          )

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
    final apiCategories = controller.categoryFilterData.value?.categories ?? [];
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
          final isSelected = controller.selectedCategoryTab.value == label;
          final count = countFor(label);
          return Expanded(
            child: GestureDetector(
              // Tapping an already-selected chip clears the filter; the
              // toggle logic itself lives in the controller.
              onTap: () => controller.onCategoryChipTap(label),
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
    if (controller.selectedCategoryTab.value != null) {
      if (controller.categoryFilterLoading.value) {
        return _sectionLoader(height: 380);
      }
      final filtered = controller.categoryFilterData.value?.properties ?? [];
      if (filtered.isEmpty) {
        return _buildEmptySectionMessage('No ${controller.selectedCategoryTab.value!} properties found near you.');
      }
      return _recommendedCardsList(
        count: filtered.length,
        titleAt: (i) => filtered[i].title,
        localityAt: (i) => filtered[i].locality,
        cityAt: (i) => filtered[i].city,
        bedroomsAt: (i) => filtered[i].bedrooms,
        furnishingAt: (i) => filtered[i].furnishing,
        priceAt: (i) => filtered[i].price,
        imageUrlsAt: (i) {
          final imgs = <String>[];
          if (filtered[i].images != null) {
            for (var img in filtered[i].images!) {
              if (img.url != null) imgs.add(img.url!);
            }
          }
          return imgs;
        },
        jsonAt: (i) => filtered[i].toJson(),
      );
    }

    final properties = controller.homeFeed.value?.recommendedProperties ?? [];
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
      imageUrlsAt: (i) {
        final imgs = <String>[];
        if (properties[i].images != null) {
          for (var img in properties[i].images!) {
            if (img.url != null) imgs.add(img.url!);
          }
        }
        return imgs;
      },
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
    required List<String> Function(int) imageUrlsAt, // 👈 Multiple images ke liye list handler
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
          return RecommendedPropertyCard(
            propertyJson: jsonAt(index),
            title: titleAt(index),
            locality: localityAt(index),
            city: cityAt(index),
            bedrooms: bedroomsAt(index),
            furnishing: furnishingAt(index),
            price: priceAt(index),
            imageUrls: imageUrlsAt(index),
            controller: controller,
            cachedImageBuilder: _cachedImage,
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
    if (controller.boostedLoading.value) {
      return _sectionLoader(height: 190);
    }
    final properties = controller.boostedData.value?.properties ?? [];
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
                onTap: () => Get.toNamed(AppRoutes.propertyDetails, arguments: {'property': item.toJson()}),
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

  Widget _buildExploreMap(BuildContext context) {
    if (controller.exploreLoading.value) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: _sectionLoader(height: 190),
      );
    }

    final explore = controller.exploreNearby.value;
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
                              Get.toNamed(AppRoutes.exploreMap);
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

  Widget _buildNewListings() {
    if (controller.newListingsLoading.value) {
      return _sectionLoader(height: 240);
    }
    final listings = controller.newListingsData.value?.properties ?? [];
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
          // ✅ Yeh ab neeche defined widget ko call karega jo automatically slide karega
          return NewListingCard(
            item: item,
            onTap: () => Get.toNamed(AppRoutes.propertyDetails, arguments: {'property': item.toJson()}),
          );
        },
      ),
    );
  }
  Widget _buildPopularAreas() {
    if (controller.popularLoading.value) {
      return _sectionLoader(height: 171);
    }
    final areas = controller.popularLocationsData.value?.areas ?? [];
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
          return InkWell(
            onTap: () {
              // Mapping area data into a standard property format expected by PropertyDetailsScreen
              final propertyData = {
                'title': '${area.locality ?? 'Popular'} Area Properties',
                'locality': area.locality ?? '',
                'city': controller.homeFeed.value?.location?.city ?? 'Indore',
                'images': area.sampleImage != null ? [{'url': area.sampleImage}] : [],
                'price': 'Explore Available',
                'description': 'Explore ${area.propertyCount ?? 0}+ verified properties available in ${area.locality ?? 'this area'}.',
                'category': 'Residential',
                'transactionType': 'Sale / Rent',
              };

              Get.toNamed(
                AppRoutes.propertyDetails,
                arguments: {'property': propertyData},
              );
            },
            child: Container(
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
            ),
          );
        },
      ),
    );
  }
  // ---------------------------------------------------------------------
  // VERIFIED AGENTS SECTION (Matching your UI Design)
  // ---------------------------------------------------------------------
  final ScrollController _agentScrollController = ScrollController();
  Timer? _agentAutoScrollTimer;

  Widget _buildVerifiedAgent() {
    if (controller.agentsLoading.value) {
      return _sectionLoader(height: 100);
    }

    final agents = controller.agentsData.value?.agents ?? [];
    if (agents.isEmpty) {
      return _buildEmptySectionMessage('No verified agents found near you yet.');
    }

    if (_agentAutoScrollTimer == null && agents.length > 1) {
      _agentAutoScrollTimer = Timer.periodic(const Duration(milliseconds: 2), (timer) {
        if (_agentScrollController.hasClients) {
          double maxScroll = _agentScrollController.position.maxScrollExtent;
          double currentScroll = _agentScrollController.offset;

          double nextScroll = currentScroll + 1.2; // Auto slide speed
          if (nextScroll >= maxScroll) {
            nextScroll = 0.0; // Wapas start par aa jayega
          }

          _agentScrollController.jumpTo(nextScroll);
        }
      });
    }

    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        controller: _agentScrollController, // 👈 Auto scroll controller attached
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        physics: const BouncingScrollPhysics(),
        itemCount: agents.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final agent = agents[index];
          final initial = (agent.name?.trim().isNotEmpty == true) ? agent.name!.trim().substring(0, 1).toUpperCase() : 'A';

          return AutoSlideAgentCard(
            agent: agent,
            initial: initial,
            cachedImageBuilder: _cachedImage,
            onProfileTap: (ctx, ag) {
              _showAgentProfileBottomSheet(ctx, ag);
            },
          );
        },
      ),
    );
  }

  /// Dynamic Agent Profile Bottom Sheet mapping 100% API response data
  void _showAgentProfileBottomSheet(BuildContext context, dynamic agent) {
    final name = agent.name ?? 'Verified Agent';
    final initial = name.trim().isNotEmpty ? name.trim().substring(0, 1).toUpperCase() : 'A';
    final avatar = agent.avatar;

    // Business info from API response
    final businessName = agent.business?.businessName;
    final businessType = agent.business?.businessType;
    final gstin = agent.business?.gstin;
    final officeAddress = agent.business?.officeAddress;

    final role = agent.role ?? agent.accountType ?? 'Real Estate Agent';
    final subtitle = (businessName != null && businessName.isNotEmpty) ? businessName : role;
    final distance = agent.distanceKm;
    final isVerified = agent.isVerified == true;

    // Contact details
    final phone = agent.contact?.phone ?? agent.phone ?? '';
    final email = agent.email ?? '';
    final canCall = agent.contact?.canCall == true || phone.isNotEmpty;

    // RERA & Location details
    final reraStatus = agent.rera?.verificationStatus;
    final reraNumber = agent.rera?.registrationNumber;
    final serviceLocalities = agent.location?.serviceLocalities ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                children: [
                  // Handle & Header
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
                              'Agent Profile Details',
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

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          Center(
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(40.r),
                                      child: (avatar != null && avatar.isNotEmpty)
                                          ? Image.network(
                                        avatar,
                                        width: 80.w,
                                        height: 80.w,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _largeInitialAvatar(initial),
                                      )
                                          : _largeInitialAvatar(initial),
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
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Badges (Distance / RERA Status)
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            alignment: WrapAlignment.center,
                            children: [
                              if (distance != null)
                                _tagBadge('📍 ${distance is double ? distance.toStringAsFixed(1) : distance} km away'),
                              if (reraStatus != null)
                                _tagBadge('🛡️ RERA: $reraStatus'),
                            ],
                          ),

                          // Business Information Card
                          if (businessName != null || businessType != null || (gstin != null && gstin.isNotEmpty) || (officeAddress != null && officeAddress.isNotEmpty)) ...[
                            SizedBox(height: 18.h),
                            Text(
                              'Business Details',
                              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: const Color(0xFFEDF2F7)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (businessName != null && businessName.isNotEmpty) ...[
                                    Text('Company: $businessName', style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                                    SizedBox(height: 4.h),
                                  ],
                                  if (businessType != null && businessType.isNotEmpty) ...[
                                    Text('Type: $businessType', style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF64748B))),
                                    SizedBox(height: 4.h),
                                  ],
                                  if (gstin != null && gstin.isNotEmpty) ...[
                                    Text('GSTIN: $gstin', style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF64748B))),
                                    SizedBox(height: 4.h),
                                  ],
                                  if (officeAddress != null && officeAddress.isNotEmpty) ...[
                                    Text('Office: $officeAddress', style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF64748B))),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          // RERA Registration Card
                          if (reraNumber != null && reraNumber.isNotEmpty) ...[
                            SizedBox(height: 16.h),
                            Text(
                              'RERA Registration',
                              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: const Color(0xFFEDF2F7)),
                              ),
                              child: Text(
                                'Reg No: $reraNumber',
                                style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                              ),
                            ),
                          ],

                          // Service Localities Chips
                          if (serviceLocalities.isNotEmpty) ...[
                            SizedBox(height: 16.h),
                            Text(
                              'Service Localities',
                              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: serviceLocalities.map<Widget>((loc) => _tagBadge('$loc')).toList(),
                            ),
                          ],

                          // Contact Information Card
                          SizedBox(height: 16.h),
                          Text(
                            'Contact Information',
                            style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                          ),
                          SizedBox(height: 8.h),
                          if (phone.isNotEmpty) ...[
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
                                      phone,
                                      style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                          if (email.isNotEmpty) ...[
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
                                      email,
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

                  // Bottom Buttons (WhatsApp & Call)
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
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                              _launchAgentWhatsApp(phone, name);
                            },
                            icon: Icon(Icons.chat_bubble_outline_rounded, size: 16.sp),
                            label: Text('WhatsApp', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
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
                          child: ElevatedButton.icon(
                            onPressed: canCall && phone.isNotEmpty
                                ? () {
                              Navigator.of(sheetContext).pop();
                              _makeAgentCall(phone);
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005B48),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            icon: Icon(Icons.call_rounded, size: 16.sp),
                            label: Text('Call Agent', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
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

  Widget _largeInitialAvatar(String initial) {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: const BoxDecoration(
        color: Color(0xFFA8E6CF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.poppins(fontSize: 26.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F2544)),
      ),
    );
  }

  Future<void> _makeAgentCall(String phone) async {
    final Uri url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchAgentWhatsApp(String phone, String name) async {
    final String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=Hello $name, I found your profile on DigiNiwas and want to connect.");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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
              onTap: () => controller.changeBottomNavIndex(2),
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
    final isSelected = controller.bottomNavIndex.value == index;
    const activeColor = Color(0xFF007A5E);
    const inactiveColor = Color(0xFF7D8C99);

    return InkWell(
      onTap: () => controller.changeBottomNavIndex(index),
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
// FULL-SCREEN EXPLORE MAP VIEW SCREEN — now fully dynamic, driven by
// BuyerHomeController.exploreNearby (GET /api/v1/properties/explore-nearby)
// instead of hardcoded demo pins.
// =====================================================================
class ExploreMapViewScreen extends StatelessWidget {
  const ExploreMapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Same controller instance HomeScreen already put() — no new API call
    // needed here, we just read what's already loaded (or re-fetch on
    // radius change below).
    final BuyerHomeController controller = Get.find<BuyerHomeController>();

    return Scaffold(
      body: Obx(() {
        final explore = controller.exploreNearby.value;
        final isInitialLoading = controller.exploreLoading.value && explore == null;

        if (isInitialLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF007A5E)),
          );
        }

        if (explore == null) {
          return _buildEmptyState();
        }

        final mapDetails = explore.map;
        final property = explore.property;

        final centerLocation = mapDetails?.center != null
            ? LatLng(mapDetails!.center!.latitude ?? 22.7533, mapDetails.center!.longitude ?? 75.8937)
            : const LatLng(22.7533, 75.8937);

        final List<Marker> mapMarkers = [];
        if (mapDetails?.markers != null) {
          for (var m in mapDetails!.markers!) {
            if (m.latitude == null || m.longitude == null) continue;
            final isProperty = m.markerType == 'PROPERTY';
            mapMarkers.add(
              Marker(
                point: LatLng(m.latitude!, m.longitude!),
                width: isProperty ? 42.w : 32.w,
                height: isProperty ? 42.w : 32.w,
                child: GestureDetector(
                  onTap: () => _showMarkerDetailSheet(context, m, isProperty),
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
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isProperty ? Icons.home_rounded : _amenityIcon(m.markerType),
                      color: isProperty ? Colors.white : _amenityColor(m.markerType),
                      size: isProperty ? 20.sp : 15.sp,
                    ),
                  ),
                ),
              ),
            );
          }
        }

        return Stack(
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

            // Top bar: back button + real property title
            Positioned(
              top: 48.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2)),
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
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: const Color(0xFF007A5E), size: 18.sp),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              property?.title ?? 'Nearby Places',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F2544),
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

            // Radius selector chips — re-calls the API at a new radius
            Positioned(
              top: 100.h,
              left: 20.w,
              right: 20.w,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [1000, 3000, 5000].map((r) {
                    final isSelected = controller.exploreRadius.value == r;
                    final label = r >= 1000 ? '${(r / 1000).toStringAsFixed(0)} km' : '$r m';
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () => controller.changeExploreRadius(r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF007A5E) : Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF0F2544),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Small "updating" pill shown while re-fetching for a new radius
            if (controller.exploreLoading.value)
              Positioned(
                top: 148.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14.w,
                          height: 14.w,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF007A5E)),
                        ),
                        SizedBox(width: 8.w),
                        Text('Updating nearby places...', style: GoogleFonts.poppins(fontSize: 10.5.sp, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom card: marker count + legend + directions
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 24.h,
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${mapMarkers.length} places found',
                          style: GoogleFonts.poppins(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                        ),
                        GestureDetector(
                          onTap: () {
                            final url = property?.mapUrl;
                            if (url != null && url.isNotEmpty) {
                              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(color: const Color(0xFF0F2544), borderRadius: BorderRadius.circular(8.r)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.directions_rounded, size: 14.sp, color: Colors.white),
                                SizedBox(width: 4.w),
                                Text('Directions', style: GoogleFonts.poppins(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 6.h,
                      children: [
                        _legendDot(const Color(0xFF007A5E), 'Property'),
                        _legendDot(const Color(0xFF3B82F6), 'Education'),
                        _legendDot(const Color(0xFFEF4444), 'Healthcare'),
                        _legendDot(const Color(0xFFEAB308), 'Food'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 4.w),
        Text(label, style: GoogleFonts.poppins(fontSize: 9.5.sp, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 44.sp, color: const Color(0xFF94A3B8)),
            SizedBox(height: 10.h),
            Text(
              "Nearby map data isn't available right now.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12.5.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(height: 14.h),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Go Back', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF007A5E))),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet shown when a marker on the full-screen map is tapped —
  /// shows the place name, distance (if available), and a "Get Directions"
  /// button that opens Google Maps via the marker's directionsUrl/mapUrl.
  void _showMarkerDetailSheet(BuildContext context, dynamic marker, bool isProperty) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isProperty ? Icons.home_rounded : _amenityIcon(marker.markerType),
                    color: isProperty ? const Color(0xFF007A5E) : _amenityColor(marker.markerType),
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      marker.name ?? 'Location',
                      style: GoogleFonts.poppins(fontSize: 14.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
              if (marker.distanceKm != null) ...[
                SizedBox(height: 8.h),
                Text(
                  '${marker.distanceKm is double ? (marker.distanceKm as double).toStringAsFixed(1) : marker.distanceKm} km away',
                  style: GoogleFonts.poppins(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
                ),
              ],
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final url = marker.directionsUrl ?? marker.mapUrl;
                    if (url != null && url.toString().isNotEmpty) {
                      Navigator.of(ctx).pop();
                      launchUrl(Uri.parse(url.toString()), mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: Icon(Icons.directions_rounded, size: 16.sp),
                  label: Text('Get Directions', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005B48),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class NewListingCard extends StatefulWidget {
  final dynamic item;
  final VoidCallback onTap;

  const NewListingCard({required this.item, required this.onTap});

  @override
  State<NewListingCard> createState() => NewListingCardState();
}

class NewListingCardState extends State<NewListingCard> {
  late PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Automatically slide every 3 seconds if multiple images exist
    final images = widget.item.images;
    if (images is List && images.length > 1) {
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController.hasClients) {
          final int length = images.length;
          if (_currentPage < length - 1) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final List<String> imageUrls = [];
    if (item.images != null && item.images!.isNotEmpty) {
      for (var img in item.images!) {
        if (img.url != null && img.url!.isNotEmpty) {
          imageUrls.add(img.url!);
        }
      }
    }

    return GestureDetector(
      onTap: widget.onTap,
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
                SizedBox(
                  height: 120.h,
                  child: imageUrls.isNotEmpty
                      ? PageView.builder(
                    controller: _pageController,
                    itemCount: imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, imgIndex) {
                      return ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                        child: Image.network(
                          imageUrls[imgIndex],
                          width: 198.w,
                          height: 120.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 24, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                    child: Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.home_work_rounded, size: 24, color: Colors.grey),
                      ),
                    ),
                  ),
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
                // ❌ Yahan se dots indicator wala code poori tarah hata diya gaya hai taaki koi indicator na dikhe.
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
  }
}



class RecommendedPropertyCard extends StatefulWidget {
  final Map<String, dynamic> propertyJson;
  final String? title;
  final String? locality;
  final String? city;
  final String? bedrooms;
  final String? furnishing;
  final int? price;
  final List<String> imageUrls;
  final BuyerHomeController controller;
  final Widget Function(String? url, {required double width, required double height, BoxFit fit, IconData fallbackIcon, BorderRadius? borderRadius}) cachedImageBuilder;

  const RecommendedPropertyCard({
    required this.propertyJson,
    required this.title,
    required this.locality,
    required this.city,
    required this.bedrooms,
    required this.furnishing,
    required this.price,
    required this.imageUrls,
    required this.controller,
    required this.cachedImageBuilder,
  });

  @override
  State<RecommendedPropertyCard> createState() => RecommendedPropertyCardState();
}

class RecommendedPropertyCardState extends State<RecommendedPropertyCard> {
  late PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // 🕒 Automatically slide every 3 seconds if multiple images exist
    if (widget.imageUrls.length > 1) {
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController.hasClients) {
          final int length = widget.imageUrls.length;
          if (_currentPage < length - 1) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemJson = widget.propertyJson;
    final propertyId = itemJson['_id']?.toString() ?? itemJson['propertyId']?.toString();

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
          Stack(
            children: [
              // 🖼️ PageView for Auto-Sliding Multiple Images (No Indicator)
              SizedBox(
                height: 208.h,
                child: widget.imageUrls.isNotEmpty
                    ? PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, imgIndex) {
                    return ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                      child: widget.cachedImageBuilder(
                        widget.imageUrls[imgIndex],
                        width: 278.w,
                        height: 208.h,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                      ),
                    );
                  },
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                  child: widget.cachedImageBuilder(
                    null,
                    width: 278.w,
                    height: 208.h,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                  ),
                ),
              ),

              // Verified Badge (Top-Left)
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

              // Heart / Favorite Icon (Top-Right)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: GestureDetector(
                  onTap: () async {
                    try {
                      String? buyerId = await StorageService.instance.buyerId;
                      if (buyerId == null || buyerId.isEmpty) {
                        buyerId = await StorageService.instance.userId;
                      }
                      if (buyerId == null || buyerId.isEmpty) {
                        final userJson = await SecureStorageService.instance.getUserData();
                        if (userJson != null && userJson.isNotEmpty) {
                          try {
                            final userMap = jsonDecode(userJson) as Map<String, dynamic>;
                            buyerId = userMap['id']?.toString() ??
                                userMap['_id']?.toString() ??
                                userMap['buyerId']?.toString();
                          } catch (_) {}
                        }
                      }

                      if (buyerId != null && buyerId.isNotEmpty && propertyId != null) {
                        await widget.controller.toggleSaveProperty(buyerId, propertyId);
                      }
                    } catch (e) {
                      print('DEBUG_HEART EXCEPTION: $e');
                    }
                  },
                  child: Obx(() {
                    final isSaved = propertyId != null && widget.controller.savedPropertyIds.contains(propertyId);

                    return Container(
                      padding: EdgeInsets.all(7.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 16.sp,
                        color: const Color(0xFFE53935),
                      ),
                    );
                  }),
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
                  widget.title ?? 'Property',
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
                        '${widget.locality ?? ''}, ${widget.city ?? ''}',
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
                      child: Text('${widget.bedrooms ?? '0'} BHK', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6.r)),
                      child: Text(widget.furnishing ?? 'Ready', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155))),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  '₹ ${widget.price ?? 0}',
                  style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.3),
                ),
              ],
            ),
          ),

          // VIEW button
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
                    Get.toNamed(
                      AppRoutes.propertyDetails,
                      arguments: {'property': itemJson},
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
  }
}class AutoSlideAgentCard extends StatelessWidget {
  final dynamic agent;
  final String initial;
  final Widget Function(String? url, {required double width, required double height, BoxFit fit, IconData fallbackIcon, BorderRadius? borderRadius}) cachedImageBuilder;
  final Function(BuildContext, dynamic) onProfileTap;

  const AutoSlideAgentCard({
    required this.agent,
    required this.initial,
    required this.cachedImageBuilder,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onProfileTap(context, agent),
      child: Container(
        width: 290.w,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Agent Avatar / Initial
            ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: (agent.avatar?.isNotEmpty == true)
                  ? cachedImageBuilder(agent.avatar, width: 50.w, height: 50.w, fallbackIcon: Icons.person)
                  : CircleAvatar(
                radius: 25.r,
                backgroundColor: const Color(0xFFA8E6CF),
                child: Text(
                  initial,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF0F2544), fontSize: 16.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Name & Verified Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    agent.name ?? 'Agent',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7F2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 12.sp, color: const Color(0xFF007A5E)),
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
            SizedBox(width: 8.w),

            // Profile Outline Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF007A5E), width: 1.2),
                borderRadius: BorderRadius.circular(20.r),
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
}