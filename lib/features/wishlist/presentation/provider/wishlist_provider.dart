import 'package:flutter/material.dart';
import 'package:rafoof/core/database/app_database.dart';
import 'package:rafoof/core/di/service_locator.dart';
import 'package:rafoof/features/products/data/models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  AppDatabase get _db => sl<AppDatabase>();

  final List<ProductModel> _items = [];
  bool _isLoading = false;

  List<ProductModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  int get itemsCount => _items.length;

  bool isFavorite(int productId) => _items.any((item) => item.id == productId);

  Future<void> loadWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rows = await _db.getWishlist();
      _items
        ..clear()
        ..addAll(rows.map(ProductModel.fromRow));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(ProductModel product) async {
    if (isFavorite(product.id)) {
      await removeFromWishlist(product.id);
      return;
    }

    _items.insert(0, product);
    notifyListeners();
    await _db.insertWishlist(product.toRow());
  }

  Future<void> removeFromWishlist(int productId) async {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
    await _db.deleteFromWishlist(productId);
  }
}
