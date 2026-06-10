import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/tarefa.dart';
import 'app_database_web.dart' as web;

Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'tarefas.db');

  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE tarefas(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          descricao TEXT,
          concluida INTEGER DEFAULT 0
        )
      ''');
    },
  );
}

Future<int> salvarTarefa(Tarefa tarefa) async {
  if (kIsWeb) {
    return web.salvarTarefaWeb(tarefa);
  }

  final Database db = await getDatabase();

  return db.insert('tarefas', {
    'titulo': tarefa.titulo,
    'descricao': tarefa.descricao,
    'concluida': tarefa.concluida ? 1 : 0,
  });
}

Future<List<Tarefa>> buscarTarefas() async {
  if (kIsWeb) {
    return web.buscarTarefasWeb();
  }

  final Database db = await getDatabase();
  final List<Map<String, dynamic>> resultado = await db.query(
    'tarefas',
    orderBy: 'id DESC',
  );

  return List.generate(resultado.length, (i) {
    return Tarefa(
      id: resultado[i]['id'],
      titulo: resultado[i]['titulo'],
      descricao: resultado[i]['descricao'] ?? '',
      concluida: resultado[i]['concluida'] == 1,
    );
  });
}

Future<void> atualizarTarefa(Tarefa tarefa) async {
  if (kIsWeb) {
    return web.atualizarTarefaWeb(tarefa);
  }

  final Database db = await getDatabase();

  await db.update(
    'tarefas',
    {
      'titulo': tarefa.titulo,
      'descricao': tarefa.descricao,
      'concluida': tarefa.concluida ? 1 : 0,
    },
    where: 'id = ?',
    whereArgs: [tarefa.id],
  );
}

Future<void> deletarTarefa(int id) async {
  if (kIsWeb) {
    return web.deletarTarefaWeb(id);
  }

  final Database db = await getDatabase();

  await db.delete(
    'tarefas',
    where: 'id = ?',
    whereArgs: [id],
  );
}
