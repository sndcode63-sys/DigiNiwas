// =====================================================================
// SAVED PROPERTIES & DYNAMIC MULTI-COMPARE INTEGRATION
// =====================================================================
import 'dart:convert';
import 'package:diginiwas/features/auth/presentation/buyer_section/property_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/controller/buyer_home_controller.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_service.dart';
import 'compare_properties_detials_screen.dart';

class SavedPropertiesScreen extends StatelessWidget {
  SavedPropertiesScreen({super.key});

  // GetX Controller instance access
  final BuyerHomeController controller = Get.find<BuyerHomeController>();

  // Map to track selection state for comparison (Local UI state per property id)
  final RxMap<String, bool> _comparedSelectionMap = <String, bool>{}.obs;

  // NEW: Sort state
  final RxString _sortOption = 'Recently Saved'.obs;

  // NEW: Quick locality chip filter
  final RxString _selectedLocality = 'All Localities'.obs;

  // NEW: Full filter set — same fields as the Explore screen's filter sheet
  // (Transaction Type, Category, City, Price Range, Verified-only)
  final RxnString _filterTransactionType = RxnString();
  final RxnString _filterCategory = RxnString();
  final RxString _filterCity = ''.obs;
  final Rxn<num> _filterMinPrice = Rxn<num>();
  final Rxn<num> _filterMaxPrice = Rxn<num>();
  final RxBool _filterVerifiedOnly = false.obs;

  int get _selectedCount =>
      _comparedSelectionMap.values.where((selected) => selected == true).length;

  bool get _isAnyAdvancedFilterActive =>
      _filterTransactionType.value != null ||
          _filterCategory.value != null ||
          _filterCity.value.trim().isNotEmpty ||
          _filterMinPrice.value != null ||
          _filterMaxPrice.value != null ||
          _filterVerifiedOnly.value == true;

  void _openComparisonScreen(BuildContext context, List<dynamic> savedList) {
    final selectedItems = savedList.where((item) {
      final propertyData = (item is Map && item['propertySnapshot'] != null)
          ? item['propertySnapshot']
          : (item is Map && item['property'] != null ? item['property'] : item);
      final id = propertyData['propertyId']?.toString() ?? propertyData['_id']?.toString() ?? '';
      return _comparedSelectionMap[id] == true;
    }).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 property to compare.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Get.toNamed(AppRoutes.compareProperties, arguments: {'comparedProperties': selectedItems});
  }

  void _toggleCompareAll(List<dynamic> savedList) {
    final bool selectAll = _selectedCount != savedList.length;
    for (var item in savedList) {
      final propertyData = (item is Map && item['propertySnapshot'] != null)
          ? item['propertySnapshot']
          : (item is Map && item['property'] != null ? item['property'] : item);
      final id = propertyData['propertyId']?.toString() ?? propertyData['_id']?.toString() ?? '';
      if (id.isNotEmpty) {
        _comparedSelectionMap[id] = selectAll;
      }
    }
  }

  Future<String?> _getBuyerId() async {
    String? buyerId = await StorageService.instance.buyerId;
    if (buyerId == null || buyerId.isEmpty) {
      buyerId = await StorageService.instance.userId;
    }
    if (buyerId == null || buyerId.isEmpty) {
      final userJson = await SecureStorageService.instance.getUserData();
      if (userJson != null && userJson.isNotEmpty) {
        try {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          buyerId = userMap['id']?.toString() ??
              userMap['_id']?.toString() ??
              userMap['buyerId']?.toString();
        } catch (_) {}
      }
    }
    return buyerId;
  }

  // ---------------------------------------------------------------------
  // Helpers to read property fields from a saved-list item
  // ---------------------------------------------------------------------
  dynamic _propertyDataOf(dynamic item) {
    return (item is Map && item['propertySnapshot'] != null)
        ? item['propertySnapshot']
        : (item is Map && item['property'] != null ? item['property'] : item);
  }

  DateTime? _savedDateOf(dynamic item) {
    dynamic raw;
    if (item is Map) {
      raw = item['createdAt'] ?? item['savedAt'] ?? item['updatedAt'];
      if (raw == null) {
        final propertyData = _propertyDataOf(item);
        if (propertyData is Map) {
          raw = propertyData['createdAt'] ?? propertyData['savedAt'];
        }
      }
    }
    if (raw == null) return null;
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return null;
    }
  }

  String _localityOf(dynamic item) {
    final propertyData = _propertyDataOf(item);
    final locality = (propertyData is Map) ? propertyData['locality']?.toString().trim() : null;
    return (locality == null || locality.isEmpty) ? 'Unknown' : locality;
  }

  num? _priceOf(dynamic item) {
    final propertyData = _propertyDataOf(item);
    final raw = (propertyData is Map) ? propertyData['price'] : null;
    if (raw == null) return null;
    return num.tryParse(raw.toString());
  }

  List<String> _availableLocalities(List<dynamic> savedList) {
    final Set<String> localities = {};
    for (var item in savedList) {
      localities.add(_localityOf(item));
    }
    final sorted = localities.toList()..sort();
    return ['All Localities', ...sorted];
  }

  /// Applies locality chip + advanced filter sheet + sort to the raw saved list.
  List<dynamic> _applyFiltersAndSort(List<dynamic> savedList) {
    List<dynamic> result = List<dynamic>.from(savedList);

    // 1. Quick locality chip filter
    if (_selectedLocality.value != 'All Localities') {
      result = result.where((item) => _localityOf(item) == _selectedLocality.value).toList();
    }

    // 2. Advanced filters (Transaction Type, Category, City, Price Range, Verified)
    if (_filterTransactionType.value != null) {
      result = result.where((item) {
        final propertyData = _propertyDataOf(item);
        final t = (propertyData is Map) ? propertyData['transactionType']?.toString() : null;
        return t?.toLowerCase() == _filterTransactionType.value!.toLowerCase();
      }).toList();
    }

    if (_filterCategory.value != null) {
      result = result.where((item) {
        final propertyData = _propertyDataOf(item);
        final c = (propertyData is Map) ? propertyData['category']?.toString() : null;
        return c?.toLowerCase() == _filterCategory.value!.toLowerCase();
      }).toList();
    }

    if (_filterCity.value.trim().isNotEmpty) {
      final query = _filterCity.value.trim().toLowerCase();
      result = result.where((item) {
        final propertyData = _propertyDataOf(item);
        final city = (propertyData is Map) ? propertyData['city']?.toString().toLowerCase() : null;
        return city != null && city.contains(query);
      }).toList();
    }

    if (_filterMinPrice.value != null) {
      result = result.where((item) {
        final price = _priceOf(item);
        return price != null && price >= _filterMinPrice.value!;
      }).toList();
    }

    if (_filterMaxPrice.value != null) {
      result = result.where((item) {
        final price = _priceOf(item);
        return price != null && price <= _filterMaxPrice.value!;
      }).toList();
    }

    if (_filterVerifiedOnly.value == true) {
      result = result.where((item) {
        final propertyData = _propertyDataOf(item);
        final status = (propertyData is Map) ? propertyData['propertyVerificationStatus']?.toString() : null;
        return status?.toLowerCase() == 'verified';
      }).toList();
    }

    // 3. Sort by saved date (falls back to list/insertion order if no dates present)
    final bool anyDateAvailable = savedList.any((item) => _savedDateOf(item) != null);

    if (anyDateAvailable) {
      result.sort((a, b) {
        final da = _savedDateOf(a) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = _savedDateOf(b) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return _sortOption.value == 'Recently Saved' ? db.compareTo(da) : da.compareTo(db);
      });
    } else {
      // No timestamps returned by the API — assume the backend returns items in the
      // order they were saved (oldest first), so "Recently Saved" = reversed order.
      if (_sortOption.value == 'Recently Saved') {
        result = result.reversed.toList();
      }
    }

    return result;
  }

  void _openFilterSheet(BuildContext context, List<dynamic> savedList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SavedFilterBottomSheet(
        initialTransactionType: _filterTransactionType.value,
        initialCategory: _filterCategory.value,
        initialCity: _filterCity.value,
        initialMinPrice: _filterMinPrice.value,
        initialMaxPrice: _filterMaxPrice.value,
        initialVerifiedOnly: _filterVerifiedOnly.value,
        onReset: () {
          _filterTransactionType.value = null;
          _filterCategory.value = null;
          _filterCity.value = '';
          _filterMinPrice.value = null;
          _filterMaxPrice.value = null;
          _filterVerifiedOnly.value = false;
        },
        onApply: ({
          required String? transactionType,
          required String? category,
          required String city,
          required num? minPrice,
          required num? maxPrice,
          required bool verifiedOnly,
        }) {
          _filterTransactionType.value = transactionType;
          _filterCategory.value = category;
          _filterCity.value = city;
          _filterMinPrice.value = minPrice;
          _filterMaxPrice.value = maxPrice;
          _filterVerifiedOnly.value = verifiedOnly;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildTopAppBar(),
      body: Obx(() {
        if (controller.savedPropertiesLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF007A5E)),
          );
        }

        final savedList = controller.savedPropertiesList;

        if (savedList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_rounded, size: 50.sp, color: const Color(0xFF94A3B8)),
                SizedBox(height: 10.h),
                Text(
                  'No Saved Properties Yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Tap the heart icon on any property to save it here.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }

        // Apply locality chip + advanced filters + sort before rendering
        final displayList = _applyFiltersAndSort(savedList);

        return Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 170.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, savedList, displayList),
                  SizedBox(height: 12.h),
                  _buildAiPortfolioInsight(),
                  SizedBox(height: 16.h),
                  if (displayList.isEmpty)
                    _buildNoMatchState()
                  else
                    ...displayList.map((item) => _buildSavedPropertyCard(context, item)),
                ],
              ),
            ),

            // Floating Action Bar
            if (_selectedCount > 0)
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 96.h,
                child: _buildComparisonBar(context, displayList),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildNoMatchState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 36.sp, color: const Color(0xFF94A3B8)),
            SizedBox(height: 8.h),
            Text(
              'No saved properties match your filters',
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                _selectedLocality.value = 'All Localities';
                _filterTransactionType.value = null;
                _filterCategory.value = null;
                _filterCity.value = '';
                _filterMinPrice.value = null;
                _filterMaxPrice.value = null;
                _filterVerifiedOnly.value = false;
              },
              child: Text(
                'Clear all filters',
                style: GoogleFonts.poppins(color: const Color(0xFF007A5E), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: const Color(0xFF0F172A), size: 22.sp),
        onPressed: () {},
      ),
      title: Text(
        'DigiNiwas',
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        CircleAvatar(
          radius: 14.r,
          backgroundImage: const NetworkImage(
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert_rounded, color: const Color(0xFF64748B), size: 20.sp),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, List<dynamic> savedList, List<dynamic> displayList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
              () => Text(
            displayList.length == savedList.length
                ? '${savedList.length} Properties Saved'
                : '${displayList.length} of ${savedList.length} Properties Saved',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Updated recently from your wishlist',
          style: GoogleFonts.poppins(
            fontSize: 11.5.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildSortDropdownChip(),
              SizedBox(width: 8.w),
              _buildLocalityDropdownChip(savedList),
              SizedBox(width: 8.w),
              _buildFiltersChip(context, savedList),
              SizedBox(width: 8.w),
              InkWell(
                onTap: () => _toggleCompareAll(displayList),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2544),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.compare_arrows_rounded, color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      Obx(
                            () => Text(
                          _selectedCount == displayList.length && displayList.isNotEmpty
                              ? 'Deselect All'
                              : 'Compare All (${displayList.length})',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10.5.sp,
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
      ],
    );
  }

  // "Recently Saved / Oldest Saved" sort dropdown
  // Highlighted (green) whenever a non-default option ("Oldest Saved") is picked.
  Widget _buildSortDropdownChip() {
    return PopupMenuButton<String>(
      onSelected: (value) => _sortOption.value = value,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      itemBuilder: (context) => [
        _popupMenuItem('Recently Saved', Icons.history_rounded),
        _popupMenuItem('Oldest Saved', Icons.hourglass_bottom_rounded),
      ],
      child: Obx(() => _dropdownChipContent(
        _sortOption.value,
        active: _sortOption.value != 'Recently Saved',
      )),
    );
  }

  // Quick locality filter dropdown, built from the saved list itself.
  // Highlighted (green) whenever a specific locality (not "All Localities") is picked.
  Widget _buildLocalityDropdownChip(List<dynamic> savedList) {
    return PopupMenuButton<String>(
      onSelected: (value) => _selectedLocality.value = value,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      itemBuilder: (context) => _availableLocalities(savedList)
          .map((locality) => _popupMenuItem(locality, Icons.location_on_outlined))
          .toList(),
      child: Obx(() => _dropdownChipContent(
        _selectedLocality.value == 'All Localities' ? 'Filter by Locality' : _selectedLocality.value,
        active: _selectedLocality.value != 'All Localities',
      )),
    );
  }

  // NEW: Full "Filters" chip — opens the same filter set used on the Explore
  // screen (Transaction Type, Category, City, Price Range, Verified-only),
  // applied locally to the saved-properties list.
  Widget _buildFiltersChip(BuildContext context, List<dynamic> savedList) {
    return GestureDetector(
      onTap: () => _openFilterSheet(context, savedList),
      child: Obx(() {
        final active = _isAnyAdvancedFilterActive;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE8F7F2) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: active ? const Color(0xFF007A5E) : const Color(0xFFCBD5E1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, size: 13.sp, color: active ? const Color(0xFF007A5E) : const Color(0xFF64748B)),
              SizedBox(width: 4.w),
              Text(
                active ? 'Filters •' : 'Filters',
                style: GoogleFonts.poppins(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w500,
                  color: active ? const Color(0xFF007A5E) : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  PopupMenuItem<String> _popupMenuItem(String label, IconData icon) {
    return PopupMenuItem<String>(
      value: label,
      child: Row(
        children: [
          Icon(icon, size: 15.sp, color: const Color(0xFF007A5E)),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  Widget _dropdownChipContent(String label, {bool active = false}) {
    final Color borderColor = active ? const Color(0xFF007A5E) : const Color(0xFFCBD5E1);
    final Color bgColor = active ? const Color(0xFFE8F7F2) : Colors.white;
    final Color textColor = active ? const Color(0xFF007A5E) : const Color(0xFF334155);
    final Color iconColor = active ? const Color(0xFF007A5E) : const Color(0xFF64748B);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down_rounded, size: 14.sp, color: iconColor),
        ],
      ),
    );
  }

  Widget _buildAiPortfolioInsight() {
    return Container(
      padding: EdgeInsets.all(13.w),
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
                padding: EdgeInsets.all(6.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF007A5E),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 13.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niwas AI Saved Portfolio Insight',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF005B48),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Review your saved properties and schedule free site visits directly with verified agents.',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF334155),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPropertyCard(BuildContext context, dynamic item) {
    final propertyData = (item is Map && item['propertySnapshot'] != null)
        ? item['propertySnapshot']
        : (item is Map && item['property'] != null ? item['property'] : item);

    // Get the exact property ID for deletion/comparison (supports propertyId or _id)
    final propertyId = propertyData['propertyId']?.toString() ?? item['propertyId']?.toString() ?? propertyData['_id']?.toString() ?? '';

    final title = propertyData['title'] ?? 'Property';
    final locality = propertyData['locality'] ?? '';
    final city = propertyData['city'] ?? '';
    final price = propertyData['price']?.toString() ?? '0';

    String? imageUrl = propertyData['image']?.toString();
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

    return Obx(() {
      final bool isCompared = _comparedSelectionMap[propertyId] ?? false;

      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
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
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    height: 165.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                      : _placeholderImage(),
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
                        Icon(Icons.verified_outlined, size: 11.sp, color: const Color(0xFF007A5E)),
                        SizedBox(width: 3.w),
                        Text(
                          'Verified',
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF007A5E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Heart Icon - Tap to Remove / Unsave
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: GestureDetector(
                    onTap: () async {
                      final buyerId = await _getBuyerId();
                      if (buyerId != null && buyerId.isNotEmpty && propertyId.isNotEmpty) {
                        // This will trigger DELETE API and remove it from saved list
                        await controller.toggleSaveProperty(buyerId, propertyId);
                      }
                    },
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite_rounded, // Filled red heart since it's in saved list
                          color: Color(0xFFE11D48),
                          size: 16,
                        ),
                      ),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        '₹ $price',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF007A5E),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12.sp, color: const Color(0xFF64748B)),
                      SizedBox(width: 3.w),
                      Text(
                        '$locality, $city',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: () {
                      _comparedSelectionMap[propertyId] = !isCompared;
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                            color: isCompared ? const Color(0xFF007A5E) : Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color: isCompared ? const Color(0xFF007A5E) : const Color(0xFF94A3B8),
                              width: 1.5,
                            ),
                          ),
                          child: isCompared
                              ? Icon(Icons.check, size: 13.sp, color: Colors.white)
                              : null,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Add to Compare',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.chat_outlined, size: 15.sp, color: const Color(0xFF007A5E)),
                          label: Text(
                            'Chat',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF007A5E),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF007A5E), width: 1.2),
                            padding: EdgeInsets.symmetric(vertical: 9.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Property Details Screen with property snapshot/data
                            Get.toNamed(
                              AppRoutes.propertyDetails,
                              arguments: {'property': propertyData},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F2544),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 9.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            elevation: 0,
                          ),
                          child: Text(
                            'View Details',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    });
  }

  Widget _placeholderImage() {
    return Container(
      height: 165.h,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.home_work_rounded, color: Color(0xFF007A5E)),
      ),
    );
  }

  Widget _buildComparisonBar(BuildContext context, List<dynamic> savedList) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(Icons.balance_rounded, color: const Color(0xFF007A5E), size: 18.sp),
          SizedBox(width: 6.w),
          Text(
            '$_selectedCount Selected',
            style: GoogleFonts.poppins(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: _selectedCount > 0
                ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Inquiry sent for selected properties!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFF0F2544),
                ),
              );
            }
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF334155),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Inquire All',
              style: GoogleFonts.poppins(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: _selectedCount > 0 ? () => _openComparisonScreen(context, savedList) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005B48),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF94A3B8),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(

                  'Compare',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(Icons.arrow_forward_rounded, size: 12.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// NEW: Filter bottom sheet — mirrors the Explore screen's filter set
// (Transaction Type, Category, City, Price Range, Verified-only), but
// applies purely client-side to the already-loaded saved properties list.
// =====================================================================
class _SavedFilterBottomSheet extends StatefulWidget {
  final String? initialTransactionType;
  final String? initialCategory;
  final String initialCity;
  final num? initialMinPrice;
  final num? initialMaxPrice;
  final bool initialVerifiedOnly;
  final VoidCallback onReset;
  final void Function({
  required String? transactionType,
  required String? category,
  required String city,
  required num? minPrice,
  required num? maxPrice,
  required bool verifiedOnly,
  }) onApply;

  const _SavedFilterBottomSheet({
    required this.initialTransactionType,
    required this.initialCategory,
    required this.initialCity,
    required this.initialMinPrice,
    required this.initialMaxPrice,
    required this.initialVerifiedOnly,
    required this.onReset,
    required this.onApply,
  });

  @override
  State<_SavedFilterBottomSheet> createState() => _SavedFilterBottomSheetState();
}

class _SavedFilterBottomSheetState extends State<_SavedFilterBottomSheet> {
  String? transactionType;
  String? category;
  bool onlyVerified = false;
  late final TextEditingController cityController;
  late final TextEditingController minPriceController;
  late final TextEditingController maxPriceController;

  @override
  void initState() {
    super.initState();
    transactionType = widget.initialTransactionType;
    category = widget.initialCategory;
    onlyVerified = widget.initialVerifiedOnly;
    cityController = TextEditingController(text: widget.initialCity);
    minPriceController = TextEditingController(text: widget.initialMinPrice?.toString() ?? '');
    maxPriceController = TextEditingController(text: widget.initialMaxPrice?.toString() ?? '');
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
                Text('Filter Saved Properties',
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
                    widget.onReset();
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
                  widget.onApply(
                    transactionType: transactionType,
                    category: category,
                    city: cityController.text.trim(),
                    minPrice: num.tryParse(minPriceController.text.trim()),
                    maxPrice: num.tryParse(maxPriceController.text.trim()),
                    verifiedOnly: onlyVerified,
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