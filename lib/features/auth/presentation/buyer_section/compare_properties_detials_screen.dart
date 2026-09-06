// =====================================================================
// DYNAMIC MULTI-PROPERTY COMPARE SCREEN (SYNCHRONIZED SCROLLING)
// =====================================================================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/widgets/app_image.dart';

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

  void _shareComparison() {
    if (_properties.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln('Property Comparison (${_properties.length})');
    buffer.writeln('--------------------------------');

    for (final item in _properties) {
      final title = item['title'] ?? item['name'] ?? 'Property';
      final locality = item['locality'] ?? item['address'] ?? '';
      final price = item['price']?.toString() ?? '0';
      final bhk = item['bedrooms'] ?? '2';
      final area = item['area']?.toString() ?? '1,240 sq.ft';

      buffer.writeln(title);
      if (locality.toString().isNotEmpty) buffer.writeln('Locality: $locality');
      buffer.writeln('Configuration: $bhk BHK');
      buffer.writeln('Area: $area');
      buffer.writeln('Price: ₹ $price');
      buffer.writeln();
    }

    buffer.writeln(_generateAiInsight());

    SharePlus.instance.share(
      ShareParams(text: buffer.toString(), subject: 'Property Comparison'),
    );
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
            // Unified Synchronized Scroll View for Cards + Table
            _buildSynchronizedComparisonContent(),
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
          onPressed: _shareComparison,
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // UNIFIED HORIZONTAL SCROLL FOR CARDS AND TABLE TOGETHER
  // ---------------------------------------------------------------------
  Widget _buildSynchronizedComparisonContent() {
    // NOTE: 110.w matches the fixed label-column width used inside the
    // table rows (see _buildDynamicTableRow). Keeping both in sync here
    // is what actually keeps cards and table columns aligned while
    // scrolling — they're already in ONE SingleChildScrollView, so the
    // real bug was misalignment, not "not scrolling together".
    const double labelColumnWidth = 110;
    final double totalWidth = labelColumnWidth.w + (_properties.length * 177.w);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: totalWidth > 1.sw ? totalWidth : 1.sw - 32.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Property Cards Row — offset by the same label-column
            // width as the table so each card lines up with its column.
            Row(
              children: [
                SizedBox(width: labelColumnWidth.w),
                ...List.generate(_properties.length, (index) {
                  return Container(
                    width: 165.w,
                    margin: EdgeInsets.only(right: index == _properties.length - 1 ? 0 : 12.w),
                    child: _buildPropertyCardItem(_properties[index], index),
                  );
                }),
              ],
            ),
            SizedBox(height: 16.h),
            // Comparison Table matching the exact width layout
            _buildComparisonTableBody(),
          ],
        ),
      ),
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

  Widget _buildComparisonTableBody() {
    return Container(
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
  }

  Widget _buildDynamicTableRow({
    required IconData icon,
    required String label,
    required List<String> values,
    bool isHighlighted = false,
    bool isVerifiedTag = false,
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
            // Fixed Property Attributes Header Column
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
            // Values mapped to individual property columns matching card widths
            ...List.generate(values.length, (i) {
              return SizedBox(
                width: 165.w,
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