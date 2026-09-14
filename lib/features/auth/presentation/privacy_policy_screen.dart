import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _handleShare() {
    Share.share(
      'DigiNiwas Privacy Policy: https://diginiwas.com/privacy-policy',
      subject: 'DigiNiwas Data Protection & Privacy Policy',
    );
  }

  void _handleDownload(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Privacy Policy downloaded to your device.',
          style: GoogleFonts.poppins(fontSize: 13.sp),
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              size: 20.sp,
              color: AppColors.textSecondary,
            ),
            onPressed: _handleShare,
          ),
          IconButton(
            icon: Icon(
              Icons.file_download_outlined,
              size: 22.sp,
              color: AppColors.textSecondary,
            ),
            onPressed: () => _handleDownload(context),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compliance Tag & Last Updated
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7F2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFA7E8D6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF007E68),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'DPDP Act 2023 Compliant',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF007E68),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Updated: August 2024',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Large Title
            Text(
              'DigiNiwas\nData Protection &\nPrivacy Policy',
              style: GoogleFonts.poppins(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
                height: 1.25,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 16.h),

            // Notice Highlight Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF9),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFCCF0E7)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007E68).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 20.sp,
                      color: const Color(0xFF007E68),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'We respect your personal privacy. Your contact details and property documents are encrypted and shared only when you explicitly unlock or authorize access.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF004D40),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // Quick Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _categoryChip('1. Data We Collect', isActive: true),
                  SizedBox(width: 8.w),
                  _categoryChip('2. Contact Protection'),
                  SizedBox(width: 8.w),
                  _categoryChip('3. Document Storage'),
                  SizedBox(width: 8.w),
                  _categoryChip('4. AI Analytics'),
                  SizedBox(width: 8.w),
                  _categoryChip('5. Rights & Erasure'),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Card 1: Information We Collect & Process
            _buildSectionCard(
              icon: Icons.inventory_2_outlined,
              numberTitle: '1. Information We Collect & Process',
              children: [
                _buildBulletItem(
                  title: 'Account Credentials: ',
                  description:
                      'Name, verified email, and phone number (kept hidden by default).',
                ),
                SizedBox(height: 10.h),
                _buildBulletItem(
                  title: 'Property Records: ',
                  description:
                      'Ownership documents, identity proofs, and property details uploaded for verification.',
                ),
                SizedBox(height: 10.h),
                _buildBulletItem(
                  title: 'Usage Data: ',
                  description:
                      'Search preferences, saved properties, and interaction metrics to improve your experience.',
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Card 2: Contact Masking & Anti-Spam
            _buildSectionCard(
              icon: Icons.lock_outline_rounded,
              numberTitle: '2. Contact Masking & Anti-Spam',
              children: [
                Text(
                  'Your phone number is never displayed publicly. All initial communication happens through our secure in-app messaging system.',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 18.sp,
                        color: const Color(0xFF0284C7),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Zero Telemarketing Spam Guarantee. You control who calls you.',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Card 3: Document Storage & Access
            _buildSectionCard(
              icon: Icons.health_and_safety_outlined,
              numberTitle: '3. Document Storage & Access',
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'All sensitive documents (Aadhaar, PAN, Sale Deeds) are encrypted using industry-standard ',
                      ),
                      TextSpan(
                        text: 'AES-256 encryption',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' at rest and in transit. DigiNiwas staff cannot read your documents. They are only decrypted for authorized legal verification partners when you initiate a background check.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Card 4: AI Matchmaking Analytics
            _buildSectionCard(
              icon: Icons.auto_awesome_outlined,
              numberTitle: '4. AI Matchmaking Analytics',
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'We utilize '),
                      TextSpan(
                        text: 'Niwas AI',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' processing to analyze locality trends and match you with ideal properties. This processing is done on anonymized data aggregates. Your individual identity is never fed into public AI models.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Card 5: Right to Access & Erase
            _buildSectionCard(
              icon: Icons.manage_accounts_outlined,
              numberTitle: '5. Right to Access & Erase',
              children: [
                Text(
                  'Under the DPDP Act 2023, you have the right to access the data we hold, correct inaccuracies, and request complete erasure of your account. You can manage these preferences directly from your Profile Settings or by contacting our Data Protection Officer.',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Footer Card: Data Protection Officer
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 24.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Data Protection Officer',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'privacy@diginiwas.com',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label, {bool isActive = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.navy : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isActive ? AppColors.navy : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11.5.sp,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String numberTitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFEBF0F5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.softBackground,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 18.sp, color: AppColors.primaryDark),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  numberTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBulletItem({
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 3.h),
          child: Icon(
            Icons.check_rounded,
            size: 16.sp,
            color: const Color(0xFF007E68),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
