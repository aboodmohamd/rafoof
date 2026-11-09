import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/language/provider/language_provider.dart';
import 'package:rafoof/core/theme/app_colors.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/auth/presentation/page/sign_in_page.dart';
import 'package:rafoof/features/auth/presentation/provider/auth_provider.dart';
import 'package:rafoof/features/cart/presentation/provider/cart_provider.dart';
import 'package:rafoof/features/checkout/presentation/page/orders_page.dart';
import 'package:rafoof/features/home/presentation/page/main_page.dart';
import 'package:rafoof/features/wishlist/presentation/page/wishlist_page.dart';
import 'package:rafoof/features/wishlist/presentation/provider/wishlist_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  void _openSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors;
    final auth = context.watch<AuthProvider>();
    final cartCount = context.watch<CartProvider>().itemsCount;
    final wishlistCount = context.watch<WishlistProvider>().itemsCount;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 24.h),
          children: [
            Text(
              AppStrings.navAccount,
              style: TextStyle(
                color: colors.ink,
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 14.h),
            _buildProfileCard(auth, theme.isDarkMode, colors),
            SizedBox(height: 14.h),
            _buildAppearance(theme, context.watch<LanguageProvider>(), colors),
            SizedBox(height: 14.h),
            _buildInfoRows(auth, cartCount, wishlistCount, colors),
            if (auth.isLoggedIn) ...[
              SizedBox(height: 14.h),
              SizedBox(
                height: 52.h,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.ink,
                    side: BorderSide(color: colors.borderStrong),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  onPressed: () => context.read<AuthProvider>().logout(),
                  icon: Icon(Icons.logout, size: 18.sp),
                  label: Text(
                    AppStrings.signOut,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(AuthProvider auth, bool isDark, AppColors colors) {
    final cardText = isDark ? colors.ink : colors.onInk;
    final cardSubText = isDark ? colors.textSecondary : colors.borderStrong;
    final user = auth.user;

    Widget content;
    if (!auth.isLoggedIn) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(
                colors,
                child: Icon(
                  Icons.person_outline,
                  color: colors.onAccent,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.guest,
                      style: TextStyle(
                        color: cardText,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      AppStrings.signInSubtitle,
                      style: TextStyle(color: cardSubText, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              onPressed: _openSignIn,
              child: Text(
                AppStrings.signIn,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    } else if (user == null) {
      content = auth.isLoading
          ? Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: CircularProgressIndicator(color: colors.accent),
              ),
            )
          : Column(
              children: [
                Text(
                  auth.error ?? AppStrings.loadUserFailed,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cardSubText, fontSize: 13.sp),
                ),
                TextButton(
                  onPressed: () => context.read<AuthProvider>().loadUser(),
                  child: Text(
                    AppStrings.retry,
                    style: TextStyle(color: colors.accent, fontSize: 14.sp),
                  ),
                ),
              ],
            );
    } else {
      content = Column(
        children: [
          Row(
            children: [
              _buildAvatar(
                colors,
                child: user.image.isEmpty
                    ? _buildInitials(user.initials, colors)
                    : ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.image,
                          width: 60.w,
                          height: 60.w,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              _buildInitials(user.initials, colors),
                        ),
                      ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cardText,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '@${user.username}',
                      style: TextStyle(color: cardSubText, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colors.inkChip,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: colors.online,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    AppStrings.signedInStatus,
                    style: TextStyle(
                      color: isDark ? colors.ink : colors.onInk,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : colors.ink,
        borderRadius: BorderRadius.circular(22.r),
        border: isDark ? Border.all(color: colors.border) : null,
      ),
      child: content,
    );
  }

  Widget _buildAvatar(AppColors colors, {required Widget child}) {
    return Container(
      width: 60.w,
      height: 60.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
      child: child,
    );
  }

  Widget _buildInitials(String initials, AppColors colors) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: colors.onAccent,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAppearance(
    ThemeProvider theme,
    LanguageProvider language,
    AppColors colors,
  ) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.appearance,
                style: TextStyle(
                  color: colors.ink,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppStrings.savedOnDevice,
                style: TextStyle(color: colors.textSecondary, fontSize: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colors.imageTile,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                _buildOption(
                  AppStrings.light,
                  Icons.light_mode_outlined,
                  !theme.isDarkMode,
                  theme.isDarkMode,
                  colors,
                  onTap: () => context.read<ThemeProvider>().changeTheme(),
                ),
                SizedBox(width: 4.w),
                _buildOption(
                  AppStrings.dark,
                  Icons.dark_mode_outlined,
                  theme.isDarkMode,
                  theme.isDarkMode,
                  colors,
                  onTap: () => context.read<ThemeProvider>().changeTheme(),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              AppStrings.language,
              style: TextStyle(
                color: colors.ink,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colors.imageTile,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                _buildOption(
                  AppStrings.english,
                  Icons.language,
                  !language.isArabic,
                  theme.isDarkMode,
                  colors,
                  onTap: () =>
                      context.read<LanguageProvider>().changeLanguage('en'),
                ),
                SizedBox(width: 4.w),
                _buildOption(
                  AppStrings.arabic,
                  Icons.translate,
                  language.isArabic,
                  theme.isDarkMode,
                  colors,
                  onTap: () =>
                      context.read<LanguageProvider>().changeLanguage('ar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    String label,
    IconData icon,
    bool isSelected,
    bool isDark,
    AppColors colors, {
    required VoidCallback onTap,
  }) {
    final selectedBackground = isDark ? colors.accent : colors.ink;
    final selectedText = isDark ? colors.onAccent : colors.onInk;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) onTap();
        },
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: isSelected ? selectedBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? selectedText : colors.ink,
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? selectedText : colors.ink,
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRows(
    AuthProvider auth,
    int cartCount,
    int wishlistCount,
    AppColors colors,
  ) {
    final user = auth.user;
    final rows = <Widget>[
      if (auth.isLoggedIn && user != null) ...[
        _buildInfoRow(AppStrings.email, user.email, colors),
        if (user.address.isNotEmpty)
          _buildInfoRow(AppStrings.shippingAddress, user.address, colors),
        _buildInfoRow(
          AppStrings.myOrders,
          AppStrings.savedOnDevice,
          colors,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrdersPage()),
            );
          },
        ),
      ],
      _buildInfoRow(
        AppStrings.myCart,
        AppStrings.items(cartCount),
        colors,
        onTap: () => MainPage.openTab(context, MainPage.cartTab),
      ),
      _buildInfoRow(
        AppStrings.wishlist,
        '${AppStrings.items(wishlistCount)} · ${AppStrings.savedOnDevice}',
        colors,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WishlistPage()),
          );
        },
      ),
    ];

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(14.w, 4.h, 6.w, 4.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++)
            Container(
              decoration: BoxDecoration(
                border: i == rows.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: colors.divider)),
              ),
              child: rows[i],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    AppColors colors, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 62.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.ink,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 36.w,
              height: 44.h,
              child: onTap == null
                  ? null
                  : Icon(
                      Icons.chevron_right,
                      color: colors.textSecondary,
                      size: 20.sp,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
