import 'package:flutter/material.dart';
import 'package:rafoof/core/database/app_database.dart';
import 'package:rafoof/core/di/service_locator.dart';
import 'package:rafoof/features/cart/data/models/cart_item_model.dart';
import 'package:rafoof/features/checkout/data/models/order_model.dart';
import 'package:rafoof/features/checkout/data/repositories/checkout_repository.dart';

class CheckoutProvider extends ChangeNotifier {
  CheckoutRepository get _checkoutRepository => sl<CheckoutRepository>();
  AppDatabase get _db => sl<AppDatabase>();

  bool _isPlacing = false;
  OrderModel? _lastOrder;
  List<OrderModel> _orders = [];
  bool _isLoadingOrders = false;

  bool get isPlacing => _isPlacing;
  OrderModel? get lastOrder => _lastOrder;
  List<OrderModel> get orders => _orders;
  bool get isLoadingOrders => _isLoadingOrders;

  Future<OrderModel> placeOrder({
    required int userId,
    required List<CartItemModel> items,
  }) async {
    _isPlacing = true;
    notifyListeners();

    try {
      final order = await _checkoutRepository.placeOrder(
        userId: userId,
        items: items,
      );
      _lastOrder = order;
      _orders = [order, ..._orders];
      await _db.insertOrder(order.toRow());
      return order;
    } finally {
      _isPlacing = false;
      notifyListeners();
    }
  }

  Future<void> loadOrders(int userId) async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      final rows = await _db.getOrders(userId);
      _orders = rows.map(OrderModel.fromRow).toList();
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }
}
