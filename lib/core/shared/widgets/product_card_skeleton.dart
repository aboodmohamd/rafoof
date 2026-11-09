import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafoof/core/shared/widgets/skeleton_box.dart';
import 'package:rafoof/core/theme/app_colors.dart';

class ProductCardSkeleton extends StatelessWidget {
  final AppColors colors;
  final double width;
  final double height;

  const ProductCardSkeleton({
    super.key,
    required this.colors,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SkeletonBox(
              colors: colors,
              width: double.infinity,
              radius: 13.r,
            ),
          ),
          SizedBox(height: 10.h),
          SkeletonBox(colors: colors, width: double.infinity, height: 12.h),
          SizedBox(height: 6.h),
          SkeletonBox(colors: colors, width: 70.w, height: 12.h),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(colors: colors, width: 56.w, height: 16.h),
              SkeletonBox(colors: colors, width: 32.w, height: 14.h),
            ],
          ),
        ],
      ),
    );
  }
}
