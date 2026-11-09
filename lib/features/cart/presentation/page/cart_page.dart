import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/shared/widgets/app_network_image.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/auth/presentation/page/sign_in_page.dart';
import 'package:rafoof/features/auth/presentation/provider/auth_provider.dart';
import 'package:rafoof/features/cart/data/models/cart_item_model.dart';
import 'package:rafoof/features/cart/presentation/provider/cart_provider.dart';
import 'package:rafoof/features/checkout/presentation/page/order_success_page.dart';
import 'package:rafoof/features/checkout/presentation/provider/checkout_provider.dart';
import 'package:rafoof/features/home/presentation/page/main_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Future<void> _checkout() async {
    if (!context.read<AuthProvider>().isLoggedIn) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
      if (!mounted || !context.read<AuthProvider>().isLoggedIn) return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      _showMessage(AppStrings.loadUserFailed);
      return;
    }

    try {
      final order = await context.read<CheckoutProvider>().placeOrder(
        userId: user.id,
        items: context.read<CartProvider>().items,
      );
      if (!mounted) return;
      await context.read<CartProvider>().clearCart();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderSuccessPage(order: order)),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmClearCart(AppColors colors) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          AppStrings.clearCart,
          style: TextStyle(color: colors.ink, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppStrings.clearCartQuestion,
          style: TextStyle(color: colors.textBody, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              AppStrings.clear,
              style: TextStyle(color: colors.ink, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    context.read<CartProvider>().clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(cart, colors),
            Expanded(child: _buildBody(cart, colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CartProvider cart, AppColors colors) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 12.w, 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.navCart,
                  style: TextStyle(
                    color: colors.ink,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${AppStrings.items(cart.itemsCount)} · ${AppStrings.units(cart.totalQuantity)}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearCart(colors),
              child: Text(
                AppStrings.clearCart,
                style: TextStyle(
                  color: colors.ink,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.ink,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(CartProvider cart, AppColors colors) {
    if (cart.items.isEmpty && cart.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cart.items.isEmpty) {
      return _buildEmpty(colors);
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: cart.items.length + 1,
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              if (index == cart.items.length) {
                return Padding(
                  padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
                  child: _buildSummary(cart, colors),
                );
              }
              return _buildCartItem(cart.items[index], colors);
            },
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.w, 8.h, 20.w, 16.h),
          child: SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              onPressed: context.watch<CheckoutProvider>().isPlacing
                  ? null
                  : _checkout,
              child: context.watch<CheckoutProvider>().isPlacing
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colors.onAccent,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.checkout,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.arrow_forward, size: 18.sp),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItemModel item, AppColors colors) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(10.w, 10.h, 6.w, 10.h),
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
            child: AppNetworkImage(url: item.image, colors: colors),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.ink,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '\$${item.price.toStringAsFixed(2)} ${AppStrings.each}',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      constraints: BoxConstraints.tightFor(
                        width: 44.w,
                        height: 44.w,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => context
                          .read<CartProvider>()
                          .removeFromCart(item.productId),
                      icon: Icon(
                        Icons.delete_outline,
                        color: colors.textSecondary,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: colors.imageTile,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              constraints: BoxConstraints.tightFor(
                                width: 44.w,
                                height: 44.h,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () => context
                                  .read<CartProvider>()
                                  .decreaseQuantity(item.productId),
                              icon: Icon(
                                Icons.remove,
                                color: colors.ink,
                                size: 16.sp,
                              ),
                            ),
                            SizedBox(
                              width: 24.w,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.ink,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              constraints: BoxConstraints.tightFor(
                                width: 44.w,
                                height: 44.h,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () => context
                                  .read<CartProvider>()
                                  .increaseQuantity(item.productId),
                              icon: Icon(
                                Icons.add,
                                color: colors.ink,
                                size: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: colors.ink,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(CartProvider cart, AppColors colors) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            AppStrings.subtotal,
            '\$${cart.subtotal.toStringAsFixed(2)}',
            colors.ink,
            FontWeight.w500,
            colors,
          ),
          SizedBox(height: 10.h),
          _buildSummaryRow(
            AppStrings.discounts,
            '-\$${cart.discount.toStringAsFixed(2)}',
            colors.success,
            FontWeight.bold,
            colors,
          ),
          SizedBox(height: 10.h),
          _buildSummaryRow(
            AppStrings.shipping,
            AppStrings.shippingAtCheckout,
            colors.ink,
            FontWeight.w500,
            colors,
          ),
          SizedBox(height: 10.h),
          Container(height: 1, color: colors.border),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.total,
                style: TextStyle(
                  color: colors.ink,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${cart.total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colors.ink,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color valueColor,
    FontWeight valueWeight,
    AppColors colors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 14.sp),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14.sp,
            fontWeight: valueWeight,
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
                Icons.shopping_bag_outlined,
                color: colors.textSecondary,
                size: 44.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppStrings.emptyCart,
              style: TextStyle(
                color: colors.ink,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              AppStrings.emptyCartHint,
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
