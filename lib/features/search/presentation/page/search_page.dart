import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/shared/widgets/app_network_image.dart';
import 'package:rafoof/core/shared/widgets/error_view.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/cart/data/models/cart_item_model.dart';
import 'package:rafoof/features/cart/presentation/provider/cart_provider.dart';
import 'package:rafoof/features/products/data/models/product_model.dart';
import 'package:rafoof/features/products/presentation/page/product_details_page.dart';
import 'package:rafoof/features/products/presentation/page/products_page.dart';
import 'package:rafoof/features/search/presentation/provider/search_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<SearchProvider>().query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchProvider>().clearQuery();
  }

  void _searchRecent(String value) {
    _searchController.text = value;
    FocusScope.of(context).unfocus();
    context.read<SearchProvider>().searchFor(value);
  }

  void _openProduct(ProductModel product) {
    context.read<SearchProvider>().saveRecentSearch();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
          productId: product.id,
          thumbnail: product.thumbnail,
        ),
      ),
    );
  }

  void _showAll(String query) {
    context.read<SearchProvider>().saveRecentSearch();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductsPage(title: '"$query"', searchQuery: query),
      ),
    );
  }

  Future<void> _addToCart(ProductModel product) async {
    final item = CartItemModel(
      productId: product.id,
      name: product.title,
      price: product.price,
      discountPercentage: product.discountPercentage,
      quantity: max(1, product.minimumOrderQuantity),
      image: product.thumbnail,
      stock: product.stock,
      minimumOrderQuantity: product.minimumOrderQuantity,
    );

    final added = await context.read<CartProvider>().addToCart(item);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added ? AppStrings.addedToCart : AppStrings.noMoreStock,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final search = context.watch<SearchProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(search, colors),
            Expanded(
              child: ListView(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 0, 20.w, 24.h),
                children: [
                  if (search.query.isNotEmpty) ..._buildResults(search, colors),
                  if (search.recentSearches.isNotEmpty) ...[
                    SizedBox(height: search.query.isEmpty ? 4.h : 24.h),
                    Text(
                      AppStrings.recentSearches,
                      style: TextStyle(
                        color: colors.ink,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildRecentSearches(search, colors),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(SearchProvider search, AppColors colors) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(8.w, 16.h, 20.w, 14.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: colors.ink, size: 22.sp),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Container(
              height: 50.h,
              padding: EdgeInsetsDirectional.only(start: 14.w, end: 4.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: colors.ink, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: colors.ink, size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: search.query.isEmpty,
                      cursorColor: colors.ink,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) =>
                          context.read<SearchProvider>().onQueryChanged(value),
                      onSubmitted: (value) {
                        final searchProvider = context.read<SearchProvider>();
                        searchProvider.saveRecentSearch();
                        searchProvider.search();
                      },
                      style: TextStyle(
                        color: colors.ink,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: AppStrings.searchHint,
                        hintStyle: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  if (search.query.isNotEmpty)
                    IconButton(
                      onPressed: _clearSearch,
                      icon: Icon(
                        Icons.close,
                        color: colors.textSecondary,
                        size: 18.sp,
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

  List<Widget> _buildResults(SearchProvider search, AppColors colors) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              search.isLoading && search.results.isEmpty
                  ? AppStrings.searching
                  : AppStrings.results(search.total),
              style: TextStyle(
                color: colors.ink,
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: Text(
              AppStrings.forQuery(search.query),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textSecondary, fontSize: 13.sp),
            ),
          ),
        ],
      ),
      SizedBox(height: 12.h),
      if (search.isLoading && search.results.isEmpty)
        Padding(
          padding: EdgeInsets.all(24.w),
          child: const Center(child: CircularProgressIndicator()),
        )
      else if (search.error != null)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: ErrorView(
            message: search.error!,
            colors: colors,
            onRetry: () => context.read<SearchProvider>().search(),
          ),
        )
      else if (search.results.isEmpty)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Text(
            AppStrings.noProducts,
            style: TextStyle(color: colors.textSecondary, fontSize: 14.sp),
          ),
        )
      else ...[
        for (final product in search.results) ...[
          _buildResultItem(product, colors),
          SizedBox(height: 10.h),
        ],
        if (search.total > search.results.length)
          SizedBox(
            height: 48.h,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.ink,
                side: BorderSide(color: colors.borderStrong),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              onPressed: () => _showAll(search.query),
              child: Text(
                AppStrings.showAllResults(search.total),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    ];
  }

  Widget _buildResultItem(ProductModel product, AppColors colors) {
    return GestureDetector(
      onTap: () => _openProduct(product),
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(10.w, 10.h, 12.w, 10.h),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            Container(
              width: 78.w,
              height: 78.w,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: colors.imageTile,
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Hero(
                tag: 'product-${product.id}',
                child: AppNetworkImage(url: product.thumbnail, colors: colors),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.categoryName(
                      product.category,
                      product.category.replaceAll('-', ' ').toUpperCase(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: colors.ink,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(Icons.star, color: colors.star, size: 13.sp),
                      SizedBox(width: 3.w),
                      Text(
                        '${product.rating}',
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
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => _addToCart(product),
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.add, color: colors.onAccent, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(SearchProvider search, AppColors colors) {
    final recentSearches = search.recentSearches;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(14.w, 4.h, 6.w, 4.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          for (int i = 0; i < recentSearches.length; i++)
            Container(
              height: 50.h,
              decoration: BoxDecoration(
                border: i == recentSearches.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: colors.textSecondary,
                    size: 18.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _searchRecent(recentSearches[i]),
                      child: Text(
                        recentSearches[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.ink, fontSize: 15.sp),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context
                        .read<SearchProvider>()
                        .removeRecentSearch(recentSearches[i]),
                    icon: Icon(
                      Icons.close,
                      color: colors.textSecondary,
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
