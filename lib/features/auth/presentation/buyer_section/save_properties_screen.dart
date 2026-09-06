// =====================================================================
// SAVED PROPERTIES & DYNAMIC MULTI-COMPARE INTEGRATION
// =====================================================================
import 'dart:convert';
import 'package:diginiwas/features/auth/presentation/buyer_section/property_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/controller/buyer_home_controller.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_service.dart';
import 'compare_properties_detials_screen.dart';

class SavedPropertiesScreen extends StatelessWidget {
  SavedPropertiesScreen({super.key});

  // GetX Controller instance access
  final BuyerHomeController controller = Get.find<BuyerHomeController>();

  // Map to track selection state for comparison (Local UI state per property id)
  final RxMap<String, bool> _comparedSelectionMap = <String, bool>{}.obs;

  int get _selectedCount =>
      _comparedSelectionMap.values.where((selected) => selected == true).length;

  void _openComparisonScreen(BuildContext context, List<dynamic> savedList) {
    final selectedItems = savedList.where((item) {
      final propertyData = (item is Map && item['propertySnapshot'] != null)
          ? item['propertySnapshot']
          : (item is Map && item['property'] != null ? item['property'] : item);
      final id = propertyData['propertyId']?.toString() ?? propertyData['_id']?.toString() ?? '';
      return _comparedSelectionMap[id] == true;
    }).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 property to compare.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Get.toNamed(AppRoutes.compareProperties, arguments: {'comparedProperties': selectedItems});
  }

  void _toggleCompareAll(List<dynamic> savedList) {
    final bool selectAll = _selectedCount != savedList.length;
    for (var item in savedList) {
      final propertyData = (item is Map && item['propertySnapshot'] != null)
          ? item['propertySnapshot']
          : (item is Map && item['property'] != null ? item['property'] : item);
      final id = propertyData['propertyId']?.toString() ?? propertyData['_id']?.toString() ?? '';
      if (id.isNotEmpty) {
        _comparedSelectionMap[id] = selectAll;
      }
    }
  }

  Future<String?> _getBuyerId() async {
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
    return buyerId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildTopAppBar(),
      body: Obx(() {
        if (controller.savedPropertiesLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF007A5E)),
          );
        }

        final savedList = controller.savedPropertiesList;

        if (savedList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_rounded, size: 50.sp, color: const Color(0xFF94A3B8)),
                SizedBox(height: 10.h),
                Text(
                  'No Saved Properties Yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Tap the heart icon on any property to save it here.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 170.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(savedList),
                  SizedBox(height: 12.h),
                  _buildAiPortfolioInsight(),
                  SizedBox(height: 16.h),
                  ...savedList.map((item) => _buildSavedPropertyCard(context, item)),
                ],
              ),
            ),

            // Floating Action Bar
            if (_selectedCount > 0)
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 96.h,
                child: _buildComparisonBar(context, savedList),
              ),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildTopAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: const Color(0xFF0F172A), size: 22.sp),
        onPressed: () {},
      ),
      title: Text(
        'DigiNiwas',
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        CircleAvatar(
          radius: 14.r,
          backgroundImage: const NetworkImage(
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert_rounded, color: const Color(0xFF64748B), size: 20.sp),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeader(List<dynamic> savedList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${savedList.length} Properties Saved',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Updated recently from your wishlist',
          style: GoogleFonts.poppins(
            fontSize: 11.5.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildDropdownChip('Recently Saved'),
              SizedBox(width: 8.w),
              _buildDropdownChip('Filter by Locality'),
              SizedBox(width: 8.w),
              InkWell(
                onTap: () => _toggleCompareAll(savedList),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2544),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.compare_arrows_rounded, color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        _selectedCount == savedList.length
                            ? 'Deselect All'
                            : 'Compare All (${savedList.length})',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildDropdownChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down_rounded, size: 14.sp, color: const Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildAiPortfolioInsight() {
    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFBCE7DA), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF007A5E),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 13.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niwas AI Saved Portfolio Insight',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF005B48),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Review your saved properties and schedule free site visits directly with verified agents.',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF334155),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPropertyCard(BuildContext context, dynamic item) {
    final propertyData = (item is Map && item['propertySnapshot'] != null)
        ? item['propertySnapshot']
        : (item is Map && item['property'] != null ? item['property'] : item);

    // Get the exact property ID for deletion/comparison (supports propertyId or _id)
    final propertyId = propertyData['propertyId']?.toString() ?? item['propertyId']?.toString() ?? propertyData['_id']?.toString() ?? '';

    final title = propertyData['title'] ?? 'Property';
    final locality = propertyData['locality'] ?? '';
    final city = propertyData['city'] ?? '';
    final price = propertyData['price']?.toString() ?? '0';

    String? imageUrl = propertyData['image']?.toString();
    if (imageUrl == null || imageUrl.isEmpty) {
      final images = propertyData['images'];
      if (images is List && images.isNotEmpty) {
        final firstImg = images.first;
        if (firstImg is Map) {
          imageUrl = firstImg['url']?.toString();
        } else if (firstImg is String) {
          imageUrl = firstImg;
        }
      }
    }

    return Obx(() {
      final bool isCompared = _comparedSelectionMap[propertyId] ?? false;

      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    height: 165.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                      : _placeholderImage(),
                ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_outlined, size: 11.sp, color: const Color(0xFF007A5E)),
                        SizedBox(width: 3.w),
                        Text(
                          'Verified',
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF007A5E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Heart Icon - Tap to Remove / Unsave
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: GestureDetector(
                    onTap: () async {
                      final buyerId = await _getBuyerId();
                      if (buyerId != null && buyerId.isNotEmpty && propertyId.isNotEmpty) {
                        // This will trigger DELETE API and remove it from saved list
                        await controller.toggleSaveProperty(buyerId, propertyId);
                      }
                    },
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite_rounded, // Filled red heart since it's in saved list
                          color: Color(0xFFE11D48),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        '₹ $price',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF007A5E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12.sp, color: const Color(0xFF64748B)),
                      SizedBox(width: 3.w),
                      Text(
                        '$locality, $city',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: () {
                      _comparedSelectionMap[propertyId] = !isCompared;
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                            color: isCompared ? const Color(0xFF007A5E) : Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color: isCompared ? const Color(0xFF007A5E) : const Color(0xFF94A3B8),
                              width: 1.5,
                            ),
                          ),
                          child: isCompared
                              ? Icon(Icons.check, size: 13.sp, color: Colors.white)
                              : null,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Add to Compare',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.chat_outlined, size: 15.sp, color: const Color(0xFF007A5E)),
                          label: Text(
                            'Chat',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF007A5E),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF007A5E), width: 1.2),
                            padding: EdgeInsets.symmetric(vertical: 9.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Property Details Screen with property snapshot/data
                            Get.toNamed(
                              AppRoutes.propertyDetails,
                              arguments: {'property': propertyData},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F2544),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 9.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            elevation: 0,
                          ),
                          child: Text(
                            'View Details',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _placeholderImage() {
    return Container(
      height: 165.h,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.home_work_rounded, color: Color(0xFF007A5E)),
      ),
    );
  }

  Widget _buildComparisonBar(BuildContext context, List<dynamic> savedList) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(Icons.balance_rounded, color: const Color(0xFF007A5E), size: 18.sp),
          SizedBox(width: 6.w),
          Text(
            '$_selectedCount Selected',
            style: GoogleFonts.poppins(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: _selectedCount > 0
                ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Inquiry sent for selected properties!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFF0F2544),
                ),
              );
            }
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF334155),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Inquire All',
              style: GoogleFonts.poppins(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: _selectedCount > 0 ? () => _openComparisonScreen(context, savedList) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005B48),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF94A3B8),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Compare',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(Icons.arrow_forward_rounded, size: 12.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}