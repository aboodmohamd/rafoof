import 'package:rafoof/core/database/tables/cart_table.dart';
import 'package:rafoof/core/database/tables/orders_table.dart';
import 'package:rafoof/core/database/tables/wishlist_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final String dbPath = join(await getDatabasesPath(), 'app.db');

    return await openDatabase(
      dbPath,
      version: 5,
      onCreate: (db, version) async {
        await CartTable.create(db);
        await WishlistTable.create(db);
        await OrdersTable.create(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS ${CartTable.tableName}');
          await CartTable.create(db);
        }
        if (oldVersion < 4) {
          await db.execute('DROP TABLE IF EXISTS ${WishlistTable.tableName}');
          await WishlistTable.create(db);
        }
        if (oldVersion < 5) {
          await db.execute('DROP TABLE IF EXISTS notification');
          await OrdersTable.create(db);
        }
      },
    );
  }
}
