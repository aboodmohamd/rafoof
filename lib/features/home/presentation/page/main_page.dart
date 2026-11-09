import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/account/presentation/page/account_page.dart';
import 'package:rafoof/features/cart/presentation/page/cart_page.dart';
import 'package:rafoof/features/cart/presentation/provider/cart_provider.dart';
import 'package:rafoof/features/categories/presentation/page/categories_page.dart';
import 'package:rafoof/features/home/presentation/page/home_page.dart';
import 'package:rafoof/features/home/presentation/provider/navigation_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static const String routeName = '/main';

  static const int homeTab = 0;
  static const int categoriesTab = 1;
  static const int cartTab = 2;
  static const int accountTab = 3;

  static void openTab(BuildContext context, int index) {
    Navigator.of(context)
        .popUntil((route) => route.settings.name == routeName || route.isFirst);
    context.read<NavigationProvider>().changeTab(index);
  }

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final NavigationProvider _navigation;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _navigation = context.read<NavigationProvider>();
    _pageController = PageController(initialPage: _navigation.currentTab);
    _navigation.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _navigation.removeListener(_onTabChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_pageController.hasClients) {
      _pageController.jumpToPage(_navigation.currentTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final currentTab = context.watch<NavigationProvider>().currentTab;
    final cartCount = context.watch<CartProvider>().itemsCount;

    return Scaffold(
      backgroundColor: colors.background,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: const [
          HomePage(),
          CategoriesPage(),
          CartPage(),
          AccountPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 76.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  MainPage.homeTab,
                  Icons.home_outlined,
                  AppStrings.navHome,
                  colors,
                  currentTab,
                ),
                _buildNavItem(
                  MainPage.categoriesTab,
                  Icons.grid_view_outlined,
                  AppStrings.navCategories,
                  colors,
                  currentTab,
                ),
                _buildNavItem(
                  MainPage.cartTab,
                  Icons.shopping_bag_outlined,
                  AppStrings.navCart,
                  colors,
                  currentTab,
                  badgeCount: cartCount,
                ),
                _buildNavItem(
                  MainPage.accountTab,
                  Icons.person_outline,
                  AppStrings.navAccount,
                  colors,
                  currentTab,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    AppColors colors,
    int currentTab, {
    int badgeCount = 0,
  }) {
    final bool isActive = currentTab == index;

    return GestureDetector(
      onTap: () => context.read<NavigationProvider>().changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80.w,
        height: 76.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: isActive ? colors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    color: isActive ? colors.onAccent : colors.textSecondary,
                    size: 22.sp,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -4.h,
                      right: 8.w,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 18.w),
                        height: 18.w,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.ink,
                          borderRadius: BorderRadius.circular(9.w),
                          border: Border.all(color: colors.surface, width: 1.5),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: TextStyle(
                            color: colors.onInk,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isActive ? colors.ink : colors.textSecondary,
                fontSize: 12.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
