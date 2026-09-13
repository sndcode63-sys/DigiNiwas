import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/shimmer.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../seller/controller/seller_controller.dart';
import '../../application/auth_controller.dart';

/// "Seller Profile" screen — fully data-driven from [SellerController]
/// (same `tag: 'sellerHome'` instance the Home / My Partner tabs use).
///
/// Data sources (real endpoints already wired in `SellerRepository`):
///   • GET /v1/sellers/:id                    → name, email, phone, verified.
///   • GET /v1/sellers/:id/properties         → stats grid + assigned partner.
///   • GET /v1/leads/partner/:partnerId       → Total Inquiries.
///   • GET /v1/visits/partner/:partnerId      → Site Visits.
///
/// NOTE — the API guide does not currently expose a seller "update profile"
/// endpoint, nor endpoints for KYC/legal docs, notification settings, or a
/// seller FAQ feed. Those menu rows are wired to a friendly "coming soon"
/// toast instead of a dead tap, and are called out below so it's easy to
/// swap in the real call once the backend adds it.
class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key, this.onNavigateTab});

  /// Lets the parent bottom-nav shell switch tabs (e.g. "My Properties &
  /// Drafts" -> Properties tab, "Assigned Partner Details" -> Partner tab).
  final void Function(int tabIndex)? onNavigateTab;

  SellerController get _controller =>
      Get.find<SellerController>(tag: 'sellerHome');

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final isFirstLoad = controller.isHomeLoading.value &&
              controller.sellerProfile.value == null &&
              controller.properties.isEmpty;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.loadSellerHome(silent: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seller Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Manage your seller account, assigned partners & documents',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  if (isFirstLoad) ...[
                    _buildSkeleton(),
                  ] else ...[
                    if (controller.homeError.value.isNotEmpty) ...[
                      _buildErrorBanner(controller),
                      SizedBox(height: 16.h),
                    ],

                    _buildProfileCard(context, controller),
                    SizedBox(height: 16.h),

                    _buildAssignedPartnerCard(controller),
                    SizedBox(height: 16.h),

                    _buildStatsGrid(controller),
                    SizedBox(height: 20.h),

                    _buildMenuItem(
                      icon: Icons.apartment_rounded,
                      title: 'My Properties & Drafts',
                      onTap: () => onNavigateTab?.call(1),
                    ),
                    SizedBox(height: 10.h),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'KYC & Legal Verification',
                      onTap: () => AppToast.success(context, 'KYC & Legal Verification is coming soon.'),
                    ),
                    SizedBox(height: 10.h),
                    _buildMenuItem(
                      icon: Icons.people_outline_rounded,
                      title: 'Assigned Partner Details',
                      onTap: () => onNavigateTab?.call(2),
                    ),
                    SizedBox(height: 10.h),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Notification & Privacy Settings',
                      onTap: () => AppToast.success(context, 'Notification & Privacy settings are coming soon.'),
                    ),
                    SizedBox(height: 10.h),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Seller FAQs',
                      onTap: () => AppToast.success(context, 'Seller FAQs are coming soon.'),
                    ),
                    SizedBox(height: 24.h),

                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.buyerHome),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C233B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                        ),
                        child: Text(
                          'Switch to Buyer Mode',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    Center(
                      child: TextButton(
                        onPressed: () => _confirmLogout(context),
                        child: Text(
                          'Log Out',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 110.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ===========================================================================
  // Error banner + Skeleton
  // ===========================================================================

  Widget _buildErrorBanner(SellerController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F0),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.redAccent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              controller.homeError.value,
              style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () => controller.loadSellerHome(),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w800, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerWidget.box(width: double.infinity, height: 260.h, borderRadius: 20.r),
        SizedBox(height: 16.h),
        ShimmerWidget.box(width: double.infinity, height: 170.h, borderRadius: 20.r),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(child: ShimmerWidget.box(height: 90.h, borderRadius: 16.r)),
            SizedBox(width: 12.w),
            Expanded(child: ShimmerWidget.box(height: 90.h, borderRadius: 16.r)),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: ShimmerWidget.box(height: 90.h, borderRadius: 16.r)),
            SizedBox(width: 12.w),
            Expanded(child: ShimmerWidget.box(height: 90.h, borderRadius: 16.r)),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // Profile Details Card
  // ===========================================================================

  Widget _buildProfileCard(BuildContext context, SellerController controller) {
    final profile = controller.sellerProfile.value;
    final name = (profile?.name.isNotEmpty ?? false) ? profile!.name : 'DigiNiwas Seller';
    final email = profile?.email ?? '';
    final phone = profile?.phone ?? '';
    final isVerified = profile?.isVerified ?? false;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initialsOf(name),
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5F1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                  size: 12.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4.w),
                Text(
                  isVerified ? 'Verified Property Owner' : 'Verification Pending',
                  style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          if (email.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline_rounded, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],
          if (phone.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_android_rounded, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 6.w),
                Text(
                  phone,
                  style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
              ],
            ),
          SizedBox(height: 16.h),
          OutlinedButton(
            // No seller "update profile" endpoint exists yet in the API
            // guide — flagging this rather than faking a save.
            onPressed: () => AppToast.error(context, 'Editing your profile isn\'t available yet — no update endpoint exists for sellers.'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300, width: 1.2),
              minimumSize: Size(double.infinity, 42.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'DN';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  // ===========================================================================
  // Assigned Partner Card
  // ===========================================================================

  Widget _buildAssignedPartnerCard(SellerController controller) {
    final property = controller.progressProperty.value;
    final hasPartner = property?.partnerId != null && property!.partnerId!.isNotEmpty;
    final partnerName = property?.partnerName ?? 'Not assigned yet';
    final isVerified = property?.partnerVerified ?? false;
    final locality = property?.partnerLocality;

    final assignedCount = hasPartner
        ? controller.properties.where((p) => p.partnerId == property.partnerId).length
        : 0;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAF7),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assigned Partner',
                style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Icon(Icons.handshake_outlined, size: 18.sp, color: AppColors.primary),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              ImageCase(
                url: property?.partnerAvatarUrl,
                width: 44.w,
                height: 44.h,
                fallbackIcon: Icons.person,
                borderRadius: BorderRadius.circular(50.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partnerName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    if (isVerified)
                      Row(
                        children: [
                          Icon(Icons.verified, size: 11.sp, color: AppColors.primary),
                          SizedBox(width: 4.w),
                          Text(
                            'Verified Partner',
                            style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (hasPartner)
                InkWell(
                  onTap: () => _callPartner(property.partnerPhone),
                  borderRadius: BorderRadius.circular(50.r),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                    ),
                    child: Icon(Icons.phone_outlined, size: 18.sp, color: AppColors.primary),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            hasPartner
                ? 'Managing $assignedCount of your properties${locality != null && locality.isNotEmpty ? ' in $locality' : ''}'
                : 'You will be matched with a partner once your property is submitted.',
            style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          if (hasPartner) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: property?.partnerOnline == true ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    property?.partnerOnline == true ? 'Active & Coordinating' : 'Coordinating your listing',
                    style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _callPartner(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ===========================================================================
  // 4 Statistics Grid
  // ===========================================================================

  Widget _buildStatsGrid(SellerController controller) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: [
        _buildStatTile('Total Listed', '${controller.myListingsCount.value}', Icons.apartment_rounded),
        _buildStatTile('Total Inquiries', '${controller.buyerInterestCount.value}', Icons.chat_bubble_outline_rounded),
        _buildStatTile('Site Visits', '${controller.siteVisitsCount.value}', Icons.directions_walk_rounded),
        _buildStatTile('Active Offers', '${controller.offersToReviewCount.value}', Icons.local_offer_outlined),
      ],
    );
  }

  Widget _buildStatTile(String label, String count, IconData icon) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5F1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16.sp),
              ),
            ],
          ),
          Text(
            count,
            style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Reusable Menu Item
  // ===========================================================================

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5F1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Log Out
  // ===========================================================================

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'Log out?',
          style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        content: Text(
          'You will need to log in again to access your seller dashboard.',
          style: GoogleFonts.poppins(fontSize: 12.5.sp, color: AppColors.textSecondary, height: 1.4),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
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

    if (confirmed != true || !context.mounted) return;

    await Get.find<AuthController>().logout();

    if (!context.mounted) return;
    AppToast.success(context, 'Logged out successfully');
    Get.offAllNamed(AppRoutes.chooseRole);
  }
}