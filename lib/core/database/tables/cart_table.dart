import 'package:sqflite/sqlite_api.dart';

class CartTable {
  static const String tableName = 'cart';

  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER UNIQUE,
        name TEXT,
        price REAL,
        discountPercentage REAL,
        quantity INTEGER,
        image TEXT,
        stock INTEGER,
        minimumOrderQuantity INTEGER
      )
    ''');
  }
}
