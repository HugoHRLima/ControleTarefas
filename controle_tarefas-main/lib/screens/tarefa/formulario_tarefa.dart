import 'package:flutter/material.dart';
import '../../components/editor.dart';
import '../../models/tarefa.dart';
import '../../repository/configuracao_persistencia.dart';
import '../../repository/tarefa_repository.dart';

class FormularioTarefa extends StatefulWidget {
  final Tarefa? tarefa;

  const FormularioTarefa({super.key, this.tarefa});

  @override
  State<FormularioTarefa> createState() => FormularioTarefaState();
}

class FormularioTarefaState extends State<FormularioTarefa> {
  late final TextEditingController _controladorTitulo;
  late final TextEditingController _controladorDescricao;
  bool _salvando = false;

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    _controladorTitulo = TextEditingController(
      text: widget.tarefa?.titulo ?? '',
    );
    _controladorDescricao = TextEditingController(
      text: widget.tarefa?.descricao ?? '',
    );
  }

  @override
  void dispose() {
    _controladorTitulo.dispose();
    _controladorDescricao.dispose();
    super.dispose();
  }

  Future<void> _salvarTarefa() async {
    final titulo = _controladorTitulo.text.trim();
    final descricao = _controladorDescricao.text.trim();

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o título da tarefa.')),
      );
      return;
    }

    final tarefa = Tarefa(
      id: widget.tarefa?.id,
      titulo: titulo,
      descricao: descricao,
      concluida: widget.tarefa?.concluida ?? false,
    );

    try {
      setState(() {
        _salvando = true;
      });

      if (_editando) {
        await RepositorioTarefa.instancia.atualizarTarefa(tarefa);
      } else {
        await RepositorioTarefa.instancia.salvarTarefa(tarefa);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Tarefa atualizada com sucesso.'
                : 'Tarefa salva com sucesso.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (erro) {
      if (!mounted) return;

      final mensagem = erro.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ConfiguracaoPersistencia.origem == OrigemPersistencia.remota
                ? 'Erro na API: $mensagem'
                : 'Erro ao salvar tarefa: $mensagem',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Tarefa' : 'Nova Tarefa'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Editor(
              controlador: _controladorTitulo,
              rotulo: 'Título',
              dica: 'Ex: Estudar Flutter',
              icone: Icons.title,
              tipoTeclado: TextInputType.text,
            ),
            Editor(
              controlador: _controladorDescricao,
              rotulo: 'Descrição',
              dica: 'Ex: Ler capítulo sobre Widgets',
              icone: Icons.description,
              tipoTeclado: TextInputType.multiline,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvarTarefa,
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
