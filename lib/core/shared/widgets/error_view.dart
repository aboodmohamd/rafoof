import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/theme/app_colors.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final AppColors colors;
  final VoidCallback onRetry;
  final bool compact;

  const ErrorView({
    super.key,
    required this.message,
    required this.colors,
    required this.onRetry,
    this.compact = false,
  });

  bool get _isOffline =>
      message == AppStrings.noInternet ||
      message == AppStrings.connectionTimeout;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      _isOffline ? Icons.wifi_off_rounded : Icons.error_outline,
      color: colors.textSecondary,
      size: compact ? 22.sp : 44.sp,
    );
    final retryButton = TextButton.icon(
      onPressed: onRetry,
      icon: Icon(Icons.refresh, color: colors.ink, size: 18.sp),
      label: Text(
        AppStrings.retry,
        style: TextStyle(
          color: colors.ink,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (compact) {
      return Row(
        children: [
          icon,
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textSecondary, fontSize: 13.sp),
            ),
          ),
          retryButton,
        ],
      );
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            retryButton,
          ],
        ),
      ),
    );
  }
}
