import 'package:flutter/material.dart';
import '../../models/tarefa.dart';
import 'formulario_tarefa.dart';

class ListaTarefas extends StatefulWidget {
  final List<Tarefa> _tarefas = [];

  ListaTarefas({super.key});

  @override
  State<StatefulWidget> createState() => ListaTarefasState();
}

class ListaTarefasState extends State<ListaTarefas> {
  static const _tituloAppBar = 'Minhas Tarefas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_tituloAppBar)),
      body: ListView.builder(
        itemCount: widget._tarefas.length,
        itemBuilder: (context, indice) {
          final tarefa = widget._tarefas[indice];
          return ItemTarefa(
            tarefa: tarefa,
            onDelete: () {
              setState(() {
                widget._tarefas.removeAt(indice);
              });
            },
            onToggleConcluida: () {
              setState(() {
                tarefa.concluida = !tarefa.concluida;
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormularioTarefa()),
          ).then((tarefaRecebida) => _atualiza(tarefaRecebida));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _atualiza(Tarefa? tarefaRecebida) {
    if (tarefaRecebida != null) {
      setState(() {
        widget._tarefas.add(tarefaRecebida);
      });
    }
  }
}

class ItemTarefa extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback onDelete;
  final VoidCallback onToggleConcluida;

  const ItemTarefa({
    super.key,
    required this.tarefa,
    required this.onDelete,
    required this.onToggleConcluida,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: tarefa.concluida,
          onChanged: (_) => onToggleConcluida(),
        ),
        title: Text(
          tarefa.titulo,
          style: TextStyle(
            decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(tarefa.descricao),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
