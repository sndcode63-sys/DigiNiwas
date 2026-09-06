import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/controller/buyer_home_controller.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_image.dart';

class ExproleName extends StatefulWidget {
  ExproleName({super.key});

  @override
  State<ExproleName> createState() => _ExproleNameState();
}

class _ExproleNameState extends State<ExproleName> {
  final BuyerHomeController controller = Get.find<BuyerHomeController>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.searchResultsList.clear();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                if (searchController.text.trim().isNotEmpty) {
                  await controller.searchProperties(searchController.text);
                }
              },
              color: const Color(0xFF00C896),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: Obx(() {
                      final count = controller.searchResultsList.length;
                      return _HeaderSection(
                        searchController: searchController,
                        propertyCount: count,
                        onChanged: (keyword) {
                          setState(() {});
                          controller.searchProperties(keyword);
                        },
                        onClear: () {
                          searchController.clear();
                          controller.searchProperties('');
                          setState(() {});
                        },
                      );
                    }),
                  ),
                  const SliverToBoxAdapter(child: _AiSummaryCard()),

                  // Dynamic Search Results Handler
                  Obx(() {
                    if (controller.searchLoading.value) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF00C896)),
                        ),
                      );
                    }

                    final results = controller.searchResultsList;

                    if (searchController.text.trim().isEmpty || results.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_rounded, size: 48.sp, color: const Color(0xFF94A3B8)),
                              SizedBox(height: 10.h),
                              Text(
                                searchController.text.trim().isEmpty
                                    ? 'Type something to search properties'
                                    : 'No properties found',
                                style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 13.sp, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final property = results[index];
                          return _PropertyCard(
                            property: property,
                            onCompareChanged: (val) {
                              setState(() {
                                property['isCompared'] = val ?? false;
                              });
                            },
                          );
                        },
                        childCount: results.length,
                      ),
                    );
                  }),

                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
            ),

            // Floating Compare Bar based on active selections
            Obx(() {
              final results = controller.searchResultsList;
              final comparedCount = results.where((p) => p['isCompared'] == true).length;

              return Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
                child: _CompareFloatingBar(count: comparedCount),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// --- Header Component ---
class _HeaderSection extends StatelessWidget {
  final TextEditingController searchController;
  final int propertyCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _HeaderSection({
    required this.searchController,
    required this.propertyCount,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.home_outlined, color: const Color(0xFF00C896), size: 22.sp),
                  SizedBox(width: 4.w),
                  Text('DIGINIWAS', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16.sp, color: const Color(0xFF00C896), letterSpacing: 1.1)),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: searchController,
              autofocus: false,
              onChanged: onChanged,
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
                hintText: 'Search locality, property or budget',
                hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14.sp),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey, size: 18.sp),
                  onPressed: onClear,
                )
                    : Icon(Icons.mic_none, color: const Color(0xFF00C896), size: 20.sp),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Dynamic Property Count Displayed Here
          Text(
            searchController.text.isEmpty ? 'Explore Properties' : '$propertyCount Properties Found',
            style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A2129)),
          ),
          Text(
            searchController.text.isEmpty ? 'Live results based on your search' : 'Live search results matching your query',
            style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton(Icons.sort, 'Sort', () {}),
                SizedBox(width: 8.w),
                _buildFilterButton(Icons.tune, 'Filters', () {}),
                SizedBox(width: 8.w),
                _buildFilterButton(Icons.map_outlined, 'Map View', () {
                  Get.toNamed(AppRoutes.exploreMap);
                }, isPrimary: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(IconData icon, String label, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF173554) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isPrimary ? Colors.transparent : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: isPrimary ? Colors.white : Colors.black87),
            SizedBox(width: 6.w),
            Text(label, style: GoogleFonts.poppins(fontSize: 12.sp, color: isPrimary ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// --- AI Summary Card ---
class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFB5E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16.sp, color: const Color(0xFF009688)),
              SizedBox(width: 6.w),
              Text('Niwas AI Smart Summary', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13.sp, color: const Color(0xFF00796B))),
            ],
          ),
          SizedBox(height: 6.h),
          Text('Found verified properties matching your preferences. Explore features, pricing, and exact locations below.', style: GoogleFonts.poppins(fontSize: 11.5.sp, color: Colors.black87, height: 1.3)),
        ],
      ),
    );
  }
}

// --- Property Card Component ---
class _PropertyCard extends StatelessWidget {
  final dynamic property;
  final ValueChanged<bool?> onCompareChanged;

  const _PropertyCard({required this.property, required this.onCompareChanged});

  @override
  Widget build(BuildContext context) {
    final title = property['title'] ?? property['name'] ?? 'Property';
    final locality = property['locality'] ?? '';
    final city = property['city'] ?? '';
    final price = property['price']?.toString() ?? '0';
    final bedrooms = property['bedrooms']?.toString() ?? '3';
    final furnishing = property['furnishing'] ?? 'Ready';
    final area = property['area']?.toString() ?? '1,150 sqft';
    final bool isCompared = property['isCompared'] ?? false;

    String? imageUrl;
    final images = property['images'];
    if (images is List && images.isNotEmpty) {
      imageUrl = images.first is Map ? images.first['url'] : images.first?.toString();
    } else if (property['image'] is String) {
      imageUrl = property['image'];
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: ImageCase(
                  url: imageUrl,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.home_work_rounded,
                ),
              ),
              Positioned(
                top: 12.h,
                left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(6.r)),
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 12.sp, color: const Color(0xFF00C896)),
                      SizedBox(width: 4.w),
                      Text('Verified', style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                    ),
                    Text('₹ $price', style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1A2129))),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text('$locality, $city', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(color: const Color(0xFFE2F8F5), borderRadius: BorderRadius.circular(4.r)),
                  child: Text('MATCHES YOUR BUDGET', style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00A87A))),
                ),
                SizedBox(height: 10.h),
                const Divider(height: 1, color: Colors.black12),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSpecItem('BHK', '$bedrooms BHK'),
                    _buildSpecItem('Area', area),
                    _buildSpecItem('Possession', furnishing),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onCompareChanged(!isCompared),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isCompared ? const Color(0xFF00C896) : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18.sp,
                              width: 18.sp,
                              child: Checkbox(
                                value: isCompared,
                                onChanged: onCompareChanged,
                                activeColor: const Color(0xFF00C896),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text('Compare', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(
                            AppRoutes.propertyDetails,
                            arguments: {'property': property},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF173554),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                        ),
                        child: Text('View Details', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w700)),
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

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey)),
        SizedBox(height: 2.h),
        Text(value, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
      ],
    );
  }
}

// --- Floating Compare Bar ---
class _CompareFloatingBar extends StatelessWidget {
  final int count;

  const _CompareFloatingBar({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF26C6DA),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: Colors.white,
                child: Text('$count', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00ACC1))),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Compare properties', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                  Text('Side by side analysis', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10.sp)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF00ACC1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              minimumSize: Size.zero,
            ),
            child: Text('Compare →', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}