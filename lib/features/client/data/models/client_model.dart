class ClientModel {
  final int? id;
  final String? nome;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? uf;

  ClientModel({
    this.id,
    this.nome,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.uf,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'isDeleted': 0,
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] as int?,
      nome: map['nome'] as String?,
      logradouro: map['logradouro'] as String?,
      numero: map['numero'] as String?,
      complemento: map['complemento'] as String?,
      bairro: map['bairro'] as String?,
      cidade: map['cidade'] as String?,
      uf: map['uf'] as String?,
    );
  }

  ClientModel copyWith({
    int? id,
    String? nome,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? uf,
  }) {
    return ClientModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
    );
  }
}
