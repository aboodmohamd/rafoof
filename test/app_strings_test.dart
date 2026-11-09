import 'package:flutter_test/flutter_test.dart';
import 'package:rafoof/core/constants/app_strings.dart';

void main() {
  tearDown(() => AppStrings.languageCode = 'en');

  group('English', () {
    setUp(() => AppStrings.languageCode = 'en');

    test('uses singular for one and plural for the rest', () {
      expect(AppStrings.items(1), '1 item');
      expect(AppStrings.items(3), '3 items');
      expect(AppStrings.units(1), '1 unit');
      expect(AppStrings.results(13), '13 results');
    });

    test('keeps the category name from the API', () {
      expect(AppStrings.categoryName('furniture', 'Furniture'), 'Furniture');
      expect(AppStrings.categoryGroup('Electronics'), 'Electronics');
    });
  });

  group('Arabic', () {
    setUp(() => AppStrings.languageCode = 'ar');

    test('follows the Arabic number rules', () {
      expect(AppStrings.items(1), 'منتج واحد');
      expect(AppStrings.items(2), 'منتجان');
      expect(AppStrings.items(5), '5 منتجات');
      expect(AppStrings.items(11), '11 منتج');
    });

    test('translates the interface text', () {
      expect(AppStrings.navHome, 'الرئيسية');
      expect(AppStrings.addToCart, 'أضف إلى السلة');
    });

    test('translates known categories and keeps unknown ones', () {
      expect(AppStrings.categoryName('furniture', 'Furniture'), 'أثاث');
      expect(AppStrings.categoryName('new-slug', 'New'), 'New');
      expect(AppStrings.categoryGroup('Electronics'), 'إلكترونيات');
      expect(AppStrings.availability('Low Stock'), 'كمية محدودة');
    });
  });
}
