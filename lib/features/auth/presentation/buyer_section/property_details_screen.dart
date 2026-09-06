import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/controller/property_detils_controller.dart';
import '../../../../core/controller/buyer_home_controller.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  late PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeSavedStatus();
  }

  Future<void> _initializeSavedStatus() async {
    String? buyerId = await _getBuyerId();
    if (buyerId != null && buyerId.isNotEmpty) {
      final BuyerHomeController buyerHomeController = Get.isRegistered<BuyerHomeController>()
          ? Get.find<BuyerHomeController>()
          : Get.put(BuyerHomeController());

      await buyerHomeController.fetchSavedProperties(buyerId);
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide(int length) {
    if (_autoSlideTimer != null || length <= 1) return;

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
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

  // 🔍 Helper to securely extract property ID from any argument format
  String _extractPropertyId(Map<String, dynamic> propertyMap) {
    return propertyMap['propertyId']?.toString() ??
        propertyMap['_id']?.toString() ??
        propertyMap['id']?.toString() ??
        '';
  }

  // 🔍 Smart Buyer ID Fetcher
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

  // Favorite Toggle with Real API Integration
  Future<void> _handleFavoriteToggle(PropertyDetailsController detailsController) async {
    final propertyId = _extractPropertyId(detailsController.property);

    if (propertyId.isEmpty) return;

    String? buyerId = await _getBuyerId();

    if (buyerId == null || buyerId.isEmpty) {
      Get.snackbar(
        'Error',
        'Please login to save properties.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
      return;
    }

    final BuyerHomeController buyerHomeController = Get.isRegistered<BuyerHomeController>()
        ? Get.find<BuyerHomeController>()
        : Get.put(BuyerHomeController());

    await buyerHomeController.toggleSaveProperty(buyerId, propertyId);
    detailsController.toggleFavorite();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PropertyDetailsController());

    final BuyerHomeController buyerHomeController = Get.isRegistered<BuyerHomeController>()
        ? Get.find<BuyerHomeController>()
        : Get.put(BuyerHomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF0F172A), size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Property Details',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          Obx(() {
            final propertyId = _extractPropertyId(controller.property);

            // Yahan ab safely check ho jayega ki ID saved list me mojood hai ya nahi
            final isSaved = buyerHomeController.savedPropertyIds.contains(propertyId) || controller.isFavorite.value;

            return IconButton(
              icon: Icon(
                isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isSaved ? Colors.red : const Color(0xFF0F172A),
                size: 20.sp,
              ),
              onPressed: () => _handleFavoriteToggle(controller),
            );
          }),
          IconButton(
            icon: Icon(Icons.share_outlined, color: const Color(0xFF0F172A), size: 20.sp),
            onPressed: controller.shareProperty,
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF007A5E)),
          );
        }

        if (controller.error.value != null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                controller.error.value!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.red),
              ),
            ),
          );
        }

        final rawImages = controller.property['images'];
        final List<String> imageUrls = [];
        if (rawImages is List) {
          for (var img in rawImages) {
            if (img is Map && img['url'] != null) {
              imageUrls.add(img['url'].toString());
            } else if (img is String && img.isNotEmpty) {
              imageUrls.add(img);
            }
          }
        }
        // Fallback for single image snapshot if passed from saved items
        if (imageUrls.isEmpty && controller.property['image'] != null) {
          imageUrls.add(controller.property['image'].toString());
        }
        if (imageUrls.isEmpty && controller.imageUrl.isNotEmpty) {
          imageUrls.add(controller.imageUrl);
        }

        if (imageUrls.isNotEmpty) {
          _startAutoSlide(imageUrls.length);
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 260.h,
                    child: imageUrls.isNotEmpty
                        ? PageView.builder(
                      controller: _pageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          imageUrls[index],
                          width: double.infinity,
                          height: 260.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.home_work_rounded, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),

                  if (imageUrls.length > 1)
                    Positioned(
                      bottom: 30.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          imageUrls.length,
                              (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            width: _currentPage == index ? 16.w : 6.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? const Color(0xFF007A5E) : Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 14.h,
                    right: 16.w,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: controller.open360View,
                        borderRadius: BorderRadius.circular(24.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2544).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.threed_rotation_rounded, color: const Color(0xFF4EE1A0), size: 16.sp),
                              SizedBox(width: 5.w),
                              Text(
                                '360° Tour',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (controller.property['propertyId'] != null || controller.property['propertyCode'] != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF8F5),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: const Color(0xFFBCE7DA)),
                            ),
                            child: Text(
                              'ID: ${controller.property['propertyId'] ?? controller.property['propertyCode']}',
                              style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: const Color(0xFF007A5E)),
                            ),
                          ),
                        SizedBox(width: 8.w),
                        if (controller.property['transactionType'] != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF4FE),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'For ${controller.property['transactionType']}',
                              style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2F70F2)),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 13.sp, color: const Color(0xFF64748B)),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Text(
                                      controller.address,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5.sp,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              controller.priceDisplay,
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF007A5E),
                              ),
                            ),
                            if (controller.property['pricePerSqft'] != null)
                              Text(
                                '₹ ${controller.property['pricePerSqft']} / sq.ft',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        if (controller.bhkLabel.isNotEmpty) _metaChip(Icons.bed_outlined, controller.bhkLabel),
                        if (controller.property['bathrooms'] != null) _metaChip(Icons.bathtub_outlined, '${controller.property['bathrooms']} Baths'),
                        if (controller.sqft.isNotEmpty) _metaChip(Icons.aspect_ratio_outlined, controller.sqft),
                        if (controller.furnishing.isNotEmpty) _metaChip(Icons.chair_outlined, controller.furnishing),
                        if (controller.property['category'] != null) _metaChip(Icons.category_outlined, '${controller.property['category']}'),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    Text(
                      'About Property',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      controller.description.isNotEmpty ? controller.description : 'No description provided.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.launchWhatsApp("919876543210"),
                icon: const Icon(Icons.chat, color: Color(0xFF007A5E)),
                label: Text(
                  'WhatsApp',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF007A5E)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF007A5E)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.makePhoneCall("9876543210"),
                icon: const Icon(Icons.call, color: Colors.white),
                label: Text(
                  'Call Owner',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A5E),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFF007A5E)),
          SizedBox(width: 5.w),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}