import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafoof/core/shared/widgets/product_card.dart';
import 'package:rafoof/core/theme/app_colors.dart';

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 180, height: 260, child: child)),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the product title, price, rating and discount', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      wrap(
        const ProductCard(
          width: 180,
          height: 260,
          colors: AppColors.light,
          title: 'Amazon Echo Plus',
          price: '\$99.99',
          rating: '4.99',
          discount: '-12%',
        ),
      ),
    );

    expect(find.text('Amazon Echo Plus'), findsOneWidget);
    expect(find.text('\$99.99'), findsOneWidget);
    expect(find.text('4.99'), findsOneWidget);
    expect(find.text('-12%'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });

  testWidgets('calls onTap and onFavoriteTap', (tester) async {
    var taps = 0;
    var favoriteTaps = 0;

    usePhoneScreen(tester);
    await tester.pumpWidget(
      wrap(
        ProductCard(
          width: 180,
          height: 260,
          colors: AppColors.light,
          title: 'Lunch Box',
          onTap: () => taps++,
          onFavoriteTap: () => favoriteTaps++,
        ),
      ),
    );

    await tester.tap(find.text('Lunch Box'));
    await tester.tap(find.byIcon(Icons.favorite_border));

    expect(taps, 1);
    expect(favoriteTaps, 1);
  });

  testWidgets('shows a filled heart when the product is a favorite', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      wrap(
        ProductCard(
          width: 180,
          height: 260,
          colors: AppColors.light,
          isFavorite: true,
          onFavoriteTap: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
