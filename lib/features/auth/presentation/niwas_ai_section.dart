// =====================================================================
// NIWAS AI SCREEN (EXACT MATCHING DARK THEME UI)
// =====================================================================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NiwasAiScreen extends StatefulWidget {
  const NiwasAiScreen({super.key});

  @override
  State<NiwasAiScreen> createState() => _NiwasAiScreenState();
}

class _NiwasAiScreenState extends State<NiwasAiScreen> {
  final TextEditingController _promptController = TextEditingController();

  final List<Map<String, dynamic>> _aiRecommendedProperties = [
    {
      'title': 'Green Valley Residency',
      'price': '₹28k',
      'unit': '/mo',
      'location': 'Model Town, Phase 2',
      'bhk': '2 BHK',
      'sqft': '1,100 sqft',
      'image':
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&auto=format&fit=crop&q=80',
      'verified': true,
      'isFavorite': false,
    },
    {
      'title': 'The Grand Residency',
      'price': '₹26k',
      'unit': '/mo',
      'location': 'Model Town, Sector 3',
      'bhk': '2 BHK',
      'sqft': '1,050 sqft',
      'image':
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&auto=format&fit=crop&q=80',
      'verified': true,
      'isFavorite': false,
    },
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071B2F),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 180.h),
              child: Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: 24.h),
                  _buildAiAvatar(),
                  SizedBox(height: 16.h),
                  _buildTitleSection(),
                  SizedBox(height: 24.h),
                  _buildFeatureGrid(),
                  SizedBox(height: 24.h),
                  _buildSectionDivider(),
                  SizedBox(height: 18.h),
                  _buildChatHistory(),
                  SizedBox(height: 16.h),
                  _buildPropertyCarousel(),
                ],
              ),
            ),

            // Bottom Floating Input Bar
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 110.h,
              child: _buildBottomInputBar(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------------------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'DigiNiwas',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0F324D),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFF1E5279)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: const Color(0xFF4EE1A0), size: 12.sp),
              SizedBox(width: 4.w),
              Text(
                'NIWAS AI',
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // AI GLOWING AVATAR
  // ---------------------------------------------------------------------
  Widget _buildAiAvatar() {
    return Container(
      width: 90.w,
      height: 90.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF0A685A),
            Color(0xFF0B3A46),
            Color(0xFF071B2F),
          ],
          stops: [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A884).withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 8,
          ),
        ],
        border: Border.all(color: const Color(0xFF0E8570).withOpacity(0.4), width: 1.5),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          color: const Color(0xFF4EE1A0),
          size: 38.sp,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // TITLE & DESCRIPTION
  // ---------------------------------------------------------------------
  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Find your next home, with Niwas AI.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16.5.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Text(
            'Your intelligent property concierge for finding, comparing and exploring verified DigiNiwas homes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.5.sp,
              color: const Color(0xFF90A3B8),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // 2x2 FEATURE ACTIONS GRID
  // ---------------------------------------------------------------------
  Widget _buildFeatureGrid() {
    final features = [
      {
        'icon': Icons.search_rounded,
        'title': 'Find My Home',
        'sub': "Tell me what you're looking for.",
      },
      {
        'icon': Icons.compare_arrows_rounded,
        'title': 'Compare Homes',
        'sub': 'See the differences clearly.',
      },
      {
        'icon': Icons.map_outlined,
        'title': 'Explore Locality',
        'sub': 'Understand the neighbourhood.',
      },
      {
        'icon': Icons.calendar_today_outlined,
        'title': 'Plan My Visit',
        'sub': 'Book, prepare and follow up.',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: features.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final item = features[index];
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF0D2841),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFF1B3F63), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(7.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF091C2E),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(item['icon'] as IconData, color: const Color(0xFF4EE1A0), size: 16.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                item['title'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                item['sub'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 9.5.sp,
                  color: const Color(0xFF869EB5),
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // SECTION DIVIDER
  // ---------------------------------------------------------------------
  Widget _buildSectionDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFF1A3854), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            'OR ASK NIWAS AI DIRECTLY',
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF67839E),
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFF1A3854), thickness: 1)),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // CHAT HISTORY
  // ---------------------------------------------------------------------
  Widget _buildChatHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // User Message Bubble
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: 0.78.sw),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF00897B),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(4.r),
              ),
            ),
            child: Text(
              'Find a 2 BHK in Model Town under ₹30K',
              style: GoogleFonts.poppins(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // AI Response Bubble
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(5.r),
              decoration: const BoxDecoration(
                color: Color(0xFF005B48),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: const Color(0xFF4EE1A0), size: 12.sp),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E2E4B),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                  border: Border.all(color: const Color(0xFF1B456C)),
                ),
                child: Text(
                  'I found a few verified 2 BHK options in Model Town under ₹30,000. Here is a top recommendation for you.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: const Color(0xFFE2E8F0),
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // PROPERTY CAROUSEL
  // ---------------------------------------------------------------------
  Widget _buildPropertyCarousel() {
    return SizedBox(
      height: 315.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _aiRecommendedProperties.length,
        itemBuilder: (context, index) {
          final property = _aiRecommendedProperties[index];
          final bool isFavorite = property['isFavorite'] == true;

          return Container(
            width: 250.w,
            margin: EdgeInsets.only(right: 14.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0D2841),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFF1B3F63)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                      child: Image.network(
                        property['image'] as String,
                        height: 135.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 135.h,
                          color: const Color(0xFF0A1E31),
                          child: const Icon(Icons.home_work_rounded, color: Color(0xFF00A884)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007A5E),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 10.sp, color: Colors.white),
                            SizedBox(width: 3.w),
                            Text(
                              'VERIFIED',
                              style: GoogleFonts.poppins(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            property['isFavorite'] = !isFavorite;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF071B2F).withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? const Color(0xFFE11D48) : Colors.white,
                            size: 14.sp,
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
                              property['title'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: property['price'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(
                                  text: property['unit'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.sp,
                                    color: const Color(0xFF869EB5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 11.sp, color: const Color(0xFF00A884)),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              property['location'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: const Color(0xFF869EB5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.bed_outlined, size: 12.sp, color: const Color(0xFF869EB5)),
                          SizedBox(width: 3.w),
                          Text(
                            property['bhk'] as String,
                            style: GoogleFonts.poppins(fontSize: 9.5.sp, color: const Color(0xFFCAD7E2)),
                          ),
                          SizedBox(width: 10.w),
                          Icon(Icons.crop_square_rounded, size: 12.sp, color: const Color(0xFF869EB5)),
                          SizedBox(width: 3.w),
                          Text(
                            property['sqft'] as String,
                            style: GoogleFonts.poppins(fontSize: 9.5.sp, color: const Color(0xFFCAD7E2)),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF11385C),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View Property',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.arrow_forward_rounded, size: 12.sp),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // BOTTOM FLOATING INPUT BAR
  // ---------------------------------------------------------------------
  Widget _buildBottomInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0C243B),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFF1C466E)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.mic_none_rounded, color: const Color(0xFF869EB5), size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _promptController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.5.sp),
              decoration: InputDecoration(
                hintText: 'Ask anything about properties...',
                hintStyle: GoogleFonts.poppins(color: const Color(0xFF627D98), fontSize: 11.5.sp),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              color: Color(0xFF00897B),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 16.sp),
          ),
        ],
      ),
    );
  }
}