import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../features/partner/controllers/partner_home_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../data/partner_repository.dart';

class PartnerChangePasswordScreen extends StatefulWidget {
  const PartnerChangePasswordScreen({super.key});

  @override
  State<PartnerChangePasswordScreen> createState() =>
      _PartnerChangePasswordScreenState();
}

class _PartnerChangePasswordScreenState
    extends State<PartnerChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_next.text != _confirm.text) {
      Get.snackbar('Error', 'New passwords do not match');
      return;
    }
    if (_next.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = Get.find<PartnerRepository>();
      await repo.changePartnerPassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      // Flag is cleared inside repository; ensure session can reach dashboard.
      await repo.clearMustChangePasswordFlag();
      if (Get.isRegistered<PartnerHomeController>()) {
        Get.delete<PartnerHomeController>(force: true);
      }
      Get.put(PartnerHomeController());
      Get.offAllNamed(AppRoutes.partnerDashboard);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    final repo = Get.find<PartnerRepository>();
    await repo.clearPartnerSession();
    if (Get.isRegistered<PartnerHomeController>()) {
      Get.delete<PartnerHomeController>(force: true);
    }
    Get.offAllNamed(AppRoutes.partnerLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _loading ? null : _signOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Text(
              'Update your password to continue to the partner dashboard.',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _current,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _next,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005B48),
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
