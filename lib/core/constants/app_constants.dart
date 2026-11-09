class AppConstants {
  static const String authTokenKey = "auth_token";
  static const String refreshTokenKey = "refresh_token";
  static const int tokenExpiresInMins = 30;
  static const String languageKey = "language";

  static const int bannerProductId = 173;

  static const Map<String, List<String>> categoryGroups = {
    'Home & kitchen': ['kitchen-accessories', 'furniture', 'home-decoration'],
    'Electronics': ['smartphones', 'mobile-accessories', 'laptops', 'tablets'],
    'Women': [
      'womens-dresses',
      'womens-shoes',
      'womens-bags',
      'womens-watches',
      'tops',
      'womens-jewellery',
    ],
    'Groceries': ['groceries'],
    'Sports': ['sports-accessories'],
    'Men': ['mens-shirts', 'mens-shoes', 'mens-watches'],
    'Beauty': ['beauty', 'fragrances', 'skin-care'],
    'Vehicles': ['vehicle', 'motorcycle'],
    'Sunglasses': ['sunglasses'],
  };
}
