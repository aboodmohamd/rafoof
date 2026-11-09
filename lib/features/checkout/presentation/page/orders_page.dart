import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/shared/widgets/app_network_image.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/auth/presentation/provider/auth_provider.dart';
import 'package:rafoof/features/checkout/data/models/order_model.dart';
import 'package:rafoof/features/checkout/presentation/provider/checkout_provider.dart';
import 'package:rafoof/features/home/presentation/page/main_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) context.read<CheckoutProvider>().loadOrders(user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final checkout = context.watch<CheckoutProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        foregroundColor: colors.ink,
        title: Text(
          AppStrings.myOrders,
          style: TextStyle(
            color: colors.ink,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(checkout, colors),
    );
  }

  Widget _buildBody(CheckoutProvider checkout, AppColors colors) {
    if (checkout.orders.isEmpty && checkout.isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }
    if (checkout.orders.isEmpty) {
      return _buildEmpty(colors);
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: checkout.orders.length,
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (context, index) =>
          _buildOrderItem(checkout.orders[index], colors),
    );
  }

  Widget _buildOrderItem(OrderModel order, AppColors colors) {
    final date = order.createdAt;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: colors.imageTile,
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: AppNetworkImage(url: order.image, colors: colors),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.orderTitle(order.id),
                  style: TextStyle(
                    color: colors.ink,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${date.day}/${date.month}/${date.year} · ${AppStrings.items(order.totalProducts)}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${order.discountedTotal.toStringAsFixed(2)}',
            style: TextStyle(
              color: colors.ink,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
                Icons.receipt_long_outlined,
                color: colors.textSecondary,
                size: 44.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppStrings.noOrders,
              style: TextStyle(
                color: colors.ink,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              AppStrings.noOrdersHint,
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
