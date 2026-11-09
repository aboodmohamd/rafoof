import 'package:flutter/material.dart';
import 'package:rafoof/core/constants/app_constants.dart';
import 'package:rafoof/core/di/service_locator.dart';
import 'package:rafoof/features/categories/data/models/category_model.dart';
import 'package:rafoof/features/categories/data/repositories/category_repository.dart';
import 'package:rafoof/features/products/data/repositories/product_repository.dart';

class CategoriesProvider extends ChangeNotifier {
  CategoryRepository get _categoryRepository => sl<CategoryRepository>();
  ProductRepository get _productRepository => sl<ProductRepository>();

  List<CategoryModel> _categories = [];
  Map<String, String> _images = {};
  Map<String, int> _counts = {};
  int _selectedGroup = 0;
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  int get selectedGroup => _selectedGroup;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> get groupNames => AppConstants.categoryGroups.keys.toList();

  String get selectedGroupName => groupNames[_selectedGroup];

  List<CategoryModel> get groupCategories {
    final slugs = AppConstants.categoryGroups[selectedGroupName] ?? [];
    return _categories
        .where((category) => slugs.contains(category.slug))
        .toList();
  }

  String? imageOf(String slug) => _images[slug];

  int countOf(String slug) => _counts[slug] ?? 0;

  int get groupProductCount =>
      groupCategories.fold(0, (sum, category) => sum + countOf(category.slug));

  int get totalProducts => _counts.values.fold(0, (sum, count) => sum + count);

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _categoryRepository.getCategories();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    try {
      final summary = await _productRepository.getCategorySummary();
      _images = summary.images;
      _counts = summary.counts;
    } catch (_) {
      _images = {};
      _counts = {};
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectGroup(int index) {
    _selectedGroup = index;
    notifyListeners();
  }
}
