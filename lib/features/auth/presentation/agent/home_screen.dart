import 'package:diginiwas/features/auth/presentation/agent/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'agent_profile.dart'; // Make sure this points to your CreditWalletScreen/Profile screen
import 'agent_property.dart';
import 'aget_lead_screen.dart';

class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top App Bar matching your layout reference
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: const Color(0xFFF4F6F8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F3F5),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Icon(Icons.grid_view_rounded, size: 18.sp, color: const Color(0xFF00838F)),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 22.sp, color: Colors.black87),
                      SizedBox(width: 14.w),
                      CircleAvatar(
                        radius: 15.r,
                        backgroundColor: const Color(0xFFE2F3F5),
                        child: Text(
                          'RS',
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00838F)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Dynamic Body Content based on Bottom Navigation Index
            Expanded(
              child: _buildCurrentTabContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(26.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(icon: Icons.home_rounded, label: 'Home', index: 0),
              _navItem(icon: Icons.group_outlined, label: 'Leads', index: 1),
              _navItem(icon: Icons.apartment_rounded, label: 'Properties', index: 2),
              _navItem(icon: Icons.task_alt_rounded, label: 'Tasks', index: 3),
              _navItem(icon: Icons.person_outline_rounded, label: 'Profile', index: 4),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // DYNAMIC TAB BODY SWITCHER
  // ---------------------------------------------------------------------
  Widget _buildCurrentTabContent() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const AgentLeadsScreen();
      case 2:
        return const AgentPropertiesScreen();
      case 3:
        return const TaskScreen();
      case 4:
        return const CreditWalletScreen(); // Profile / Wallet screen
      default:
        return _buildHomeTab();
    }
  }

  // ---------------------------------------------------------------------
  // HOME TAB CONTENT
  // ---------------------------------------------------------------------
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 80.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, Rahul',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F8F5),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified, size: 14.sp, color: const Color(0xFF00C896)),
                          SizedBox(width: 4.w),
                          Text(
                            'Verified DigiNiwas Partner',
                            style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00A87A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'You have 3 seller requests and 4 follow-ups today.',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C896), Color(0xFF00838F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Credit Balance', style: TextStyle(fontSize: 11.sp, color: Colors.white70)),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Text('3,250', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(width: 6.w),
                            Text('Credits', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 24.sp),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text('₹1 = 1 Credit', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                SizedBox(height: 14.h),
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
          SizedBox(height: 12.h),

          // Request Stats Grid (2x2 properly expanded to prevent right-side overflow)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F8F5),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.group_add_rounded, size: 16.sp, color: const Color(0xFF00C896)),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'New Seller\nRequests',
                          style: TextStyle(fontSize: 9.5.sp, color: Colors.grey.shade700, height: 1.1),
                        ),
                      ),
                      Text('3', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F3F5),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.lock_open_rounded, size: 16.sp, color: const Color(0xFF00838F)),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Unlocked Buyer\nLeads',
                          style: TextStyle(fontSize: 9.5.sp, color: Colors.grey.shade700, height: 1.1),
                        ),
                      ),
                      Text('8', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F8F9),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.directions_walk_rounded, size: 16.sp, color: const Color(0xFF00C896)),
                          ),
                          SizedBox(width: 8.w),
                          Text('Visits Today', style: TextStyle(fontSize: 10.5.sp, color: Colors.grey.shade700)),
                        ],
                      ),
                      Text('3', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F3F5),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.local_offer_outlined, size: 16.sp, color: const Color(0xFF00838F)),
                          ),
                          SizedBox(width: 8.w),
                          Text('Offers Pending', style: TextStyle(fontSize: 10.5.sp, color: Colors.grey.shade700)),
                        ],
                      ),
                      Text('2', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Niwas AI Daily Brief Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF173554),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: const Color(0xFF00C896), size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Niwas AI Daily Brief',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  '2 properties need document checks and 3 unlocked leads need follow-up.',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5.sp, height: 1.3),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C896),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          elevation: 0,
                        ),
                        child: Text('View Tasks', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_outlined, size: 14.sp, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text('Ask Niwas AI', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Today's Schedule Section
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.black87)),
                    Row(
                      children: [
                        Text('View Calendar', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00838F))),
                        Icon(Icons.chevron_right, size: 16.sp, color: const Color(0xFF00838F)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildScheduleItem('10:00 AM', 'Seller verification visit', 'Model Town', const Color(0xFF00C896)),
                Divider(height: 16.h, color: Colors.grey.shade100),
                _buildScheduleItem('12:30 PM', 'Buyer property visit', 'Ambala Cantt', const Color(0xFF29B6F6)),
                Divider(height: 16.h, color: Colors.grey.shade100),
                _buildScheduleItem('4:00 PM', 'Offer discussion', 'Green Valley Residency', Colors.orange),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Partner Activity This Month Card (with Chevron Arrow Shape Design)
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
                Text('Partner Activity This Month', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.black87)),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _buildChevronStep(
                      icon: Icons.person_outline_rounded,
                      count: '12',
                      label: 'Seller\nAssignments',
                      color: const Color(0xFF00C896),
                      bgColor: const Color(0xFFE8F8F9),
                      stepIndex: 0,
                    ),
                    _buildChevronStep(
                      icon: Icons.home_outlined,
                      count: '8',
                      label: 'Properties\nLive',
                      color: const Color(0xFF173554),
                      bgColor: const Color(0xFFEAF2F8),
                      stepIndex: 1,
                    ),
                    _buildChevronStep(
                      icon: Icons.visibility_outlined,
                      count: '24',
                      label: 'Buyer\nInterests',
                      color: const Color(0xFF00C896),
                      bgColor: const Color(0xFFE8F8F9),
                      stepIndex: 2,
                    ),
                    _buildChevronStep(
                      icon: Icons.verified_user_outlined,
                      count: '6',
                      label: 'Visits\nCompleted',
                      color: Colors.orange,
                      bgColor: const Color(0xFFFFF3E0),
                      stepIndex: 3,
                      isLast: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Bottom Usage Summary Container
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F8F5),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.credit_card_rounded, size: 18.sp, color: const Color(0xFF00C896)),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('75 Credits used this week', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                        SizedBox(height: 2.h),
                        Text('1 lead unlocked · 1 listing boosted', style: TextStyle(fontSize: 10.5.sp, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                Icon(Icons.trending_up_rounded, color: Colors.grey.shade600, size: 22.sp),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    const activeColor = Color(0xFF00838F);
    const inactiveColor = Color(0xFF7D8C99);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? activeColor : inactiveColor, size: 20.sp),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String time, String title, String location, Color dotColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 65.w,
          child: Text(time, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.h, right: 10.w),
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 11.sp, color: Colors.grey),
                  SizedBox(width: 2.w),
                  Text(location, style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChevronStep({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    required Color bgColor,
    required int stepIndex,
    bool isLast = false,
  }) {
    return Expanded(
      child: CustomPaint(
        painter: _ChevronPainter(bgColor: bgColor),
        child: Container(
          height: 74.h,
          padding: EdgeInsets.only(
            left: stepIndex == 0 ? 4.w : 8.w,
            right: isLast ? 4.w : 8.w,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13.sp, color: color),
              SizedBox(height: 2.h),
              Text(
                count,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 7.5.sp,
                  color: Colors.grey.shade700,
                  height: 1.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the chevron arrow shape
class _ChevronPainter extends CustomPainter {
  final Color bgColor;

  _ChevronPainter({required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    const double arrowWidth = 7.0;

    path.moveTo(0, 0);
    path.lineTo(w - arrowWidth, 0);
    path.lineTo(w, h / 2);
    path.lineTo(w - arrowWidth, h);
    path.lineTo(0, h);
    path.lineTo(arrowWidth, h / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}