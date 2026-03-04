import 'package:bolo/core/database/database_helper.dart';
import 'package:bolo/features/order/data/models/order_item_model.dart';
import 'package:bolo/features/order/data/models/order_model.dart';

class OrderLocalDatasource {
  final DatabaseHelper _dbHelper;

  OrderLocalDatasource(this._dbHelper);

  Future<List<OrderModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tbPedido',
      where: 'isDeleted = ?',
      whereArgs: [0],
    );
    return maps.map((m) => OrderModel.fromMap(m)).toList();
  }

  Future<List<OrderModel>> getByMonth(int year, int month) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tbPedido',
      where: 'isDeleted = ?',
      whereArgs: [0],
    );
    final allOrders = maps.map((m) => OrderModel.fromMap(m)).toList();
    return allOrders.where((order) {
      if (order.dataHora == null) return false;
      return order.dataHora!.year == year && order.dataHora!.month == month;
    }).toList();
  }

  Future<OrderModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tbPedido',
      where: 'id = ? AND isDeleted = ?',
      whereArgs: [id, 0],
    );
    if (maps.isEmpty) return null;

    final items = await getItemsByOrderId(id);
    return OrderModel.fromMap(maps.first, items: items);
  }

  Future<List<OrderItemModel>> getItemsByOrderId(int orderId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tbItensPedido',
      where: 'tbPedidoId = ? AND isDeleted = ?',
      whereArgs: [orderId, 0],
    );
    return maps.map((m) => OrderItemModel.fromMap(m)).toList();
  }

  Future<int> insert(OrderModel order) async {
    final db = await _dbHelper.database;
    final orderId = await db.insert('tbPedido', order.toMap());

    for (final item in order.items) {
      item.tbPedidoId = orderId;
      await db.insert('tbItensPedido', item.toMap());
    }

    return orderId;
  }

  Future<int> update(OrderModel order) async {
    final db = await _dbHelper.database;

    await db.update(
      'tbPedido',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );

    // Delete existing items and re-insert
    await db.delete(
      'tbItensPedido',
      where: 'tbPedidoId = ?',
      whereArgs: [order.id],
    );

    for (final item in order.items) {
      item.tbPedidoId = order.id;
      await db.insert('tbItensPedido', item.toMap());
    }

    return order.id!;
  }

  Future<int> softDelete(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tbPedido',
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
