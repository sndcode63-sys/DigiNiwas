import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/controller/partner_home_controller.dart';
import '../../../../core/models/partner_models.dart';
import '../../../../core/routes/app_routes.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ensurePartnerHomeController();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Obx(() {
          final visits = c.filteredVisits;
          final unassigned = c.unassignedProperties;
          final vs = c.visitsSummary.value;

          return RefreshIndicator(
            onRefresh: c.loadTasks,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seller Assignments',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Verify properties before they go live',
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _counter(
                          'New Requests',
                          '${unassigned.length}',
                          Icons.description_outlined,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _counter(
                          'Visits Scheduled',
                          '${vs?.upcoming ?? visits.length}',
                          Icons.calendar_today_outlined,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _counter(
                          'Pending Approval',
                          '${vs?.pendingApproval ?? 0}',
                          Icons.folder_open_rounded,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final tab in [
                          'New',
                          'In Progress',
                          'Verified',
                          'Completed',
                        ]) ...[
                          _tab(c, tab),
                          SizedBox(width: 8.w),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Get.toNamed(AppRoutes.agentAddProperty),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Property'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005B48),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  if (c.tasksLoading.value)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    if (c.tasksTab.value == 'New') ...[
                      Text('Unassigned properties',
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      if (unassigned.isEmpty)
                        _empty('No new seller assignments')
                      else
                        ...unassigned.map((p) => Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: _propertyTaskCard(p),
                            )),
                    ],
                    Text('Visits',
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    if (visits.isEmpty)
                      _empty('No visits in this tab')
                    else
                      ...visits.map((v) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: _visitCard(c, v),
                          )),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _empty(String msg) => Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: Text(msg,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
        ),
      );

  Widget _counter(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18.sp, color: const Color(0xFF00838F)),
          SizedBox(height: 6.h),
          Text(value,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _tab(PartnerHomeController c, String tab) {
    final selected = c.tasksTab.value == tab;
    return GestureDetector(
      onTap: () => c.tasksTab.value = tab,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF005B48) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? const Color(0xFF005B48) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          tab,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _propertyTaskCard(PartnerProperty p) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F3F5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.home_work_outlined,
                    color: const Color(0xFF00838F), size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title,
                        style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    Text(
                      p.city.isEmpty ? p.status : '${p.city} • ${p.status}',
                      style: TextStyle(
                          fontSize: 11.sp, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.toNamed(
                AppRoutes.agentAddProperty,
                arguments: {
                  'assignedPropertyId': p.id,
                  'title': p.title,
                  'city': p.city,
                },
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005B48),
                foregroundColor: Colors.white,
              ),
              child: const Text('List property'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitCard(PartnerHomeController c, PartnerVisit v) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(v.propertyTitle,
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F8F5),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(v.status,
                    style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00A87A))),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text('Buyer: ${v.buyerName}',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700)),
          if (v.scheduledAt.isNotEmpty)
            Text(v.scheduledAt,
                style:
                    TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      c.updateVisitStatus(v, 'Completed'),
                  child: const Text('Complete'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      c.updateVisitStatus(v, 'Follow_Up'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005B48),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Follow-up'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
