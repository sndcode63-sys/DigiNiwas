import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/buyer_home_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final BuyerHomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BuyerHomeController>()
        ? Get.find<BuyerHomeController>()
        : Get.put(BuyerHomeController());
    controller.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFF0F172A), size: 18.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            final unread = controller.unreadNotificationsCount.value;
            if (unread == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: () {
                controller.markAllNotificationsAsRead();
              },
              child: Text(
                'Mark read',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF007A5E),
                ),
              ),
            );
          }),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.notificationsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF007A5E)),
          );
        }

        final list = controller.notificationsList;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007A5E).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 48.sp,
                    color: const Color(0xFF007A5E),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'No Notifications Yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    'We will notify you about property updates, visits, price drops, and verified listings here.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () => controller.fetchNotifications(),
                  icon: Icon(Icons.refresh_rounded, size: 16.sp),
                  label: Text('Refresh', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A5E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          color: const Color(0xFF007A5E),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemCount: list.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final item = list[index];
              return _NotificationCard(
                notification: item is Map ? Map<String, dynamic>.from(item) : {'title': item.toString()},
                onTap: () {
                  if (item is Map && item['_id'] != null) {
                    controller.markNotificationAsRead(item['_id'].toString());
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = notification['title']?.toString() ?? 'Notification';
    final message = notification['message']?.toString() ??
        notification['body']?.toString() ??
        notification['description']?.toString() ??
        '';
    final time = notification['createdAt']?.toString() ?? notification['date']?.toString() ?? '';
    final isRead = notification['isRead'] == true || notification['read'] == true;
    final type = (notification['type']?.toString() ?? '').toLowerCase();

    IconData iconData = Icons.notifications_rounded;
    Color iconColor = const Color(0xFF007A5E);
    Color iconBg = const Color(0xFF007A5E).withValues(alpha: 0.1);

    if (type.contains('property') || type.contains('listing')) {
      iconData = Icons.home_work_rounded;
      iconColor = const Color(0xFF3B82F6);
      iconBg = const Color(0xFF3B82F6).withValues(alpha: 0.1);
    } else if (type.contains('visit') || type.contains('schedule')) {
      iconData = Icons.calendar_month_rounded;
      iconColor = const Color(0xFF8B5CF6);
      iconBg = const Color(0xFF8B5CF6).withValues(alpha: 0.1);
    } else if (type.contains('offer') || type.contains('price') || type.contains('discount')) {
      iconData = Icons.local_offer_rounded;
      iconColor = const Color(0xFFF59E0B);
      iconBg = const Color(0xFFF59E0B).withValues(alpha: 0.1);
    } else if (type.contains('verified') || type.contains('rera')) {
      iconData = Icons.verified_rounded;
      iconColor = const Color(0xFF10B981);
      iconBg = const Color(0xFF10B981).withValues(alpha: 0.1);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isRead ? const Color(0xFFE2E8F0) : const Color(0xFF86EFAC),
            width: isRead ? 1 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          margin: EdgeInsets.only(left: 6.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFF007A5E),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (message.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      message,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5.sp,
                        color: const Color(0xFF475569),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (time.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      _formatDate(time),
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return raw;
    }
  }
}
