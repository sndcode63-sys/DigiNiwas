import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  void _handleShare() {
    Share.share(
      'DigiNiwas Terms of Service: https://diginiwas.com/terms',
      subject: 'DigiNiwas Platform Terms & User Agreement',
    );
  }

  void _handleDownload(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Terms of Service downloaded to your device.',
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
          'Terms of Service',
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
              Icons.file_download_outlined,
              size: 22.sp,
              color: AppColors.textSecondary,
            ),
            onPressed: () => _handleDownload(context),
          ),
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              size: 20.sp,
              color: AppColors.textSecondary,
            ),
            onPressed: _handleShare,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Version Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DigiNiwas Platform\nTerms & User\nAgreement',
                              style: GoogleFonts.poppins(
                                fontSize: 23.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                                height: 1.25,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Effective Date: August 2024',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          'v2.4',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Summary Notice Box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'This summary is provided for convenience. Please review the full legal terms below carefully before continuing to use the platform.',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Quick Category Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _categoryChip('1. Platform Scope', isActive: true),
                        SizedBox(width: 8.w),
                        _categoryChip('2. Partner Roles'),
                        SizedBox(width: 8.w),
                        _categoryChip('3. Credits & Payments'),
                        SizedBox(width: 8.w),
                        _categoryChip('4. Niwas AI'),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Section 1: Platform Scope & Intermediary Role
                  _buildSectionCard(
                    icon: Icons.holiday_village_outlined,
                    numberTitle: '1. Platform Scope & Intermediary Role',
                    children: [
                      Text(
                        'DigiNiwas operates strictly as a digital intermediary connecting property seekers, owners, and verified partners.',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _bulletText('We do not act as a real estate broker or agent.'),
                      SizedBox(height: 6.h),
                      _bulletRichText(
                        prefix: 'We charge ',
                        boldText: '0% commission',
                        suffix:
                            ' on property transactions facilitated through introductions made on this platform.',
                      ),
                      SizedBox(height: 6.h),
                      _bulletText(
                        'Users are solely responsible for verifying the authenticity of any documents or claims before signing formal agreements.',
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Section 2: Credit Wallet & Contact Unlocking
                  _buildSectionCard(
                    icon: Icons.account_balance_wallet_outlined,
                    numberTitle: '2. Credit Wallet & Contact Unlocking',
                    children: [
                      Text(
                        'Access to verified owner contact details requires platform credits, purchased via our secure gateway.',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.published_with_changes_rounded,
                                  size: 16.sp,
                                  color: const Color(0xFF1D4ED8),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Credit Protection Rule',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'If an unlocked contact is found to be unresponsive or inactive within 48 hours, users may request a credit refund via the support dashboard, subject to review.',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5.sp,
                                color: const Color(0xFF1E3A8A),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Section 3: Automated Intelligence (Niwas AI)
                  _buildSectionCard(
                    icon: Icons.auto_awesome_outlined,
                    numberTitle: '3. Automated Intelligence (Niwas AI)',
                    children: [
                      Text(
                        'Niwas AI provides predictive pricing and layout analysis based on aggregated market data.',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFFDE047)),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF713F12),
                              height: 1.45,
                            ),
                            children: [
                              TextSpan(
                                text: 'Disclaimer: ',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF713F12),
                                ),
                              ),
                              const TextSpan(
                                text:
                                    'AI-generated insights are estimations for guidance only. They do not constitute official appraisals or structural guarantees.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Section 4: Verification & Submission Accuracy
                  _buildSectionCard(
                    icon: Icons.verified_outlined,
                    numberTitle: '4. Verification & Submission Accuracy',
                    children: [
                      Text(
                        'Users listing properties must provide accurate documentation (RERA, layout plans).\n\nFraudulent listings will result in immediate permanent suspension from the DigiNiwas network.',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // Questions Support Pill
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7F2),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFA7E8D6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 18.sp,
                          color: const Color(0xFF007E68),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Questions? ',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'legal@diginiwas.com',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF007E68),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),

          // Sticky Bottom Bar with Decline and Accept buttons
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26.r),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.4),
                    ),
                    child: Text(
                      'Decline',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Terms & User Agreement accepted.',
                            style: GoogleFonts.poppins(fontSize: 13.sp),
                          ),
                          backgroundColor: const Color(0xFF007E68),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007E68),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26.r),
                      ),
                    ),
                    child: Text(
                      'I Accept Terms',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _bulletText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: Container(
            width: 5.w,
            height: 5.w,
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12.5.sp,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bulletRichText({
    required String prefix,
    required String boldText,
    required String suffix,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: Container(
            width: 5.w,
            height: 5.w,
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
              children: [
                TextSpan(text: prefix),
                TextSpan(
                  text: boldText,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(text: suffix),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
