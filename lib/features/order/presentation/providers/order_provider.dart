import 'package:flutter/foundation.dart';
import 'package:confeito/features/order/data/models/order_model.dart';
import 'package:confeito/features/order/data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;

  OrderProvider(this._repository);

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    _orders = await _repository.getOrders();
    _isLoading = false;
    notifyListeners();
  }

  Future<OrderModel?> getOrderWithItems(int id) async {
    return await _repository.getOrder(id);
  }

  Future<void> saveOrder(OrderModel order) async {
    await _repository.saveOrder(order);
    await loadOrders();
  }

  Future<void> deleteOrder(int id) async {
    await _repository.deleteOrder(id);
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
  }
}
