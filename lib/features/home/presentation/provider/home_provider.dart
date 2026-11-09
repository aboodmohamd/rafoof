import 'package:flutter/material.dart';
import 'package:rafoof/core/constants/app_constants.dart';
import 'package:rafoof/core/di/service_locator.dart';
import 'package:rafoof/features/categories/data/models/category_model.dart';
import 'package:rafoof/features/categories/data/repositories/category_repository.dart';
import 'package:rafoof/features/products/data/models/product_model.dart';
import 'package:rafoof/features/products/data/repositories/product_repository.dart';

class HomeProvider extends ChangeNotifier {
  ProductRepository get _productRepository => sl<ProductRepository>();
  CategoryRepository get _categoryRepository => sl<CategoryRepository>();

  ProductModel? _bannerProduct;
  List<CategoryModel> _categories = [];
  List<ProductModel> _topRated = [];
  Map<String, String> _categoryImages = {};

  bool _isLoadingBanner = false;
  bool _isLoadingCategories = false;
  bool _isLoadingTopRated = false;

  String? _categoriesError;
  String? _topRatedError;

  ProductModel? get bannerProduct => _bannerProduct;
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get topRated => _topRated;

  String? categoryImage(String slug) => _categoryImages[slug];

  bool get isLoadingBanner => _isLoadingBanner;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingTopRated => _isLoadingTopRated;

  String? get categoriesError => _categoriesError;
  String? get topRatedError => _topRatedError;

  Future<void> loadHome() async {
    await Future.wait([
      _loadBanner(),
      _loadCategories(),
      _loadCategoryImages(),
      _loadTopRated(),
    ]);
  }

  Future<void> _loadCategoryImages() async {
    try {
      final summary = await _productRepository.getCategorySummary();
      _categoryImages = summary.images;
    } catch (_) {
      _categoryImages = {};
    }
    notifyListeners();
  }

  Future<void> _loadBanner() async {
    _isLoadingBanner = true;
    notifyListeners();
    try {
      _bannerProduct = await _productRepository.getProduct(
        AppConstants.bannerProductId,
      );
    } catch (_) {
      _bannerProduct = null;
    }
    _isLoadingBanner = false;
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();
    try {
      _categories = await _categoryRepository.getCategories();
      _categoriesError = null;
    } catch (e) {
      _categoriesError = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoadingCategories = false;
    notifyListeners();
  }

  Future<void> _loadTopRated() async {
    _isLoadingTopRated = true;
    notifyListeners();
    try {
      final page = await _productRepository.getProducts(
        limit: 10,
        sortBy: 'rating',
        order: 'desc',
      );
      _topRated = page.products;
      _topRatedError = null;
    } catch (e) {
      _topRatedError = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoadingTopRated = false;
    notifyListeners();
  }
}
