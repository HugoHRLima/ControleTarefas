class Tarefa {
  final String titulo;
  final String descricao;

  Tarefa(this.titulo, this.descricao);

  @override
  String toString() {
    return 'Tarefa: $titulo - $descricao';
  }
}
