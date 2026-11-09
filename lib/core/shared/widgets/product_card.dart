import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafoof/core/shared/widgets/app_network_image.dart';
import 'package:rafoof/core/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final double width;
  final double height;
  final AppColors colors;
  final String? imagePath;
  final String title;
  final String price;
  final String rating;
  final String discount;
  final int? productId;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const ProductCard({
    super.key,
    required this.width,
    required this.height,
    required this.colors,
    this.imagePath,
    this.title = 'Product name goes here',
    this.price = '\$120.00',
    this.rating = '4.9',
    this.discount = '-10%',
    this.productId,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: colors.imageTile,
                      child: imagePath == null
                          ? Icon(
                              Icons.image_outlined,
                              color: colors.textSecondary,
                              size: 42.sp,
                            )
                          : Padding(
                              padding: EdgeInsets.all(8.w),
                              child: productId == null
                                  ? _buildImage()
                                  : Hero(
                                      tag: 'product-$productId',
                                      child: _buildImage(),
                                    ),
                            ),
                    ),
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                        child: Text(
                          discount,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: colors.onAccent,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (onFavoriteTap != null)
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: GestureDetector(
                          onTap: onFavoriteTap,
                          child: Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: colors.ink,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 36.sp,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.ink,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Row(
                  children: [
                    Icon(Icons.star, color: colors.star, size: 14.sp),
                    SizedBox(width: 3.w),
                    Text(
                      rating,
                      style: TextStyle(
                        color: colors.ink,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AppNetworkImage(url: imagePath!, colors: colors, iconSize: 42.sp);
  }
}
