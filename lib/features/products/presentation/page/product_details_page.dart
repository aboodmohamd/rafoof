import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/shared/widgets/app_network_image.dart';
import 'package:rafoof/core/shared/widgets/cart_button.dart';
import 'package:rafoof/core/shared/widgets/error_view.dart';
import 'package:rafoof/core/shared/widgets/fly_to_cart.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/cart/data/models/cart_item_model.dart';
import 'package:rafoof/features/cart/presentation/provider/cart_provider.dart';
import 'package:rafoof/features/home/presentation/page/main_page.dart';
import 'package:rafoof/features/products/data/models/product_details_model.dart';
import 'package:rafoof/features/products/presentation/provider/product_details_provider.dart';
import 'package:rafoof/features/wishlist/presentation/provider/wishlist_provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;
  final String thumbnail;

  const ProductDetailsPage({
    super.key,
    required this.productId,
    required this.thumbnail,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey _cartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailsProvider>().openProduct(widget.productId);
    });
  }

  Future<void> _addToCart(ProductDetailsModel details, int quantity) async {
    final item = CartItemModel(
      productId: details.id,
      name: details.title,
      price: details.price,
      discountPercentage: details.discountPercentage,
      quantity: quantity,
      image: details.thumbnail,
      stock: details.stock,
      minimumOrderQuantity: details.minimumOrderQuantity,
    );

    final added = await context.read<CartProvider>().addToCart(item);
    if (!mounted) return;

    if (added) {
      FlyToCart.run(
        context: context,
        imageUrl: details.thumbnail,
        startKey: _imageKey,
        endKey: _cartKey,
      );
      context.read<ProductDetailsProvider>().showAdded();
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(AppStrings.noMoreStock)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final provider = context.watch<ProductDetailsProvider>();
    final isCurrent = provider.productId == widget.productId;
    final details = isCurrent ? provider.details : null;
    final error = isCurrent ? provider.error : null;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildGallery(provider, details, colors),
                if (details != null)
                  _buildSheet(details, colors)
                else if (error != null)
                  _buildError(error, colors)
                else
                  Padding(
                    padding: EdgeInsets.all(40.w),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          _buildTopBar(details, colors),
        ],
      ),
      bottomNavigationBar: details == null
          ? null
          : _buildBottomBar(provider, details, colors),
    );
  }

  Widget _buildTopBar(ProductDetailsModel? details, AppColors colors) {
    final cartCount = context.watch<CartProvider>().itemsCount;
    final isFavorite = context.watch<WishlistProvider>().isFavorite(
      widget.productId,
    );

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.arrow_back, color: colors.ink, size: 22.sp),
              ),
            ),
            const Spacer(),
            if (details != null)
              GestureDetector(
                onTap: () => context.read<WishlistProvider>().toggleWishlist(
                  details.toProductModel(),
                ),
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  margin: EdgeInsetsDirectional.only(end: 10.w),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: colors.ink,
                    size: 22.sp,
                  ),
                ),
              ),
            CartButton(
              key: _cartKey,
              colors: colors,
              count: cartCount,
              size: 48.w,
              onTap: () => MainPage.openTab(context, MainPage.cartTab),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(
    ProductDetailsProvider provider,
    ProductDetailsModel? details,
    AppColors colors,
  ) {
    final images = details?.images ?? [];
    final imageIndex = provider.imageIndex < images.length
        ? provider.imageIndex
        : 0;
    final imageUrl = images.isEmpty ? widget.thumbnail : images[imageIndex];

    return Container(
      color: colors.galleryBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 300.h,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      key: _imageKey,
                      padding: EdgeInsets.all(32.w),
                      child: Hero(
                        tag: 'product-${widget.productId}',
                        child: AppNetworkImage(
                          url: imageUrl,
                          colors: colors,
                          iconSize: 60.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (images.length > 1)
              SizedBox(
                height: 64.w,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: images.length,
                  separatorBuilder: (context, index) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    final isSelected = index == imageIndex;
                    return GestureDetector(
                      onTap: () => context
                          .read<ProductDetailsProvider>()
                          .selectImage(index),
                      child: Container(
                        width: 64.w,
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected ? colors.ink : colors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: AppNetworkImage(
                          url: images[index],
                          colors: colors,
                          iconSize: 20.sp,
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSheet(ProductDetailsModel details, AppColors colors) {
    final category = AppStrings.categoryName(
      details.category,
      details.category,
    );
    final subtitle = details.brand.isEmpty
        ? category
        : '${details.brand} · $category';
    final status = details.availabilityStatus.isEmpty
        ? AppStrings.inStock
        : AppStrings.availability(details.availabilityStatus);

    return Transform.translate(
      offset: Offset(0, -28.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 24.h, 20.w, 0),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.successBackground,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$status · ${AppStrings.stockLeft(details.stock)}',
                    style: TextStyle(
                      color: colors.success,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              details.title,
              style: TextStyle(
                color: colors.ink,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.star, color: colors.star, size: 16.sp),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    '${details.rating} · ${AppStrings.reviewsCount(details.reviews.length)} · ${AppStrings.sku} ${details.sku}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Text(
                  '\$${details.finalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: colors.ink,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  '\$${details.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 15.sp,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '-${details.discountPercentage.round()}%',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: colors.onAccent,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                _buildInfoTile(
                  Icons.local_shipping_outlined,
                  details.shippingInformation,
                  colors,
                ),
                SizedBox(width: 10.w),
                _buildInfoTile(
                  Icons.assignment_return_outlined,
                  details.returnPolicy,
                  colors,
                ),
                SizedBox(width: 10.w),
                _buildInfoTile(
                  Icons.verified_user_outlined,
                  details.warrantyInformation,
                  colors,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              AppStrings.description,
              style: TextStyle(
                color: colors.ink,
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              details.description,
              style: TextStyle(
                color: colors.textBody,
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
            if (details.reviews.isNotEmpty) ...[
              SizedBox(height: 20.h),
              Text(
                AppStrings.reviewsTitle,
                style: TextStyle(
                  color: colors.ink,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: colors.imageTile,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            details.reviews.first.reviewerName,
                            style: TextStyle(
                              color: colors.ink,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(Icons.star, color: colors.star, size: 14.sp),
                        SizedBox(width: 3.w),
                        Text(
                          '${details.reviews.first.rating.round()}',
                          style: TextStyle(
                            color: colors.ink,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      details.reviews.first.comment,
                      style: TextStyle(color: colors.textBody, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text, AppColors colors) {
    return Expanded(
      child: Container(
        height: 86.h,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: colors.imageTile,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.ink, size: 20.sp),
            SizedBox(height: 6.h),
            Expanded(
              child: Text(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textBody,
                  fontSize: 11.sp,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error, AppColors colors) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: ErrorView(
        message: error,
        colors: colors,
        onRetry: () => context.read<ProductDetailsProvider>().loadDetails(),
      ),
    );
  }

  Widget _buildBottomBar(
    ProductDetailsProvider provider,
    ProductDetailsModel details,
    AppColors colors,
  ) {
    final total = details.finalPrice * provider.quantity;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 10.h, 20.w, 10.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.minimumOrder}: ${details.minimumOrderQuantity}',
              style: TextStyle(color: colors.textSecondary, fontSize: 12.sp),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(color: colors.borderStrong),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context
                            .read<ProductDetailsProvider>()
                            .decreaseQuantity(),
                        icon: Icon(Icons.remove, color: colors.ink),
                      ),
                      Text(
                        '${provider.quantity}',
                        style: TextStyle(
                          color: colors.ink,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => context
                            .read<ProductDetailsProvider>()
                            .increaseQuantity(),
                        icon: Icon(Icons.add, color: colors.ink),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.isAdded
                            ? colors.ink
                            : colors.accent,
                        foregroundColor: provider.isAdded
                            ? colors.onInk
                            : colors.onAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      onPressed: () => _addToCart(details, provider.quantity),
                      child: provider.isAdded
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: colors.accent,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  AppStrings.addedToCartLabel,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '${AppStrings.addToCart} · \$${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
