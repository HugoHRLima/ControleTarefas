import 'package:flutter/material.dart';
import '../../models/tarefa.dart';
import '../../repository/configuracao_persistencia.dart';
import '../../repository/tarefa_repository.dart';
import 'formulario_tarefa.dart';

class ListaTarefas extends StatefulWidget {
  const ListaTarefas({super.key});

  @override
  State<ListaTarefas> createState() => ListaTarefasState();
}

class ListaTarefasState extends State<ListaTarefas> {
  static const _tituloAppBar = 'Minhas Tarefas';

  final List<Tarefa> _tarefas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    setState(() {
      _carregando = true;
    });

    try {
      final tarefas = await RepositorioTarefa.instancia.buscarTarefas();

      if (!mounted) return;

      setState(() {
        _tarefas
          ..clear()
          ..addAll(tarefas);
      });
    } catch (erro) {
      debugPrint('Erro ao carregar tarefas: $erro');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ConfiguracaoPersistencia.origem == OrigemPersistencia.remota
                ? 'Erro ao carregar da API. Verifique a URL no Render ou use modo Local.'
                : 'Erro ao carregar tarefas.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _alternarConcluida(Tarefa tarefa) async {
    tarefa.concluida = !tarefa.concluida;

    try {
      await RepositorioTarefa.instancia.atualizarTarefa(tarefa);

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tarefa.concluida
                ? 'Tarefa marcada como concluída.'
                : 'Tarefa marcada como pendente.',
          ),
        ),
      );
    } catch (erro) {
      tarefa.concluida = !tarefa.concluida;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar tarefa: $erro')),
      );
    }
  }

  Future<void> _excluirTarefa(Tarefa tarefa, int indice) async {
    if (tarefa.id == null) return;

    try {
      await RepositorioTarefa.instancia.deletarTarefa(tarefa.id!);

      if (!mounted) return;

      setState(() {
        _tarefas.removeAt(indice);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa excluída com sucesso.')),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir tarefa: $erro')),
      );
    }
  }

  Future<void> _abrirFormulario({Tarefa? tarefa}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioTarefa(tarefa: tarefa),
      ),
    );

    await _carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_tituloAppBar),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                ConfiguracaoPersistencia.descricao,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _tarefas.isEmpty
          ? const Center(child: Text('Nenhuma tarefa encontrada.'))
          : ListView.builder(
              itemCount: _tarefas.length,
              itemBuilder: (context, indice) {
                final tarefa = _tarefas[indice];
                return ItemTarefa(
                  tarefa: tarefa,
                  onDelete: () => _excluirTarefa(tarefa, indice),
                  onToggleConcluida: () => _alternarConcluida(tarefa),
                  onTap: () => _abrirFormulario(tarefa: tarefa),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ItemTarefa extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback onDelete;
  final VoidCallback onToggleConcluida;
  final VoidCallback onTap;

  const ItemTarefa({
    super.key,
    required this.tarefa,
    required this.onDelete,
    required this.onToggleConcluida,
    required this.onTap,
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
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
