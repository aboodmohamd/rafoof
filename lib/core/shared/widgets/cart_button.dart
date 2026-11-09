import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafoof/core/theme/app_colors.dart';

class CartButton extends StatelessWidget {
  final AppColors colors;
  final int count;
  final double size;
  final VoidCallback? onTap;

  const CartButton({
    super.key,
    required this.colors,
    required this.count,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: colors.ink,
                borderRadius: BorderRadius.circular(size / 3),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: colors.onInk,
                size: size * 0.46,
              ),
            ),
            if (count > 0)
              Positioned(
                top: -6.h,
                right: -6.w,
                child: Container(
                  constraints: BoxConstraints(minWidth: 22.w),
                  height: 22.w,
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(11.w),
                    border: Border.all(color: colors.background, width: 2),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: colors.onAccent,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
