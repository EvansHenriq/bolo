import 'package:confeito/features/product/data/datasources/product_local_datasource.dart';
import 'package:confeito/features/product/data/models/product_model.dart';

class ProductRepository {
  final ProductLocalDatasource _datasource;

  ProductRepository(this._datasource);

  Future<List<ProductModel>> getProducts() => _datasource.getAll();
  Future<ProductModel?> getProduct(int id) => _datasource.getById(id);

  Future<int> saveProduct(ProductModel product) {
    if (product.id != null) {
      return _datasource.update(product);
    }
    return _datasource.insert(product);
  }

  Future<int> deleteProduct(int id) => _datasource.softDelete(id);
}
