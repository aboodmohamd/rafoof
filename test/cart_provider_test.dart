import 'package:flutter_test/flutter_test.dart';
import 'package:rafoof/core/database/app_database.dart';
import 'package:rafoof/core/di/service_locator.dart';
import 'package:rafoof/features/cart/data/models/cart_item_model.dart';
import 'package:rafoof/features/cart/presentation/provider/cart_provider.dart';

class FakeAppDatabase implements AppDatabase {
  final Map<int, Map<String, dynamic>> cart = {};

  @override
  Future<List<Map<String, dynamic>>> getCart() async =>
      cart.values.map((row) => Map<String, dynamic>.of(row)).toList();

  @override
  Future<void> insertCart(Map<String, dynamic> data) async {
    cart[data['productId'] as int] = Map<String, dynamic>.of(data);
  }

  @override
  Future<void> updateCartQuantity({
    required int productId,
    required int quantity,
  }) async {
    cart[productId]?['quantity'] = quantity;
  }

  @override
  Future<void> deleteCartItem({required int productId}) async {
    cart.remove(productId);
  }

  @override
  Future<void> delete({
    required String tableName,
    String? where,
    List<Object?>? listWhere,
  }) async {
    if (tableName == 'cart') cart.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

CartItemModel buildItem({
  int productId = 1,
  int quantity = 1,
  int stock = 10,
  int minimumOrderQuantity = 1,
  double price = 100,
  double discountPercentage = 10,
}) {
  return CartItemModel(
    productId: productId,
    name: 'Product $productId',
    price: price,
    discountPercentage: discountPercentage,
    quantity: quantity,
    image: '',
    stock: stock,
    minimumOrderQuantity: minimumOrderQuantity,
  );
}

void main() {
  late FakeAppDatabase db;
  late CartProvider cart;

  setUp(() async {
    await sl.reset();
    db = FakeAppDatabase();
    sl.registerSingleton<AppDatabase>(db);
    cart = CartProvider();
  });

  test('adds a new product and saves it', () async {
    final added = await cart.addToCart(buildItem(quantity: 2));

    expect(added, isTrue);
    expect(cart.itemsCount, 1);
    expect(cart.totalQuantity, 2);
    expect(db.cart[1]?['quantity'], 2);
  });

  test('adding the same product again never goes above the stock', () async {
    await cart.addToCart(buildItem(quantity: 6, stock: 10));
    final addedAgain = await cart.addToCart(buildItem(quantity: 6, stock: 10));
    final addedWhenFull = await cart.addToCart(buildItem(stock: 10));

    expect(addedAgain, isTrue);
    expect(cart.items.first.quantity, 10);
    expect(addedWhenFull, isFalse);
  });

  test('quantity stays between the minimum order and the stock', () async {
    await cart.addToCart(
      buildItem(quantity: 2, stock: 3, minimumOrderQuantity: 2),
    );

    await cart.increaseQuantity(1);
    await cart.increaseQuantity(1);
    expect(cart.items.first.quantity, 3);

    await cart.decreaseQuantity(1);
    await cart.decreaseQuantity(1);
    expect(cart.items.first.quantity, 2);
    expect(db.cart[1]?['quantity'], 2);
  });

  test('calculates the subtotal, discount and total', () async {
    await cart.addToCart(buildItem(quantity: 2, price: 100));
    await cart.addToCart(
      buildItem(productId: 2, quantity: 1, price: 50, discountPercentage: 0),
    );

    expect(cart.subtotal, 250);
    expect(cart.total, closeTo(230, 0.001));
    expect(cart.discount, closeTo(20, 0.001));
  });

  test('removes one product and clears the whole cart', () async {
    await cart.addToCart(buildItem());
    await cart.addToCart(buildItem(productId: 2));

    await cart.removeFromCart(1);
    expect(cart.itemsCount, 1);
    expect(db.cart.containsKey(1), isFalse);

    await cart.clearCart();
    expect(cart.items, isEmpty);
    expect(db.cart, isEmpty);
  });

  test('loads the products that were saved before', () async {
    db.cart[7] = buildItem(productId: 7, quantity: 4).toRow();

    await cart.loadCart();

    expect(cart.itemsCount, 1);
    expect(cart.items.first.productId, 7);
    expect(cart.items.first.quantity, 4);
  });
}
