import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// The single reusable image widget for the whole app — "ImageCase".
///
/// Handles all three cases any property/agent/area image needs:
///   - a network URL (cached, with a small spinner while it loads)
///   - a local asset path (with a graceful fallback if it's missing)
///   - nothing at all (straight to the fallback icon)
///
/// Replaces the copy-pasted `_cachedImage` / `_imageFallback` helpers that
/// used to live inside individual screens (e.g. the buyer home screen) so
/// every image on every screen behaves — and looks — the same.
///
/// ```dart
/// ImageCase(
///   url: property.imageUrl,
///   width: 278.w,
///   height: 208.h,
///   borderRadius: BorderRadius.circular(18.r),
/// )
/// ```
class ImageCase extends StatelessWidget {
  const ImageCase({
    super.key,
    this.url,
    this.assetPath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.home_work_rounded,
    this.borderRadius,
    this.backgroundColor = const Color(0xFFF1F6F8),
    this.iconColor = const Color(0xFF007A5E),
  });

  /// Network image URL. Takes priority over [assetPath] when both are set.
  final String? url;

  /// Local asset path, used when [url] is null/empty.
  final String? assetPath;

  final double width;
  final double height;
  final BoxFit fit;

  /// Shown when there's no image, or the image fails to load.
  final IconData fallbackIcon;

  /// Rounds the corners of the whole widget (image + placeholder + error
  /// state all share the same shape).
  final BorderRadius? borderRadius;

  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (url != null && url!.trim().isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, _) => _placeholder(),
        errorWidget: (context, _, __) => _fallback(),
      );
    } else if (assetPath != null && assetPath!.trim().isNotEmpty) {
      image = Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    } else {
      image = _fallback();
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      alignment: Alignment.center,
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: iconColor.withOpacity(0.6)),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon,
        color: iconColor,
        size: (height * 0.18).clamp(18, 40).toDouble(),
      ),
    );
  }
}
