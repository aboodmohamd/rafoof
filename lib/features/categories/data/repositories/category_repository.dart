import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/network/api_client.dart';
import 'package:rafoof/core/network/api_endpoints.dart';
import 'package:rafoof/core/network/response_wrapper.dart';
import 'package:rafoof/features/categories/data/models/category_model.dart';

class CategoryRepository {
  final ApiConsumer apiConsumer;

  CategoryRepository({required this.apiConsumer});

  Future<List<CategoryModel>> getCategories() async {
    final ResponseWrapper response = await apiConsumer.get(
      ApiEndpoints.categories,
    );

    final data = response.data;
    if (data is! List) {
      throw Exception(AppStrings.loadCategoriesFailed);
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }
}
