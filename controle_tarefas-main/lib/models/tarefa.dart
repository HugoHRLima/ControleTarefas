class Tarefa {
  final String titulo;
  final String descricao;
  bool concluida;

  Tarefa(this.titulo, this.descricao, {this.concluida = false});

  @override
  String toString() {
    return "Tarefa{titulo: $titulo, descricao: $descricao, concluida: $concluida}";
  }
}
