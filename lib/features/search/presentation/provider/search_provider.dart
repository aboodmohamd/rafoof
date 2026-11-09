import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rafoof/core/di/service_locator.dart';
import 'package:rafoof/core/services/app_preferences.dart';
import 'package:rafoof/features/products/data/models/product_model.dart';
import 'package:rafoof/features/products/data/repositories/product_repository.dart';

class SearchProvider extends ChangeNotifier {
  ProductRepository get _productRepository => sl<ProductRepository>();
  AppPreferences get _appPreferences => sl<AppPreferences>();

  static const int _previewSize = 6;
  static const int _maxRecentSearches = 6;

  String _query = '';
  List<ProductModel> _results = [];
  int _total = 0;
  bool _isLoading = false;
  String? _error;
  List<String> _recentSearches = [];
  Timer? _debounce;
  int _requestId = 0;

  String get query => _query;
  List<ProductModel> get results => _results;
  int get total => _total;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get recentSearches => _recentSearches;

  void loadRecentSearches() {
    _recentSearches = _appPreferences.getRecentSearches();
    notifyListeners();
  }

  void onQueryChanged(String value) {
    _debounce?.cancel();
    _query = value.trim();

    if (_query.isEmpty) {
      _clearResults();
    } else {
      _debounce = Timer(const Duration(milliseconds: 500), search);
    }
    notifyListeners();
  }

  Future<void> search() async {
    _debounce?.cancel();
    if (_query.isEmpty) return;

    final requestId = ++_requestId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final page = await _productRepository.getProducts(
        limit: _previewSize,
        searchQuery: _query,
      );
      if (requestId != _requestId) return;
      _results = page.products;
      _total = page.total;
    } catch (e) {
      if (requestId != _requestId) return;
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchFor(String value) {
    _query = value.trim();
    saveRecentSearch();
    search();
  }

  void clearQuery() {
    _debounce?.cancel();
    _query = '';
    _clearResults();
    notifyListeners();
  }

  Future<void> saveRecentSearch() async {
    if (_query.isEmpty) return;

    _recentSearches = [
      _query,
      ..._recentSearches.where(
        (search) => search.toLowerCase() != _query.toLowerCase(),
      ),
    ].take(_maxRecentSearches).toList();
    notifyListeners();
    await _appPreferences.setRecentSearches(_recentSearches);
  }

  Future<void> removeRecentSearch(String value) async {
    _recentSearches = _recentSearches
        .where((search) => search != value)
        .toList();
    notifyListeners();
    await _appPreferences.setRecentSearches(_recentSearches);
  }

  void _clearResults() {
    _requestId++;
    _results = [];
    _total = 0;
    _isLoading = false;
    _error = null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
