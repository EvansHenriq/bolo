import 'package:bolo/features/order/data/datasources/order_local_datasource.dart';
import 'package:bolo/features/order/data/models/order_model.dart';

class OrderRepository {
  final OrderLocalDatasource _datasource;

  OrderRepository(this._datasource);

  Future<List<OrderModel>> getOrders() => _datasource.getAll();
  Future<List<OrderModel>> getOrdersByMonth(int year, int month) =>
      _datasource.getByMonth(year, month);
  Future<OrderModel?> getOrder(int id) => _datasource.getById(id);

  Future<int> saveOrder(OrderModel order) {
    if (order.id != null) {
      return _datasource.update(order);
    }
    return _datasource.insert(order);
  }

  Future<int> deleteOrder(int id) => _datasource.softDelete(id);
}
