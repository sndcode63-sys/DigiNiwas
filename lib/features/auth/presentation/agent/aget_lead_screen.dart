import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgentLeadsScreen extends StatefulWidget {
  const AgentLeadsScreen({super.key});

  @override
  State<AgentLeadsScreen> createState() => _AgentLeadsScreenState();
}

class _AgentLeadsScreenState extends State<AgentLeadsScreen> {
  String _selectedTab = 'Available';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Header
              Text(
                'Buyer Leads',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 2.h),
              Text(
                'Unlock verified contacts and manage follow-ups',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 12.h),

              // Credit Balance Banner Card (Overflow Fixed using Expanded)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F8F5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.stars_rounded, size: 22.sp, color: const Color(0xFF00C896)),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('3,250', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                              SizedBox(width: 4.w),
                              Text('Credits', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Unlock verified contact: 25 Credits',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005B48),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('Top Up', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // Top 4 Counter Cards (Available, Unlocked, Follow-up, Visit Planned)
              Row(
                children: [
                  Expanded(child: _buildCounterCard('Available', '12', Icons.person_outline_rounded)),
                  SizedBox(width: 6.w),
                  Expanded(child: _buildCounterCard('Unlocked', '8', Icons.lock_open_rounded)),
                  SizedBox(width: 6.w),
                  Expanded(child: _buildCounterCard('Follow-up', '5', Icons.access_time_rounded)),
                  SizedBox(width: 6.w),
                  Expanded(child: _buildCounterCard('Visit Planned', '3', Icons.calendar_today_rounded)),
                ],
              ),
              SizedBox(height: 14.h),

              // Filter Tabs (Available, Unlocked, Follow-ups)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterTab('Available'),
                    SizedBox(width: 8.w),
                    _buildFilterTab('Unlocked'),
                    SizedBox(width: 8.w),
                    _buildFilterTab('Follow-ups'),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Lead Card 1: Buyer in Ambala (High Intent)
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: const Color(0xFFE2F3F5),
                          child: Icon(Icons.person, color: const Color(0xFF00838F), size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Buyer in Ambala',
                                    style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2F8F5),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text('High Intent', style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00C896))),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Looking for 3 BHK • Model Town',
                                style: TextStyle(fontSize: 11.5.sp, color: Colors.grey.shade700),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Budget ₹1.20–₹1.50 Cr',
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Intent Tag Chips wrapped safely
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
                        _tagBadge('Budget provided', Icons.check_circle_outline_rounded),
                        _tagBadge('Requested callback', Icons.check_circle_outline_rounded),
                        _tagBadge('Mobile verified', Icons.check_circle_outline_rounded),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    SizedBox(height: 10.h),

                    // Property Match
                    Row(
                      children: [
                        Icon(Icons.apartment_rounded, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 6.w),
                        Text('Property Match: ', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                        Expanded(
                          child: Text(
                            'Green Valley Residency',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005B48)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Unlock Contact Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.lock_open_rounded, size: 16.sp, color: Colors.white),
                        label: Text('Unlock Contact • 25 Credits', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005B48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: Text('Save for Later', style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005B48))),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Lead Card 2: Buyer in Ambala Cantt (New)
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: const Color(0xFFE2F3F5),
                          child: Icon(Icons.person, color: const Color(0xFF00838F), size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Buyer in Ambala Cantt',
                                    style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text('New', style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '2 BHK • Ready to Move',
                                style: TextStyle(fontSize: 11.5.sp, color: Colors.grey.shade700),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Budget up to ₹80 L',
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.lock_open_rounded, size: 16.sp, color: Colors.white),
                        label: Text('Unlock Contact • 25 Credits', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005B48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: Text('Save for Later', style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005B48))),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Recently Unlocked Header & Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recently Unlocked', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text('View All', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005B48))),
                ],
              ),
              SizedBox(height: 10.h),

              // Unlocked Lead Card: Priya Sharma
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: const Color(0xFFE2F3F5),
                          child: Icon(Icons.person, color: const Color(0xFF00838F), size: 22.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Priya Sharma',
                                    style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2F8F5),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.verified, size: 11.sp, color: const Color(0xFF00C896)),
                                        SizedBox(width: 3.w),
                                        Text('Contact Unlocked', style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00C896))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Interested in Sky Lofts',
                                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Text('Contacted', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                              SizedBox(width: 4.w),
                              Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp, color: Colors.black87),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    SizedBox(height: 12.h),

                    // Action Buttons (Call, WhatsApp, Schedule Visit)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.phone_outlined, size: 14.sp, color: const Color(0xFF005B48)),
                            label: Text('Call', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005B48))),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.chat_bubble_outline_rounded, size: 14.sp, color: const Color(0xFF00C896)),
                            label: Text('WhatsApp', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00C896))),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.calendar_today_outlined, size: 14.sp, color: const Color(0xFF173554)),
                            label: Text('Schedule\nVisit', textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Credit Rules Footer Info Box
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 18.sp, color: Colors.blue.shade700),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report duplicate or invalid contact within 24 hours. Eligible credits are returned after review.',
                            style: TextStyle(fontSize: 11.sp, color: Colors.blue.shade900, height: 1.3),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'View Credit Rules',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard(String title, String count, IconData icon) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15.sp, color: const Color(0xFF00838F)),
          SizedBox(height: 6.h),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade600)),
          SizedBox(height: 2.h),
          Text(count, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF005B48) : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _tagBadge(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: const Color(0xFF005B48)),
          SizedBox(width: 4.w),
          Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500, color: const Color(0xFF334155))),
        ],
      ),
    );
  }
}