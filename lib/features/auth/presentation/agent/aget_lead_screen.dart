import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/controller/partner_home_controller.dart';
import '../../../../core/models/partner_models.dart';

class AgentLeadsScreen extends StatelessWidget {
  const AgentLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ensurePartnerHomeController();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Obx(() {
          final dash = c.leadsDashboard.value;
          final leads = c.filteredLeads;

          return RefreshIndicator(
            onRefresh: c.loadLeads,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buyer Leads',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Unlock verified contacts and manage follow-ups',
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 12.h),
                  _creditBanner(c),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _counter(
                          'Available',
                          '${dash?.available ?? leads.where((l) => !l.isUnlocked).length}',
                          Icons.person_outline_rounded,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: _counter(
                          'Unlocked',
                          '${dash?.unlocked ?? leads.where((l) => l.isUnlocked).length}',
                          Icons.lock_open_rounded,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: _counter(
                          'Follow-up',
                          '${dash?.followUp ?? 0}',
                          Icons.access_time_rounded,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: _counter(
                          'Visit Planned',
                          '${dash?.visitPlanned ?? 0}',
                          Icons.calendar_today_rounded,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final tab in [
                          'Available',
                          'Unlocked',
                          'Follow-ups',
                          'Visit Planned',
                        ]) ...[
                          _filterTab(c, tab),
                          SizedBox(width: 8.w),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  if (c.leadsLoading.value)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (leads.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Center(
                        child: Text(
                          'No leads in this tab',
                          style: TextStyle(
                              fontSize: 13.sp, color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  else
                    ...leads.map((lead) => Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: _leadCard(c, lead),
                        )),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _creditBanner(PartnerHomeController c) {
    return Container(
      width: double.infinity,
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
              color: const Color(0xFFE2F8F5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.stars_rounded,
                size: 22.sp, color: const Color(0xFF00C896)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _fmt(c.creditBalance.value),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text('Credits',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700)),
                  ],
                ),
                Text(
                  'Unlock verified contact: 25 Credits',
                  style:
                      TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: c.goToProfileTab,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005B48),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('Top Up',
                style:
                    TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _counter(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16.sp, color: const Color(0xFF00838F)),
          SizedBox(height: 4.h),
          Text(value,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _filterTab(PartnerHomeController c, String tab) {
    final selected = c.leadsTab.value == tab ||
        (tab == 'Follow-ups' && c.leadsTab.value == 'Follow-up');
    return GestureDetector(
      onTap: () => c.leadsTab.value = tab == 'Follow-ups' ? 'Follow-up' : tab,
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

  Widget _leadCard(PartnerHomeController c, PartnerLead lead) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: const Color(0xFFE2F3F5),
                child: Icon(Icons.person,
                    color: const Color(0xFF00838F), size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lead.buyerName,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: lead.isUnlocked
                                ? const Color(0xFFE2F8F5)
                                : const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            lead.isUnlocked ? 'Unlocked' : lead.status,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.bold,
                              color: lead.isUnlocked
                                  ? const Color(0xFF00C896)
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      lead.location.isEmpty
                          ? lead.propertyTitle
                          : '${lead.propertyTitle} • ${lead.location}',
                      style: TextStyle(
                          fontSize: 11.5.sp, color: Colors.grey.shade700),
                    ),
                    if (lead.budget.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        lead.budget,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                    if (lead.isUnlocked && lead.phone.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        lead.phone,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF005B48),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (!lead.isUnlocked)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: c.unlockLoading.value
                    ? null
                    : () => c.unlockLead(lead),
                icon: Icon(Icons.lock_open_rounded,
                    size: 16.sp, color: Colors.white),
                label: Text(
                  'Unlock Contact • ${lead.unlockCost} Credits',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005B48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  elevation: 0,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        c.setLeadStatus(lead, 'Follow_Up'),
                    child: const Text('Mark Follow-up'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        c.setLeadStatus(lead, 'Visit_Planned'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005B48),
                    ),
                    child: const Text('Plan Visit'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}
