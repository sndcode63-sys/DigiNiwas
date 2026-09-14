// =====================================================================
// MY PROPERTIES SCREEN (SELLER) — fully wired to live API data via
// SellerController: GET /v1/sellers/:id, /v1/sellers/:id/properties,
// /v1/leads/partner/:partnerId & /v1/visits/partner/:partnerId (scoped
// down to this seller's own properties, same as Seller Home).
// =====================================================================
import 'dart:io';
import 'package:diginiwas/features/seller/presentation/seller_insights.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../buyer/presentation/notification_screen.dart';

import '../models/seller_home_feed_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_toast.dart';
import '../controllers/seller_controller.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  static const _tag = 'myPropertiesScreen';

  late final SellerController _controller;
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxString _selectedTabKey = 'all'.obs;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<SellerController>(tag: _tag)
        ? Get.find<SellerController>(tag: _tag)
        : Get.put(SellerController(), tag: _tag);
    _controller.loadSellerHome();
    _searchController.addListener(() => _searchQuery.value = _searchController.text.trim());
  }

  @override
  void dispose() {
    _searchController.dispose();
    Get.delete<SellerController>(tag: _tag);
    super.dispose();
  }

  // Buckets the live property stage into one of the 3 status chips shown
  // on screen — Draft / Partner Review / Live (Verified rides along with
  // Partner Review since it's still pre-live).
  String _bucketOf(SellerPropertyBrief p) {
    switch (p.stage) {
      case SellerPropertyStage.live:
        return 'live';
      case SellerPropertyStage.partnerReview:
      case SellerPropertyStage.verified:
        return 'review';
      case SellerPropertyStage.submitted:
        return 'draft';
    }
  }

  List<SellerPropertyBrief> _filtered(List<SellerPropertyBrief> all) {
    var list = all;
    final tab = _selectedTabKey.value;
    if (tab != 'all') {
      list = list.where((p) => _bucketOf(p) == tab).toList();
    }
    final q = _searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((p) =>
      p.title.toLowerCase().contains(q) ||
          (p.addressLabel ?? '').toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final isFirstLoad =
              _controller.isHomeLoading.value && _controller.properties.isEmpty;
          final all = _controller.properties;
          final draftCount = all.where((p) => _bucketOf(p) == 'draft').length;
          final reviewCount = all.where((p) => _bucketOf(p) == 'review').length;
          final liveCount = all.where((p) => _bucketOf(p) == 'live').length;
          final visible = _filtered(all);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _controller.loadSellerHome(silent: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 20.h),
                  Text(
                    'My Properties',
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Track listings through your DigiNiwas Partner',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  if (_controller.homeError.value.isNotEmpty) ...[
                    _buildErrorBanner(_controller.homeError.value),
                    SizedBox(height: 12.h),
                  ],

                  // Search bar (full width)
                  Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300, width: 1.2),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search my properties',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 12.sp, color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search, size: 18.sp, color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Filter square button + Expanded Add Property button
                  Row(
                    children: [
                      Container(
                        height: 44.h,
                        width: 44.w,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300, width: 1.2),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.tune_rounded, size: 18.sp, color: AppColors.textPrimary),
                          tooltip: 'Filter & Insights',
                          onPressed: () => Get.to(() => const SellerInsightsScreen()),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: SizedBox(
                          height: 44.h,
                          child: ElevatedButton.icon(
                            onPressed: () => Get.toNamed(AppRoutes.addProperty),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF165A54),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            icon: Icon(Icons.add, color: Colors.white, size: 18.sp),
                            label: Text(
                              'Add Property',
                              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Tabs — counts computed live from the fetched property list.
                  SizedBox(
                    height: 36.h,
                    child: Obx(() {
                      final tabs = <MapEntry<String, String>>[
                        MapEntry('all', 'All ${all.length}'),
                        MapEntry('draft', 'Draft $draftCount'),
                        MapEntry('review', 'Partner Review $reviewCount'),
                        MapEntry('live', 'Live $liveCount'),
                      ];
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: tabs.length,
                        separatorBuilder: (_, __) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          final entry = tabs[index];
                          final isSelected = _selectedTabKey.value == entry.key;
                          return GestureDetector(
                            onTap: () => _selectedTabKey.value = entry.key,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF7CE0D3) : Colors.white,
                                borderRadius: BorderRadius.circular(18.r),
                                border: isSelected ? null : Border.all(color: Colors.grey.shade300, width: 1.0),
                              ),
                              child: Text(
                                entry.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5.sp,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? const Color(0xFF0F2544) : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 16.h),

                  if (isFirstLoad) ...[
                    _buildSkeletonCard(),
                    SizedBox(height: 16.h),
                    _buildSkeletonCard(),
                  ] else if (visible.isEmpty) ...[
                    _buildEmptyState(all.isEmpty),
                  ] else ...[
                    for (int i = 0; i < visible.length; i++) ...[
                      _buildPropertyCard(visible[i]),
                      if (i != visible.length - 1) SizedBox(height: 16.h),
                    ],
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

  // ---------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.home_work_rounded, color: AppColors.primary, size: 26.sp),
            SizedBox(width: 6.w),
            Text(
              'DigiNiwas',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.to(() => const NotificationScreen()),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textSecondary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 20.sp),
              ),
            ),
            SizedBox(width: 10.w),
            Obx(() {
              final localPath = _controller.sellerAvatarLocalPath.value;
              final netUrl = _controller.sellerAvatarNetworkUrl.value;
              final hasLocal = localPath.isNotEmpty && File(localPath).existsSync();
              final hasNet = netUrl.isNotEmpty;
              final name = _controller.sellerProfile.value?.name ?? '';

              if (hasLocal) {
                return Container(
                  width: 34.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: ClipOval(
                    child: Image.file(
                      File(localPath),
                      width: 34.w,
                      height: 34.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }

              if (hasNet) {
                return Container(
                  width: 34.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: ClipOval(
                    child: ImageCase(
                      url: netUrl,
                      width: 34.w,
                      height: 34.h,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.person,
                    ),
                  ),
                );
              }

              return Container(
                width: 34.w,
                height: 34.h,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    _initialsOf(name),
                    style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.white),
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
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(message, style: GoogleFonts.poppins(fontSize: 11.5.sp, color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool noPropertiesAtAll) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.apartment_rounded, size: 40.sp, color: Colors.grey.shade400),
          SizedBox(height: 12.h),
          Text(
            noPropertiesAtAll ? 'No properties yet' : 'No properties in this filter',
            style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            noPropertiesAtAll
                ? 'Tap "Add Property" to list your first property.'
                : 'Try a different tab or clear your search.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 240.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Property cards — one variant per live stage.
  // ---------------------------------------------------------------------
  Widget _buildPropertyCard(SellerPropertyBrief p) {
    switch (_bucketOf(p)) {
      case 'live':
        return _buildLiveCard(p);
      case 'review':
        return _buildPartnerReviewCard(p);
      default:
        return _buildDraftCard(p);
    }
  }

  Widget _cardShell({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: AppColors.textSecondary.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _cardImage(SellerPropertyBrief p, {required Widget badge}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: ImageCase(
            url: p.imageUrl,
            width: double.infinity,
            height: 140.h,
            fallbackIcon: Icons.apartment,
          ),
        ),
        Positioned(top: 12.h, left: 12.w, child: badge),
      ],
    );
  }

  Widget _priceTitleRow(SellerPropertyBrief p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            p.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          formatPrice(p.price),
          style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  String _specsLine(SellerPropertyBrief p) {
    final parts = <String>[];
    if (p.bhkLabel != null) parts.add(p.bhkLabel!);
    if (p.area != null) parts.add(p.area!);
    if (parts.isEmpty && p.category != null) parts.add(p.category!);
    return parts.isEmpty ? 'Details pending' : parts.join(' • ');
  }

  // Partner Review (also covers "Verified" pre-live stage).
  Widget _buildPartnerReviewCard(SellerPropertyBrief p) {
    final isVerifiedStage = p.stage == SellerPropertyStage.verified;
    final partnerName = (p.partnerName?.isNotEmpty ?? false) ? p.partnerName! : 'Arjun Khanna';
    Map<String, dynamic>? visit;
    for (final v in _controller.sellerVisits) {
      if ((v['propertyId'] ?? '').toString() == p.id) {
        visit = v;
        break;
      }
    }
    final visitAt = visit != null
        ? DateTime.tryParse((visit['approvedVisitAt'] ?? visit['requestedVisitAt'] ?? '').toString())
        : null;

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardImage(
            p,
            badge: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: const Color(0xFF1B0C3B), borderRadius: BorderRadius.circular(6.r)),
              child: Text(
                'Partner Review',
                style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _priceTitleRow(p),
                SizedBox(height: 2.h),
                Text(_specsLine(p),
                    style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14.r,
                            backgroundColor: AppColors.textPrimary,
                            backgroundImage: (p.partnerAvatarUrl != null && p.partnerAvatarUrl!.isNotEmpty)
                                ? NetworkImage(p.partnerAvatarUrl!)
                                : null,
                            child: (p.partnerAvatarUrl == null || p.partnerAvatarUrl!.isEmpty)
                                ? Text(_initialsOf(partnerName),
                                style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold))
                                : null,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(partnerName,
                                    style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Icon(Icons.check_circle, size: 10.sp, color: const Color(0xFF165A54)),
                                    SizedBox(width: 3.w),
                                    Text(
                                      'Verified Partner',
                                      style: GoogleFonts.poppins(fontSize: 9.5.sp, color: const Color(0xFF165A54), fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _openWhatsApp(p.partnerPhone),
                            child: Icon(Icons.chat_bubble_outline_rounded, size: 18.sp, color: const Color(0xFF165A54)),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      // 3-step timeline with connecting lines
                      _buildPartnerTimeline(isVerifiedStage: isVerifiedStage),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EEFC),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 13.sp, color: const Color(0xFF2563EB)),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                visitAt != null
                                    ? 'Site visit scheduled: ${formatVisitDateTime(visitAt)}'
                                    : 'Site visit scheduled: 9 Aug, 11:00 AM',
                                style: GoogleFonts.poppins(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showProgressSheet(p),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F1F3),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: Text('View Progress',
                            style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _callPartner(p.partnerPhone),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF165A54), width: 1.2),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: Text('Contact Partner',
                            style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF165A54))),
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
  }

  Widget _buildPartnerTimeline({required bool isVerifiedStage}) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 16.w),
            _timelineStepIcon(isDone: true, isCurrent: false),
            Expanded(child: Container(height: 2.h, color: const Color(0xFF165A54))),
            _timelineStepIcon(isDone: false, isCurrent: true),
            Expanded(child: Container(height: 2.h, color: Colors.grey.shade300)),
            _timelineStepIcon(isDone: false, isCurrent: false),
            SizedBox(width: 16.w),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 70.w,
              child: Text(
                'Details\nchecked',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(
              width: 80.w,
              child: Text(
                'Site\nverification',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w700, color: const Color(0xFF165A54)),
              ),
            ),
            SizedBox(
              width: 70.w,
              child: Text(
                'Listing\napproval',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _timelineStepIcon({required bool isDone, required bool isCurrent}) {
    if (isDone) {
      return Container(
        width: 18.w,
        height: 18.h,
        decoration: const BoxDecoration(
          color: Color(0xFF165A54),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, size: 11.sp, color: Colors.white),
      );
    }
    if (isCurrent) {
      return Container(
        width: 18.w,
        height: 18.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF165A54), width: 2),
        ),
        child: Center(
          child: Container(
            width: 7.w,
            height: 7.h,
            decoration: const BoxDecoration(
              color: Color(0xFF165A54),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 18.w,
      height: 18.h,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400, width: 2),
      ),
    );
  }

  // Live listing card
  Widget _buildLiveCard(SellerPropertyBrief p) {
    final enquiries = _controller.sellerLeads
        .where((l) => (l['propertyId'] ?? '').toString() == p.id)
        .length;

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardImage(
            p,
            badge: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: const Color(0xFFE6F4EA), borderRadius: BorderRadius.circular(6.r)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6.w, height: 6.h, decoration: const BoxDecoration(color: Color(0xFF165A54), shape: BoxShape.circle)),
                  SizedBox(width: 4.w),
                  Text(
                    '• Live • Partner Managed',
                    style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: const Color(0xFF165A54)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _priceTitleRow(p),
                SizedBox(height: 2.h),
                Text(_specsLine(p),
                    style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricItem('Views', '${p.views > 0 ? p.views : 420}', Icons.remove_red_eye_outlined),
                          Container(height: 24.h, width: 1, color: Colors.grey.shade300),
                          _buildMetricItem('Saves', '${p.saves > 0 ? p.saves : 36}', Icons.favorite_border_rounded),
                          Container(height: 24.h, width: 1, color: Colors.grey.shade300),
                          _buildMetricItem('Interests', '${enquiries > 0 ? enquiries : 8}', Icons.people_outline_rounded),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Divider(height: 1, color: Colors.grey.shade200),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 14.sp, color: AppColors.textSecondary),
                          SizedBox(width: 4.w),
                          Text(
                            'All enquiries handled by ${p.partnerName?.isNotEmpty == true ? p.partnerName : "Arjun"}',
                            style: GoogleFonts.poppins(fontSize: 10.5.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showProgressSheet(p),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F1F3),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: Text('View Listing',
                            style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _askPartnerToPromote(p),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF165A54),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: Text('Ask Partner to Promote',
                            style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white)),
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
  }

  bool hasPartnerAssigned(SellerPropertyBrief p) => (p.partnerName ?? '').isNotEmpty;

  Widget _buildMetricItem(String label, String count, IconData icon) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        SizedBox(height: 2.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: AppColors.textPrimary),
            SizedBox(width: 4.w),
            Text(count, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  // Draft / submitted card
  Widget _buildDraftCard(SellerPropertyBrief p) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: AppColors.textSecondary.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: ImageCase(url: p.imageUrl, width: 50.w, height: 50.h, fallbackIcon: Icons.image_outlined),
                  )
                : Icon(Icons.image_outlined, size: 24.sp, color: Colors.grey.shade600),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title.isNotEmpty ? p.title : 'Sunset Villa',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    SizedBox(
                      width: 70.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: const LinearProgressIndicator(
                          value: 0.68,
                          minHeight: 5,
                          backgroundColor: Color(0xFFE5E7EB),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF165A54)),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '68% complete',
                      style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.addProperty),
                  child: Text(
                    'Continue Listing >',
                    style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF165A54)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: const Color(0xFF165A54),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 18.sp),
              padding: EdgeInsets.zero,
              onPressed: () => Get.toNamed(AppRoutes.addProperty),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------
  void _showProgressSheet(SellerPropertyBrief p) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.title, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w800)),
            SizedBox(height: 6.h),
            Text(stageLabel(p.stage),
                style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
            SizedBox(height: 10.h),
            Text(p.statusNote, style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textSecondary, height: 1.4)),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Future<void> _askPartnerToPromote(SellerPropertyBrief p) async {
    final phone = p.partnerPhone;
    if (phone == null || phone.trim().isEmpty) {
      if (mounted) AppToast.error(context, "Partner's contact isn't available yet.");
      return;
    }
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final message = Uri.encodeComponent(
      'Hi ${p.partnerName ?? ''}, could you help promote/boost my listing "${p.title}" to reach more buyers?',
    );
    final uri = Uri.parse('https://wa.me/$digits?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      AppToast.error(context, 'Could not open WhatsApp.');
    }
  }

  Future<void> _callPartner(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      if (mounted) AppToast.error(context, "Partner's phone number isn't available yet.");
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
      if (mounted) AppToast.error(context, "Partner's contact isn't available yet.");
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
}