import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rafoof/core/database/app_database.dart';
import 'package:rafoof/core/database/tables/cart_table.dart';
import 'package:rafoof/core/di/service_locator.dart';
import 'package:rafoof/features/cart/data/models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  AppDatabase get _db => sl<AppDatabase>();

  final List<CartItemModel> _items = [];
  bool _hasLoaded = false;
  bool _isLoading = false;

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  int get itemsCount => _items.length;

  int get totalQuantity =>
      _items.fold(0, (total, item) => total + item.quantity);

  double get subtotal => _items.fold(0, (total, item) => total + item.total);

  double get total => _items.fold(0, (total, item) => total + item.finalTotal);

  double get discount => subtotal - total;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rows = await _db.getCart();
      _items
        ..clear()
        ..addAll(rows.map(CartItemModel.fromRow));
      _hasLoaded = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(CartItemModel item) async {
    await _ensureLoaded();
    final index = _findItemIndex(item.productId);
    final currentQuantity = index == -1 ? 0 : _items[index].quantity;
    final newQuantity = min(currentQuantity + item.quantity, item.stock);

    if (newQuantity <= currentQuantity) return false;

    final newItem = _withQuantity(item, newQuantity);
    if (index == -1) {
      _items.add(newItem);
    } else {
      _items[index] = newItem;
    }
    notifyListeners();
    await _db.insertCart(newItem.toRow());
    return true;
  }

  Future<void> increaseQuantity(int productId) async {
    final index = _findItemIndex(productId);
    if (index == -1) return;

    final item = _items[index];
    if (item.quantity >= item.stock) return;

    await _changeQuantity(index, item.quantity + 1);
  }

  Future<void> decreaseQuantity(int productId) async {
    final index = _findItemIndex(productId);
    if (index == -1) return;

    final item = _items[index];
    if (item.quantity <= max(1, item.minimumOrderQuantity)) return;

    await _changeQuantity(index, item.quantity - 1);
  }

  Future<void> removeFromCart(int productId) async {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
    await _db.deleteCartItem(productId: productId);
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await _db.delete(tableName: CartTable.tableName);
  }

  Future<void> _changeQuantity(int index, int quantity) async {
    final item = _items[index];
    _items[index] = _withQuantity(item, quantity);
    notifyListeners();
    await _db.updateCartQuantity(productId: item.productId, quantity: quantity);
  }

  Future<void> _ensureLoaded() async {
    if (!_hasLoaded) await loadCart();
  }

  int _findItemIndex(int productId) {
    return _items.indexWhere((item) => item.productId == productId);
  }

  CartItemModel _withQuantity(CartItemModel item, int quantity) {
    return CartItemModel(
      productId: item.productId,
      name: item.name,
      price: item.price,
      discountPercentage: item.discountPercentage,
      quantity: quantity,
      image: item.image,
      stock: item.stock,
      minimumOrderQuantity: item.minimumOrderQuantity,
    );
  }
}
