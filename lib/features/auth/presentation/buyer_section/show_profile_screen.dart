// =====================================================================
// USER PROFILE SCREEN (MATCHING SCREENSHOT UI)
// =====================================================================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../application/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'Log out?',
          style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
        ),
        content: Text(
          'You will need to verify your phone number again to log back in.',
          style: GoogleFonts.poppins(fontSize: 12.5.sp, color: const Color(0xFF64748B), height: 1.4),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    await Get.find<AuthController>().logout();

    if (!mounted) return;
    setState(() => _isLoggingOut = false);

    AppToast.success(context, 'Logged out successfully');
    if (!context.mounted) return;
    Get.offAllNamed(AppRoutes.chooseRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 120.h),
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20.h),
            _buildStatsGrid(),
            SizedBox(height: 24.h),
            _buildSavedSectionHeader(),
            SizedBox(height: 12.h),
            _buildPropertyCard(
              title: 'Skyline Penthouse, Bandra',
              location: 'Mumbai',
              price: '₹ 4.5 Cr',
              bhk: '4 BHK',
              sqft: '3200 Sq Ft',
              tag: 'Premium',
              tagColor: const Color(0xFF0F172A),
              image:
              'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&auto=format&fit=crop&q=80',
            ),
            SizedBox(height: 14.h),
            _buildPropertyCard(
              title: 'The Heritage Villa',
              location: 'Delhi',
              price: '₹ 12 Cr',
              bhk: '6 BHK',
              sqft: '8500 Sq Ft',
              tag: 'Verified',
              isVerified: true,
              tagColor: const Color(0xFF007A5E),
              image:
              'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&auto=format&fit=crop&q=80',
            ),
            SizedBox(height: 20.h),
            _buildQuickNavTile(
              icon: Icons.favorite_rounded,
              iconBgColor: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              title: 'Saved Properties',
              onTap: () {},
            ),
            SizedBox(height: 10.h),
            _buildQuickNavTile(
              icon: Icons.history_rounded,
              iconBgColor: const Color(0xFFEDE9FE),
              iconColor: const Color(0xFF7C3AED),
              title: 'Recently Viewed',
              onTap: () {},
            ),
            SizedBox(height: 10.h),
            _buildQuickNavTile(
              icon: Icons.logout_rounded,
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFE11D48),
              title: _isLoggingOut ? 'Logging out...' : 'Log Out',
              titleColor: const Color(0xFFE11D48),
              onTap: _isLoggingOut ? () {} : _confirmLogout,
              trailing: _isLoggingOut
                  ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE11D48)),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: const Color(0xFF0F172A), size: 22.sp),
        onPressed: () {},
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home_work_rounded, color: const Color(0xFF00A884), size: 18.sp),
          SizedBox(width: 4.w),
          Text(
            'DIGINIWAS',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F2544),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_none_rounded, color: const Color(0xFF0F172A), size: 22.sp),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE11D48),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 12.w),
        CircleAvatar(
          radius: 14.r,
          backgroundImage: const NetworkImage(
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
          ),
        ),
        SizedBox(width: 14.w),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF007A5E), width: 2),
              ),
              child: CircleAvatar(
                radius: 40.r,
                backgroundImage: const NetworkImage(
                  'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=300&auto=format&fit=crop&q=80',
                ),
              ),
            ),
            Positioned(
              bottom: 4.h,
              right: 4.w,
              child: Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          'Rahul Sharma',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 3.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_outlined, size: 12.sp, color: const Color(0xFF64748B)),
            SizedBox(width: 4.w),
            Text(
              '+91 98765 43210',
              style: GoogleFonts.poppins(
                fontSize: 11.5.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline_rounded, size: 12.sp, color: const Color(0xFF64748B)),
            SizedBox(width: 4.w),
            Text(
              'rahul.sharma@example.com',
              style: GoogleFonts.poppins(
                fontSize: 11.5.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7F2),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFBCE7DA), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user_rounded, size: 12.sp, color: const Color(0xFF007A5E)),
              SizedBox(width: 4.w),
              Text(
                'Verified Buyer',
                style: GoogleFonts.poppins(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF007A5E),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF007A5E),
                ),
              ),
              SizedBox(width: 3.w),
              Icon(Icons.edit_outlined, size: 12.sp, color: const Color(0xFF007A5E)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem('SAVED PROPERTIES', '12', Icons.bookmark_border_rounded),
              ),
              Container(width: 1, height: 44.h, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _buildStatItem('RECENTLY VIEWED', '27', Icons.history_rounded),
              ),
            ],
          ),
          Divider(height: 20.h, thickness: 0.8, color: const Color(0xFFE2E8F0)),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('SCHEDULED VISITS', '5', Icons.calendar_today_outlined),
              ),
              Container(width: 1, height: 44.h, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _buildStatItem('MY ENQUIRIES', '8', Icons.chat_bubble_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF005B48),
                ),
              ),
            ],
          ),
          Icon(icon, size: 20.sp, color: const Color(0xFFCBD5E1)),
        ],
      ),
    );
  }

  Widget _buildSavedSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Saved Properties',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        InkWell(
          onTap: () {},
          child: Text(
            'View All ›',
            style: GoogleFonts.poppins(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF007A5E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard({
    required String title,
    required String location,
    required String price,
    required String bhk,
    required String sqft,
    required String tag,
    required String image,
    required Color tagColor,
    bool isVerified = false,
  }) {
    return Container(
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
                child: Image.network(
                  image,
                  height: 155.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 155.h,
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(Icons.home_work_rounded, color: Color(0xFF007A5E)),
                  ),
                ),
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
                      if (isVerified) ...[
                        Icon(Icons.verified_outlined, size: 10.sp, color: tagColor),
                        SizedBox(width: 3.w),
                      ],
                      Text(
                        tag,
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: tagColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.favorite_rounded, color: const Color(0xFFE11D48), size: 16.sp),
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
                        style: GoogleFonts.poppins(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF007A5E),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 11.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 2.w),
                    Text(
                      location,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Divider(height: 1, thickness: 0.8, color: const Color(0xFFF1F5F9)),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.king_bed_outlined, size: 13.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 4.w),
                    Text(
                      bhk,
                      style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF475569)),
                    ),
                    SizedBox(width: 14.w),
                    Icon(Icons.crop_square_rounded, size: 13.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 4.w),
                    Text(
                      sqft,
                      style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF475569)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16.sp, color: iconColor),
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: titleColor ?? const Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 12.sp, color: const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}