class ProductModel {
  final int? id;
  final String? nome;
  final String? descricao;
  final double? precoCusto;
  final String? foto;

  ProductModel({
    this.id,
    this.nome,
    this.descricao,
    this.precoCusto,
    this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'descricao': descricao,
      'precoCusto': precoCusto,
      'foto': foto,
      'isDeleted': 0,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      nome: map['nome'] as String?,
      descricao: map['descricao'] as String?,
      precoCusto: (map['precoCusto'] as num?)?.toDouble(),
      foto: map['foto'] as String?,
    );
  }

  ProductModel copyWith({
    int? id,
    String? nome,
    String? descricao,
    double? precoCusto,
    String? foto,
  }) {
    return ProductModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      precoCusto: precoCusto ?? this.precoCusto,
      foto: foto ?? this.foto,
    );
  }
}
