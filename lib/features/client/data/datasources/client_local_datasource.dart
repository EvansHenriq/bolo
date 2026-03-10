import 'package:confeito/core/database/database_helper.dart';
import 'package:confeito/features/client/data/models/client_model.dart';

class ClientLocalDatasource {
  final DatabaseHelper _dbHelper;

  ClientLocalDatasource(this._dbHelper);

  Future<List<ClientModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tbCliente',
      where: 'isDeleted = ?',
      whereArgs: [0],
    );
    return maps.map((m) => ClientModel.fromMap(m)).toList();
  }

  Future<ClientModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tbCliente',
      where: 'id = ? AND isDeleted = ?',
      whereArgs: [id, 0],
    );
    if (maps.isEmpty) return null;
    return ClientModel.fromMap(maps.first);
  }

  Future<int> insert(ClientModel client) async {
    final db = await _dbHelper.database;
    return await db.insert('tbCliente', client.toMap());
  }

  Future<int> update(ClientModel client) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tbCliente',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> softDelete(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tbCliente',
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
