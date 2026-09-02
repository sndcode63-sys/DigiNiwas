import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CreditWalletScreen extends StatefulWidget {
  const CreditWalletScreen({super.key});

  @override
  State<CreditWalletScreen> createState() => _CreditWalletScreenState();
}

class _CreditWalletScreenState extends State<CreditWalletScreen> {
  int _selectedPackIndex = 2; // Default to 3,000 Credits pack

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(Icons.arrow_back, size: 20.sp, color: Colors.black87),
                      ),
                      SizedBox(width: 14.w),
                      Text(
                        'Credit Wallet',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  Icon(Icons.swap_horiz_rounded, size: 22.sp, color: Colors.black87),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gradient Balance Banner Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C896), Color(0xFF00838F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available Balance', style: TextStyle(fontSize: 11.sp, color: Colors.white70)),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Text('3,250', style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                              SizedBox(width: 6.w),
                              Text('Credits', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white70)),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text('₹1 = 1 DigiNiwas Credit', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF00838F),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    padding: EdgeInsets.symmetric(vertical: 10.h),
                                  ),
                                  child: Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    padding: EdgeInsets.symmetric(vertical: 10.h),
                                  ),
                                  child: Text('View Usage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // What Credits Are Used For Container
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('What Credits Are Used For', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                          SizedBox(height: 12.h),
                          _buildUsageRow(Icons.person_outline_rounded, 'Unlock verified buyer contact', '25 Credits', const Color(0xFF00C896)),
                          Divider(height: 16.h, color: Colors.grey.shade100),
                          _buildUsageRow(Icons.bolt_rounded, 'Boost a listing', '50 Credits', const Color(0xFF00838F)),
                          Divider(height: 16.h, color: Colors.grey.shade100),
                          _buildUsageRow(Icons.work_outline_rounded, 'Other optional tools', 'Cost shown before use', Colors.grey.shade700),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Top Up Credits Packs Header & Options
                    Text('Top Up Credits', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(child: _buildTopUpCard(0, '500', '₹500', 'Credits', false)),
                        SizedBox(width: 8.w),
                        Expanded(child: _buildTopUpCard(1, '1,000', '₹1,000', 'Credits', false)),
                        SizedBox(width: 8.w),
                        Expanded(child: _buildTopUpCard(2, '3,000', '₹3,000', '+ 100 Bonus\nCredits', true)),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Recent Activity Container
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recent Activity', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                          SizedBox(height: 12.h),
                          _buildActivityRow(Icons.person_outline_rounded, 'Lead contact unlocked', '-25 Credits', 'Today', Colors.red, const Color(0xFFFFF0F0)),
                          Divider(height: 16.h, color: Colors.grey.shade100),
                          _buildActivityRow(Icons.bolt_rounded, 'Listing boost', '-50 Credits', 'Yesterday', Colors.red, const Color(0xFFFFF0F0)),
                          Divider(height: 16.h, color: Colors.grey.shade100),
                          _buildActivityRow(Icons.arrow_upward_rounded, 'Credit top-up', '+1,000 Credits', '2 days ago', const Color(0xFF00C896), const Color(0xFFE2F8F5)),
                          Divider(height: 16.h, color: Colors.grey.shade100),
                          _buildActivityRow(Icons.check_circle_outline_rounded, 'Invalid lead refund', '+25 Credits', '3 days ago', const Color(0xFF00C896), const Color(0xFFE2F8F5)),
                          SizedBox(height: 12.h),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('View All Transactions', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005B48))),
                                SizedBox(width: 4.w),
                                Icon(Icons.chevron_right, size: 16.sp, color: const Color(0xFF005B48)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Credit Protection Card
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F8F5).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFF00C896).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF005B48),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(Icons.verified_user_outlined, color: Colors.white, size: 20.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Credit Protection', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                                SizedBox(height: 2.h),
                                Text('Duplicate or invalid lead reports can be reviewed for credit return.', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700, height: 1.2)),
                                SizedBox(height: 6.h),
                                Text('Read Rules', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005B48))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // No DigiNiwas Commission Card
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(Icons.account_balance_wallet_outlined, color: Colors.blue.shade700, size: 20.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('No DigiNiwas Commission', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                                SizedBox(height: 2.h),
                                Text('DigiNiwas does not deduct commission from your property deals.', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700, height: 1.2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Bottom Top Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005B48),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          elevation: 0,
                        ),
                        icon: Icon(Icons.account_balance_wallet_rounded, size: 18.sp),
                        label: Text('Top Up Credits', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageRow(IconData icon, String title, String cost, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 16.sp, color: iconColor),
            ),
            SizedBox(width: 10.w),
            Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.black87)),
          ],
        ),
        Text(cost, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: iconColor)),
      ],
    );
  }

  Widget _buildTopUpCard(int index, String credits, String price, String subtitle, bool isBestValue) {
    final bool isSelected = _selectedPackIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF005B48) : Colors.grey.shade200,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: const Color(0xFF005B48).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            if (isBestValue)
              Container(
                margin: EdgeInsets.only(bottom: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF005B48),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text('Best Value', style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              )
            else
              SizedBox(height: 14.h),
            Icon(Icons.stars_rounded, size: 20.sp, color: const Color(0xFF00C896)),
            SizedBox(height: 6.h),
            Text(credits, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text('Credits', style: TextStyle(fontSize: 9.5.sp, color: Colors.grey)),
            SizedBox(height: 4.h),
            Text(subtitle, textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: 8.5.sp, color: const Color(0xFF00838F), height: 1.1)),
            SizedBox(height: 8.h),
            Text(price, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () => setState(() => _selectedPackIndex = index),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? const Color(0xFF005B48) : Colors.white,
                foregroundColor: isSelected ? Colors.white : const Color(0xFF005B48),
                side: BorderSide(color: const Color(0xFF005B48)),
                elevation: 0,
                minimumSize: Size(double.infinity, 30.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                padding: EdgeInsets.zero,
              ),
              child: Text('Select', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(IconData icon, String title, String amount, String time, Color amountColor, Color iconBg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 16.sp, color: amountColor),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                SizedBox(height: 1.h),
                Text(time, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
              ],
            ),
          ],
        ),
        Text(amount, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: amountColor)),
      ],
    );
  }
}