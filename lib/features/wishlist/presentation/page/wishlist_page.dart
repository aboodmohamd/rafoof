import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/shared/widgets/product_card.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/home/presentation/page/main_page.dart';
import 'package:rafoof/features/products/presentation/page/product_details_page.dart';
import 'package:rafoof/features/wishlist/presentation/provider/wishlist_provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final wishlist = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        foregroundColor: colors.ink,
        title: Text(
          AppStrings.wishlist,
          style: TextStyle(
            color: colors.ink,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(wishlist, colors),
    );
  }

  Widget _buildBody(WishlistProvider wishlist, AppColors colors) {
    if (wishlist.items.isEmpty && wishlist.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (wishlist.items.isEmpty) {
      return _buildEmpty(colors);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 4.h, 16.w, 0),
          child: Text(
            '${AppStrings.items(wishlist.itemsCount)} · ${AppStrings.savedOnDevice}',
            style: TextStyle(color: colors.textSecondary, fontSize: 14.sp),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              mainAxisExtent: 250.h,
            ),
            itemCount: wishlist.items.length,
            itemBuilder: (context, index) {
              final product = wishlist.items[index];
              return ProductCard(
                width: double.infinity,
                height: double.infinity,
                colors: colors,
                productId: product.id,
                imagePath: product.thumbnail,
                title: product.title,
                price: '\$${product.price.toStringAsFixed(2)}',
                rating: '${product.rating}',
                discount: '-${product.discountPercentage.round()}%',
                isFavorite: true,
                onFavoriteTap: () => context
                    .read<WishlistProvider>()
                    .removeFromWishlist(product.id),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsPage(
                        productId: product.id,
                        thumbnail: product.thumbnail,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(AppColors colors) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                color: colors.textSecondary,
                size: 44.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppStrings.emptyWishlist,
              style: TextStyle(
                color: colors.ink,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              AppStrings.emptyWishlistHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 14.sp),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.onAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onPressed: () => MainPage.openTab(context, MainPage.homeTab),
                child: Text(
                  AppStrings.startShopping,
                  style: TextStyle(
                    fontSize: 15.sp,
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
