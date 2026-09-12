import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/models/seller_home_feed_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/shimmer.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../seller/controller/seller_controller.dart';
import 'add_property_flow_screen.dart';
import 'my_partner.dart';
import 'seller_profile_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _currentIndex = 0;

  // Shared across every tab of the Seller section for this screen's
  // lifetime, so switching tabs doesn't re-fetch the dashboard.
  late final SellerController _controller;

  // List of screens corresponding to the 5 bottom navigation bar items
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SellerController(), tag: 'sellerHome');
    _controller.loadSellerHome();

    _screens = [
      _buildHomeBodyContent(), // Index 0: Home
      const AddPropertyFlowScreen(), // Index 1: Properties
      const MyPartnerScreen(),
      const _PlaceholderScreen(title: 'Updates Screen'), // Index 3: Updates
      const SellerProfileScreen(),
    ];
  }

  @override
  void dispose() {
    Get.delete<SellerController>(tag: 'sellerHome');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      // Dynamically display the screen based on _currentIndex
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
      // Show FAB only on the Home tab (Index 0)
      floatingActionButton: _currentIndex == 0 ? _buildAddPropertyFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Extracted Home Body Content — now fully data-driven from SellerController.
  Widget _buildHomeBodyContent() {
    return SafeArea(
      child: Obx(() {
        final isFirstLoad = _controller.isHomeLoading.value && _controller.sellerProfile.value == null;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _controller.loadSellerHome(silent: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header (Logo & Icons)
                _buildHeader(),
                SizedBox(height: 20.h),

                if (isFirstLoad) ...[
                  _buildHomeSkeleton(),
                ] else ...[
                  if (_controller.homeError.value.isNotEmpty) ...[
                    _buildErrorBanner(),
                    SizedBox(height: 16.h),
                  ],

                  // Welcome Banner Card
                  _buildWelcomeCard(),
                  SizedBox(height: 20.h),

                  // 4 Stat Grids
                  _buildStatGrids(),
                  SizedBox(height: 24.h),

                  // Your DigiNiwas Partner Card
                  _buildPartnerSection(),
                  SizedBox(height: 20.h),

                  // Property Progress Tracking Card
                  if (_controller.progressProperty.value != null) ...[
                    _buildPropertyProgressCard(_controller.progressProperty.value!),
                    SizedBox(height: 20.h),
                  ] else if (_controller.properties.isEmpty) ...[
                    _buildNoPropertiesCard(),
                    SizedBox(height: 20.h),
                  ],

                  // Niwas AI Suggestion Box
                  if (_controller.aiSuggestionAvailable.value) ...[
                    _buildAiSuggestionCard(),
                    SizedBox(height: 24.h),
                  ],

                  // Recent Partner Updates Section
                  _buildRecentUpdatesSection(),
                ],

                SizedBox(height: 110.h), // Bottom spacing for navigation bar
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorBanner() {
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
              _controller.homeError.value,
              style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () => _controller.loadSellerHome(),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w800, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerWidget.box(width: double.infinity, height: 150.h, borderRadius: 20.r),
        SizedBox(height: 20.h),
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
        SizedBox(height: 20.h),
        ShimmerWidget.box(width: double.infinity, height: 140.h, borderRadius: 18.r),
        SizedBox(height: 20.h),
        ShimmerWidget.box(width: double.infinity, height: 130.h, borderRadius: 18.r),
      ],
    );
  }

  // Top Header Widget
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.home_work_rounded, color: AppColors.primary, size: 28.sp),
            SizedBox(width: 8.w),
            Text(
              'DigiNiwas',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textSecondary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Obx(() {
              final name = _controller.sellerProfile.value?.name ?? '';
              return Container(
                width: 36.w,
                height: 36.h,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initialsOf(name),
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  // Welcome Banner Card
  Widget _buildWelcomeCard() {
    final profile = _controller.sellerProfile.value;
    final name = (profile?.name.isNotEmpty ?? false) ? profile!.name : 'there';
    final isVerified = profile?.isVerified ?? false;
    final updatesCount = _controller.recentUpdates.length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F1), // Soft mint green background
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $name',
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                  color: AppColors.primary,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  isVerified ? 'Verified Owner' : 'Verification Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            updatesCount > 0
                ? 'Your DigiNiwas Partner has $updatesCount update${updatesCount == 1 ? '' : 's'} for you.'
                : "You're all caught up — no new updates right now.",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 4 Stats Grids Cards
  Widget _buildStatGrids() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.65,
      children: [
        _buildStatCard(
          title: 'My Listings',
          count: '${_controller.myListingsCount.value}',
          icon: Icons.description_outlined,
          onTap: () => setState(() => _currentIndex = 1),
        ),
        _buildStatCard(
          title: 'Partner Review',
          count: '${_controller.partnerReviewCount.value}',
          icon: Icons.star_border_rounded,
          onTap: () => setState(() => _currentIndex = 1),
        ),
        _buildStatCard(
          title: 'Buyer Interest',
          count: '${_controller.buyerInterestCount.value}',
          icon: Icons.people_outline_rounded,
        ),
        _buildStatCard(
          title: 'Offers to Review',
          count: '${_controller.offersToReviewCount.value}',
          icon: Icons.local_offer_outlined,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
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
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5F1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Partner Section
  Widget _buildPartnerSection() {
    final property = _controller.progressProperty.value;
    final hasPartner = property?.partnerId != null && property!.partnerId!.isNotEmpty;
    final partnerName = property?.partnerName ?? 'Not assigned yet';
    final partnerLocality = property?.partnerLocality;
    final isOnline = property?.partnerOnline == true;
    final isVerified = property?.partnerVerified ?? false;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your DigiNiwas Partner',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Stack(
                children: [
                  ImageCase(
                    url: property?.partnerAvatarUrl,
                    width: 50.w,
                    height: 50.h,
                    fallbackIcon: Icons.person,
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          'Online',
                          style: GoogleFonts.poppins(fontSize: 7.sp, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            partnerName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isVerified) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF5F1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Verified Partner',
                              style: GoogleFonts.poppins(fontSize: 8.sp, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      hasPartner
                          ? 'Local property expert${partnerLocality != null ? ' • $partnerLocality' : ''}'
                          : 'You will be matched with a partner once your property is submitted.',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasPartner ? () => _openWhatsApp(property?.partnerPhone) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 16.sp),
                  label: Text(
                    'Chat with Partner',
                    style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasPartner ? () => _callPartner(property?.partnerPhone) : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: hasPartner ? AppColors.primary : Colors.grey.shade300, width: 1.2),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: Icon(Icons.phone_outlined, color: hasPartner ? AppColors.primary : Colors.grey, size: 16.sp),
                  label: Text(
                    'Call Partner',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: hasPartner ? AppColors.primary : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _callPartner(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      AppToast.error(context, "Partner's phone number isn't available yet.");
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      AppToast.error(context, 'Could not open the dialer.');
    }
  }

  Future<void> _openWhatsApp(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      AppToast.error(context, "Partner's contact isn't available yet.");
      return;
    }
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      AppToast.error(context, 'Could not open WhatsApp.');
    }
  }

  // Empty state when the seller hasn't added any property yet.
  Widget _buildNoPropertiesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.apartment_rounded, size: 32.sp, color: AppColors.primary),
          SizedBox(height: 10.h),
          Text(
            'No properties yet',
            style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            'Add your first property to get matched with a DigiNiwas Partner.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: () => setState(() => _currentIndex = 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text(
              'Add Property',
              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Property Progress Card Tracker
  Widget _buildPropertyProgressCard(SellerPropertyBrief property) {
    final stage = property.stage;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageCase(
            url: property.imageUrl,
            width: 75.w,
            height: 75.h,
            fallbackIcon: Icons.apartment,
            borderRadius: BorderRadius.circular(12.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildStepIndicator('Submitted', true, stage.index > 0),
                    _buildStepLine(stage.index >= 1),
                    _buildStepIndicator('Partner Review', stage.index > 1, stage.index > 1,
                        isCurrent: stage == SellerPropertyStage.partnerReview),
                    _buildStepLine(stage.index >= 2),
                    _buildStepIndicator('Verified', stage.index > 2, stage.index > 2,
                        isCurrent: stage == SellerPropertyStage.verified),
                    _buildStepLine(stage.index >= 3),
                    _buildStepIndicator('Live', stage == SellerPropertyStage.live, false,
                        isCurrent: stage == SellerPropertyStage.live),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  property.statusNote,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View Progress',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
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

  Widget _buildStepIndicator(String label, bool isCompleted, bool isPassed, {bool isCurrent = false}) {
    return Column(
      children: [
        Container(
          width: 14.w,
          height: 14.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppColors.primary : Colors.white,
            border: Border.all(
              color: isCompleted || isCurrent ? AppColors.primary : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: isCompleted
              ? Icon(Icons.check, size: 8.sp, color: Colors.white)
              : null,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 7.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2.h,
        color: isActive ? AppColors.primary : Colors.grey.shade300,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
      ),
    );
  }

  // Niwas AI Suggestion Box
  Widget _buildAiSuggestionCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF0C233B), // Dark Navy Blue Theme
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Niwas AI Suggestion',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _controller.aiSuggestionBody.value,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    height: 1.3,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: () => setState(() => _currentIndex = 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text(
              'Complete Task',
              style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Recent Partner Updates Section
  Widget _buildRecentUpdatesSection() {
    final updates = _controller.recentUpdates;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Partner Updates',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (updates.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _currentIndex = 3),
                child: Text(
                  'View All →',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: updates.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'No updates yet. Your Partner will keep you posted here.',
                    style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < updates.length; i++)
                      _buildUpdateItem(
                        icon: _iconForUpdateKind(updates[i].kind),
                        title: updates[i].title,
                        time: timeAgoLabel(updates[i].timestamp),
                        showDivider: i != updates.length - 1,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  IconData _iconForUpdateKind(SellerUpdateKind kind) {
    switch (kind) {
      case SellerUpdateKind.visit:
        return Icons.calendar_today_outlined;
      case SellerUpdateKind.lead:
        return Icons.people_outline_rounded;
      case SellerUpdateKind.offer:
        return Icons.local_offer_outlined;
      case SellerUpdateKind.property:
        return Icons.description_outlined;
      case SellerUpdateKind.generic:
        return Icons.notifications_none_rounded;
    }
  }

  Widget _buildUpdateItem({required IconData icon, required String title, required String time, required bool showDivider}) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5F1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
        ],
      ],
    );
  }

  // Floating Action Button for Adding Property
  Widget _buildAddPropertyFab() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          setState(() => _currentIndex = 1);
        },
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        label: Text(
          'Add Property',
          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Standard Bottom Navigation Bar (Chatbot floating button removed)
  Widget _buildBottomNavigationBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
      height: 64.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
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
          _navItem(icon: Icons.home_rounded, label: 'Home', index: 0),
          _navItem(icon: Icons.apartment_rounded, label: 'Properties', index: 1),
          _navItem(icon: Icons.person_outline_rounded, label: 'My Partner', index: 2),
          _navItem(icon: Icons.chat_bubble_outline_rounded, label: 'Updates', index: 3),
          _navItem(icon: Icons.person_outline_rounded, label: 'Profile', index: 4),
        ],
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    const activeColor = Color(0xFF007A5E);
    const inactiveColor = Color(0xFF7D8C99);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? activeColor : inactiveColor, size: 20.sp),
            SizedBox(height: 3.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 9.5.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple Placeholder Screen for other tabs until you create their actual screens
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
