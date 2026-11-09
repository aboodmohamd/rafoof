import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/shared/widgets/app_network_image.dart';
import 'package:rafoof/core/shared/widgets/error_view.dart';
import 'package:rafoof/core/shared/widgets/skeleton_box.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/categories/presentation/provider/categories_provider.dart';
import 'package:rafoof/features/products/presentation/page/products_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final categoriesProvider = context.watch<CategoriesProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.navCategories,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    categoriesProvider.categories.isEmpty
                        ? ''
                        : '${AppStrings.categories(categoriesProvider.categories.length)} · ${AppStrings.products(categoriesProvider.totalProducts)}',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(categoriesProvider, colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CategoriesProvider categoriesProvider, AppColors colors) {
    if (categoriesProvider.categories.isEmpty && categoriesProvider.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92.w,
              child: Column(
                children: [
                  for (int i = 0; i < 6; i++) ...[
                    SkeletonBox(
                      colors: colors,
                      width: double.infinity,
                      height: 44.h,
                      radius: 14.r,
                    ),
                    SizedBox(height: 10.h),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < 4; i++) ...[
                    SkeletonBox(
                      colors: colors,
                      width: double.infinity,
                      height: 76.h,
                      radius: 16.r,
                    ),
                    SizedBox(height: 10.h),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (categoriesProvider.categories.isEmpty &&
        categoriesProvider.error != null) {
      return ErrorView(
        message: categoriesProvider.error!,
        colors: colors,
        onRetry: () => context.read<CategoriesProvider>().loadCategories(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupsRail(categoriesProvider, colors),
        Expanded(child: _buildGroupPanel(categoriesProvider, colors)),
      ],
    );
  }

  Widget _buildGroupsRail(
    CategoriesProvider categoriesProvider,
    AppColors colors,
  ) {
    final groupNames = categoriesProvider.groupNames;

    return SizedBox(
      width: 104.w,
      child: ListView.separated(
        padding: EdgeInsetsDirectional.only(start: 12.w, bottom: 16.h),
        itemCount: groupNames.length,
        separatorBuilder: (context, index) => SizedBox(height: 6.h),
        itemBuilder: (context, index) {
          final isSelected = index == categoriesProvider.selectedGroup;
          return GestureDetector(
            onTap: () => context.read<CategoriesProvider>().selectGroup(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected ? colors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                AppStrings.categoryGroup(groupNames[index]),
                style: TextStyle(
                  color: isSelected ? colors.onAccent : colors.textSecondary,
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupPanel(
    CategoriesProvider categoriesProvider,
    AppColors colors,
  ) {
    final groupCategories = categoriesProvider.groupCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12.w, 0, 16.w, 12.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.categoryGroup(
                    categoriesProvider.selectedGroupName,
                  ),
                  style: TextStyle(
                    color: colors.ink,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                AppStrings.products(categoriesProvider.groupProductCount),
                style: TextStyle(color: colors.textSecondary, fontSize: 12.sp),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsetsDirectional.fromSTEB(12.w, 0, 16.w, 16.h),
            itemCount: groupCategories.length,
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final category = groupCategories[index];
              final image = categoriesProvider.imageOf(category.slug);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductsPage(
                        title: AppStrings.categoryName(
                          category.slug,
                          category.name,
                        ),
                        categorySlug: category.slug,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 76.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: colors.imageTile,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: image == null
                            ? Icon(
                                Icons.category_outlined,
                                color: colors.textSecondary,
                                size: 24.sp,
                              )
                            : AppNetworkImage(url: image, colors: colors),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.categoryName(
                                category.slug,
                                category.name,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.ink,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              AppStrings.products(
                                categoriesProvider.countOf(category.slug),
                              ),
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: colors.textSecondary,
                        size: 22.sp,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
