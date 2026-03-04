class OrderItemModel {
  int? id;
  String? nome;
  String? descricao;
  double? precoCusto;
  int? quantidade;
  int? tbPedidoId;

  OrderItemModel({
    this.id,
    this.nome,
    this.descricao,
    this.precoCusto,
    this.quantidade,
    this.tbPedidoId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'descricao': descricao,
      'precoCusto': precoCusto,
      'quantidade': quantidade,
      'tbPedidoId': tbPedidoId,
      'isDeleted': 0,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as int?,
      nome: map['nome'] as String?,
      descricao: map['descricao'] as String?,
      precoCusto: (map['precoCusto'] as num?)?.toDouble(),
      quantidade: map['quantidade'] as int?,
      tbPedidoId: map['tbPedidoId'] as int?,
    );
  }

  OrderItemModel copyWith({
    int? id,
    String? nome,
    String? descricao,
    double? precoCusto,
    int? quantidade,
    int? tbPedidoId,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      precoCusto: precoCusto ?? this.precoCusto,
      quantidade: quantidade ?? this.quantidade,
      tbPedidoId: tbPedidoId ?? this.tbPedidoId,
    );
  }
}
