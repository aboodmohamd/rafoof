import 'package:rafoof/core/database/database_helper.dart';
import 'package:rafoof/core/database/tables/cart_table.dart';
import 'package:rafoof/core/database/tables/orders_table.dart';
import 'package:rafoof/core/database/tables/wishlist_table.dart';
import 'package:sqflite/sqlite_api.dart';

class AppDatabase {
  final DatabaseHelper provider;

  AppDatabase(this.provider);

  Future<void> delete({
    required String tableName,
    String? where,
    List<Object?>? listWhere,
  }) async {
    final db = await provider.database;
    await db.delete(tableName, where: where, whereArgs: listWhere);
  }

  Future<void> insertCart(Map<String, dynamic> data) async {
    final db = await provider.database;
    await db.insert(
      CartTable.tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCart() async {
    final db = await provider.database;
    return await db.query(CartTable.tableName);
  }

  Future<void> deleteCartItem({required int productId}) async {
    final db = await provider.database;
    await db.delete(
      CartTable.tableName,
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<void> updateCartQuantity({
    required int productId,
    required int quantity,
  }) async {
    final Database db = await provider.database;
    await db.update(
      CartTable.tableName,
      {'quantity': quantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<void> insertWishlist(Map<String, dynamic> data) async {
    final db = await provider.database;
    await db.insert(
      WishlistTable.tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getWishlist() async {
    final db = await provider.database;
    return await db.query(WishlistTable.tableName, orderBy: 'id DESC');
  }

  Future<void> deleteFromWishlist(int productId) async {
    final db = await provider.database;
    await db.delete(
      WishlistTable.tableName,
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<void> insertOrder(Map<String, dynamic> data) async {
    final db = await provider.database;
    await db.insert(OrdersTable.tableName, data);
  }

  Future<List<Map<String, dynamic>>> getOrders(int userId) async {
    final db = await provider.database;
    return await db.query(
      OrdersTable.tableName,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }
}
