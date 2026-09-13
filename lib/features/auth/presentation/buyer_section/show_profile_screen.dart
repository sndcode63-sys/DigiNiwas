// =====================================================================
// USER PROFILE SCREEN (MATCHING SCREENSHOT UI) — now wired to live data:
//   - Name / phone / email / role  -> cached session (SecureStorageService)
//     + refreshed from GET /api/v1/user/dashboard-header (name + avatar)
//   - Saved Properties (count+cards) -> GET /api/saved-properties/buyer/:id
//     via the same BuyerHomeController used on Buyer Home / Saved tab.
//   - Recently Viewed / Scheduled Visits -> local counters that the app
//     already tracks in StorageService (no "list all" endpoint exists on
//     the backend yet for these two, so counts are a device-local tally
//     of what this buyer actually did in-app).
//   - My Enquiries -> same local-tally idea (see StorageService.addEnquiryPropertyId);
//     will read 0 until that call is wired into the lead-creation flow.
// =====================================================================
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/controller/buyer_home_controller.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../application/auth_controller.dart';
import '../../data/auth_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;
  bool _isLoadingProfile = true;

  late final BuyerHomeController _controller;

  String _name = 'Guest';
  String _phone = '';
  String? _email;
  String _role = 'Buyer';
  String? _avatarUrl;
  String? _localAvatarPath;
  String? _buyerId;

  int _recentlyViewedCount = 0;
  int _scheduledVisitsCount = 0;
  int _enquiriesCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<BuyerHomeController>()
        ? Get.find<BuyerHomeController>()
        : Get.put(BuyerHomeController());
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // 1) Fastest source: whatever the app already has in memory from the
    //    last login (AuthController) — falls back to the persisted
    //    session (survives app restart) and finally the raw secure-storage
    //    blob, in case only that got written.
    Map<String, dynamic>? userData = Get.find<AuthController>().state.value.userData;
    userData ??= await Get.find<AuthRepository>().getStoredSession();
    userData ??= await _readSecureUser();

    if (userData != null) {
      final name = (userData['name'] as String?)?.trim();
      if (name != null && name.isNotEmpty) _name = name;
      final phone = (userData['phone'] as String?)?.trim();
      if (phone != null && phone.isNotEmpty) _phone = phone;
      final email = (userData['email'] as String?)?.trim();
      if (email != null && email.isNotEmpty) _email = email;
      final role = (userData['role'] as String?)?.trim();
      if (role != null && role.isNotEmpty) _role = role;
      final avatar = (userData['avatar'] as String?)?.trim();
      if (avatar != null && avatar.isNotEmpty) _avatarUrl = avatar;
      _buyerId = userData['id']?.toString() ??
          userData['_id']?.toString() ??
          userData['buyerId']?.toString();
    }

    // Cached user blob sometimes lacks the id (older sessions) — fall back
    // to the shared-prefs copy StorageService keeps.
    if (_buyerId == null || _buyerId!.isEmpty) {
      _buyerId = await StorageService.instance.buyerId;
    }
    if (_buyerId == null || _buyerId!.isEmpty) {
      _buyerId = await StorageService.instance.userId;
    }

    _localAvatarPath = await StorageService.instance.localAvatarPath;

    final recentlyViewed = await StorageService.instance.getRecentlyViewedIds();
    final visits = await StorageService.instance.getVisitIds();
    final enquiries = await StorageService.instance.getEnquiryIds();

    if (!mounted) return;
    setState(() {
      _recentlyViewedCount = recentlyViewed.length;
      _scheduledVisitsCount = visits.length;
      _enquiriesCount = enquiries.length;
      _isLoadingProfile = false;
    });

    // 2) Real network refresh — same dashboard-header API the Buyer Home
    //    screen uses, so name/avatar reflect the backend, not just cache.
    if (_controller.dashboardHeader.value == null) {
      unawaited(_controller.loadDashboardHeader());
    }

    // 3) Saved properties — real API call, same controller/list the
    //    Saved Properties tab renders from.
    if (_buyerId != null && _buyerId!.isNotEmpty) {
      unawaited(_controller.fetchSavedProperties(_buyerId!));
    }
  }

  Future<Map<String, dynamic>?> _readSecureUser() async {
    final raw = await SecureStorageService.instance.getUserData();
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

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
    await StorageService.instance.clearSession();

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
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 120.h),
          child: _isLoadingProfile
              ? SizedBox(
            height: 420.h,
            child: const Center(child: CircularProgressIndicator()),
          )
              : Column(
            children: [
              _buildProfileHeader(),
              SizedBox(height: 20.h),
              _buildStatsGrid(),
              SizedBox(height: 24.h),
              _buildSavedSectionHeader(),
              SizedBox(height: 12.h),
              _buildSavedPropertiesSection(),
              SizedBox(height: 20.h),
              _buildQuickNavTile(
                icon: Icons.favorite_rounded,
                iconBgColor: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0284C7),
                title: 'Saved Properties',
                onTap: () => _controller.changeBottomNavIndex(3),
              ),
              SizedBox(height: 10.h),
              _buildQuickNavTile(
                icon: Icons.history_rounded,
                iconBgColor: const Color(0xFFEDE9FE),
                iconColor: const Color(0xFF7C3AED),
                title: 'Recently Viewed',
                onTap: () => AppToast.success(context, 'Recently viewed screen is coming soon'),
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
        Obx(() {
          final unread = _controller.dashboardHeader.value?.unreadNotificationsCount ?? 0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none_rounded, color: const Color(0xFF0F172A), size: 22.sp),
              if (unread > 0)
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
          );
        }),
        SizedBox(width: 12.w),
        _buildAppBarAvatar(),
        SizedBox(width: 14.w),
      ],
    );
  }

  Widget _buildAppBarAvatar() {
    return Obx(() {
      final networkAvatar = _controller.dashboardHeader.value?.user?.avatar ?? _avatarUrl;
      return CircleAvatar(
        radius: 14.r,
        backgroundColor: const Color(0xFFE2E8F0),
        backgroundImage: _avatarImageProvider(networkAvatar),
        child: _avatarImageProvider(networkAvatar) == null
            ? Icon(Icons.person_rounded, size: 16.sp, color: const Color(0xFF94A3B8))
            : null,
      );
    });
  }

  ImageProvider? _avatarImageProvider(String? networkAvatar) {
    if (_localAvatarPath != null && _localAvatarPath!.isNotEmpty) {
      return FileImage(File(_localAvatarPath!));
    }
    if (networkAvatar != null && networkAvatar.isNotEmpty) {
      return NetworkImage(networkAvatar);
    }
    return null;
  }

  Widget _buildProfileHeader() {
    return Obx(() {
      final headerUser = _controller.dashboardHeader.value?.user;
      final displayName = (headerUser?.name != null && headerUser!.name!.trim().isNotEmpty)
          ? headerUser.name!
          : _name;
      final avatar = headerUser?.avatar ?? _avatarUrl;

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
                  backgroundColor: const Color(0xFFE2E8F0),
                  backgroundImage: _avatarImageProvider(avatar),
                  child: _avatarImageProvider(avatar) == null
                      ? Icon(Icons.person_rounded, size: 36.sp, color: const Color(0xFF94A3B8))
                      : null,
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
            displayName,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 3.h),
          if (_phone.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_outlined, size: 12.sp, color: const Color(0xFF64748B)),
                SizedBox(width: 4.w),
                Text(
                  _phone,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          if (_email != null && _email!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline_rounded, size: 12.sp, color: const Color(0xFF64748B)),
                SizedBox(width: 4.w),
                Text(
                  _email!,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
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
                  '$_role Account',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF007A5E),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
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
                child: Obx(() => _buildStatItem(
                  'SAVED PROPERTIES',
                  '${_controller.savedPropertiesList.length}',
                  Icons.bookmark_border_rounded,
                )),
              ),
              Container(width: 1, height: 44.h, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _buildStatItem('RECENTLY VIEWED', '$_recentlyViewedCount', Icons.history_rounded),
              ),
            ],
          ),
          Divider(height: 20.h, thickness: 0.8, color: const Color(0xFFE2E8F0)),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('SCHEDULED VISITS', '$_scheduledVisitsCount', Icons.calendar_today_outlined),
              ),
              Container(width: 1, height: 44.h, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _buildStatItem('MY ENQUIRIES', '$_enquiriesCount', Icons.chat_bubble_outline_rounded),
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
          onTap: () => _controller.changeBottomNavIndex(3),
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

  Widget _buildSavedPropertiesSection() {
    return Obx(() {
      if (_controller.savedPropertiesLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final saved = _controller.savedPropertiesList;
      if (saved.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(Icons.favorite_border_rounded, size: 32.sp, color: const Color(0xFFCBD5E1)),
              SizedBox(height: 8.h),
              Text(
                'No saved properties yet',
                style: GoogleFonts.poppins(fontSize: 12.5.sp, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        );
      }

      // Show up to the 2 most recent saves here; the rest are one tap away
      // via "View All".
      final preview = saved.take(2).toList();
      return Column(
        children: [
          for (int i = 0; i < preview.length; i++) ...[
            _buildPropertyCardFromItem(preview[i]),
            if (i != preview.length - 1) SizedBox(height: 14.h),
          ],
        ],
      );
    });
  }

  Widget _buildPropertyCardFromItem(dynamic item) {
    final propertyData = (item is Map && item['propertySnapshot'] != null)
        ? item['propertySnapshot']
        : (item is Map && item['property'] != null ? item['property'] : item);

    final title = (propertyData is Map ? propertyData['title'] : null)?.toString() ?? 'Property';
    final locality = (propertyData is Map ? propertyData['locality'] : null)?.toString() ?? '';
    final city = (propertyData is Map ? propertyData['city'] : null)?.toString() ?? '';
    final location = [locality, city].where((s) => s.isNotEmpty).join(', ');
    final rawPrice = propertyData is Map ? propertyData['price'] : null;
    final price = rawPrice == null ? '—' : formatPrice(rawPrice);
    final bhk = (propertyData is Map ? (propertyData['bedrooms'] ?? propertyData['bhk']) : null)?.toString();
    final sqft = (propertyData is Map ? (propertyData['area'] ?? propertyData['sqft']) : null)?.toString();
    final isVerified = propertyData is Map &&
        (propertyData['propertyVerificationStatus'] == 'verified' || propertyData['isVerified'] == true);

    String? imageUrl;
    if (propertyData is Map) {
      imageUrl = propertyData['image']?.toString();
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
    }

    return _buildPropertyCard(
      title: title,
      location: location.isNotEmpty ? location : '—',
      price: price,
      bhk: bhk != null ? '$bhk BHK' : '—',
      sqft: sqft != null ? '$sqft Sq Ft' : '—',
      tag: isVerified ? 'Verified' : 'Saved',
      isVerified: isVerified,
      tagColor: isVerified ? const Color(0xFF007A5E) : const Color(0xFF0F172A),
      image: imageUrl,
    );
  }

  Widget _buildPropertyCard({
    required String title,
    required String location,
    required String price,
    required String bhk,
    required String sqft,
    required String tag,
    required Color tagColor,
    String? image,
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
                child: (image != null && image.isNotEmpty)
                    ? Image.network(
                  image,
                  height: 155.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _propertyImagePlaceholder(),
                )
                    : _propertyImagePlaceholder(),
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
                    Expanded(
                      child: Text(
                        location,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5.sp,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
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

  Widget _propertyImagePlaceholder() {
    return Container(
      height: 155.h,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.home_work_rounded, color: Color(0xFF007A5E)),
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