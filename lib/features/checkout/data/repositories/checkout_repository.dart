import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/network/api_client.dart';
import 'package:rafoof/core/network/api_endpoints.dart';
import 'package:rafoof/core/network/response_wrapper.dart';
import 'package:rafoof/features/cart/data/models/cart_item_model.dart';
import 'package:rafoof/features/checkout/data/models/order_model.dart';

class CheckoutRepository {
  final ApiConsumer apiConsumer;

  CheckoutRepository({required this.apiConsumer});

  Future<OrderModel> placeOrder({
    required int userId,
    required List<CartItemModel> items,
  }) async {
    final ResponseWrapper response = await apiConsumer.post(
      ApiEndpoints.addCart,
      body: {
        'userId': userId,
        'products': items
            .map((item) => {'id': item.productId, 'quantity': item.quantity})
            .toList(),
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['id'] == null) {
      throw Exception(AppStrings.placeOrderFailed);
    }

    return OrderModel.fromJson(data);
  }
}
