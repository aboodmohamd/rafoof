import 'package:sqflite/sqlite_api.dart';

class OrdersTable {
  static const String tableName = 'orders';

  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER,
        userId INTEGER,
        total REAL,
        discountedTotal REAL,
        totalProducts INTEGER,
        totalQuantity INTEGER,
        image TEXT,
        createdAt TEXT
      )
    ''');
  }
}
