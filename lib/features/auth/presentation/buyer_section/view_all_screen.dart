import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/controller/buyer_home_controller.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../data/view_all_repository.dart';

enum ViewAllType { property, popularArea, agent }

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({
    super.key,
    required this.title,
    required this.type,
    this.propertyItems = const [],
    this.areaItems = const [],
    this.agentItems = const [],
    this.section,
    this.badgeLabel,
    this.badgeColor,
    this.onAgentTap,
    this.controller,
  });

  final String title;
  final ViewAllType type;
  final List<Map<String, dynamic>> propertyItems;
  final List<Map<String, dynamic>> areaItems;
  final List<dynamic> agentItems;
  final ViewAllSection? section;
  final String? badgeLabel;
  final Color? badgeColor;
  final void Function(BuildContext context, dynamic agent)? onAgentTap;
  final BuyerHomeController? controller;

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  final ViewAllRepository _repository = ViewAllRepository();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _fetchedItems = [];

  bool get _usesSection => widget.section != null;

  @override
  void initState() {
    super.initState();
    if (_usesSection) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _repository.fetchProperties(widget.section!);
      if (!mounted) return;
      setState(() {
        _fetchedItems = result;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load this list. Please try again.';
        _isLoading = false;
      });
    }
  }

  int get _count {
    if (_usesSection) return _fetchedItems.length;
    switch (widget.type) {
      case ViewAllType.property:
        return widget.propertyItems.length;
      case ViewAllType.popularArea:
        return widget.areaItems.length;
      case ViewAllType.agent:
        return widget.agentItems.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF007A5E)),
      );
    }
    if (_error != null) {
      return _buildErrorState();
    }
    if (_count == 0) {
      return _buildEmpty();
    }
    if (_usesSection) {
      return RefreshIndicator(
        color: const Color(0xFF007A5E),
        onRefresh: _load,
        child: _buildVerticalList(context),
      );
    }
    return _buildVerticalList(context);
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: const Color(0xFFC62828), size: 32.sp),
            SizedBox(height: 10.h),
            Text(
              _error ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(height: 14.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007A5E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: _load,
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Text(
          'Nothing to show here yet.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: const Color(0xFF64748B)),
        ),
      ),
    );
  }

  /// Renders all card types in a uniform vertical list with perfect padding & spacing.
  Widget _buildVerticalList(BuildContext context) {
    final propertyList = _usesSection ? _fetchedItems : widget.propertyItems;
    final areaList = _usesSection ? _fetchedItems : widget.areaItems;

    return ListView.separated(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: _count,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        switch (widget.type) {
          case ViewAllType.agent:
            return _AgentRow(
              agent: widget.agentItems[index],
              onTap: widget.onAgentTap,
            );
          case ViewAllType.popularArea:
            return _AreaCard(area: areaList[index]);
          case ViewAllType.property:
            return _PropertyCard(
              data: propertyList[index],
              controller: widget.controller,
              badgeLabel: widget.badgeLabel,
              badgeColor: widget.badgeColor,
            );
        }
      },
    );
  }
}

/// Stunning Full-Width Vertical Property Card with Auto-Sliding Images & No Indicators
class _PropertyCard extends StatefulWidget {
  const _PropertyCard({required this.data, this.controller, this.badgeLabel, this.badgeColor});

  final Map<String, dynamic> data;
  final BuyerHomeController? controller;
  final String? badgeLabel;
  final Color? badgeColor;

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Setup auto-slide timer if there are multiple images
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final images = (widget.data['images'] as List?)?.cast<String>() ?? const <String>[];
      if (images.length > 1) {
        _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
          if (!mounted) return;
          if (_pageController.hasClients) {
            _currentPage = (_currentPage + 1) % images.length;
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = (widget.data['images'] as List?)?.cast<String>() ?? const <String>[];
    final propertyId = (widget.data['json'] as Map?)?['_id']?.toString() ?? (widget.data['json'] as Map?)?['propertyId']?.toString();

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () => Get.toNamed(AppRoutes.propertyDetails, arguments: {'property': widget.data['json'] ?? {}}),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Auto-Slider Container (No indicators shown)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: SizedBox(
                    height: 180.h,
                    width: double.infinity,
                    child: images.isNotEmpty
                        ? PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return ImageCase(
                          url: images[index],
                          width: double.infinity,
                          height: 180.h,
                          fallbackIcon: Icons.home_work_rounded,
                        );
                      },
                    )
                        : const ImageCase(
                      url: null,
                      width: double.infinity,
                      height: 180,
                      fallbackIcon: Icons.home_work_rounded,
                    ),
                  ),
                ),
                if (widget.badgeLabel != null)
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: widget.badgeColor ?? const Color(0xFFE5A000),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        widget.badgeLabel!,
                        style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                if (widget.controller != null && propertyId != null)
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: Obx(() {
                      final isSaved = widget.controller!.savedPropertyIds.contains(propertyId);
                      return InkWell(
                        onTap: () async {
                          String? buyerId = await StorageService.instance.buyerId;
                          buyerId ??= await StorageService.instance.userId;
                          if (buyerId != null && buyerId.isNotEmpty) {
                            widget.controller!.toggleSaveProperty(buyerId, propertyId);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(7.w),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 16.sp,
                            color: const Color(0xFFE53935),
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
            // Property Content Information
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (widget.data['title'] as String?) ?? 'Property',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 13.sp, color: const Color(0xFF64748B)),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '${widget.data['locality'] ?? ''}, ${widget.data['city'] ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '₹ ${widget.data['price'] ?? 0}',
                    style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF007A5E)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-Width Vertical Popular Area Card
class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.area});

  final Map<String, dynamic> area;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        final propertyData = {
          'title': '${area['locality'] ?? 'Popular'} Area Properties',
          'locality': area['locality'] ?? '',
          'city': area['city'] ?? '',
          'images': area['image'] != null ? [{'url': area['image']}] : [],
          'price': 'Explore Available',
          'description': 'Explore ${area['propertyCount'] ?? 0}+ verified properties available in ${area['locality'] ?? 'this area'}.',
          'category': 'Residential',
          'transactionType': 'Sale / Rent',
        };
        Get.toNamed(AppRoutes.propertyDetails, arguments: {'property': propertyData});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: ImageCase(
                url: area['image'] as String?,
                width: double.infinity,
                height: 150.h,
                fallbackIcon: Icons.location_city_rounded,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (area['locality'] as String?) ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14.sp, color: const Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${area['propertyCount'] ?? 0} Properties Available',
                    style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 11.5.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentRow extends StatelessWidget {
  const _AgentRow({required this.agent, this.onTap});

  final dynamic agent;
  final void Function(BuildContext context, dynamic agent)? onTap;

  @override
  Widget build(BuildContext context) {
    final name = (agent.name as String?) ?? 'Agent';
    final initial = name.trim().isNotEmpty ? name.trim().substring(0, 1).toUpperCase() : 'A';
    final avatar = agent.avatar as String?;
    final businessName = agent.business?.businessName as String?;
    final isVerified = agent.isVerified == true;
    final distance = agent.distanceKm;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () => onTap?.call(context, agent),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: (avatar?.isNotEmpty == true)
                  ? ImageCase(url: avatar, width: 52.w, height: 52.w, fallbackIcon: Icons.person)
                  : CircleAvatar(
                radius: 26.r,
                backgroundColor: const Color(0xFFA8E6CF),
                child: Text(initial, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF0F2544), fontSize: 16.sp)),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14.sp, color: const Color(0xFF0F172A))),
                  SizedBox(height: 3.h),
                  Text(
                    businessName?.isNotEmpty == true ? businessName! : (distance != null ? '${distance is double ? distance.toStringAsFixed(1) : distance} km away' : 'Real Estate Agent'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
                  ),
                  if (isVerified) ...[
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 13.sp, color: const Color(0xFF007A5E)),
                        SizedBox(width: 4.w),
                        Text('Verified Partner', style: GoogleFonts.poppins(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF007A5E))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}