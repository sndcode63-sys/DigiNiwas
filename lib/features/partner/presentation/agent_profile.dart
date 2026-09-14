import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../features/partner/controllers/partner_home_controller.dart';
import '../../../features/partner/models/partner_models.dart';
import '../../../core/routes/app_routes.dart';

class CreditWalletScreen extends StatelessWidget {
  const CreditWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ensurePartnerHomeController();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Obx(() {
          final packs = c.creditPacks;
          final history = c.creditHistory;

          return Column(
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                color: Colors.white,
                child:                   Row(
                    children: [
                      Text(
                        'Credit Wallet',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (c.isTeamOwner.value)
                        IconButton(
                          tooltip: 'Team',
                          onPressed: () => Get.toNamed(AppRoutes.partnerTeam),
                          icon: const Icon(Icons.groups_outlined),
                        ),
                      IconButton(
                        tooltip: 'Change password',
                        onPressed: () =>
                            Get.toNamed(AppRoutes.partnerChangePassword),
                        icon: const Icon(Icons.lock_outline),
                      ),
                      IconButton(
                        tooltip: 'Logout',
                        onPressed: () => c.logout(),
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  ),
              ),
              Expanded(
                  child: RefreshIndicator(
                  onRefresh: () async {
                    await c.loadCredits();
                    await c.loadCreditPacks();
                    await c.loadPromotions();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 80.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              Text('Available Balance',
                                  style: TextStyle(
                                      fontSize: 11.sp, color: Colors.white70)),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Text(
                                    _fmt(c.creditBalance.value),
                                    style: TextStyle(
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text('Credits',
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70)),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                c.partnerName.value,
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Text('Top-up packs',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold)),
                        if (c.usingFallbackPacks.value)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h, bottom: 6.h),
                            child: Text(
                              'Showing demo packs (credit settings unavailable)',
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.orange.shade800),
                            ),
                          ),
                        SizedBox(height: 10.h),
                        if (c.purchaseLoading.value)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ...packs.map((pack) => Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: _packTile(c, pack),
                            )),
                        SizedBox(height: 16.h),
                        Text('Boost / promotions',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 10.h),
                        if (c.promotionsLoading.value)
                          const Center(child: CircularProgressIndicator())
                        else if (c.promotions.isEmpty)
                          Text('No promotion requests yet',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600))
                        else
                          ...c.promotions.take(10).map((p) {
                            final title = asString(p['promotionType']) ??
                                asString(p['status']) ??
                                'Promotion';
                            final status = asString(p['status']) ?? '';
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(title,
                                          style: TextStyle(
                                              fontSize: 12.5.sp,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Text(status,
                                        style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.grey.shade700)),
                                  ],
                                ),
                              ),
                            );
                          }),
                        if (c.boostDashboard.value != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            'Active boosts: ${asMap(c.boostDashboard.value!['summary'])['activeBoosts'] ?? 0}',
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey.shade700),
                          ),
                        ],
                        SizedBox(height: 16.h),
                        Text('Usage history',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 10.h),
                        if (c.creditsLoading.value)
                          const Center(child: CircularProgressIndicator())
                        else if (history.isEmpty)
                          Text('No credit history yet',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600))
                        else
                          ...history.take(20).map((tx) => Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: _historyTile(tx),
                              )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _packTile(PartnerHomeController c, CreditPack pack) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pack.label,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.bold)),
                Text(
                  '${pack.credits} credits • ₹${pack.priceInr}',
                  style:
                      TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: c.purchaseLoading.value
                ? null
                : () => c.purchasePack(pack),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005B48),
              foregroundColor: Colors.white,
            ),
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(Map<String, dynamic> tx) {
    final title = asString(tx['type']) ??
        asString(tx['title']) ??
        asString(tx['description']) ??
        'Credit event';
    final amount = asInt(tx['credits']) ??
        asInt(tx['amount']) ??
        asInt(tx['quantity']);
    final created = asString(tx['createdAt']) ??
        asString(tx['date']) ??
        '';

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_outlined,
              color: const Color(0xFF00838F), size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 12.5.sp, fontWeight: FontWeight.w600)),
                if (created.isNotEmpty)
                  Text(created,
                      style: TextStyle(
                          fontSize: 10.sp, color: Colors.grey.shade600)),
              ],
            ),
          ),
          if (amount != null)
            Text(
              amount >= 0 ? '+$amount' : '$amount',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: amount >= 0
                    ? const Color(0xFF00A87A)
                    : Colors.red.shade700,
              ),
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
