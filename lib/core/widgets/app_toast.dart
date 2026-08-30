import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

enum AppToastType { success, error }

/// App-themed toast — designed with a clean rounded card layout matching
/// the app components, smooth pop-in animation, and bottom positioning.
///
/// Usage:
///   AppToast.success(context, 'OTP sent successfully');
///   AppToast.error(context, 'This number is not registered.');
class AppToast {
  AppToast._();

  static OverlayEntry? _current;

  static void success(BuildContext context, String message) =>
      _show(context, message: message, type: AppToastType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message: message, type: AppToastType.error);

  static void _show(
      BuildContext context, {
        required String message,
        required AppToastType type,
      }) {
    // Only one toast at a time — a fresh one replaces whatever is showing.
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastCard(
        message: message,
        type: type,
        onFinished: () {
          entry.remove();
          if (identical(_current, entry)) _current = null;
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({
    required this.message,
    required this.type,
    required this.onFinished,
  });

  final String message;
  final AppToastType type;
  final VoidCallback onFinished;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _autoDismiss;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _scale = Tween<double>(begin: 0.90, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _autoDismiss = Timer(const Duration(milliseconds: 2600), _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _autoDismiss?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onFinished();
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.type == AppToastType.success;

    // Background color based on success or error matching app theme style
    final Color bgColor = isSuccess ? Colors.green.shade700 : Colors.red.shade700;
    final IconData icon = isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded;

    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: 40.h, // Screen ke bottom mein fix rahega
      child: IgnorePointer(
        ignoring: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: _dismiss,
            onVerticalDragEnd: (_) => _dismiss(),
            child: ScaleTransition(
              scale: _scale,
              child: FadeTransition(
                opacity: _fade,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 400.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16.r), // App card jaisa rounded shape
                      boxShadow: [
                        BoxShadow(
                          color: bgColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 22.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}