class Tarefa {
  final int? id;
  final String titulo;
  final String descricao;
  bool concluida;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida ? 1 : 0,
    };
  }

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'] ?? '',
      concluida: json['concluida'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
    };
  }

  @override
  String toString() {
    return 'Tarefa{id: $id, titulo: $titulo, descricao: $descricao, concluida: $concluida}';
  }
}
