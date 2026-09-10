import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../core/controller/buyer_home_controller.dart';
import '../../../../core/controller/property_detils_controller.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_service.dart';


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
                    _buildPartnerCard(),
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
            onTap: () {
              // TODO: hook up real "how this was calculated" explanation sheet
            },
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

  Widget _buildPartnerCard() {
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
              onPressed: () {
                // TODO: hook up real partner-connect flow
              },
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
              onPressed: () {
                // TODO: hook up real save-property flow (reuse _handleFavoriteToggle)
              },
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

  // =====================================================================
  // 🏘️ REAL SIMILAR PROPERTIES SECTION (Driven via API)
  // =====================================================================
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