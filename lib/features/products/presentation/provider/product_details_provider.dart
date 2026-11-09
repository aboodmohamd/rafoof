import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rafoof/core/di/service_locator.dart';
import 'package:rafoof/features/products/data/models/product_details_model.dart';
import 'package:rafoof/features/products/data/repositories/product_repository.dart';

class ProductDetailsProvider extends ChangeNotifier {
  ProductRepository get _productRepository => sl<ProductRepository>();

  ProductDetailsModel? _details;
  bool _isLoading = false;
  String? _error;
  int _imageIndex = 0;
  int _quantity = 1;
  int _productId = 0;
  int _requestId = 0;
  bool _isAdded = false;
  int _addedId = 0;

  int get productId => _productId;
  ProductDetailsModel? get details => _details;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get imageIndex => _imageIndex;
  int get quantity => _quantity;
  bool get isAdded => _isAdded;

  void openProduct(int id) {
    _productId = id;
    _details = null;
    _error = null;
    _imageIndex = 0;
    _quantity = 1;
    _isAdded = false;
    _requestId++;
    loadDetails();
  }

  Future<void> showAdded() async {
    final addedId = ++_addedId;
    _isAdded = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (addedId != _addedId) return;
    _isAdded = false;
    notifyListeners();
  }

  Future<void> loadDetails() async {
    final requestId = _requestId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final details = await _productRepository.getProductDetails(_productId);
      if (requestId != _requestId) return;
      _details = details;
      _quantity = max(1, details.minimumOrderQuantity);
    } catch (e) {
      if (requestId != _requestId) return;
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectImage(int index) {
    _imageIndex = index;
    notifyListeners();
  }

  void increaseQuantity() {
    if (_details == null || _quantity >= _details!.stock) return;
    _quantity++;
    notifyListeners();
  }

  void decreaseQuantity() {
    if (_details == null) return;
    if (_quantity <= max(1, _details!.minimumOrderQuantity)) return;
    _quantity--;
    notifyListeners();
  }
}
