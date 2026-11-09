import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/shared/widgets/app_network_image.dart';
import 'package:rafoof/core/shared/widgets/cart_button.dart';
import 'package:rafoof/core/shared/widgets/error_view.dart';
import 'package:rafoof/core/shared/widgets/product_card.dart';
import 'package:rafoof/core/shared/widgets/product_card_skeleton.dart';
import 'package:rafoof/core/shared/widgets/skeleton_box.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/cart/presentation/provider/cart_provider.dart';
import 'package:rafoof/features/home/presentation/page/main_page.dart';
import 'package:rafoof/features/home/presentation/provider/home_provider.dart';
import 'package:rafoof/features/products/presentation/page/product_details_page.dart';
import 'package:rafoof/features/products/presentation/page/products_page.dart';
import 'package:rafoof/features/search/presentation/page/search_page.dart';
import 'package:rafoof/features/wishlist/presentation/page/wishlist_page.dart';
import 'package:rafoof/features/wishlist/presentation/provider/wishlist_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _openBannerProduct() {
    final bannerProduct = context.read<HomeProvider>().bannerProduct;
    if (bannerProduct == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
          productId: bannerProduct.id,
          thumbnail: bannerProduct.thumbnail,
        ),
      ),
    );
  }

  void _openWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WishlistPage()),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final home = context.watch<HomeProvider>();
    final cartCount = context.watch<CartProvider>().itemsCount;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(
          AppStrings.appName,
          style: TextStyle(
            color: colors.ink,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        leading: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.surface,
          ),
          child: Image.asset('assets/img/logo.png'),
        ),
        actions: [
          GestureDetector(
            onTap: _openWishlist,
            child: Container(
              width: 40.w,
              height: 40.w,
              margin: EdgeInsets.symmetric(vertical: 8.w, horizontal: 4.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(13.w),
                border: Border.all(color: colors.border),
              ),
              child: Icon(
                Icons.favorite_border,
                color: colors.ink,
                size: 20.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(4.w, 8.w, 12.w, 8.w),
            child: CartButton(
              colors: colors,
              count: cartCount,
              size: 40.w,
              onTap: () => MainPage.openTab(context, MainPage.cartTab),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: colors.ink,
        backgroundColor: colors.surface,
        onRefresh: () => context.read<HomeProvider>().loadHome(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _openSearch,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                  height: 45.h,

                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.search, color: colors.textSecondary),
                        onPressed: _openSearch,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          AppStrings.searchHint,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.all(16.w),
                height: 164.h,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.todaysDeals,
                            style: TextStyle(
                              color: colors.onAccent,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            AppStrings.freshPicks(home.categories.length),
                            style: TextStyle(
                              color: colors.onAccent,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          TextButton.icon(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                colors.onAccent,
                              ),
                              shape:
                                  WidgetStateProperty.all<
                                    RoundedRectangleBorder
                                  >(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                  ),
                            ),
                            onPressed: _openBannerProduct,
                            iconAlignment: IconAlignment.end,

                            label: Text(
                              AppStrings.shopNow,
                              style: TextStyle(
                                color: colors.accent,
                                fontSize: 16.sp,
                              ),
                            ),
                            icon: Icon(
                              Icons.arrow_forward,
                              color: colors.accent,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 130.w,
                      height: 130.w,
                      child: home.bannerProduct == null
                          ? const SizedBox()
                          : AppNetworkImage(
                              url: home.bannerProduct!.thumbnail,
                              colors: colors,
                            ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.shopByCategory,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        MainPage.openTab(context, MainPage.categoriesTab),
                    child: Text(
                      AppStrings.seeAll,
                      style: TextStyle(color: colors.ink, fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              SizedBox(
                height: 58.w + 28.h,
                child: _buildCategories(home, colors),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.topRated,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductsPage(title: AppStrings.topRated),
                        ),
                      );
                    },
                    child: Text(
                      AppStrings.seeAll,
                      style: TextStyle(color: colors.ink, fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              SizedBox(height: 210.h, child: _buildTopRated(home, colors)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(HomeProvider home, AppColors colors) {
    if (home.isLoadingCategories && home.categories.isEmpty) {
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(width: 15.w),
        itemBuilder: (context, index) => Column(
          children: [
            SkeletonBox(
              colors: colors,
              width: 58.w,
              height: 58.w,
              radius: 20.r,
            ),
            SizedBox(height: 9.h),
            SkeletonBox(colors: colors, width: 46.w, height: 10.h),
          ],
        ),
      );
    }
    if (home.categoriesError != null && home.categories.isEmpty) {
      return ErrorView(
        message: home.categoriesError!,
        colors: colors,
        compact: true,
        onRetry: () => context.read<HomeProvider>().loadHome(),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: home.categories.length,
      separatorBuilder: (context, index) => SizedBox(width: 15.w),
      itemBuilder: (context, index) {
        final category = home.categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsPage(
                  title: AppStrings.categoryName(category.slug, category.name),
                  categorySlug: category.slug,
                ),
              ),
            );
          },
          child: SizedBox(
            width: 58.w,
            child: Column(
              children: [
                Container(
                  height: 58.w,
                  width: 58.w,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: colors.border),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: home.categoryImage(category.slug) == null
                        ? Icon(
                            Icons.category_outlined,
                            color: colors.textSecondary,
                            size: 24.sp,
                          )
                        : AppNetworkImage(
                            url: home.categoryImage(category.slug)!,
                            colors: colors,
                            iconSize: 24.sp,
                          ),
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  AppStrings.categoryName(category.slug, category.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.ink,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopRated(HomeProvider home, AppColors colors) {
    if (home.isLoadingTopRated && home.topRated.isEmpty) {
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) =>
            ProductCardSkeleton(colors: colors, width: 152.w, height: 210.h),
      );
    }
    if (home.topRatedError != null && home.topRated.isEmpty) {
      return ErrorView(
        message: home.topRatedError!,
        colors: colors,
        onRetry: () => context.read<HomeProvider>().loadHome(),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: home.topRated.length,
      separatorBuilder: (context, index) => SizedBox(width: 12.w),
      itemBuilder: (context, index) {
        final product = home.topRated[index];
        return ProductCard(
          width: 152.w,
          height: 210.h,
          colors: colors,
          productId: product.id,
          imagePath: product.thumbnail,
          title: product.title,
          price: '\$${product.price.toStringAsFixed(2)}',
          rating: '${product.rating}',
          discount: '-${product.discountPercentage.round()}%',
          isFavorite: context.watch<WishlistProvider>().isFavorite(product.id),
          onFavoriteTap: () =>
              context.read<WishlistProvider>().toggleWishlist(product),
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
    );
  }
}
