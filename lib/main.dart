import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rafoof/core/di/service_locator.dart';
import 'package:rafoof/core/env_config.dart';
import 'package:rafoof/core/language/provider/language_provider.dart';
import 'package:rafoof/core/services/app_preferences.dart';
import 'package:rafoof/core/theme/provider/theme_provider.dart';
import 'package:rafoof/features/auth/presentation/provider/auth_provider.dart';
import 'package:rafoof/features/cart/presentation/provider/cart_provider.dart';
import 'package:rafoof/features/categories/presentation/provider/categories_provider.dart';
import 'package:rafoof/features/checkout/presentation/provider/checkout_provider.dart';
import 'package:rafoof/features/home/presentation/page/main_page.dart';
import 'package:rafoof/features/home/presentation/provider/home_provider.dart';
import 'package:rafoof/features/home/presentation/provider/navigation_provider.dart';
import 'package:rafoof/features/products/presentation/provider/product_details_provider.dart';
import 'package:rafoof/features/products/presentation/provider/products_provider.dart';
import 'package:rafoof/features/search/presentation/provider/search_provider.dart';
import 'package:rafoof/features/wishlist/presentation/provider/wishlist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  await initDI();
  await sl<AppPreferences>().loadToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
            ChangeNotifierProvider(create: (_) => NavigationProvider()),
            ChangeNotifierProvider(create: (_) => HomeProvider()..loadHome()),
            ChangeNotifierProvider(create: (_) => ProductsProvider()),
            ChangeNotifierProvider(
              create: (_) => CategoriesProvider()..loadCategories(),
            ),
            ChangeNotifierProvider(create: (_) => ProductDetailsProvider()),
            ChangeNotifierProvider(create: (_) => CartProvider()..loadCart()),
            ChangeNotifierProvider(
              create: (_) => SearchProvider()..loadRecentSearches(),
            ),
            ChangeNotifierProvider(create: (_) => AuthProvider()..loadUser()),
            ChangeNotifierProvider(
              create: (_) => WishlistProvider()..loadWishlist(),
            ),
            ChangeNotifierProvider(create: (_) => CheckoutProvider()),
            ChangeNotifierProvider(
              create: (_) => LanguageProvider()..loadLanguage(),
            ),
          ],
          child: Builder(
            builder: (context) {
              final languageCode = context
                  .watch<LanguageProvider>()
                  .languageCode;
              final colors = context.watch<ThemeProvider>().colors;

              return MaterialApp(
                key: ValueKey(languageCode),
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  progressIndicatorTheme: ProgressIndicatorThemeData(
                    color: colors.ink,
                  ),
                ),
                locale: Locale(languageCode),
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: (context, child) {
                  final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
                  return AnnotatedRegion<SystemUiOverlayStyle>(
                    value: isDarkMode
                        ? SystemUiOverlayStyle.light
                        : SystemUiOverlayStyle.dark,
                    child: child!,
                  );
                },
                home: const MainPage(),
              );
            },
          ),
        );
      },
    );
  }
}
