import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rafoof/core/theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String url;
  final AppColors colors;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double iconSize;

  const AppNetworkImage({
    super.key,
    required this.url,
    required this.colors,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final errorIcon = Icon(
      Icons.broken_image_outlined,
      color: colors.textSecondary,
      size: iconSize,
    );

    if (url.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: Center(child: errorIcon),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 200),
      errorWidget: (context, url, error) => Center(child: errorIcon),
    );
  }
}
