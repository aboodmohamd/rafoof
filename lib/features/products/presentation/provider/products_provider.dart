import 'package:flutter/material.dart';
import 'package:rafoof/core/constants/app_strings.dart';
import 'package:rafoof/core/di/service_locator.dart';
import 'package:rafoof/features/products/data/models/product_model.dart';
import 'package:rafoof/features/products/data/models/sort_option.dart';
import 'package:rafoof/features/products/data/repositories/product_repository.dart';

class ProductsProvider extends ChangeNotifier {
  ProductRepository get _productRepository => sl<ProductRepository>();

  static const int _pageSize = 20;

  static List<SortOption> get sortOptions => [
    SortOption(label: AppStrings.sortTopRated, sortBy: 'rating', order: 'desc'),
    SortOption(label: AppStrings.sortPriceLow, sortBy: 'price', order: 'asc'),
    SortOption(label: AppStrings.sortPriceHigh, sortBy: 'price', order: 'desc'),
    SortOption(label: AppStrings.sortName, sortBy: 'title', order: 'asc'),
  ];

  List<ProductModel> _products = [];
  String _categorySlug = '';
  String _searchQuery = '';
  int _sortIndex = 0;
  int _total = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _requestId = 0;

  List<ProductModel> get products => _products;
  int get sortIndex => _sortIndex;
  SortOption get sortOption => sortOptions[_sortIndex];
  int get total => _total;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  void openList({
    String categorySlug = '',
    String searchQuery = '',
    int sortIndex = 0,
  }) {
    _categorySlug = categorySlug;
    _searchQuery = searchQuery;
    _sortIndex = sortIndex;
    _reset();
    loadMore();
  }

  void changeSort(int index) {
    if (index == _sortIndex) return;
    _sortIndex = index;
    _reset();
    loadMore();
  }

  Future<void> refresh() async {
    _reset();
    await loadMore();
  }

  void _reset() {
    _products = [];
    _total = 0;
    _hasMore = true;
    _isLoading = false;
    _error = null;
    _requestId++;
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    final requestId = _requestId;
    _isLoading = true;
    notifyListeners();

    try {
      final page = await _productRepository.getProducts(
        limit: _pageSize,
        skip: _products.length,
        sortBy: sortOption.sortBy,
        order: sortOption.order,
        categorySlug: _categorySlug,
        searchQuery: _searchQuery,
      );
      if (requestId != _requestId) return;
      _products = [..._products, ...page.products];
      _total = page.total;
      _hasMore = page.products.isNotEmpty && _products.length < page.total;
      _error = null;
    } catch (e) {
      if (requestId != _requestId) return;
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }
}
