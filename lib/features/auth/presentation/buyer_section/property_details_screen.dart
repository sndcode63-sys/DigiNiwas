import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/controller/property_detils_controller.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PropertyDetailsController());

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
          Obx(() => IconButton(
            icon: Icon(
              controller.isFavorite.value ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: controller.isFavorite.value ? Colors.red : const Color(0xFF0F172A),
              size: 20.sp,
            ),
            onPressed: controller.toggleFavorite,
          )),
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

        // Extracting images list safely for the gallery/carousel view
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
        if (imageUrls.isEmpty && controller.imageUrl.isNotEmpty) {
          imageUrls.add(controller.imageUrl);
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel / Stack with 360 Tour Button
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 260.h,
                    child: imageUrls.isNotEmpty
                        ? PageView.builder(
                      itemCount: imageUrls.length,
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

              // Content Body
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property ID & Transaction Type Badge
                    Row(
                      children: [
                        if (controller.property['propertyId'] != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF8F5),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: const Color(0xFFBCE7DA)),
                            ),
                            child: Text(
                              'ID: ${controller.property['propertyId']}',
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

                    // Title & Price Row
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

                    // Meta Info Chips
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

                    // Description Section
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
                    SizedBox(height: 40.h), // Extra space at bottom so content isn't hidden behind the bottom bar
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      // 👇 Yeh raha fixed Bottom Navigation Bar jo WhatsApp aur Call buttons ko hamesha bottom par dikhayega
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