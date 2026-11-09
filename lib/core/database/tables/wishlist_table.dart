import 'package:sqflite/sqlite_api.dart';

class WishlistTable {
  static const String tableName = 'wishlist';

  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER UNIQUE,
        name TEXT,
        price REAL,
        discountPercentage REAL,
        rating REAL,
        category TEXT,
        image TEXT,
        stock INTEGER,
        minimumOrderQuantity INTEGER
      )
    ''');
  }
}
