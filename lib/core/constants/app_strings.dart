class AppStrings {
  static String languageCode = 'en';

  static bool get isArabic => languageCode == 'ar';

  static String _text(String english, String arabic) =>
      isArabic ? arabic : english;

  static String _count(
    int count, {
    required String englishOne,
    required String englishMany,
    required String arabicOne,
    required String arabicTwo,
    required String arabicFew,
    required String arabicMany,
  }) {
    if (!isArabic) {
      return count == 1 ? '1 $englishOne' : '$count $englishMany';
    }
    if (count == 1) return arabicOne;
    if (count == 2) return arabicTwo;
    if (count >= 3 && count <= 10) return '$count $arabicFew';
    return '$count $arabicMany';
  }

  static String get appName => _text("Rafoof", "رفوف");

  static String get navHome => _text("Home", "الرئيسية");
  static String get navCategories => _text("Categories", "الأقسام");
  static String get navCart => _text("Cart", "السلة");
  static String get navAccount => _text("Account", "حسابي");

  static String get invalidCredentials => _text(
    "Invalid username or password.",
    "اسم المستخدم أو كلمة المرور غير صحيحة.",
  );
  static String get connectionTimeout => _text(
    "Connection timed out. Please check your internet connection.",
    "انتهت مهلة الاتصال. تأكد من اتصالك بالإنترنت.",
  );
  static String get serverError => _text("Server error.", "خطأ في الخادم.");
  static String get accessDenied => _text("Access denied.", "تم رفض الوصول.");
  static String get serverUnavailable =>
      _text("Server is currently unavailable.", "الخادم غير متاح حالياً.");
  static String get requestCancelled =>
      _text("Request cancelled.", "تم إلغاء الطلب.");
  static String get noInternet =>
      _text("No internet connection.", "لا يوجد اتصال بالإنترنت.");
  static String get somethingWentWrong => _text(
    "Something went wrong. Please try again.",
    "حدث خطأ ما. حاول مرة أخرى.",
  );

  static String get loadProductsFailed => _text(
    "Failed to load products. Please try again.",
    "تعذّر تحميل المنتجات. حاول مرة أخرى.",
  );
  static String get loadProductFailed => _text(
    "Failed to load this product. Please try again.",
    "تعذّر تحميل هذا المنتج. حاول مرة أخرى.",
  );
  static String get loadCategoriesFailed => _text(
    "Failed to load categories. Please try again.",
    "تعذّر تحميل الأقسام. حاول مرة أخرى.",
  );

  static String get retry => _text("Retry", "إعادة المحاولة");
  static String get noProducts =>
      _text("No products found.", "لا توجد منتجات.");

  static String get searchHint => _text("Search products", "ابحث عن منتج");
  static String get todaysDeals => _text("TODAY'S DEALS", "عروض اليوم");
  static String freshPicks(int categoriesCount) => categoriesCount == 0
      ? _text("Fresh picks\nfor you", "اختيارات جديدة\nلك")
      : _text(
          "Fresh picks from\n${categories(categoriesCount)}",
          "اختيارات جديدة من\n${categories(categoriesCount)}",
        );
  static String get shopNow => _text("Shop now", "تسوّق الآن");
  static String get shopByCategory =>
      _text("Shop by category", "تسوّق حسب القسم");
  static String get seeAll => _text("See all", "عرض الكل");
  static String get topRated => _text("Top rated", "الأعلى تقييماً");

  static String items(int count) => _count(
    count,
    englishOne: "item",
    englishMany: "items",
    arabicOne: "منتج واحد",
    arabicTwo: "منتجان",
    arabicFew: "منتجات",
    arabicMany: "منتج",
  );
  static String products(int count) => _count(
    count,
    englishOne: "product",
    englishMany: "products",
    arabicOne: "منتج واحد",
    arabicTwo: "منتجان",
    arabicFew: "منتجات",
    arabicMany: "منتج",
  );
  static String categories(int count) => _count(
    count,
    englishOne: "category",
    englishMany: "categories",
    arabicOne: "قسم واحد",
    arabicTwo: "قسمان",
    arabicFew: "أقسام",
    arabicMany: "قسم",
  );
  static String units(int count) => _count(
    count,
    englishOne: "unit",
    englishMany: "units",
    arabicOne: "قطعة واحدة",
    arabicTwo: "قطعتان",
    arabicFew: "قطع",
    arabicMany: "قطعة",
  );
  static String results(int count) => _count(
    count,
    englishOne: "result",
    englishMany: "results",
    arabicOne: "نتيجة واحدة",
    arabicTwo: "نتيجتان",
    arabicFew: "نتائج",
    arabicMany: "نتيجة",
  );
  static String reviewsCount(int count) => _count(
    count,
    englishOne: "review",
    englishMany: "reviews",
    arabicOne: "تقييم واحد",
    arabicTwo: "تقييمان",
    arabicFew: "تقييمات",
    arabicMany: "تقييم",
  );
  static String orders(int count) => _count(
    count,
    englishOne: "order",
    englishMany: "orders",
    arabicOne: "طلب واحد",
    arabicTwo: "طلبان",
    arabicFew: "طلبات",
    arabicMany: "طلب",
  );

  static String get sortTopRated => _text("Top rated", "الأعلى تقييماً");
  static String get sortPriceLow =>
      _text("Price: low to high", "السعر: من الأقل للأعلى");
  static String get sortPriceHigh =>
      _text("Price: high to low", "السعر: من الأعلى للأقل");
  static String get sortName => _text("Name: A to Z", "الاسم أبجدياً");

  static String get inStock => _text("In stock", "متوفر");
  static String stockLeft(int count) => _text("$count left", "متبقي $count");
  static String availability(String status) {
    if (!isArabic) return status;
    switch (status.toLowerCase()) {
      case 'in stock':
        return "متوفر";
      case 'low stock':
        return "كمية محدودة";
      case 'out of stock':
        return "غير متوفر";
      default:
        return status;
    }
  }

  static String get sku => _text("SKU", "رمز المنتج");
  static String get description => _text("Description", "الوصف");
  static String get reviewsTitle => _text("Reviews", "التقييمات");
  static String get minimumOrder => _text("Minimum order", "الحد الأدنى للطلب");
  static String get addToCart => _text("Add to cart", "أضف إلى السلة");
  static String get addedToCart =>
      _text("Added to cart.", "تمت الإضافة إلى السلة.");
  static String get addedToCartLabel => _text("Added to cart", "تمت الإضافة");
  static String get noMoreStock => _text(
    "No more stock for this product.",
    "لا يوجد مخزون إضافي لهذا المنتج.",
  );

  static String get each => _text("each", "للقطعة");
  static String get clearCart => _text("Clear cart", "إفراغ السلة");
  static String get clearCartQuestion => _text(
    "Remove all products from your cart?",
    "هل تريد حذف كل المنتجات من السلة؟",
  );
  static String get clear => _text("Clear", "إفراغ");
  static String get cancel => _text("Cancel", "إلغاء");
  static String get subtotal => _text("Subtotal", "المجموع الفرعي");
  static String get discounts => _text("Discounts", "الخصومات");
  static String get shipping => _text("Shipping", "الشحن");
  static String get shippingAtCheckout =>
      _text("Calculated at checkout", "يُحسب عند الدفع");
  static String get total => _text("Total", "الإجمالي");
  static String get checkout => _text("Checkout", "إتمام الشراء");
  static String get placeOrderFailed => _text(
    "Failed to place your order. Please try again.",
    "تعذّر إرسال طلبك. حاول مرة أخرى.",
  );
  static String get orderPlaced => _text("Order placed!", "تم تأكيد طلبك!");
  static String orderTitle(int id) => _text("Order #$id", "طلب رقم $id");
  static String get itemsCountLabel => _text("Items", "المنتجات");
  static String get orderPlacedHint => _text(
    "This is a demo order from DummyJSON, nothing will be shipped.",
    "هذا طلب تجريبي من DummyJSON، ولن يتم شحن أي شيء.",
  );
  static String get continueShopping =>
      _text("Continue shopping", "متابعة التسوق");

  static String get myOrders => _text("My orders", "طلباتي");
  static String get noOrders => _text("No orders yet", "لا توجد طلبات بعد");
  static String get noOrdersHint => _text(
    "Orders you place will show up here.",
    "ستظهر هنا الطلبات التي تتمها.",
  );

  static String get wishlist => _text("Wishlist", "المفضلة");
  static String get emptyWishlist =>
      _text("Your wishlist is empty", "قائمة المفضلة فارغة");
  static String get emptyWishlistHint => _text(
    "Tap the heart on any product to save it here.",
    "اضغط على القلب في أي منتج لحفظه هنا.",
  );
  static String get emptyCart => _text("Your cart is empty", "سلتك فارغة");
  static String get emptyCartHint => _text(
    "Products you add will show up here.",
    "ستظهر هنا المنتجات التي تضيفها.",
  );
  static String get startShopping => _text("Start shopping", "ابدأ التسوق");

  static String get searching => _text("Searching…", "جارٍ البحث…");
  static String forQuery(String query) => _text('for "$query"', 'عن "$query"');
  static String showAllResults(int count) =>
      _text("Show all ${results(count)}", "عرض كل النتائج ($count)");
  static String get recentSearches =>
      _text("Recent searches", "عمليات البحث الأخيرة");

  static String get signIn => _text("Sign in", "تسجيل الدخول");
  static String get welcomeBack => _text("Welcome back.", "أهلاً بعودتك.");
  static String get signInSubtitle => _text(
    "Sign in to see your account and saved details.",
    "سجّل دخولك لرؤية حسابك وبياناتك المحفوظة.",
  );
  static String get username => _text("Username", "اسم المستخدم");
  static String get password => _text("Password", "كلمة المرور");
  static String get enterUsername =>
      _text("Enter your username.", "أدخل اسم المستخدم.");
  static String get enterPassword =>
      _text("Enter your password.", "أدخل كلمة المرور.");
  static String get keepSignedIn => _text("Keep me signed in", "تذكّرني");
  static String get continueAsGuest =>
      _text("Continue as guest", "المتابعة كضيف");
  static String get demoAccount => _text(
    "Demo account from the DummyJSON docs: ",
    "حساب تجريبي من توثيق DummyJSON: ",
  );
  static String get loadUserFailed => _text(
    "Failed to load your account. Please try again.",
    "تعذّر تحميل حسابك. حاول مرة أخرى.",
  );

  static String get guest => _text("Guest", "ضيف");
  static String get signedInStatus => _text(
    "Signed in · session renews automatically",
    "تم تسجيل الدخول · تتجدد الجلسة تلقائياً",
  );
  static String get appearance => _text("Appearance", "المظهر");
  static String get savedOnDevice =>
      _text("Saved on this device", "محفوظ على هذا الجهاز");
  static String get light => _text("Light", "فاتح");
  static String get dark => _text("Dark", "داكن");
  static String get language => _text("Language", "اللغة");
  static const String english = "English";
  static const String arabic = "العربية";
  static String get email => _text("Email", "البريد الإلكتروني");
  static String get shippingAddress => _text("Shipping address", "عنوان الشحن");
  static String get myCart => _text("My cart", "سلتي");
  static String get signOut => _text("Sign out", "تسجيل الخروج");

  static String categoryGroup(String name) {
    if (!isArabic) return name;
    const names = {
      'Home & kitchen': 'المنزل والمطبخ',
      'Electronics': 'إلكترونيات',
      'Women': 'نساء',
      'Groceries': 'بقالة',
      'Sports': 'رياضة',
      'Men': 'رجال',
      'Beauty': 'تجميل',
      'Vehicles': 'مركبات',
      'Sunglasses': 'نظارات شمسية',
    };
    return names[name] ?? name;
  }

  static String categoryName(String slug, String fallback) {
    if (!isArabic) return fallback;
    const names = {
      'beauty': 'تجميل',
      'fragrances': 'عطور',
      'furniture': 'أثاث',
      'groceries': 'بقالة',
      'home-decoration': 'ديكور المنزل',
      'kitchen-accessories': 'أدوات المطبخ',
      'laptops': 'لابتوبات',
      'mens-shirts': 'قمصان رجالية',
      'mens-shoes': 'أحذية رجالية',
      'mens-watches': 'ساعات رجالية',
      'mobile-accessories': 'إكسسوارات الجوال',
      'motorcycle': 'دراجات نارية',
      'skin-care': 'العناية بالبشرة',
      'smartphones': 'هواتف ذكية',
      'sports-accessories': 'إكسسوارات رياضية',
      'sunglasses': 'نظارات شمسية',
      'tablets': 'أجهزة لوحية',
      'tops': 'بلوزات',
      'vehicle': 'سيارات',
      'womens-bags': 'حقائب نسائية',
      'womens-dresses': 'فساتين',
      'womens-jewellery': 'مجوهرات نسائية',
      'womens-shoes': 'أحذية نسائية',
      'womens-watches': 'ساعات نسائية',
    };
    return names[slug] ?? fallback;
  }
}
