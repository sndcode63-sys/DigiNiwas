import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/controller/buyer_home_controller.dart';
import '../../../../core/models/property_filter_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_image.dart';

/// Converts a typed [PfPropertyData] (from the filter API) into the loose
/// `Map` shape that `_PropertyCard` and the compare screen already expect,
/// keeping display fields aligned with the search API's raw map results.
Map<String, dynamic> _pfPropertyToMap(PfPropertyData p) {
  return {
    '_id': p.sId,
    'propertyId': p.propertyId,
    'title': p.title,
    'name': p.title,
    'locality': p.locality,
    'address': p.address,
    'city': p.city,
    'price': p.price,
    'bedrooms': p.bedrooms,
    'furnishing': p.furnishing,
    'area': p.superBuiltupArea != null ? '${p.superBuiltupArea} sqft' : null,
    'images': p.images?.map((img) => {'url': img.url}).toList(),
    'isCompared': p.isCompared,
  };
}

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
    controller.clearPropertyFilters();
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
                      final count = controller.isFilterApplied.value
                          ? controller.filteredResultsList.length
                          : controller.searchResultsList.length;
                      return _HeaderSection(
                        searchController: searchController,
                        propertyCount: count,
                        controller: controller,
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

                  // Dynamic Search / Filter Results Handler
                  Obx(() {
                    final isFilterMode = controller.isFilterApplied.value;
                    final isLoading = isFilterMode
                        ? controller.filterLoading.value
                        : controller.searchLoading.value;

                    if (isLoading) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF00C896)),
                        ),
                      );
                    }

                    // Filter mode uses typed PfPropertyData; search mode uses raw dynamic maps.
                    final List<dynamic> results = isFilterMode
                        ? controller.filteredResultsList
                        : controller.searchResultsList;

                    final bool showEmptyState = isFilterMode
                        ? results.isEmpty
                        : (searchController.text.trim().isEmpty || results.isEmpty);

                    if (showEmptyState) {
                      final String emptyMessage = isFilterMode
                          ? 'No properties match your filters'
                          : (searchController.text.trim().isEmpty
                          ? 'Type something to search properties'
                          : 'No properties found');
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isFilterMode ? Icons.filter_alt_off_rounded : Icons.search_rounded,
                                size: 48.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                emptyMessage,
                                style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 13.sp, fontWeight: FontWeight.w500),
                              ),
                              if (isFilterMode) ...[
                                SizedBox(height: 12.h),
                                TextButton(
                                  onPressed: controller.clearPropertyFilters,
                                  child: Text('Clear Filters', style: GoogleFonts.poppins(color: const Color(0xFF00C896), fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final rawProperty = results[index];
                          final property = isFilterMode
                              ? _pfPropertyToMap(rawProperty as PfPropertyData)
                              : rawProperty as Map;
                          return _PropertyCard(
                            property: property,
                            onCompareChanged: (val) {
                              setState(() {
                                if (isFilterMode) {
                                  (rawProperty as PfPropertyData).isCompared = val ?? false;
                                } else {
                                  property['isCompared'] = val ?? false;
                                }
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

            // Floating Compare Bar with Navigation to ComparePropertiesScreen
            Obx(() {
              final isFilterMode = controller.isFilterApplied.value;
              final List<dynamic> results = isFilterMode
                  ? controller.filteredResultsList.map(_pfPropertyToMap).toList()
                  : controller.searchResultsList.map((e) => e as Map).toList();
              final comparedList = results.where((p) => p['isCompared'] == true).toList();
              final comparedCount = comparedList.length;

              return Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
                child: _CompareFloatingBar(
                  count: comparedCount,
                  onTapCompare: () {
                    Get.to(() => ComparePropertiesScreen(comparedProperties: comparedList));
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

void _showFilterSheet(BuildContext context, BuyerHomeController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterBottomSheet(controller: controller),
  );
}

// --- Filter Bottom Sheet (GET /api/newproperties/filter) ---
class _FilterBottomSheet extends StatefulWidget {
  final BuyerHomeController controller;
  const _FilterBottomSheet({required this.controller});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? transactionType;
  String? category;
  bool onlyVerified = false;
  final TextEditingController cityController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill from currently applied filters, if any.
    final applied = widget.controller.currentAppliedFilters.value;
    if (applied != null) {
      transactionType = applied.transactionType;
      category = applied.category;
      onlyVerified = applied.propertyVerificationStatus == 'verified';
      cityController.text = applied.city ?? '';
      minPriceController.text = applied.minPrice?.toString() ?? '';
      maxPriceController.text = applied.maxPrice?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    cityController.dispose();
    minPriceController.dispose();
    maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter Properties',
                    style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      transactionType = null;
                      category = null;
                      onlyVerified = false;
                      cityController.clear();
                      minPriceController.clear();
                      maxPriceController.clear();
                    });
                    widget.controller.clearPropertyFilters();
                  },
                  child: Text('Reset', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12.sp)),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text('Transaction Type', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: ['Buy', 'Rent', 'Lease']
                  .map((t) => _chip(t, transactionType == t, () {
                setState(() => transactionType = transactionType == t ? null : t);
              }))
                  .toList(),
            ),
            SizedBox(height: 16.h),
            Text('Category', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: ['Residential', 'Commercial', 'Plot']
                  .map((c) => _chip(c, category == c, () {
                setState(() => category = category == c ? null : c);
              }))
                  .toList(),
            ),
            SizedBox(height: 16.h),
            Text('City', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: 'Enter city',
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
            SizedBox(height: 16.h),
            Text('Price Range', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Min',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Max',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Checkbox(
                  value: onlyVerified,
                  onChanged: (v) => setState(() => onlyVerified = v ?? false),
                  activeColor: const Color(0xFF00C896),
                ),
                Text('Only verified properties', style: GoogleFonts.poppins(fontSize: 12.sp)),
              ],
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.controller.applyPropertyFilters(
                    transactionType: transactionType,
                    category: category,
                    city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
                    minPrice: num.tryParse(minPriceController.text.trim()),
                    maxPrice: num.tryParse(maxPriceController.text.trim()),
                    propertyVerificationStatus: onlyVerified ? 'verified' : null,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF173554),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Apply Filters',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00C896) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: selected ? const Color(0xFF00C896) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
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
  final BuyerHomeController controller;

  const _HeaderSection({
    required this.searchController,
    required this.propertyCount,
    required this.onChanged,
    required this.onClear,
    required this.controller,
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
          Obx(() {
            final isFilterMode = controller.isFilterApplied.value;
            final showCount = isFilterMode || searchController.text.isNotEmpty;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showCount ? '$propertyCount Properties Found' : 'Explore Properties',
                  style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A2129)),
                ),
                Text(
                  isFilterMode
                      ? 'Results matching your selected filters'
                      : (searchController.text.isEmpty
                      ? 'Live results based on your search'
                      : 'Live search results matching your query'),
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            );
          }),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton(Icons.sort, 'Sort', () {}),
                SizedBox(width: 8.w),
                Obx(() => _buildFilterButton(
                  Icons.tune,
                  controller.isFilterApplied.value ? 'Filters •' : 'Filters',
                      () => _showFilterSheet(context, controller),
                  isPrimary: controller.isFilterApplied.value,
                )),
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
  final VoidCallback onTapCompare;

  const _CompareFloatingBar({required this.count, required this.onTapCompare});

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
            onPressed: onTapCompare,
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

// =====================================================================
// DYNAMIC MULTI-PROPERTY COMPARE SCREEN (2, 3, 4+ PROPERTIES SUPPORT)
// =====================================================================
class ComparePropertiesScreen extends StatefulWidget {
  final List<dynamic> comparedProperties;

  const ComparePropertiesScreen({
    super.key,
    required this.comparedProperties,
  });

  @override
  State<ComparePropertiesScreen> createState() => _ComparePropertiesScreenState();
}

class _ComparePropertiesScreenState extends State<ComparePropertiesScreen> {
  late List<dynamic> _properties;

  @override
  void initState() {
    super.initState();
    _properties = List.from(widget.comparedProperties);
  }

  void _removeProperty(int index) {
    setState(() {
      _properties.removeAt(index);
    });
  }

  String _generateAiInsight() {
    if (_properties.isEmpty) return '';
    if (_properties.length == 1) {
      final title = _properties[0]['title'] ?? _properties[0]['name'] ?? 'Property';
      final locality = _properties[0]['locality'] ?? _properties[0]['address'] ?? '';
      return '$title is a great choice in $locality.';
    }
    final t1 = _properties[0]['title'] ?? _properties[0]['name'] ?? 'First property';
    final t2 = _properties[1]['title'] ?? _properties[1]['name'] ?? 'Second property';
    return '$t1 fits budget better, while $t2 offers high connectivity across ${_properties.length} compared properties.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: _properties.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopPropertyCards(),
            SizedBox(height: 20.h),
            _buildComparisonTable(),
            SizedBox(height: 20.h),
            _buildAiInsightCard(),
            SizedBox(height: 20.h),
            _buildNeedHelpCard(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: EdgeInsets.all(8.r),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: const Color(0xFF0F172A), size: 18.sp),
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      title: Text(
        'Compare (${_properties.length}) Properties',
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: const Color(0xFF0F172A), size: 20.sp),
          onPressed: () {},
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildTopPropertyCards() {
    final bool isMultiScroll = _properties.length > 2;

    if (isMultiScroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_properties.length, (index) {
            return Container(
              width: 165.w,
              margin: EdgeInsets.only(right: 12.w),
              child: _buildPropertyCardItem(_properties[index], index),
            );
          }),
        ),
      );
    }

    return Row(
      children: List.generate(_properties.length, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index == 0 && _properties.length > 1 ? 12.w : 0,
            ),
            child: _buildPropertyCardItem(_properties[index], index),
          ),
        );
      }),
    );
  }

  Widget _buildPropertyCardItem(dynamic item, int index) {
    final title = item['title'] ?? item['name'] ?? 'Property';
    final locality = item['locality'] ?? item['address'] ?? '';
    final price = item['price']?.toString() ?? '0';

    String? imageUrl;
    final images = item['images'];
    if (images is List && images.isNotEmpty) {
      imageUrl = images.first is Map ? images.first['url'] : images.first?.toString();
    } else if (item['image'] is String) {
      imageUrl = item['image'];
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: ImageCase(
                  url: imageUrl,
                  height: 105.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.home_work_rounded,
                ),
              ),
              Positioned(
                top: 6.h,
                right: 6.w,
                child: GestureDetector(
                  onTap: () => _removeProperty(index),
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 13.sp, color: const Color(0xFF334155)),
                  ),
                ),
              ),
              Positioned(
                bottom: 6.h,
                left: 6.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_outlined, size: 9.sp, color: const Color(0xFF007A5E)),
                      SizedBox(width: 2.w),
                      Text(
                        'Verified',
                        style: GoogleFonts.poppins(
                          fontSize: 8.sp,
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
          SizedBox(height: 8.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 10.sp, color: const Color(0xFF64748B)),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  locality,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '₹ $price',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF007A5E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    final bool isMulti = _properties.length > 2;

    Widget tableContent = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildDynamicTableRow(
            icon: Icons.grid_view_rounded,
            label: 'Configuration',
            values: _properties.map((e) => '${e['bedrooms'] ?? '2'} BHK').toList(),
            isFirst: true,
          ),
          _buildDynamicTableRow(
            icon: Icons.crop_square_rounded,
            label: 'Carpet Area',
            values: _properties.map((e) => e['area']?.toString() ?? '1,240 sq.ft').toList(),
          ),
          _buildDynamicTableRow(
            icon: Icons.calendar_today_outlined,
            label: 'Possession',
            values: _properties.map((e) => e['furnishing']?.toString() ?? 'Ready to Move').toList(),
          ),
          _buildDynamicTableRow(
            icon: Icons.sell_outlined,
            label: 'Price',
            values: _properties.map((e) => '₹ ${e['price'] ?? '85 L'}').toList(),
            isHighlighted: true,
          ),
          _buildDynamicTableRow(
            icon: Icons.location_on_outlined,
            label: 'Locality',
            values: _properties.map((e) => e['locality']?.toString() ?? 'Bopal').toList(),
          ),
          _buildDynamicTableRow(
            icon: Icons.verified_user_outlined,
            label: 'Verification',
            values: _properties.map((e) => 'Verified').toList(),
            isVerifiedTag: true,
            isLast: true,
          ),
        ],
      ),
    );

    if (isMulti) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: 120.w + (_properties.length * 115.w),
          child: tableContent,
        ),
      );
    }

    return tableContent;
  }

  Widget _buildDynamicTableRow({
    required IconData icon,
    required String label,
    required List<String> values,
    bool isHighlighted = false,
    bool isVerifiedTag = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 110.w,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                child: Row(
                  children: [
                    Icon(icon, size: 14.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...List.generate(values.length, (i) {
              return Expanded(
                child: Row(
                  children: [
                    Container(width: 1, color: const Color(0xFFE2E8F0)),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
                          child: isVerifiedTag
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 12.sp, color: const Color(0xFF007A5E)),
                              SizedBox(width: 2.w),
                              Text(
                                values[i],
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF007A5E),
                                ),
                              ),
                            ],
                          )
                              : Text(
                            values[i],
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                              color: isHighlighted
                                  ? const Color(0xFF007A5E)
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFBCE7DA), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF005B48),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'AI',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niwas AI Insight',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF005B48),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      _generateAiInsight(),
                      style: GoogleFonts.poppins(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: const Color(0xFFBCE7DA), thickness: 0.8),
          SizedBox(height: 4.h),
          Text(
            'Use this guidance with property documents and a site inspection.',
            style: GoogleFonts.poppins(
              fontSize: 9.5.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedHelpCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline_rounded, color: const Color(0xFF007A5E), size: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Need local help?',
            style: GoogleFonts.poppins(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Connect with a verified DigiNiwas\npartner for property details and availability.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.5.sp,
              color: const Color(0xFF64748B),
              height: 1.3,
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005B48),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Connect with DigiNiwas Partner',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward_rounded, size: 14.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows_rounded, size: 48.sp, color: const Color(0xFF94A3B8)),
          SizedBox(height: 8.h),
          Text(
            'No properties selected to compare',
            style: GoogleFonts.poppins(fontSize: 13.sp, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}