// =====================================================================
// SAVED PROPERTIES & DYNAMIC MULTI-COMPARE INTEGRATION
// =====================================================================
import 'package:diginiwas/features/auth/presentation/buyer_section/property_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'compare_properties_detials_screen.dart';

class SavedPropertiesScreen extends StatefulWidget {
  const SavedPropertiesScreen({super.key});

  @override
  State<SavedPropertiesScreen> createState() => _SavedPropertiesScreenState();
}

class _SavedPropertiesScreenState extends State<SavedPropertiesScreen> {
  final List<Map<String, dynamic>> _savedList = [
    {
      'id': '1',
      'name': 'Celestial Heights',
      'address': 'Bopal, Ahmedabad',
      'price': '₹85 L',
      'bhk': '2 BHK',
      'sqft': '1,240 sq.ft',
      'status': 'Ready to Move',
      'possession': 'Ready to Move',
      'image':
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&auto=format&fit=crop&q=80',
      'tag': 'Matches your budget',
      'tagIcon': Icons.account_balance_wallet_outlined,
      'isCompared': true,
      'isFavorite': true,
      'verified': true,
    },
    {
      'id': '2',
      'name': 'EcoPark Residences',
      'address': 'South Bopal, Ahmedabad',
      'price': '₹92 L',
      'bhk': '3 BHK',
      'sqft': '1,310 sq.ft',
      'status': 'Under Construction',
      'possession': 'Dec 2026',
      'image':
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&auto=format&fit=crop&q=80',
      'tag': 'Good locality match',
      'tagIcon': Icons.location_on_outlined,
      'isCompared': true,
      'isFavorite': true,
      'verified': true,
    },
    {
      'id': '3',
      'name': 'Skyline Greens',
      'address': 'Bopal, Ahmedabad',
      'price': '₹82 L',
      'bhk': '2 BHK',
      'sqft': '1,180 sq.ft',
      'status': 'Under Construction',
      'possession': 'Jan 2027',
      'image':
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&auto=format&fit=crop&q=80',
      'tag': 'Price dropped ₹2 L',
      'tagIcon': Icons.trending_down_rounded,
      'isCompared': false,
      'isFavorite': true,
      'verified': true,
    },
  ];

  int get _selectedCount =>
      _savedList.where((item) => item['isCompared'] == true).length;

  void _openComparisonScreen() {
    final selectedItems =
    _savedList.where((item) => item['isCompared'] == true).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 property to compare.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComparePropertiesScreen(
          comparedProperties: selectedItems,
        ),
      ),
    );
  }

  void _toggleCompareAll() {
    setState(() {
      final bool selectAll = _selectedCount != _savedList.length;
      for (var item in _savedList) {
        item['isCompared'] = selectAll;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildTopAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 170.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 12.h),
                _buildAiPortfolioInsight(),
                SizedBox(height: 16.h),
                ..._savedList.map((item) => _buildSavedPropertyCard(item)),
              ],
            ),
          ),

          // Floating Action Bar
          if (_selectedCount > 0)
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 96.h,
              child: _buildComparisonBar(),
            ),
        ],
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_savedList.length} Properties Saved',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Updated recently across Ahmedabad',
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
              _buildDropdownChip('Recently Saved'),
              SizedBox(width: 8.w),
              _buildDropdownChip('Filter by Locality'),
              SizedBox(width: 8.w),
              InkWell(
                onTap: _toggleCompareAll,
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
                      Text(
                        _selectedCount == _savedList.length
                            ? 'Deselect All'
                            : 'Compare All (${_savedList.length})',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
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

  Widget _buildDropdownChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down_rounded, size: 14.sp, color: const Color(0xFF64748B)),
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
                      '2 of your saved properties are in Bopal with an average price of ₹83.5 L. Ready to schedule site visits?',
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
          SizedBox(height: 8.h),
          InkWell(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Book Free Site Visit',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF007A5E),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_forward_ios_rounded, size: 10.sp, color: const Color(0xFF007A5E)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPropertyCard(Map<String, dynamic> item) {
    final bool isCompared = item['isCompared'] ?? false;
    final bool isFavorite = item['isFavorite'] ?? true;

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
                child: Image.network(
                  item['image'] as String,
                  height: 165.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 165.h,
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
              Positioned(
                top: 10.h,
                right: 10.w,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      item['isFavorite'] = !isFavorite;
                    });
                  },
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ),
              if (item['tag'] != null)
                Positioned(
                  bottom: 8.h,
                  right: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2544).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item['tagIcon'] as IconData, size: 11.sp, color: const Color(0xFF4EE1A0)),
                        SizedBox(width: 4.w),
                        Text(
                          item['tag'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 9.5.sp,
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
                        item['name'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      item['price'] as String,
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
                      item['address'] as String,
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
                    setState(() {
                      item['isCompared'] = !isCompared;
                    });
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyDetailsScreen(property: item),
                            ),
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
  }

  Widget _buildComparisonBar() {
    final bool hasSelection = _selectedCount > 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
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

          // TAB 1: Inquire All Button
          OutlinedButton(
            onPressed: hasSelection
                ? () {
              final selectedItems = _savedList
                  .where((item) => item['isCompared'] == true)
                  .toList();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Inquiry sent for ${selectedItems.length} selected properties!',
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF0F2544),
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

          // TAB 2: Compare Button
          ElevatedButton(
            onPressed: hasSelection ? _openComparisonScreen : null,
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
  }}

