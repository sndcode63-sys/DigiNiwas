import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
    this.baseColor = const Color(0xFFE9F1EE),
    this.highlightColor = const Color(0xFFFFFFFF),
  });

  factory ShimmerWidget.box({
    Key? key,
    double? width,
    double height = 16,
    double borderRadius = 8,
  }) {
    return ShimmerWidget(
      key: key,
      child: ShimmerBox(width: width, height: height, borderRadius: borderRadius),
    );
  }

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double slide = _controller.value * 2 - 1; // -1 to 1
            return LinearGradient(
              begin: Alignment(-1.5 + slide * 2, -0.3),
              end: Alignment(1.5 + slide * 2, 0.3),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Solid rounded-rect placeholder block — wrap in [ShimmerWidget] or use
/// inside a shared [ShimmerWidget] tree (only ONE ShaderMask animator is
/// needed to shimmer many boxes at once — see [ShimmerGroup]).
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color color;

  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.color = const Color(0xFFE1EAE7),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  final Color color;

  const ShimmerCircle({
    super.key,
    this.size = 40,
    this.color = const Color(0xFFE1EAE7),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}


class ShimmerGroup extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const ShimmerGroup({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1600),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      duration: duration,
      baseColor: AppColors.background,
      highlightColor: Colors.white,
      child: child,
    );
  }
}


class ShimmerGroupDark extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const ShimmerGroupDark({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1600),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      duration: duration,
      baseColor: const Color(0xFF0E3A5C),
      highlightColor: AppColors.turquoise.withOpacity(0.55),
      child: child,
    );
  }
}


class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerShimmer(),
            SizedBox(height: 20.h),
            _categoryChipsShimmer(),
            SizedBox(height: 24.h),
            _sectionTitleShimmer(),
            SizedBox(height: 12.h),
            _quickAiGridShimmer(),
            SizedBox(height: 24.h),
            _sectionTitleShimmer(showViewAll: true),
            SizedBox(height: 12.h),
            _recommendedCardsShimmer(),
            SizedBox(height: 24.h),
            _sectionTitleShimmer(),
            SizedBox(height: 12.h),
            _exploreMapShimmer(),
            SizedBox(height: 24.h),
            _sectionTitleShimmer(showViewAll: true),
            SizedBox(height: 12.h),
            _newListingsShimmer(),
            SizedBox(height: 24.h),
            _sectionTitleShimmer(),
            SizedBox(height: 12.h),
            _popularAreasShimmer(),
            SizedBox(height: 24.h),
            _sectionTitleShimmer(),
            SizedBox(height: 12.h),
            _agentShimmer(),
            SizedBox(height: 28.h),
            _ecosystemShimmer(),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  // ---- Header --------------------------------------------------------
  Widget _headerShimmer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
      ),
      child: ShimmerGroupDark(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox(width: 110.w, height: 14.h, borderRadius: 4, color: Colors.white24),
                const Spacer(),
                ShimmerCircle(size: 30.w, color: Colors.white24),
                SizedBox(width: 10.w),
                ShimmerCircle(size: 32.w, color: Colors.white24),
              ],
            ),
            SizedBox(height: 16.h),
            ShimmerBox(width: 180.w, height: 22.h, borderRadius: 6, color: Colors.white24),
            SizedBox(height: 8.h),
            ShimmerBox(width: 220.w, height: 12.h, borderRadius: 4, color: Colors.white24),
            SizedBox(height: 18.h),
            ShimmerBox(width: double.infinity, height: 46.h, borderRadius: 16, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  // ---- Category chips --------------------------------------------------
  Widget _categoryChipsShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ShimmerGroup(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (_) {
            return Column(
              children: [
                ShimmerBox(width: 56.w, height: 56.w, borderRadius: 16),
                SizedBox(height: 6.h),
                ShimmerBox(width: 40.w, height: 10.h, borderRadius: 4),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ---- Generic section title -------------------------------------------
  Widget _sectionTitleShimmer({bool showViewAll = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ShimmerGroup(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBox(width: 150.w, height: 16.h, borderRadius: 4),
            if (showViewAll) ShimmerBox(width: 50.w, height: 12.h, borderRadius: 4),
          ],
        ),
      ),
    );
  }

  // ---- Quick AI discovery grid -------------------------------------------
  Widget _quickAiGridShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ShimmerGroup(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 2.3,
          ),
          itemBuilder: (context, index) {
            return ShimmerBox(borderRadius: 14, height: double.infinity);
          },
        ),
      ),
    );
  }

  // ---- Recommended property cards -------------------------------------------
  Widget _recommendedCardsShimmer() {
    return SizedBox(
      height: 250.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: 2,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          return ShimmerGroup(
            child: Container(
              width: 240.w,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 120.h, borderRadius: 0, width: double.infinity),
                  Padding(
                    padding: EdgeInsets.all(10.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 140.w, height: 14.h, borderRadius: 4),
                        SizedBox(height: 6.h),
                        ShimmerBox(width: 100.w, height: 10.h, borderRadius: 4),
                        SizedBox(height: 10.h),
                        ShimmerBox(width: 160.w, height: 10.h, borderRadius: 4),
                        SizedBox(height: 8.h),
                        ShimmerBox(width: 90.w, height: 16.h, borderRadius: 4),
                        SizedBox(height: 10.h),
                        ShimmerBox(width: double.infinity, height: 32.h, borderRadius: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---- Explore map -------------------------------------------
  Widget _exploreMapShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ShimmerGroup(
        child: Column(
          children: [
            ShimmerBox(width: double.infinity, height: 150.h, borderRadius: 16),
            SizedBox(height: 10.h),
            Row(
              children: [
                ShimmerBox(width: 200.w, height: 12.h, borderRadius: 4),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                ShimmerBox(width: 90.w, height: 26.h, borderRadius: 20),
                SizedBox(width: 10.w),
                ShimmerBox(width: 100.w, height: 26.h, borderRadius: 20),
                SizedBox(width: 10.w),
                ShimmerBox(width: 80.w, height: 26.h, borderRadius: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---- New listings -------------------------------------------
  Widget _newListingsShimmer() {
    return SizedBox(
      height: 150.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: 2,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          return ShimmerGroup(
            child: Container(
              width: 160.w,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 90.h, borderRadius: 0, width: double.infinity),
                  Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 100.w, height: 12.h, borderRadius: 4),
                        SizedBox(height: 6.h),
                        ShimmerBox(width: 70.w, height: 10.h, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---- Popular areas -------------------------------------------
  Widget _popularAreasShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ShimmerGroup(
        child: Row(
          children: [
            Expanded(child: ShimmerBox(height: 70.h, borderRadius: 14)),
            SizedBox(width: 12.w),
            Expanded(child: ShimmerBox(height: 70.h, borderRadius: 14)),
          ],
        ),
      ),
    );
  }

  // ---- Verified agent -------------------------------------------
  Widget _agentShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ShimmerGroup(
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
          child: Row(
            children: [
              ShimmerCircle(size: 44.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 100.w, height: 12.h, borderRadius: 4),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 80.w, height: 10.h, borderRadius: 4),
                  ],
                ),
              ),
              ShimmerBox(width: 70.w, height: 28.h, borderRadius: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Future ecosystem (dark section) -------------------------------------------
  Widget _ecosystemShimmer() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(24.r)),
      child: ShimmerGroupDark(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 140.w, height: 20.h, borderRadius: 8, color: Colors.white24),
            SizedBox(height: 16.h),
            ShimmerBox(width: double.infinity, height: 20.h, borderRadius: 4, color: Colors.white24),
            SizedBox(height: 8.h),
            ShimmerBox(width: 220.w, height: 20.h, borderRadius: 4, color: Colors.white24),
            SizedBox(height: 10.h),
            ShimmerBox(width: double.infinity, height: 12.h, borderRadius: 4, color: Colors.white24),
            SizedBox(height: 6.h),
            ShimmerBox(width: 250.w, height: 12.h, borderRadius: 4, color: Colors.white24),
            SizedBox(height: 18.h),
            SizedBox(
              height: 160.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  return ShimmerBox(width: 150.w, height: double.infinity, borderRadius: 16, color: Colors.white24);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}