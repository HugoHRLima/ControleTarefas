import 'package:flutter/material.dart';
import '../../models/tarefa.dart';

class FormularioTarefa extends StatefulWidget {
  final TextEditingController _controladorTitulo = TextEditingController();
  final TextEditingController _controladorDescricao = TextEditingController();

  FormularioTarefa({super.key});

  @override
  State<StatefulWidget> createState() => FormularioTarefaState();
}

class FormularioTarefaState extends State<FormularioTarefa> {
  static const _tituloAppBar = 'Nova Tarefa';
  static const _textBotaoConfirmar = 'Salvar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_tituloAppBar)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: widget._controladorTitulo,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ex: Estudar Flutter',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget._controladorDescricao,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Ex: Ler capítulo sobre Widgets',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text(_textBotaoConfirmar),
              onPressed: () {
                final tarefaCriada = Tarefa(
                  widget._controladorTitulo.text,
                  widget._controladorDescricao.text,
                );
                Navigator.pop(context, tarefaCriada);
              },
            ),
          ],
        ),
      ),
    );
  }
}
