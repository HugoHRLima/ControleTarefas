import '../models/tarefa.dart';
import 'configuracao_persistencia.dart';
import '../db/app_database.dart' as bancolocal;
import '../services/api_service.dart';

// Interface do repository: as telas dependem apenas desta abstração.
abstract class TarefaRepository {
  Future<List<Tarefa>> buscarTarefas();
  Future<void> salvarTarefa(Tarefa tarefa);
  Future<void> atualizarTarefa(Tarefa tarefa);
  Future<void> deletarTarefa(int id);
}

// Persistência local: delega para a camada db (SQLite ou navegador).
class TarefaRepositoryLocal implements TarefaRepository {
  @override
  Future<List<Tarefa>> buscarTarefas() {
    return bancolocal.buscarTarefas();
  }

  @override
  Future<void> salvarTarefa(Tarefa tarefa) async {
    await bancolocal.salvarTarefa(tarefa);
  }

  @override
  Future<void> atualizarTarefa(Tarefa tarefa) async {
    await bancolocal.atualizarTarefa(tarefa);
  }

  @override
  Future<void> deletarTarefa(int id) async {
    await bancolocal.deletarTarefa(id);
  }
}

// Persistência remota: delega para a camada de serviço da API.
class TarefaRepositoryRemoto implements TarefaRepository {
  @override
  Future<List<Tarefa>> buscarTarefas() {
    return ApiService.buscarTarefas();
  }

  @override
  Future<void> salvarTarefa(Tarefa tarefa) async {
    await ApiService.salvarTarefa(tarefa);
  }

  @override
  Future<void> atualizarTarefa(Tarefa tarefa) async {
    await ApiService.atualizarTarefa(tarefa);
  }

  @override
  Future<void> deletarTarefa(int id) async {
    await ApiService.deletarTarefa(id);
  }

  Future<String> testarConexao() {
    return ApiService.testarConexaoBanco();
  }
}

// Factory que escolhe entre persistência local ou remota.
class RepositorioTarefa {
  static TarefaRepository get instancia {
    switch (ConfiguracaoPersistencia.origem) {
      case OrigemPersistencia.local:
        return local;
      case OrigemPersistencia.remota:
        return remoto;
    }
  }

  static TarefaRepositoryLocal get local => TarefaRepositoryLocal();

  static TarefaRepositoryRemoto get remoto => TarefaRepositoryRemoto();

  static Future<String> testarConexaoRemota() {
    return remoto.testarConexao();
  }
}
