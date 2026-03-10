import 'package:confeito/core/database/database_helper.dart';
import 'package:confeito/features/product/data/models/product_model.dart';

class ProductLocalDatasource {
  final DatabaseHelper _dbHelper;

  ProductLocalDatasource(this._dbHelper);

  Future<List<ProductModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tbProduto',
      where: 'isDeleted = ?',
      whereArgs: [0],
    );
    return maps.map((m) => ProductModel.fromMap(m)).toList();
  }

  Future<ProductModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'tbProduto',
      where: 'id = ? AND isDeleted = ?',
      whereArgs: [id, 0],
    );
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  Future<int> insert(ProductModel product) async {
    final db = await _dbHelper.database;
    return await db.insert('tbProduto', product.toMap());
  }

  Future<int> update(ProductModel product) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tbProduto',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> softDelete(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tbProduto',
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
