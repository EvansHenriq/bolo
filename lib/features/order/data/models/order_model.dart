import 'package:bolo/features/order/data/models/order_item_model.dart';

class OrderModel {
  final int? id;
  final String? nomeCliente;
  final DateTime? dataHora;
  final double? valorTotal;
  final int? tbClienteId;
  final List<OrderItemModel> items;

  OrderModel({
    this.id,
    this.nomeCliente,
    this.dataHora,
    this.valorTotal,
    this.tbClienteId,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nomeCliente': nomeCliente,
      'dataHora': dataHora?.toIso8601String(),
      'valorTotal': valorTotal,
      'tbClienteId': tbClienteId,
      'isDeleted': 0,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map,
      {List<OrderItemModel> items = const []}) {
    return OrderModel(
      id: map['id'] as int?,
      nomeCliente: map['nomeCliente'] as String?,
      dataHora: _parseDateTime(map['dataHora']),
      valorTotal: (map['valorTotal'] as num?)?.toDouble(),
      tbClienteId: map['tbClienteId'] as int?,
      items: items,
    );
  }

  /// Handles both ISO 8601 strings and millisecond epoch integers
  /// for backward compatibility with SqfEntity data.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    final str = value.toString();
    final asInt = int.tryParse(str);
    if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
    return DateTime.tryParse(str);
  }

  OrderModel copyWith({
    int? id,
    String? nomeCliente,
    DateTime? dataHora,
    double? valorTotal,
    int? tbClienteId,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      dataHora: dataHora ?? this.dataHora,
      valorTotal: valorTotal ?? this.valorTotal,
      tbClienteId: tbClienteId ?? this.tbClienteId,
      items: items ?? this.items,
    );
  }
}
