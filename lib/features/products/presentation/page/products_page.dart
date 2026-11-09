import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/shared/widgets/error_view.dart';
import 'package:rafoof/core/shared/widgets/product_card.dart';
import 'package:rafoof/core/shared/widgets/product_card_skeleton.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/products/presentation/page/product_details_page.dart';
import 'package:rafoof/features/products/presentation/provider/products_provider.dart';
import 'package:rafoof/features/wishlist/presentation/provider/wishlist_provider.dart';

class ProductsPage extends StatefulWidget {
  final String title;
  final String categorySlug;
  final String searchQuery;

  const ProductsPage({
    super.key,
    required this.title,
    this.categorySlug = '',
    this.searchQuery = '',
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().openList(
        categorySlug: widget.categorySlug,
        searchQuery: widget.searchQuery,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<ProductsProvider>().loadMore();
    }
  }

  void _changeSort(int index) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    context.read<ProductsProvider>().changeSort(index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final productsProvider = context.watch<ProductsProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        foregroundColor: colors.ink,
        title: Text(
          widget.title,
          style: TextStyle(
            color: colors.ink,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(productsProvider, colors),
          Expanded(child: _buildBody(productsProvider, colors)),
        ],
      ),
    );
  }

  Widget _buildHeader(ProductsProvider productsProvider, AppColors colors) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 4.h, 8.w, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.products(productsProvider.total),
              style: TextStyle(color: colors.textSecondary, fontSize: 14.sp),
            ),
          ),
          PopupMenuButton<int>(
            initialValue: productsProvider.sortIndex,
            color: colors.surface,
            onSelected: _changeSort,
            itemBuilder: (context) => [
              for (int i = 0; i < ProductsProvider.sortOptions.length; i++)
                PopupMenuItem<int>(
                  value: i,
                  child: Text(
                    ProductsProvider.sortOptions[i].label,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 14.sp,
                      fontWeight: i == productsProvider.sortIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
            ],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_vert, color: colors.ink, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    productsProvider.sortOption.label,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ProductsProvider productsProvider, AppColors colors) {
    final products = productsProvider.products;

    if (products.isEmpty && productsProvider.isLoading) {
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          mainAxisExtent: 250.h,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => ProductCardSkeleton(
          colors: colors,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    if (products.isEmpty && productsProvider.error != null) {
      return ErrorView(
        message: productsProvider.error!,
        colors: colors,
        onRetry: productsProvider.loadMore,
      );
    }
    if (products.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noProducts,
          style: TextStyle(color: colors.textSecondary, fontSize: 14.sp),
        ),
      );
    }

    return RefreshIndicator(
      color: colors.ink,
      backgroundColor: colors.surface,
      onRefresh: productsProvider.refresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          mainAxisExtent: 250.h,
        ),
        itemCount: products.length + (productsProvider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= products.length) {
            if (productsProvider.error != null) {
              return Center(
                child: TextButton(
                  onPressed: productsProvider.loadMore,
                  child: Text(
                    AppStrings.retry,
                    style: TextStyle(color: colors.ink, fontSize: 14.sp),
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          final product = products[index];
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
            isFavorite: context.watch<WishlistProvider>().isFavorite(
              product.id,
            ),
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
      ),
    );
  }
}
