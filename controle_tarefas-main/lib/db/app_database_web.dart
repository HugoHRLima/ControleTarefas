import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tarefa.dart';

const _chaveTarefas = 'tarefas_local_web';
const _chaveProximoId = 'tarefas_proximo_id_web';

Future<List<Tarefa>> buscarTarefasWeb() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_chaveTarefas);

  if (json == null || json.isEmpty) {
    return [];
  }

  final List<dynamic> lista = jsonDecode(json);

  return lista.map((item) {
    return Tarefa(
      id: item['id'],
      titulo: item['titulo'],
      descricao: item['descricao'] ?? '',
      concluida: item['concluida'] == true,
    );
  }).toList();
}

Future<void> _salvarListaWeb(List<Tarefa> tarefas) async {
  final prefs = await SharedPreferences.getInstance();
  final lista = tarefas
      .map(
        (t) => {
          'id': t.id,
          'titulo': t.titulo,
          'descricao': t.descricao,
          'concluida': t.concluida,
        },
      )
      .toList();

  await prefs.setString(_chaveTarefas, jsonEncode(lista));
}

Future<int> _proximoIdWeb() async {
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getInt(_chaveProximoId) ?? 1;
  await prefs.setInt(_chaveProximoId, id + 1);
  return id;
}

Future<int> salvarTarefaWeb(Tarefa tarefa) async {
  final tarefas = await buscarTarefasWeb();
  final id = await _proximoIdWeb();

  tarefas.insert(
    0,
    Tarefa(
      id: id,
      titulo: tarefa.titulo,
      descricao: tarefa.descricao,
      concluida: tarefa.concluida,
    ),
  );

  await _salvarListaWeb(tarefas);
  return id;
}

Future<void> atualizarTarefaWeb(Tarefa tarefa) async {
  final tarefas = await buscarTarefasWeb();
  final indice = tarefas.indexWhere((t) => t.id == tarefa.id);

  if (indice == -1) {
    throw Exception('Tarefa não encontrada');
  }

  tarefas[indice] = tarefa;
  await _salvarListaWeb(tarefas);
}

Future<void> deletarTarefaWeb(int id) async {
  final tarefas = await buscarTarefasWeb();
  tarefas.removeWhere((t) => t.id == id);
  await _salvarListaWeb(tarefas);
}
