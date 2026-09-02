// =====================================================================
// PROPERTY DETAILS SCREEN (WITH REAL SHARE & DYNAMIC FAVORITE TOGGLE)
// =====================================================================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:share_plus/share_plus.dart'; // 👈 Real device sharing package
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const PropertyDetailsScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  bool _isFavorite = false;

  void _open360View(BuildContext context) {
    Get.to(() => PanoramaViewerScreen(
          imageUrl: widget.property['panorama_image'] ??
              'https://images.unsplash.com/photo-1557971370-e7298ee473fb?w=1600&auto=format&fit=crop&q=80',
          title: widget.property['name'] ?? 'Celestial Heights',
        ));
  }

  // Helper function to launch WhatsApp safely
  Future<void> _launchWhatsApp(String phone) async {
    final String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final Uri url = Uri.parse(
        "https://wa.me/$cleanPhone?text=Hello, I am interested in ${widget.property['name'] ?? 'this property'}.");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch WhatsApp");
    }
  }

  // Helper function to make a phone call
  Future<void> _makePhoneCall(String phone) async {
    final Uri url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Could not launch Dialler");
    }
  }

  // Real Native Share Method
  Future<void> _shareProperty() async {
    final propertyName = widget.property['name'] ?? 'Property';
    final propertyPrice = widget.property['price'] ?? '';
    final propertyAddress = widget.property['address'] ?? '';

    await Share.share(
      'Check out this verified property on DigiNiwas!\n\n'
          '🏠 $propertyName\n'
          '📍 Location: $propertyAddress\n'
          '💰 Price: $propertyPrice\n\n'
          'Download DigiNiwas App for more amazing deals.',
    );
  }

  void _showConnectPartnerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Text(
                'Connect with DigiNiwas\nPartner',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F2544),
                  height: 1.25,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Get verified pricing, floor plans, and arrange direct site visits.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: const Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        widget.property['image'] ??
                            'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&auto=format&fit=crop&q=80',
                        width: 44.w,
                        height: 44.w,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 44.w,
                          height: 44.w,
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(Icons.home_rounded, color: Color(0xFF007A5E)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.property['name'] ?? 'Celestial Heights',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 10.sp, color: const Color(0xFF64748B)),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  widget.property['address'] ?? 'Bopal, Ahmedabad',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      widget.property['price'] ?? '₹85 L',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF007A5E),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FBF9),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFCCEFE5), width: 1.2),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 12.h),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26.r,
                            backgroundImage: const NetworkImage(
                              'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200&auto=format&fit=crop&q=80',
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amit Verma',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Locality Specialist • Bopal & South Bopal',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(Icons.star_rounded, size: 13.sp, color: const Color(0xFFF59E0B)),
                                    SizedBox(width: 2.w),
                                    Text(
                                      '4.9',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '(120+ site visits hosted)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 9.5.sp,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007A5E),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15.r),
                            bottomLeft: Radius.circular(10.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_outlined, size: 10.sp, color: Colors.white),
                            SizedBox(width: 3.w),
                            Text(
                              'Verified Partner',
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
              SizedBox(height: 16.h),

              // WhatsApp Chat Button Trigger
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _launchWhatsApp("919876543210");
                  },
                  icon: Icon(Icons.chat_bubble_outline_rounded, size: 16.sp, color: Colors.white),
                  label: Text(
                    'Chat on WhatsApp',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A5E),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Direct Call Button Trigger
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _makePhoneCall("9876543210");
                  },
                  icon: Icon(Icons.phone_outlined, size: 16.sp, color: Colors.white),
                  label: Text(
                    'Call Partner Directly',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2544),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.calendar_month_outlined, size: 16.sp, color: const Color(0xFF007A5E)),
                  label: Text(
                    'Request Instant Callback',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF007A5E),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF007A5E), width: 1.2),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 12.sp, color: const Color(0xFF64748B)),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      'Zero Spam Guarantee • Direct connection with verified DigiNiwas partner.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 8.5.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Favorite / Dil Toggle Button with dynamic message
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.red : const Color(0xFF0F172A),
              size: 20.sp,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite ? 'Property added to saved list!' : 'Property removed from saved list!',
                    style: GoogleFonts.poppins(fontSize: 12.sp),
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: const Color(0xFF0F2544),
                ),
              );
            },
          ),

          // Real Native Share Button
          IconButton(
            icon: Icon(Icons.share_outlined, color: const Color(0xFF0F172A), size: 20.sp),
            onPressed: _shareProperty,
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.network(
                  widget.property['image'] ??
                      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&auto=format&fit=crop&q=80',
                  width: double.infinity,
                  height: 250.h,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 14.h,
                  right: 16.w,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _open360View(context),
                      borderRadius: BorderRadius.circular(24.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2544).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
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
                Positioned(
                  bottom: 10.h,
                  left: 20.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7F2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFBCE7DA), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_outlined, size: 12.sp, color: const Color(0xFF007A5E)),
                        SizedBox(width: 4.w),
                        Text(
                          'Verified',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF007A5E),
                          ),
                        ),
                      ],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.property['name'] ?? 'Celestial Heights',
                              style: GoogleFonts.poppins(
                                fontSize: 19.sp,
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
                                    widget.property['address'] ?? 'Bopal, Ahmedabad',
                                    maxLines: 1,
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
                      Text(
                        widget.property['price'] ?? '₹85 L',
                        style: GoogleFonts.poppins(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF007A5E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${widget.property['bhk'] ?? '2 BHK'}  •  ${widget.property['sqft'] ?? '1,240 sq.ft'}  •  ${widget.property['status'] ?? 'Ready to Move'}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildAiSnapshotCard(),
                  SizedBox(height: 16.h),
                  _buildPartnerCard(context),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiSnapshotCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFCCEFE5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF007A5E),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 14.sp),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niwas AI Property Snapshot',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF005B48),
                      ),
                    ),
                    Text(
                      'Understand value, rental potential and locality performance',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _snapshotTile(
                  icon: Icons.sell_outlined,
                  title: 'Price Comparison',
                  highlight: '3% below',
                  subtitle: 'similar properties',
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _snapshotTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Estimated Gross\nRental Yield',
                  highlight: '4.8%–5.4%',
                  subtitle: '',
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _snapshotTile(
                  icon: Icons.trending_up_rounded,
                  title: 'Historical Locality\nTrend',
                  highlight: '+7.1% yearly',
                  subtitle: 'Past 3 years',
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _snapshotTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Data Confidence',
                  highlight: 'Medium',
                  subtitle: 'Based on 24\ncomparable listings',
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14.sp, color: const Color(0xFF007A5E)),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'See How This Was Calculated',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF007A5E),
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 11.sp, color: const Color(0xFF007A5E)),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Updated August 2026',
            style: GoogleFonts.poppins(fontSize: 9.sp, color: const Color(0xFF94A3B8)),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5F2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 13.sp, color: const Color(0xFF64748B)),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'Estimates are based on available listings and locality data. Actual rent and property value may vary.',
                    style: GoogleFonts.poppins(
                      fontSize: 9.5.sp,
                      color: const Color(0xFF64748B),
                      height: 1.3,
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

  Widget _snapshotTile({
    required IconData icon,
    required String title,
    required String highlight,
    required String subtitle,
  }) {
    return Container(
      height: 94.h,
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8F5),
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(icon, size: 15.sp, color: const Color(0xFF007A5E)),
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  highlight,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF007A5E),
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 8.sp,
                      color: const Color(0xFF64748B),
                      height: 1.1,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17.r,
                backgroundColor: const Color(0xFFEFF8F5),
                child: Icon(Icons.people_alt_outlined, color: const Color(0xFF007A5E), size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need property details?',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Connect with a verified DigiNiwas partner for availability, documents and local support.',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5.sp,
                        color: const Color(0xFF64748B),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showConnectPartnerBottomSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005B48),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Connect with DigiNiwas Partner',
                    style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.arrow_forward_rounded, size: 14.sp),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isFavorite ? 'Property saved successfully!' : 'Property removed from saved!',
                      style: GoogleFonts.poppins(fontSize: 12.sp),
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: const Color(0xFF0F2544),
                  ),
                );
              },
              icon: Icon(
                _isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                size: 16.sp,
                color: const Color(0xFF005B48),
              ),
              label: Text(
                _isFavorite ? 'Saved Property' : 'Save Property',
                style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF005B48),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFBCE7DA), width: 1.2),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PanoramaViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String title;

  const PanoramaViewerScreen({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PanoramaViewer(
            animSpeed: 1.0,
            sensorControl: SensorControl.orientation,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Text(
                  '360° image failed to load',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
          Positioned(
            top: 48.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.threed_rotation_rounded, color: const Color(0xFF4EE1A0), size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '$title • 360° View',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13.sp,
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
          Positioned(
            bottom: 30.h,
            left: 20.w,
            right: 20.w,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_outlined, color: Colors.white70, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Drag or move phone to explore 360°',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}