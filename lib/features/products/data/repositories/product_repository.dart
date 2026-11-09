import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/network/api_client.dart';
import 'package:rafoof/core/network/api_endpoints.dart';
import 'package:rafoof/core/network/response_wrapper.dart';
import 'package:rafoof/features/categories/data/models/category_summary_model.dart';
import 'package:rafoof/features/products/data/models/product_details_model.dart';
import 'package:rafoof/features/products/data/models/product_model.dart';
import 'package:rafoof/features/products/data/models/products_page_model.dart';

class ProductRepository {
  final ApiConsumer apiConsumer;

  ProductRepository({required this.apiConsumer});

  Future<ProductsPageModel> getProducts({
    int limit = 20,
    int skip = 0,
    String sortBy = '',
    String order = '',
    String categorySlug = '',
    String searchQuery = '',
  }) async {
    String path = ApiEndpoints.products;
    if (searchQuery.isNotEmpty) {
      path = ApiEndpoints.searchProducts;
    } else if (categorySlug.isNotEmpty) {
      path = '${ApiEndpoints.categoryProducts}/$categorySlug';
    }

    final ResponseWrapper response = await apiConsumer.get(
      path,
      queryParameters: {
        if (searchQuery.isNotEmpty) 'q': searchQuery,
        'limit': limit,
        'skip': skip,
        if (sortBy.isNotEmpty) 'sortBy': sortBy,
        if (order.isNotEmpty) 'order': order,
      },
    );

    final data = response.data;
    if (data is! Map || data['products'] is! List) {
      throw Exception(AppStrings.loadProductsFailed);
    }

    final products = (data['products'] as List)
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();

    return ProductsPageModel(
      products: products,
      total: int.tryParse(data['total']?.toString() ?? '') ?? products.length,
    );
  }

  Future<ProductModel> getProduct(int id) async {
    final ResponseWrapper response = await apiConsumer.get(
      '${ApiEndpoints.products}/$id',
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['id'] == null) {
      throw Exception(AppStrings.loadProductFailed);
    }

    return ProductModel.fromJson(data);
  }

  Future<ProductDetailsModel> getProductDetails(int id) async {
    final ResponseWrapper response = await apiConsumer.get(
      '${ApiEndpoints.products}/$id',
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['id'] == null) {
      throw Exception(AppStrings.loadProductFailed);
    }

    return ProductDetailsModel.fromJson(data);
  }

  Future<CategorySummaryModel> getCategorySummary() async {
    final ResponseWrapper response = await apiConsumer.get(
      ApiEndpoints.products,
      queryParameters: {'limit': 0, 'select': 'category,thumbnail'},
    );

    final data = response.data;
    if (data is! Map || data['products'] is! List) {
      throw Exception(AppStrings.loadCategoriesFailed);
    }

    final images = <String, String>{};
    final counts = <String, int>{};
    for (final product
        in (data['products'] as List).whereType<Map<String, dynamic>>()) {
      final category = product['category']?.toString() ?? '';
      final thumbnail = product['thumbnail']?.toString() ?? '';
      if (category.isEmpty) continue;
      counts[category] = (counts[category] ?? 0) + 1;
      if (thumbnail.isNotEmpty) {
        images.putIfAbsent(category, () => thumbnail);
      }
    }

    return CategorySummaryModel(images: images, counts: counts);
  }
}
