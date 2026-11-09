import 'package:rafoof/features/products/data/models/product_model.dart';

class ProductsPageModel {
  final List<ProductModel> products;
  final int total;

  ProductsPageModel({required this.products, required this.total});
}
