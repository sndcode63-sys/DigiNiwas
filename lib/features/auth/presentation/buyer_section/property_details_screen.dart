import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/controller/buyer_home_controller.dart';
import '../../../../core/controller/lead_controller.dart';
import '../../../../core/controller/property_detils_controller.dart';
import '../../../../core/controller/visit_controller.dart';
import '../../../../core/models/requestVisitModels.dart';
import '../../../../core/models/visit_status.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_service.dart';

import '../../data/agent_repo.dart';
import '../../data/lead_repository.dart';
import '../../data/visit_repositort.dart';


class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  PropertyDetailsController get controller => Get.find<PropertyDetailsController>();

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

  // 🔍 Universal Property ID & Code Extractor
  String _extractPropertyId(Map<String, dynamic> propertyMap) {
    return propertyMap['_id']?.toString() ??
        propertyMap['propertyId']?.toString() ??
        propertyMap['propertyCode']?.toString() ??
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

  String formatPrice(dynamic priceValue) {
    if (priceValue == null) return '₹ 0';
    String priceStr = priceValue.toString().trim();
    if (priceStr.contains('L') || priceStr.contains('Cr') || priceStr.contains('₹')) {
      return priceStr;
    }

    double? price = double.tryParse(priceStr);
    if (price == null) return '₹ $priceValue';

    if (price >= 10000000) {
      double cr = price / 10000000;
      return '₹ ${cr % 1 == 0 ? cr.toInt() : cr.toStringAsFixed(1)} Cr';
    } else if (price >= 100000) {
      double lakh = price / 100000;
      return '₹ ${lakh % 1 == 0 ? lakh.toInt() : lakh.toStringAsFixed(1)} L';
    } else if (price >= 1000) {
      double thousand = price / 1000;
      return '₹ ${thousand % 1 == 0 ? thousand.toInt() : thousand.toStringAsFixed(1)} K';
    }
    return '₹ $price';
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

  // 🔍 Full-screen Image Zoom Viewer Dialog
  void _openZoomImageViewer(BuildContext context, List<String> imageUrls, int initialIndex) {
    _autoSlideTimer?.cancel();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenZoomGallery(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    ).then((_) {
      if (imageUrls.length > 1) {
        _startAutoSlide(imageUrls.length);
      }
    });
  }

  // 📅 Schedule Visit Bottom Sheet
  void _showScheduleVisitSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScheduleVisitBottomSheet(controller: controller),
    );
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
            final propertyCode = controller.property['propertyCode']?.toString() ?? controller.property['propertyId']?.toString() ?? '';

            bool isSavedInList = false;
            for (var item in buyerHomeController.savedPropertiesList) {
              final pData = (item is Map && item['propertySnapshot'] != null)
                  ? item['propertySnapshot']
                  : (item is Map && item['property'] != null ? item['property'] : item);

              final savedId = pData['_id']?.toString() ?? '';
              final savedCode = pData['propertyCode']?.toString() ?? pData['propertyId']?.toString() ?? '';

              if ((propertyId.isNotEmpty && savedId == propertyId) ||
                  (propertyCode.isNotEmpty && savedCode == propertyCode) ||
                  buyerHomeController.savedPropertyIds.contains(propertyId)) {
                isSavedInList = true;
                break;
              }
            }

            final isSaved = isSavedInList || controller.isFavorite.value;

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
                        return GestureDetector(
                          onTap: () => _openZoomImageViewer(context, imageUrls, index),
                          child: Hero(
                            tag: imageUrls[index],
                            child: Image.network(
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
                ],
              ),

              // ================= FLOATING VERIFIED / TITLE / PRICE CARD =================
              Transform.translate(
                offset: Offset(0, -34.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: _buildFloatingInfoCard(controller),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -22.h),
                      child: Row(
                        children: [
                          if (controller.property['propertyId'] != null || controller.property['propertyCode'] != null)
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
                    ),
                    Transform.translate(
                      offset: Offset(0, -16.h),
                      child: Wrap(
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
                    ),
                    SizedBox(height: 6.h),

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
                    SizedBox(height: 22.h),

                    // ================= AI PROPERTY SNAPSHOT =================
                    _buildAiSnapshotCard(),
                    SizedBox(height: 18.h),

                    // ================= CONNECT WITH PARTNER =================
                    _buildPartnerCard(context),
                    SizedBox(height: 26.h),
                  ],
                ),
              ),

              // ================= REAL SIMILAR PROPERTIES SECTION =================
              _buildSimilarProperties(),
              SizedBox(height: 24.h),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 📅 Schedule Visit Button Added Here
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showScheduleVisitSheet(context),
                icon: Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16.sp),
                label: Text(
                  'Schedule Visit',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A5E),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
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
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingInfoCard(PropertyDetailsController controller) {
    final specsParts = <String>[
      if (controller.bhkLabel.isNotEmpty) controller.bhkLabel,
      if (controller.sqft.isNotEmpty) controller.sqft,
      (controller.property['possessionStatus']?.toString().isNotEmpty ?? false)
          ? controller.property['possessionStatus'].toString()
          : (controller.property['status']?.toString().isNotEmpty ?? false)
          ? controller.property['status'].toString()
          : 'Ready to Move',
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 13.sp, color: const Color(0xFF007A5E)),
              SizedBox(width: 4.w),
              Text(
                'Verified',
                style: GoogleFonts.poppins(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF007A5E),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  controller.title,
                  style: GoogleFonts.poppins(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                formatPrice(controller.property['price'] ?? controller.priceDisplay),
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF007A5E),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 13.sp, color: const Color(0xFF64748B)),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  controller.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            specsParts.where((e) => e.isNotEmpty).join('  ·  '),
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
          ),
        ],
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

  Widget _buildAiSnapshotCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FBF8),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFCBEFE0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF007A5E),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                'Niwas AI Property Snapshot',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Understand value, rental potential and locality performance',
            style: GoogleFonts.poppins(
              fontSize: 10.5.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 14.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _aiMetricTile(
                  icon: Icons.compare_arrows_rounded,
                  label: 'Price Comparison',
                  value: '3% below',
                  subValue: 'similar properties',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _aiMetricTile(
                  icon: Icons.savings_outlined,
                  label: 'Estimated Rental Yield',
                  value: '4.8%–5.4%',
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _aiMetricTile(
                  icon: Icons.trending_up_rounded,
                  label: 'Locality Trend',
                  value: '+7.1% yearly',
                  subValue: 'Past 3 years',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _aiMetricTile(
                  icon: Icons.verified_outlined,
                  label: 'Data Confidence',
                  value: 'Medium',
                  valueColor: const Color(0xFFB45309),
                  subValue: '24 comparable listings',
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(color: const Color(0xFFCBEFE0), height: 1),
          SizedBox(height: 10.h),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14.sp, color: const Color(0xFF007A5E)),
                SizedBox(width: 5.w),
                Text(
                  'See How This Was Calculated',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF007A5E),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Updated August 2026',
            style: GoogleFonts.poppins(fontSize: 9.5.sp, color: const Color(0xFF94A3B8)),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              'Estimates are based on available listings and locality data. Actual rent and property value may vary.',
              style: GoogleFonts.poppins(
                fontSize: 9.5.sp,
                color: const Color(0xFF64748B),
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiMetricTile({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    Color valueColor = const Color(0xFF007A5E),
  }) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13.sp, color: const Color(0xFF64748B)),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 9.5.sp, color: const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          if (subValue != null)
            Text(
              subValue,
              style: GoogleFonts.poppins(fontSize: 9.sp, color: const Color(0xFF94A3B8)),
            ),
        ],
      ),
    );
  }

  // 🤝 Connect With Partner Bottom Sheet — collects/creates a lead via
  // POST /leads/from-property (see LeadRepository.createLeadFromProperty).
  void _showConnectPartnerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConnectPartnerSheet(controller: controller),
    );
  }

  Widget _buildPartnerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8F5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.groups_rounded, color: const Color(0xFF007A5E), size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need property details?',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Connect with a verified DigiNiwas partner for availability, documents and local support.',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showConnectPartnerSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007A5E),
                padding: EdgeInsets.symmetric(vertical: 13.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Connect with DigiNiwas Partner',
                    style: GoogleFonts.poppins(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15.sp),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.bookmark_border_rounded, color: const Color(0xFF007A5E), size: 16.sp),
              label: Text(
                'Save Property',
                style: GoogleFonts.poppins(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF007A5E)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: EdgeInsets.symmetric(vertical: 13.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProperties() {
    return Obx(() {
      if (controller.isSimilarLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: const Center(child: CircularProgressIndicator(color: Color(0xFF007A5E))),
        );
      }

      if (controller.similarProperties.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              children: [
                Text(
                  'Similar Properties Near You',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Text(
                  'See All (${controller.similarProperties.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF007A5E),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 180.h,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              itemCount: controller.similarProperties.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final item = controller.similarProperties[index];

                String imgUrl = '';
                final rawImgs = item['images'];
                if (rawImgs is List && rawImgs.isNotEmpty) {
                  imgUrl = rawImgs[0] is Map ? (rawImgs[0]['url'] ?? '') : rawImgs[0].toString();
                } else {
                  imgUrl = item['image']?.toString() ?? '';
                }

                final propTitle = item['title']?.toString() ?? item['name']?.toString() ?? 'Property';
                final locality = item['locality']?.toString() ?? item['city']?.toString() ?? '';
                final priceVal = item['price'];

                return GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.propertyDetails,
                      arguments: {'property': item},
                    );
                  },
                  child: _similarPropertyCard(
                    image: imgUrl,
                    title: propTitle,
                    location: locality,
                    price: formatPrice(priceVal),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _similarPropertyCard({
    required String image,
    required String title,
    required String location,
    required String price,
  }) {
    return Container(
      width: 165.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                child: Image.network(
                  image,
                  width: double.infinity,
                  height: 100.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 100.h,
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.home_work_rounded, color: Colors.grey)),
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
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 10.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 9.5.sp, color: const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  price,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF007A5E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 📅 Schedule Visit Bottom Sheet — now wired to real POST /visits/request
// ============================================================
// 🤝 Connect With Partner Bottom Sheet
// Matches the "Connect with DigiNiwas Partner" popup: shows the resolved
// partner for this property and three contact actions. WhatsApp/Call fire
// a best-effort lead (POST /leads/from-property) in the background before
// opening WhatsApp/the dialer. "Request Instant Callback" is the actual
// lead form — it collects name + phone and submits the lead directly.
// ============================================================
class _ConnectPartnerSheet extends StatefulWidget {
  final PropertyDetailsController controller;

  const _ConnectPartnerSheet({required this.controller});

  @override
  State<_ConnectPartnerSheet> createState() => _ConnectPartnerSheetState();
}

class _ConnectPartnerSheetState extends State<_ConnectPartnerSheet> {
  String _partnerName = 'DigiNiwas Partner';
  String _partnerSub = 'Verified Partner';
  String _partnerPhone = '9876543210';
  String _partnerId = '';
  bool _resolvingPartner = true;

  bool _showCallbackForm = false;
  bool _callbackSent = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  AgentRepository get _agentRepository {
    if (Get.isRegistered<AgentRepository>()) return Get.find<AgentRepository>();
    return Get.put(AgentRepository(ApiService.instance), permanent: true);
  }

  LeadController get _leadController {
    if (Get.isRegistered<LeadController>()) return Get.find<LeadController>();
    final repo = Get.isRegistered<LeadRepository>()
        ? Get.find<LeadRepository>()
        : Get.put(LeadRepository(ApiService.instance), permanent: true);
    return Get.put(LeadController(repo), permanent: true);
  }

  @override
  void initState() {
    super.initState();
    _prefillBuyerInfo();
    _resolvePartner();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _prefillBuyerInfo() async {
    final name = await StorageService.instance.name;
    final phone = await StorageService.instance.phone;
    if (!mounted) return;
    setState(() {
      if (name != null && name.isNotEmpty) _nameController.text = name;
      if (phone != null && phone.isNotEmpty) _phoneController.text = phone;
    });
  }

  String _extractPropertyId(Map<String, dynamic> propertyMap) {
    return propertyMap['_id']?.toString() ??
        propertyMap['propertyId']?.toString() ??
        propertyMap['propertyCode']?.toString() ??
        propertyMap['id']?.toString() ??
        '';
  }

  /// Same resolution order as the Schedule Visit flow: a partnerId/object
  /// carried directly on the property, else the best-ranked nearby agent.
  Future<void> _resolvePartner() async {
    final property = widget.controller.property;
    final direct = property['partnerId']?.toString() ?? property['assignedPartnerId']?.toString();

    Map<String, dynamic>? partnerMap;
    for (final key in ['partner', 'assignedPartner']) {
      if (property[key] is Map) {
        partnerMap = Map<String, dynamic>.from(property[key]);
        break;
      }
    }

    if (partnerMap == null || (direct == null || direct.isEmpty)) {
      try {
        final lat = (property['latitude'] as num?)?.toDouble();
        final lng = (property['longitude'] as num?)?.toDouble();
        final city = property['city']?.toString();
        final agents = await _agentRepository.getNearbyAgents(lat: lat, lng: lng, city: city);
        if (agents.isNotEmpty) partnerMap ??= agents.first;
      } catch (_) {
        // Keep the generic placeholder if resolution fails — contact
        // actions still work using the shared support numbers.
      }
    }

    if (!mounted) return;
    setState(() {
      _partnerId = (direct != null && direct.isNotEmpty)
          ? direct
          : partnerMap?['_id']?.toString() ?? partnerMap?['id']?.toString() ?? '';
      if (partnerMap != null) {
        _partnerName = partnerMap['name']?.toString() ?? _partnerName;
        final locality = partnerMap['locality']?.toString() ?? partnerMap['serviceLocality']?.toString();
        _partnerSub = (locality != null && locality.isNotEmpty)
            ? 'Locality Specialist • $locality'
            : (partnerMap['partnerType']?.toString() ?? _partnerSub);
        final phone = partnerMap['phone']?.toString();
        if (phone != null && phone.isNotEmpty) _partnerPhone = phone;
      }
      _resolvingPartner = false;
    });
  }

  Future<String?> _getBuyerId() async {
    String? buyerId = await StorageService.instance.buyerId;
    if (buyerId == null || buyerId.isEmpty) buyerId = await StorageService.instance.userId;
    if (buyerId == null || buyerId.isEmpty) {
      final userJson = await SecureStorageService.instance.getUserData();
      if (userJson != null && userJson.isNotEmpty) {
        try {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          buyerId = userMap['id']?.toString() ?? userMap['_id']?.toString() ?? userMap['buyerId']?.toString();
        } catch (_) {}
      }
    }
    return buyerId;
  }

  /// WhatsApp / Call: create the lead in the background (best-effort — a
  /// missing name/phone must never block the actual contact action), then
  /// perform the action itself.
  Future<void> _handleQuickContact(String contactPreference) async {
    final propertyId = _extractPropertyId(widget.controller.property);
    final buyerId = await _getBuyerId();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (propertyId.isNotEmpty && (name.isNotEmpty || phone.isNotEmpty || (buyerId != null && buyerId.isNotEmpty))) {
      unawaited(_leadController.createLeadFromProperty(
        propertyId: propertyId,
        buyerId: buyerId,
        partnerId: _partnerId,
        name: name.isNotEmpty ? name : 'Guest',
        phone: phone,
        contactPreference: contactPreference,
      ));
    }

    if (contactPreference == 'whatsapp') {
      await widget.controller.launchWhatsApp(_partnerPhone);
    } else {
      await widget.controller.makePhoneCall(_partnerPhone);
    }
    if (mounted) Navigator.pop(context);
  }

  /// Request Instant Callback — the actual lead form: requires a name and
  /// phone (the partner needs these to call the buyer back) and POSTs
  /// straight to /leads/from-property.
  Future<void> _submitCallbackRequest() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      Get.snackbar(
        'Details Required',
        'Please enter your name and phone number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
      return;
    }

    final propertyId = _extractPropertyId(widget.controller.property);
    if (propertyId.isEmpty) {
      Get.snackbar(
        'Error',
        'Could not identify this property. Please go back and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
      return;
    }

    final buyerId = await _getBuyerId();
    final success = await _leadController.createLeadFromProperty(
      propertyId: propertyId,
      buyerId: buyerId,
      partnerId: _partnerId,
      name: name,
      phone: phone,
      contactPreference: 'callback',
    );

    if (!success) {
      Get.snackbar(
        'Error',
        _leadController.submitError.value ?? 'Could not send your request. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
      return;
    }

    if (!mounted) return;
    setState(() => _callbackSent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Connect with DigiNiwas Partner',
                      style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close_rounded, color: const Color(0xFF64748B), size: 20.sp),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Get verified pricing, floor plans, and arrange direct site visits.',
                style: GoogleFonts.poppins(fontSize: 11.5.sp, color: const Color(0xFF64748B), height: 1.35),
              ),
              SizedBox(height: 16.h),
              _buildPropertyRow(),
              SizedBox(height: 14.h),
              if (_callbackSent)
                _buildCallbackSuccess()
              else if (_showCallbackForm)
                _buildCallbackForm()
              else
                _buildPartnerAndActions(),
              SizedBox(height: 14.h),
              Center(
                child: Text(
                  '🛡️ Zero Spam Guarantee • Direct connection with verified DigiNiwas partner.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyRow() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: widget.controller.imageUrl.isNotEmpty
                ? Image.network(widget.controller.imageUrl, width: 44.w, height: 44.w, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 44.w, height: 44.w, color: const Color(0xFFE2E8F0)))
                : Container(width: 44.w, height: 44.w, color: const Color(0xFFE2E8F0), child: const Icon(Icons.apartment_rounded, color: Colors.white)),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.controller.title.isNotEmpty ? widget.controller.title : 'This Property',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                ),
                if (widget.controller.address.isNotEmpty)
                  Text(
                    widget.controller.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 10.5.sp, color: const Color(0xFF64748B)),
                  ),
              ],
            ),
          ),
          if (widget.controller.priceDisplay.isNotEmpty)
            Text(
              widget.controller.priceDisplay,
              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF007A5E)),
            ),
        ],
      ),
    );
  }

  Widget _buildPartnerAndActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF9),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFCFF3E7)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: const Color(0xFF007A5E),
                child: Text(
                  _resolvingPartner ? '..' : (_partnerName.isNotEmpty ? _partnerName[0].toUpperCase() : 'P'),
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _resolvingPartner ? 'Finding your partner…' : _partnerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        if (!_resolvingPartner)
                          Icon(Icons.verified_rounded, color: const Color(0xFF007A5E), size: 14.sp),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _resolvingPartner ? ' ' : _partnerSub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 10.5.sp, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleQuickContact('whatsapp'),
            icon: const Icon(Icons.chat_rounded, color: Colors.white, size: 16),
            label: Text('Chat on WhatsApp', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12.5.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              padding: EdgeInsets.symmetric(vertical: 13.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleQuickContact('call'),
            icon: const Icon(Icons.call_rounded, color: Colors.white, size: 16),
            label: Text('Call Partner Directly', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12.5.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F2544),
              padding: EdgeInsets.symmetric(vertical: 13.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _showCallbackForm = true),
            icon: Icon(Icons.notifications_active_rounded, color: const Color(0xFF007A5E), size: 16.sp),
            label: Text('Request Instant Callback', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF007A5E), fontSize: 12.5.sp)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: EdgeInsets.symmetric(vertical: 13.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallbackForm() {
    return Obx(() {
      final isSubmitting = _leadController.isSubmitting.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request Instant Callback', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
          SizedBox(height: 2.h),
          Text(
            'Share your details and a verified partner will call you back shortly.',
            style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF64748B), height: 1.35),
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: _nameController,
            style: GoogleFonts.poppins(fontSize: 12.5.sp),
            decoration: InputDecoration(
              labelText: 'Your Name',
              labelStyle: GoogleFonts.poppins(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
              prefixIcon: Icon(Icons.person_outline_rounded, color: const Color(0xFF64748B), size: 18.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.poppins(fontSize: 12.5.sp),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: GoogleFonts.poppins(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
              prefixIcon: Icon(Icons.phone_outlined, color: const Color(0xFF64748B), size: 18.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : () => setState(() => _showCallbackForm = false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('Back', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF334155), fontSize: 12.5.sp)),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitCallbackRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A5E),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Request Callback', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12.5.sp)),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildCallbackSuccess() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(color: const Color(0xFFEFF8F5), shape: BoxShape.circle),
          child: Icon(Icons.check_circle_rounded, color: const Color(0xFF007A5E), size: 32.sp),
        ),
        SizedBox(height: 12.h),
        Text('Callback Requested!', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
        SizedBox(height: 4.h),
        Text(
          'A verified DigiNiwas partner will call you back shortly on ${_phoneController.text.trim()}.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 11.5.sp, color: const Color(0xFF64748B), height: 1.4),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007A5E),
              padding: EdgeInsets.symmetric(vertical: 13.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
            ),
            child: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12.5.sp)),
          ),
        ),
      ],
    );
  }
}

class _ScheduleVisitBottomSheet extends StatefulWidget {
  final PropertyDetailsController controller;

  const _ScheduleVisitBottomSheet({required this.controller});

  @override
  State<_ScheduleVisitBottomSheet> createState() => _ScheduleVisitBottomSheetState();
}

class _ScheduleVisitBottomSheetState extends State<_ScheduleVisitBottomSheet> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  String _selectedTimeSlot = '11:00 AM - 12:00 PM';

  final List<String> _timeSlots = [
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 01:00 PM',
    '02:00 PM - 03:00 PM',
    '04:00 PM - 05:00 PM',
    '05:00 PM - 06:00 PM',
  ];

  /// Registered lazily so this bottom sheet works even if the app's
  /// InitialBinding hasn't put VisitController yet.
  /// NOTE: ApiService is a plain singleton (`ApiService.instance`), not a
  /// GetX-registered dependency, so we pass it in directly here rather
  /// than calling `Get.find()` for it.
  VisitController get _visitController {
    if (Get.isRegistered<VisitController>()) return Get.find<VisitController>();
    final repo = Get.isRegistered<VisitRepository>()
        ? Get.find<VisitRepository>()
        : Get.put(VisitRepository(ApiService.instance), permanent: true);
    return Get.put(VisitController(repo), permanent: true);
  }

  AgentRepository get _agentRepository {
    if (Get.isRegistered<AgentRepository>()) return Get.find<AgentRepository>();
    return Get.put(AgentRepository(ApiService.instance), permanent: true);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = now;
  }

  void _changeMonth(int increment) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + increment, 1);
    });
  }

  // Safe Price Formatter helper inside BottomSheet
  String _formatPriceSafely(dynamic priceValue) {
    if (priceValue == null) return '₹ 0';
    String priceStr = priceValue.toString().trim();
    if (priceStr.contains('L') || priceStr.contains('Cr') || priceStr.contains('₹')) {
      return priceStr;
    }

    double? price = double.tryParse(priceStr);
    if (price == null) return '₹ $priceValue';

    if (price >= 10000000) {
      double cr = price / 10000000;
      return '₹ ${cr % 1 == 0 ? cr.toInt() : cr.toStringAsFixed(1)} Cr';
    } else if (price >= 100000) {
      double lakh = price / 100000;
      return '₹ ${lakh % 1 == 0 ? lakh.toInt() : lakh.toStringAsFixed(1)} L';
    } else if (price >= 1000) {
      double thousand = price / 1000;
      return '₹ ${thousand % 1 == 0 ? thousand.toInt() : thousand.toStringAsFixed(1)} K';
    }
    return '₹ $price';
  }

  String _extractPropertyId(Map<String, dynamic> propertyMap) {
    return propertyMap['_id']?.toString() ??
        propertyMap['propertyId']?.toString() ??
        propertyMap['propertyCode']?.toString() ??
        propertyMap['id']?.toString() ??
        '';
  }

  /// The backend requires a `partnerId` on every visit request. Tries the
  /// common shapes a property payload might carry it in — a flat
  /// `partnerId`/`assignedPartnerId` field, or a nested `partner`/
  /// `assignedPartner` object with an `_id`/`id`.
  /// NOTE: confirm the actual field name your `/properties/:id` (or
  /// `/properties/new-listings` etc.) response uses and adjust this list
  /// if none of these match.
  String _extractPartnerId(Map<String, dynamic> propertyMap) {
    final direct = propertyMap['partnerId']?.toString() ??
        propertyMap['assignedPartnerId']?.toString();
    if (direct != null && direct.isNotEmpty) return direct;

    for (final key in ['partner', 'assignedPartner']) {
      final nested = propertyMap[key];
      if (nested is Map) {
        final id = nested['_id']?.toString() ?? nested['id']?.toString();
        if (id != null && id.isNotEmpty) return id;
      }
    }
    return '';
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

  /// Actually calls POST /visits/request via VisitController, then shows
  /// the confirmation dialog populated with the real response.
  Future<void> _submitVisitRequest() async {
    debugPrint('🟢 _submitVisitRequest CALLED'); // TEMP DEBUG — remove once flow works
    final visitController = _visitController;
    debugPrint('🟢 isSubmitting currently = ${visitController.isSubmitting.value}');

    final buyerId = await _getBuyerId();
    debugPrint('🔵 buyerId = $buyerId'); // TEMP DEBUG
    if (buyerId == null || buyerId.isEmpty) {
      debugPrint('🔴 STOPPED: buyerId missing — showing Login Required snackbar'); // TEMP DEBUG
      Get.snackbar(
        'Login Required',
        'Please login to schedule a visit.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
      return;
    }

    final propertyId = _extractPropertyId(widget.controller.property);
    debugPrint('🔵 propertyId = $propertyId'); // TEMP DEBUG
    if (propertyId.isEmpty) {
      debugPrint('🔴 STOPPED: propertyId missing — showing Error snackbar'); // TEMP DEBUG
      debugPrint('🔵 Full property map = ${widget.controller.property}'); // TEMP DEBUG
      Get.snackbar(
        'Error',
        'Could not identify this property. Please go back and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
      return;
    }

    var partnerId = _extractPartnerId(widget.controller.property);
    debugPrint('🔵 partnerId (from property) = $partnerId'); // TEMP DEBUG

    if (partnerId.isEmpty) {
      // Property didn't carry a partnerId directly — resolve one via the
      // "nearby verified agents" endpoint using the property's location.
      debugPrint('🟠 partnerId not on property — resolving via nearby agents...'); // TEMP DEBUG
      final lat = (widget.controller.property['latitude'] as num?)?.toDouble();
      final lng = (widget.controller.property['longitude'] as num?)?.toDouble();
      final city = widget.controller.property['city']?.toString();

      partnerId = await _agentRepository.getBestNearbyPartnerId(
        lat: lat,
        lng: lng,
        city: city,
      ) ??
          '';
      debugPrint('🔵 partnerId (from nearby agents) = $partnerId'); // TEMP DEBUG
    }

    if (partnerId.isEmpty) {
      debugPrint('🔴 STOPPED: no partner found at all — showing No Partner Assigned snackbar'); // TEMP DEBUG
      Get.snackbar(
        'No Partner Assigned',
        'This property doesn\'t have a verified partner assigned yet, so a visit can\'t be scheduled right now.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
      return;
    }

    // Combine the selected calendar date with the start of the selected
    // time slot (e.g. "11:00 AM - 12:00 PM" -> 11:00 AM) into one DateTime.
    final startTimeStr = _selectedTimeSlot.split(' - ').first.trim();
    final parsedTime = DateFormat('hh:mm a').parse(startTimeStr);
    final requestedVisitAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      parsedTime.hour,
      parsedTime.minute,
    );

    debugPrint('🔵 requestedVisitAt = $requestedVisitAt — calling visitController.requestVisit NOW'); // TEMP DEBUG

    final success = await visitController.requestVisit(
      propertyId: propertyId,
      buyerId: buyerId,
      partnerId: partnerId,
      requestedVisitAt: requestedVisitAt,
    );
    debugPrint('🔵 requestVisit returned success = $success'); // TEMP DEBUG

    if (!success) {
      Get.snackbar(
        'Error',
        visitController.submitError.value ?? 'Could not schedule the visit. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
      return;
    }

    if (mounted) Navigator.pop(context); // close bottom sheet
    _showSuccessDialog(visitController.lastRequestedVisit.value);
  }

  void _showSuccessDialog(RequestVisitData? visitData) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    final propertyTitle = visitData?.propertySnapshot?.title ??
        visitData?.propertySnapshot?.projectName ??
        widget.controller.title;

    DateTime? requestedAt;
    if (visitData?.requestedVisitAt != null) {
      requestedAt = DateTime.tryParse(visitData!.requestedVisitAt!);
    }
    requestedAt ??= DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    final statusLabel = () {
      final approval = visitData?.approvalStatus?.toLowerCase();
      if (approval == 'approved') return 'Confirmed';
      if (approval == 'rejected') return 'Rejected';
      return 'Pending Partner Confirmation';
    }();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, size: 18.sp, color: const Color(0xFF64748B)),
                ),
              ),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F4EA),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: const Color(0xFF007A5E), size: 28.sp),
              ),
              SizedBox(height: 14.h),
              Text(
                'Visit Request Received!',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'We\'ve notified the DigiNiwas desk. A local verified partner is being assigned to lock your slot and guide your tour.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.home_work_rounded, size: 14.sp, color: const Color(0xFF64748B)),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            propertyTitle,
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
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, size: 14.sp, color: const Color(0xFF007A5E)),
                        SizedBox(width: 6.w),
                        Text(
                          '${requestedAt.day} ${months[requestedAt.month - 1].substring(0, 3)} • ${DateFormat('hh:mm a').format(requestedAt)}',
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
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_outlined, size: 16.sp, color: const Color(0xFF2563EB)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'You\'ll receive a WhatsApp & in-app update once confirmed.',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5.sp,
                          color: const Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => const ScheduledVisitsScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A5E),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    'View My Scheduled Visits',
                    style: GoogleFonts.poppins(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.poppins(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    String imgUrl = '';
    final rawImgs = widget.controller.property['images'];
    if (rawImgs is List && rawImgs.isNotEmpty) {
      imgUrl = rawImgs[0] is Map ? (rawImgs[0]['url']?.toString() ?? '') : rawImgs[0].toString();
    } else {
      imgUrl = widget.controller.property['image']?.toString() ?? '';
    }

    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    int daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    int firstDayOfWeek = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday % 7;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: const Color(0xFF007A5E), size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Schedule Visit',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Property Mini Card
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: imgUrl.isNotEmpty
                        ? Image.network(imgUrl, width: 50.w, height: 50.h, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 50.w, height: 50.h, color: Colors.grey.shade200, child: const Icon(Icons.home, size: 20)))
                        : Container(width: 50.w, height: 50.h, color: Colors.grey.shade200, child: const Icon(Icons.home, size: 20)),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.controller.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.controller.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 10.5.sp, color: const Color(0xFF64748B)),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _formatPriceSafely(widget.controller.property['price']),
                          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF007A5E)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified, size: 10.sp, color: const Color(0xFF007A5E)),
                        SizedBox(width: 3.w),
                        Text('Verified', style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w600, color: const Color(0xFF007A5E))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Dynamic Calendar View
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${months[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                        style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 20),
                            onPressed: () => _changeMonth(-1),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.all(4.w),
                          ),
                          SizedBox(width: 12.w),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 20),
                            onPressed: () => _changeMonth(1),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.all(4.w),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekDays.map((day) => Text(day, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)))).toList(),
                  ),
                  SizedBox(height: 8.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    ),
                    itemCount: daysInMonth + firstDayOfWeek,
                    itemBuilder: (context, index) {
                      if (index < firstDayOfWeek) {
                        return const SizedBox.shrink();
                      }
                      int day = index - firstDayOfWeek + 1;
                      DateTime currentDate = DateTime(_displayedMonth.year, _displayedMonth.month, day);
                      bool isSelected = _selectedDate.year == currentDate.year &&
                          _selectedDate.month == currentDate.month &&
                          _selectedDate.day == currentDate.day;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = currentDate;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF007A5E) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Select Time Title
            Text(
              'Select Time',
              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
            ),
            SizedBox(height: 8.h),

            // Time Slots Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                String slot = _timeSlots[index];
                bool isSelected = _selectedTimeSlot == slot;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeSlot = slot;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF007A5E) : const Color(0xFFCBD5E1),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      slot,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF007A5E) : const Color(0xFF334155),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),

            // Request Visit Button — now hits POST /visits/request for real
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final visitController = _visitController;
                debugPrint('🟡 Button rebuilt, isSubmitting=${visitController.isSubmitting.value}'); // TEMP DEBUG
                return ElevatedButton(
                  onPressed: visitController.isSubmitting.value
                      ? null
                      : () {
                    debugPrint('🟢 BUTTON TAPPED'); // TEMP DEBUG
                    _submitVisitRequest();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A5E),
                    disabledBackgroundColor: const Color(0xFF007A5E).withOpacity(0.6),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: visitController.isSubmitting.value
                      ? SizedBox(
                    height: 18.h,
                    width: 18.h,
                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    'Request Visit for ${_selectedDate.day} ${months[_selectedDate.month - 1].substring(0, 3)}',
                    style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenZoomGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenZoomGallery({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenZoomGallery> createState() => _FullScreenZoomGalleryState();
}

class _FullScreenZoomGalleryState extends State<_FullScreenZoomGallery> {
  late PageController _galleryPageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _galleryPageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _galleryPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.imageUrls.length}',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _galleryPageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================= REAL, API-DRIVEN SCHEDULED VISITS SCREEN =================
class ScheduledVisitsScreen extends StatefulWidget {
  const ScheduledVisitsScreen({super.key});

  @override
  State<ScheduledVisitsScreen> createState() => _ScheduledVisitsScreenState();
}

class _ScheduledVisitsScreenState extends State<ScheduledVisitsScreen> {
  int _selectedTab = 0; // 0 for Upcoming, 1 for Under Review

  VisitController get controller {
    if (Get.isRegistered<VisitController>()) return Get.find<VisitController>();
    final repo = Get.isRegistered<VisitRepository>()
        ? Get.find<VisitRepository>()
        : Get.put(VisitRepository(ApiService.instance), permanent: true);
    return Get.put(VisitController(repo), permanent: true);
  }

  @override
  void initState() {
    super.initState();
    controller.fetchMyVisits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: const Color(0xFF0F172A), size: 20.sp),
          onPressed: () {},
        ),
        title: Text(
          'LuxeEstate',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF007A5E),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: const Color(0xFF0F172A), size: 20.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF007A5E),
        onRefresh: controller.fetchMyVisits,
        child: Obx(() {
          final isLoading = controller.isFetchingVisits.value;
          final upcoming = controller.upcomingVisits;
          final underReview = controller.underReviewVisits;
          final activeList = _selectedTab == 0 ? upcoming : underReview;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Scheduled Visits',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 14.h),

                Row(
                  children: [
                    _buildTabButton(0, 'Upcoming', '${upcoming.length}'),
                    SizedBox(width: 10.w),
                    _buildTabButton(1, 'Under Review', '${underReview.length}'),
                  ],
                ),
                SizedBox(height: 20.h),

                if (isLoading && activeList.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 60.h),
                    child: const Center(child: CircularProgressIndicator(color: Color(0xFF007A5E))),
                  )
                else if (controller.fetchError.value != null && activeList.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Center(
                      child: Text(
                        controller.fetchError.value!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 12.5.sp, color: Colors.red),
                      ),
                    ),
                  )
                else if (activeList.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 60.h),
                      child: Center(
                        child: Text(
                          _selectedTab == 0 ? 'No upcoming visits yet.' : 'Nothing under review right now.',
                          style: GoogleFonts.poppins(fontSize: 12.5.sp, color: const Color(0xFF64748B)),
                        ),
                      ),
                    )
                  else
                    ...activeList.map((visit) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _selectedTab == 0
                          ? _buildUpcomingVisitCard(visit)
                          : _buildUnderReviewVisitCard(visit),
                    )),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Widget for Filter Tabs
  Widget _buildTabButton(int index, String title, String count) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007A5E) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFFCBD5E1),
                shape: BoxShape.circle,
              ),
              child: Text(
                count,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return DateFormat('EEE, d MMM • hh:mm a').format(dt);
  }

  // Upcoming Visit Card — built entirely from live VisitStatusData
  Widget _buildUpcomingVisitCard(VisitStatusData v) {
    final propertyTitle = v.propertySnapshot?.title ?? v.propertySnapshot?.projectName ?? 'Property';
    final locality = [v.propertySnapshot?.locality, v.propertySnapshot?.city]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');
    final propertyImage = v.propertySnapshot?.image;
    final partner = v.partnerSnapshot;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info: Image, Title, Status Badge
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: (propertyImage != null && propertyImage.isNotEmpty)
                      ? Image.network(
                    propertyImage,
                    width: 60.w,
                    height: 60.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60.w,
                      height: 60.w,
                      color: Colors.grey.shade300,
                      child: Icon(Icons.image, color: Colors.grey.shade600),
                    ),
                  )
                      : Container(
                    width: 60.w,
                    height: 60.w,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.image, color: Colors.grey.shade600),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              propertyTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F4EA),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6.w, height: 6.w, decoration: const BoxDecoration(color: Color(0xFF007A5E), shape: BoxShape.circle)),
                                SizedBox(width: 4.w),
                                Text(
                                  'Visit Confirmed',
                                  style: GoogleFonts.poppins(fontSize: 9.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF007A5E)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      if (locality.isNotEmpty)
                        Text(
                          locality,
                          style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF64748B)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Date & Time Banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, size: 16.sp, color: const Color(0xFF007A5E)),
                SizedBox(width: 8.w),
                Text(
                  _formatDateTime(v.approvedVisitAt ?? v.requestedVisitAt),
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          // Timeline Section — built from real visit history
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              children: _buildTimeline(v),
            ),
          ),

          // Partner Details Card
          if (partner != null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.w),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: Colors.grey.shade400,
                    child: Icon(Icons.person, color: Colors.white, size: 20.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partner.name ?? 'Assigned Partner',
                          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                        ),
                        if (partner.partnerType != null)
                          Text(
                            partner.partnerType!,
                            style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF64748B)),
                          ),
                      ],
                    ),
                  ),
                  if (partner.phone != null) ...[
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.phone_outlined, size: 16.sp, color: const Color(0xFF007A5E)),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(color: Color(0xFFE6F4EA), shape: BoxShape.circle),
                      child: Icon(Icons.chat_bubble_outline_rounded, size: 16.sp, color: const Color(0xFF007A5E)),
                    ),
                  ],
                ],
              ),
            ),
          SizedBox(height: 14.h),

          // Bottom Action Buttons (Get Directions & Reschedule)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007A5E),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions, size: 16.sp, color: Colors.white),
                        SizedBox(width: 6.w),
                        Text('Get Directions', style: GoogleFonts.poppins(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text('Reschedule / Cancel', style: GoogleFonts.poppins(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
        ],
      ),
    );
  }

  /// Builds the timeline tiles from the visit's real `history` list. Falls
  /// back to a simple "Visit Requested" step if history is empty.
  List<Widget> _buildTimeline(VisitStatusData v) {
    final entries = <_TimelineEntry>[];

    if (v.history != null && v.history!.isNotEmpty) {
      for (final h in v.history!) {
        entries.add(_TimelineEntry(
          title: h.action ?? (h.toStatus != null ? 'Status: ${h.toStatus}' : 'Update'),
          subtitle: _formatDateTime(h.updatedAt),
        ));
      }
    } else {
      entries.add(_TimelineEntry(
        title: 'Visit Requested',
        subtitle: _formatDateTime(v.createdAt ?? v.requestedVisitAt),
      ));
    }

    // Always show a final "Physical Tour" step as the pending future step.
    entries.add(const _TimelineEntry(title: 'Physical Tour', subtitle: '', isFuture: true));

    return List.generate(entries.length, (i) {
      final e = entries[i];
      final isLast = i == entries.length - 1;
      return _buildTimelineTile(
        e.title,
        e.subtitle,
        !e.isFuture,
        !isLast,
        isCurrent: !e.isFuture && i == entries.length - 2,
      );
    });
  }

  // Under Review Visit Card — built entirely from live VisitStatusData
  Widget _buildUnderReviewVisitCard(VisitStatusData v) {
    final propertyTitle = v.propertySnapshot?.title ?? v.propertySnapshot?.projectName ?? 'Property';
    final locality = [v.propertySnapshot?.locality, v.propertySnapshot?.city]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');
    final propertyImage = v.propertySnapshot?.image;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VisitDetailsScreen(visit: v),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: (propertyImage != null && propertyImage.isNotEmpty)
                        ? Image.network(
                      propertyImage,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60.w,
                        height: 60.w,
                        color: Colors.grey.shade300,
                        child: Icon(Icons.image, color: Colors.grey.shade600),
                      ),
                    )
                        : Container(
                      width: 60.w,
                      height: 60.w,
                      color: Colors.grey.shade300,
                      child: Icon(Icons.image, color: Colors.grey.shade600),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                propertyTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                'Under Review',
                                style: GoogleFonts.poppins(fontSize: 9.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFFB45309)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        if (locality.isNotEmpty)
                          Text(
                            locality,
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF64748B)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              color: const Color(0xFFF8FAFC),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 16.sp, color: const Color(0xFF007A5E)),
                  SizedBox(width: 8.w),
                  Text(
                    _formatDateTime(v.requestedVisitAt),
                    style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16.sp, color: const Color(0xFFB45309)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Finding the best agent',
                          style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFFB45309)),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          v.teamRemarks ?? v.adminRemarks ?? 'We are currently assigning a dedicated property expert for this visit. You will be notified once confirmed.',
                          style: GoogleFonts.poppins(fontSize: 10.5.sp, color: const Color(0xFF92400E), height: 1.3),
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
  }

  // Helper widget for Timeline Steps
  Widget _buildTimelineTile(String title, String subtitle, bool isCompleted, bool showLine, {bool isCurrent = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted && !isCurrent ? const Color(0xFF007A5E) : Colors.white,
                border: Border.all(
                  color: isCompleted ? const Color(0xFF007A5E) : const Color(0xFFCBD5E1),
                  width: isCurrent ? 5.w : 2.w,
                ),
              ),
              child: isCompleted && !isCurrent
                  ? Icon(Icons.check, size: 10.sp, color: Colors.white)
                  : null,
            ),
            if (showLine)
              Container(
                width: 2.w,
                height: 26.h,
                color: const Color(0xFFCBD5E1),
              ),
          ],
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: isCompleted || isCurrent ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF64748B)),
                ),
              ],
              SizedBox(height: 14.h),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineEntry {
  final String title;
  final String subtitle;
  final bool isFuture;

  const _TimelineEntry({required this.title, required this.subtitle, this.isFuture = false});
}



class VisitDetailsScreen extends StatelessWidget {
  final VisitStatusData visit;

  const VisitDetailsScreen({super.key, required this.visit});

  String _formatDateTime(String? iso) {
    if (iso == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $hour:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final propertyTitle = visit.propertySnapshot?.title ?? visit.propertySnapshot?.projectName ?? 'Property Details';
    final locality = [visit.propertySnapshot?.locality, visit.propertySnapshot?.city]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');
    final propertyImage = visit.propertySnapshot?.image;
    final partner = visit.partnerSnapshot;
    final isConfirmed = visit.approvalStatus?.toLowerCase() == 'approved' || visit.status?.toLowerCase() == 'confirmed';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF0F172A), size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Visit Details',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Card Header
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: (propertyImage != null && propertyImage.isNotEmpty)
                        ? Image.network(
                      propertyImage,
                      width: 70.w,
                      height: 70.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70.w,
                        height: 70.w,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.home),
                      ),
                    )
                        : Container(
                      width: 70.w,
                      height: 70.w,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.home),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: isConfirmed ? const Color(0xFFE6F4EA) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            isConfirmed ? 'Visit Confirmed' : 'Under Review',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w600,
                              color: isConfirmed ? const Color(0xFF007A5E) : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          propertyTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (locality.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            locality,
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Date & Time Box
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.calendar_month_rounded, color: const Color(0xFF007A5E), size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled Date & Time',
                        style: GoogleFonts.poppins(fontSize: 10.5.sp, color: const Color(0xFF64748B)),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _formatDateTime(visit.approvedVisitAt ?? visit.requestedVisitAt),
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Timeline Section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visit Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  ...(_buildFullTimeline(visit)),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Partner Details Card (if available)
            if (partner != null) ...[
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22.r,
                      backgroundColor: const Color(0xFF007A5E).withOpacity(0.1),
                      child: Icon(Icons.person, color: const Color(0xFF007A5E), size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partner.name ?? 'Assigned Partner',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            partner.partnerType?.isNotEmpty == true ? partner.partnerType! : 'Verified DigiNiwas Partner',
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    if (partner.phone != null && partner.phone!.isNotEmpty)
                      IconButton(
                        onPressed: () {},
                        icon: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6F4EA),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.phone, color: const Color(0xFF007A5E), size: 18.sp),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.directions, color: Colors.white),
                label: Text(
                  'Get Directions',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A5E),
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'Reschedule / Cancel Visit',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFullTimeline(VisitStatusData v) {
    final history = v.history ?? [];
    return [
      _timelineTile('Visit Requested', subtitle: _formatDateTime(v.createdAt), isCompleted: true, showLine: true),
      _timelineTile(
        'Agent Assigned',
        subtitle: history.length > 1 ? 'Assigned successfully' : 'Pending assignment',
        isCompleted: history.isNotEmpty,
        showLine: true,
      ),
      _timelineTile('Slot Confirmed & Locked', isCompleted: history.isNotEmpty, showLine: true),
      _timelineTile('Physical Tour', isCompleted: false, showLine: false, isFuture: true),
    ];
  }

  Widget _timelineTile(
      String title, {
        String? subtitle,
        bool isCompleted = true,
        bool showLine = true,
        bool isFuture = false,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted && !isFuture ? const Color(0xFF007A5E) : Colors.white,
                border: Border.all(
                  color: isCompleted && !isFuture ? const Color(0xFF007A5E) : const Color(0xFFCBD5E1),
                  width: 2.w,
                ),
              ),
              child: isCompleted && !isFuture
                  ? Icon(Icons.check, size: 11.sp, color: Colors.white)
                  : null,
            ),
            if (showLine)
              Container(
                width: 2.w,
                height: 30.h,
                color: const Color(0xFFCBD5E1),
              ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: isFuture ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(fontSize: 10.5.sp, color: const Color(0xFF64748B)),
                ),
              ],
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ],
    );
  }
}