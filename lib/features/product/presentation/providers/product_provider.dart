import 'package:flutter/foundation.dart';
import 'package:bolo/features/product/data/models/product_model.dart';
import 'package:bolo/features/product/data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider(this._repository);

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    _products = await _repository.getProducts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProduct(ProductModel product) async {
    await _repository.saveProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _repository.deleteProduct(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
