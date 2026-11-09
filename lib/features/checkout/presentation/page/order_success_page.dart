import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/checkout/data/models/order_model.dart';
import 'package:rafoof/features/home/presentation/page/main_page.dart';

class OrderSuccessPage extends StatefulWidget {
  final OrderModel order;

  const OrderSuccessPage({super.key, required this.order});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final order = widget.order;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 16.h),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: colors.onAccent, size: 48.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                AppStrings.orderPlaced,
                style: TextStyle(
                  color: colors.ink,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                AppStrings.orderTitle(order.id),
                style: TextStyle(color: colors.textSecondary, fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      AppStrings.itemsCountLabel,
                      '${AppStrings.items(order.totalProducts)} · ${AppStrings.units(order.totalQuantity)}',
                      colors.ink,
                      colors,
                    ),
                    SizedBox(height: 10.h),
                    _buildRow(
                      AppStrings.subtotal,
                      '\$${order.total.toStringAsFixed(2)}',
                      colors.ink,
                      colors,
                    ),
                    SizedBox(height: 10.h),
                    _buildRow(
                      AppStrings.discounts,
                      '-\$${order.discount.toStringAsFixed(2)}',
                      colors.success,
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
                          '\$${order.discountedTotal.toStringAsFixed(2)}',
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
              ),
              SizedBox(height: 14.h),
              Text(
                AppStrings.orderPlacedHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13.sp,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              SizedBox(
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
                  onPressed: () => MainPage.openTab(context, MainPage.homeTab),
                  child: Text(
                    AppStrings.continueShopping,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value,
    Color valueColor,
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
