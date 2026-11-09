import 'package:flutter_test/flutter_test.dart';
import 'package:rafoof/features/auth/data/models/user_model.dart';
import 'package:rafoof/features/cart/data/models/cart_item_model.dart';
import 'package:rafoof/features/checkout/data/models/order_model.dart';
import 'package:rafoof/features/products/data/models/product_details_model.dart';
import 'package:rafoof/features/products/data/models/product_model.dart';

void main() {
  group('ProductModel', () {
    test('reads the fields from DummyJSON', () {
      final product = ProductModel.fromJson({
        'id': 173,
        'title': "Heshe Women's Leather Bag",
        'price': 129.99,
        'discountPercentage': 3.87,
        'rating': 4.92,
        'category': 'womens-bags',
        'thumbnail': 'https://example.com/bag.webp',
        'stock': 99,
        'minimumOrderQuantity': 5,
      });

      expect(product.id, 173);
      expect(product.price, 129.99);
      expect(product.category, 'womens-bags');
      expect(product.stock, 99);
      expect(product.minimumOrderQuantity, 5);
    });

    test('uses safe defaults when fields are missing', () {
      final product = ProductModel.fromJson({'id': '7'});

      expect(product.id, 7);
      expect(product.title, '');
      expect(product.price, 0);
      expect(product.stock, 0);
      expect(product.minimumOrderQuantity, 1);
    });

    test('keeps the same values after saving and reading a row', () {
      final product = ProductModel.fromJson({
        'id': 1,
        'title': 'Mascara',
        'price': 9.99,
        'discountPercentage': 10.48,
        'rating': 4.94,
        'category': 'beauty',
        'thumbnail': 'thumb.webp',
        'stock': 5,
        'minimumOrderQuantity': 2,
      });

      final copy = ProductModel.fromRow(product.toRow());

      expect(copy.id, product.id);
      expect(copy.title, product.title);
      expect(copy.price, product.price);
      expect(copy.rating, product.rating);
      expect(copy.thumbnail, product.thumbnail);
      expect(copy.minimumOrderQuantity, 2);
    });
  });

  group('ProductDetailsModel', () {
    test('calculates the final price after the discount', () {
      final details = ProductDetailsModel.fromJson({
        'id': 1,
        'price': 100,
        'discountPercentage': 25,
        'thumbnail': 'thumb.webp',
      });

      expect(details.finalPrice, 75);
    });

    test('falls back to the thumbnail when there are no images', () {
      final details = ProductDetailsModel.fromJson({
        'id': 1,
        'thumbnail': 'thumb.webp',
      });

      expect(details.images, ['thumb.webp']);
      expect(details.reviews, isEmpty);
    });

    test('converts to a ProductModel for the wishlist', () {
      final details = ProductDetailsModel.fromJson({
        'id': 9,
        'title': 'Laptop',
        'price': 999,
        'stock': 3,
        'minimumOrderQuantity': 1,
        'thumbnail': 'laptop.webp',
      });

      final product = details.toProductModel();

      expect(product.id, 9);
      expect(product.title, 'Laptop');
      expect(product.stock, 3);
    });
  });

  group('UserModel', () {
    test('builds the full name, initials and address', () {
      final user = UserModel.fromJson({
        'id': 1,
        'username': 'emilys',
        'email': 'emily@example.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'address': {
          'address': '626 Main Street',
          'city': 'Phoenix',
          'country': 'United States',
        },
      });

      expect(user.fullName, 'Emily Johnson');
      expect(user.initials, 'EJ');
      expect(user.address, '626 Main Street, Phoenix, United States');
    });

    test('shows a question mark when there is no name', () {
      final user = UserModel.fromJson({'id': 1});

      expect(user.initials, '?');
      expect(user.address, '');
    });
  });

  group('OrderModel', () {
    test('reads the DummyJSON cart response', () {
      final order = OrderModel.fromJson({
        'id': 209,
        'userId': 1,
        'total': 269.97,
        'discountedTotal': 259,
        'totalProducts': 2,
        'totalQuantity': 3,
        'products': [
          {'id': 173, 'thumbnail': 'bag.webp'},
        ],
      });

      expect(order.id, 209);
      expect(order.discount, closeTo(10.97, 0.001));
      expect(order.image, 'bag.webp');
    });

    test('keeps the same values after saving and reading a row', () {
      final order = OrderModel.fromJson({
        'id': 5,
        'userId': 2,
        'total': 50,
        'discountedTotal': 45,
        'totalProducts': 1,
        'totalQuantity': 2,
      });

      final copy = OrderModel.fromRow(order.toRow());

      expect(copy.id, 5);
      expect(copy.userId, 2);
      expect(copy.discountedTotal, 45);
      expect(
        copy.createdAt.toIso8601String(),
        order.createdAt.toIso8601String(),
      );
    });
  });

  group('CartItemModel', () {
    test('calculates totals with and without the discount', () {
      final item = CartItemModel(
        productId: 1,
        name: 'Bag',
        price: 100,
        discountPercentage: 10,
        quantity: 3,
        image: '',
        stock: 10,
        minimumOrderQuantity: 1,
      );

      expect(item.total, 300);
      expect(item.finalPrice, 90);
      expect(item.finalTotal, 270);
    });

    test('keeps the same values after saving and reading a row', () {
      final item = CartItemModel(
        productId: 4,
        name: 'Cup',
        price: 5.99,
        discountPercentage: 2,
        quantity: 2,
        image: 'cup.webp',
        stock: 8,
        minimumOrderQuantity: 2,
      );

      final copy = CartItemModel.fromRow(item.toRow());

      expect(copy.productId, 4);
      expect(copy.quantity, 2);
      expect(copy.stock, 8);
      expect(copy.minimumOrderQuantity, 2);
    });
  });
}
