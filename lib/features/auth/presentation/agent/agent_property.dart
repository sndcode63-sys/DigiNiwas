import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgentPropertiesScreen extends StatefulWidget {
  const AgentPropertiesScreen({super.key});

  @override
  State<AgentPropertiesScreen> createState() => _AgentPropertiesScreenState();
}

class _AgentPropertiesScreenState extends State<AgentPropertiesScreen> {
  String _selectedTab = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Header
                    Text(
                      'Partner Properties',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Manage verified seller listings',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 12.h),

                    // Top 4 Counter Cards
                    Row(
                      children: [
                        Expanded(child: _buildCounterCard('Assigned', '12', Icons.person_outline_rounded)),
                        SizedBox(width: 6.w),
                        Expanded(child: _buildCounterCard('Live', '8', Icons.check_circle_outline_rounded)),
                        SizedBox(width: 6.w),
                        Expanded(child: _buildCounterCard('Partner Review', '3', Icons.history_rounded, isHighlighted: true)),
                        SizedBox(width: 6.w),
                        Expanded(child: _buildCounterCard('Draft', '1', Icons.description_outlined)),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Search & Filter Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 42.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, size: 18.sp, color: Colors.grey),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search properties',
                                      hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          height: 42.h,
                          width: 42.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Center(
                            child: Icon(Icons.filter_list_rounded, size: 18.sp, color: Colors.black87),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005B48),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: Icon(Icons.add, size: 16.sp),
                          label: Text('Add for Seller', style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Filter Tabs (All, Live, Review, Draft)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterTab('All'),
                          SizedBox(width: 8.w),
                          _buildFilterTab('Live'),
                          SizedBox(width: 8.w),
                          _buildFilterTab('Review'),
                          SizedBox(width: 8.w),
                          _buildFilterTab('Draft'),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Property Card 1: Green Valley Residency (Live)
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&auto=format&fit=crop&q=80',
                                  width: 80.w,
                                  height: 80.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _statusBadge('Live', const Color(0xFF00C896), const Color(0xFFE2F8F5)),
                                        SizedBox(width: 6.w),
                                        _statusBadge('Verified', const Color(0xFF00838F), const Color(0xFFE2F3F5)),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Green Valley Residency',
                                      style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    SizedBox(height: 2.h),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, size: 11.sp, color: Colors.grey),
                                        SizedBox(width: 2.w),
                                        Text('Model Town, Ambala', style: TextStyle(fontSize: 10.5.sp, color: Colors.grey)),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '₹1.40 Cr • 3 BHK • 1,850 sq.ft',
                                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          // Owner Verified Container
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Owner: Aaryan Mehta', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700)),
                                Row(
                                  children: [
                                    Icon(Icons.verified, size: 13.sp, color: const Color(0xFF00C896)),
                                    SizedBox(width: 4.w),
                                    Text('Verified', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00C896))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          SizedBox(height: 12.h),

                          // Views, Saves, Buyer Interests Analytics Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _analyticItem(Icons.visibility_outlined, '420', 'VIEWS'),
                              _analyticItem(Icons.favorite_border_rounded, '36', 'SAVES'),
                              _analyticItem(Icons.group_outlined, '8', 'BUYER INTERESTS'),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // Availability confirmed today badge
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 12.sp, color: const Color(0xFF00C896)),
                                SizedBox(width: 5.w),
                                Text('Availability confirmed today', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF00C896))),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.settings_outlined, size: 14.sp, color: Colors.black87),
                                  label: Text('Manage Listing', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    padding: EdgeInsets.symmetric(vertical: 9.h),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.group_outlined, size: 14.sp, color: Colors.black87),
                                  label: Text('Buyer Matches', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    padding: EdgeInsets.symmetric(vertical: 9.h),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.bolt_rounded, size: 16.sp, color: Colors.white),
                              label: Text('Boost • 50 Credits', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005B48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Property Card 2: Sunset Villa (Partner Review)
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&auto=format&fit=crop&q=80',
                                  width: 80.w,
                                  height: 80.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _statusBadge('Partner Review', Colors.amber.shade800, Colors.amber.shade50),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Sunset Villa',
                                      style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    SizedBox(height: 2.h),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, size: 11.sp, color: Colors.grey),
                                        SizedBox(width: 2.w),
                                        Text('Ambala Cantt', style: TextStyle(fontSize: 10.5.sp, color: Colors.grey)),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Text('Neha Kapoor', style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                                        SizedBox(width: 8.w),
                                        Icon(Icons.verified, size: 12.sp, color: const Color(0xFF00C896)),
                                        SizedBox(width: 2.w),
                                        Text('Verified Owner', style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF00C896))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Documents 3 of 4', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                              Text('75%', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005B48))),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: 0.75,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF005B48)),
                              minHeight: 5.h,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade500.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 15.sp, color: Colors.orange.shade800),
                                SizedBox(width: 8.w),
                                Text('Ownership proof pending', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.orange.shade900)),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.folder_open_outlined, size: 14.sp, color: const Color(0xFF005B48)),
                                  label: Text('Review Documents', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005B48))),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: const Color(0xFF005B48).withOpacity(0.5)),
                                    backgroundColor: const Color(0xFFE8F8F9),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    padding: EdgeInsets.symmetric(vertical: 9.h),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.phone_outlined, size: 14.sp, color: Colors.black87),
                                  label: Text('Contact Seller', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    padding: EdgeInsets.symmetric(vertical: 9.h),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Property Tools Section
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.work_outline_rounded, size: 16.sp, color: const Color(0xFF00838F)),
                              SizedBox(width: 6.w),
                              Text('Property Tools', style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.description_outlined, size: 14.sp, color: const Color(0xFF173554)),
                                  label: Text('Generate Brochure', style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    padding: EdgeInsets.symmetric(vertical: 10.h),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.share_outlined, size: 14.sp, color: const Color(0xFF173554)),
                                  label: Text('Share Listing', style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                    padding: EdgeInsets.symmetric(vertical: 10.h),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F8F9),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, size: 13.sp, color: const Color(0xFF007A5E)),
                                SizedBox(width: 6.w),
                                Text('Any credit cost is shown before confirmation.', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF007A5E), fontWeight: FontWeight.w500)),
                              ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard(String title, String count, IconData icon, {bool isHighlighted = false}) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFFFFBE6) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isHighlighted ? Colors.amber.shade300 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15.sp, color: isHighlighted ? Colors.amber.shade800 : const Color(0xFF00838F)),
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

  Widget _statusBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(text, style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _analyticItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 13.sp, color: Colors.grey),
            SizedBox(width: 4.w),
            Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        SizedBox(height: 2.h),
        Text(label, style: TextStyle(fontSize: 8.5.sp, fontWeight: FontWeight.w600, color: Colors.grey)),
      ],
    );
  }
}