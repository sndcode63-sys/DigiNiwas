import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/controller/partner_home_controller.dart';
import '../../../../core/models/partner_models.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_image.dart';

class AgentPropertiesScreen extends StatelessWidget {
  const AgentPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ensurePartnerHomeController();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.agentAddProperty),
        backgroundColor: const Color(0xFF005B48),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add property'),
      ),
      body: SafeArea(
        child: Obx(() {
          final list = c.filteredProperties;
          return RefreshIndicator(
            onRefresh: c.loadProperties,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding:
                        EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Partner Properties',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Manage verified seller listings',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: _counter(
                                  'Assigned', '${c.propAssignedCount}',
                                  Icons.person_outline_rounded),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: _counter('Live', '${c.propLiveCount}',
                                  Icons.check_circle_outline_rounded),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: _counter(
                                  'Partner Review',
                                  '${c.propReviewCount}',
                                  Icons.history_rounded,
                                  highlighted: true),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: _counter('Draft', '${c.propDraftCount}',
                                  Icons.description_outlined),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 42.h,
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                      color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.search,
                                        size: 18.sp, color: Colors.grey),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: TextField(
                                        onChanged: (v) =>
                                            c.propertySearch.value = v,
                                        decoration: InputDecoration(
                                          hintText: 'Search properties',
                                          hintStyle: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey),
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                'All',
                                'Assigned',
                                'Live',
                                'Partner Review',
                                'Draft',
                              ]) ...[
                                _tab(c, tab),
                                SizedBox(width: 8.w),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 14.h),
                        if (c.propertiesLoading.value)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child:
                                Center(child: CircularProgressIndicator()),
                          )
                        else if (list.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Center(
                              child: Text(
                                'No properties found',
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade600),
                              ),
                            ),
                          )
                        else
                          ...list.map((p) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: _propertyCard(c, p),
                              )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _counter(String label, String value, IconData icon,
      {bool highlighted = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFE2F8F5) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: highlighted
              ? const Color(0xFF00C896)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 15.sp, color: const Color(0xFF00838F)),
          SizedBox(height: 4.h),
          Text(value,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 8.5.sp, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _tab(PartnerHomeController c, String tab) {
    final selected = c.propertiesTab.value == tab;
    return GestureDetector(
      onTap: () => c.propertiesTab.value = tab,
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

  Widget _propertyCard(PartnerHomeController c, PartnerProperty p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.imageUrl != null)
            SizedBox(
              height: 140.h,
              width: double.infinity,
              child: ImageCase(
                url: p.imageUrl,
                width: double.infinity,
                height: 140.h,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 120.h,
              color: const Color(0xFFE2F3F5),
              child: Center(
                child: Icon(Icons.apartment,
                    size: 40.sp, color: const Color(0xFF00838F)),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F8F5),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        p.status,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00A87A),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  p.address.isEmpty ? p.city : p.address,
                  style:
                      TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                if (p.priceLabel.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    p.priceLabel,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: p.isBoosted
                            ? () => c.unboostProperty(p)
                            : () => c.boostProperty(p),
                        icon: Icon(Icons.rocket_launch_outlined, size: 16.sp),
                        label: Text(p.isBoosted ? 'Unboost' : 'Boost'),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'live') {
                          c.updatePropertyStatus(p, 'Live');
                        } else if (v == 'delete') {
                          c.deleteProperty(p);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'live', child: Text('Set Live')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
