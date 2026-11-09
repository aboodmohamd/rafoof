class ApiEndpoints {
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String login = '/auth/login';
  static const String currentUser = '/auth/me';
  static const String refreshToken = '/auth/refresh';

  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/categories';
  static const String categoryProducts = '/products/category';

  static const String addCart = '/carts/add';
}
