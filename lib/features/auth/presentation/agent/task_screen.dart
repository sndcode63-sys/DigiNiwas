import 'package:diginiwas/features/auth/presentation/agent/property_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String _selectedTab = 'In Progress';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [

            // 2. Fully Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Header
                    Text(
                      'Seller Assignments',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Verify properties before they go live',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 12.h),

                    // Top 3 Counter Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildCounterCard('New Requests', '3', Icons.description_outlined),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildCounterCard('Visits Scheduled', '2', Icons.calendar_today_outlined),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildCounterCard('Awaiting Docs', '4', Icons.folder_open_rounded),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Filter Tabs (New, In Progress, Verified, Completed)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterTab('New'),
                          SizedBox(width: 8.w),
                          _buildFilterTab('In Progress'),
                          SizedBox(width: 8.w),
                          _buildFilterTab('Verified'),
                          SizedBox(width: 8.w),
                          _buildFilterTab('Completed'),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Main Assignment Task Card (Green Valley Residency)
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade200),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2F8F5),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 11.sp, color: const Color(0xFF00C896)),
                                    SizedBox(width: 5.w),
                                    Text(
                                      'Site Visit Due',
                                      style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00A87A)),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.more_vert_rounded, color: Colors.grey.shade600, size: 18.sp),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&auto=format&fit=crop&q=80',
                                  width: 65.w,
                                  height: 65.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 65.w,
                                    height: 65.w,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.apartment_rounded, color: Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Green Valley Residency',
                                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    SizedBox(height: 2.h),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, size: 11.sp, color: Colors.grey),
                                        SizedBox(width: 2.w),
                                        Text('Model Town, Ambala', style: TextStyle(fontSize: 10.5.sp, color: Colors.grey)),
                                      ],
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      '3 BHK • 1,850 sq.ft • ₹1.40 Cr',
                                      style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 8.r,
                                          backgroundColor: const Color(0xFFE2F3F5),
                                          child: Text('AM', style: TextStyle(fontSize: 7.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00838F))),
                                        ),
                                        SizedBox(width: 5.w),
                                        Text('Aaryan Mehta', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                                        SizedBox(width: 8.w),
                                        Container(
                                          width: 3.w,
                                          height: 3.w,
                                          decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text('Verified Owner', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: const Color(0xFF00C896))),
                                        SizedBox(width: 3.w),
                                        Icon(Icons.verified, size: 12.sp, color: const Color(0xFF00C896)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          SizedBox(height: 14.h),

                          // Milestones Progress List
                          _buildMilestoneItem('Seller contacted', '5 Aug • 10:15 AM', isDone: true),
                          _buildMilestoneItem('Documents checked', '6 Aug • 02:30 PM', isDone: true),
                          _buildMilestoneItem('Property visit', '8 Aug • 11:00 AM', isCurrent: true, badgeText: '8 Aug • 11:00 AM'),
                          _buildMilestoneItem('Publish listing', 'Pending', isPending: true),
                          SizedBox(height: 14.h),

                          // Bottom Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.checklist_rounded, size: 14.sp, color: const Color(0xFF173554)),
                                      SizedBox(width: 3.w),
                                      Text('Checklist', style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: const Color(0xFF00C896).withOpacity(0.5)),
                                    backgroundColor: const Color(0xFFE8F8F9),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.phone_outlined, size: 14.sp, color: const Color(0xFF00C896)),
                                      SizedBox(width: 3.w),
                                      Text('Call Seller', style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00C896))),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF007A5E),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.navigation_rounded, size: 14.sp, color: Colors.white),
                                      SizedBox(width: 3.w),
                                      Text('Navigate', style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.white)),
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

                    // Niwas AI Suggested Action Card
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF005B48),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: const Color(0xFF4EE1A0), size: 15.sp),
                              SizedBox(width: 6.w),
                              Text('Niwas AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Text('Suggested next action', style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                          SizedBox(height: 8.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  'Confirm the Green Valley visit and request one missing exterior photo.',
                                  style: TextStyle(color: Colors.white, fontSize: 11.5.sp, height: 1.3),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F2544),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                  elevation: 0,
                                ),
                                child: Text('Complete', style: TextStyle(color: Colors.white, fontSize: 10.5.sp, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Add Property for Seller Button aligned strictly to the RIGHT
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push(AppRoutes.agentAddProperty);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005B48),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                          elevation: 3,
                        ),
                        label: Text('Add Property for Seller', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        icon: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(Icons.add, size: 14.sp, color: const Color(0xFF005B48)),
                        ),
                      ),
                    ),                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
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
          Icon(icon, size: 16.sp, color: const Color(0xFF00838F)),
          SizedBox(height: 6.h),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9.5.sp, color: Colors.grey.shade600)),
          SizedBox(height: 2.h),
          Text(count, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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

  Widget _buildMilestoneItem(String title, String subtitle, {bool isDone = false, bool isCurrent = false, bool isPending = false, String? badgeText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFF00C896)
                    : isCurrent
                    ? Colors.white
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone
                      ? const Color(0xFF00C896)
                      : isCurrent
                      ? const Color(0xFF00C896)
                      : Colors.grey.shade400,
                  width: isCurrent ? 4.w : 2.w,
                ),
              ),
              child: isDone ? Icon(Icons.check, size: 10.sp, color: Colors.white) : null,
            ),
            if (!isPending)
              Container(
                width: 2.w,
                height: 20.h,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isPending ? Colors.grey : Colors.black87,
                    ),
                  ),
                  if (isPending)
                    Text(subtitle, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                ],
              ),
              if (badgeText != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005B48),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(badgeText, style: TextStyle(fontSize: 9.5.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                )
              else if (!isPending)
                Text(subtitle, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}