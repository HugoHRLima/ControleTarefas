import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/tarefa.dart';

// Camada de serviço responsável pela comunicação HTTP com a API remota.
// As telas não devem usar esta classe diretamente — use RepositorioTarefa.
class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 90);

  static Exception _erroConexao(String acao, [Object? erro]) {
    final detalhe = erro != null ? ' Detalhe: $erro' : '';
    return Exception(
      'Não foi possível $acao em $baseUrl.$detalhe '
      'No plano Free do Render, a primeira requisição pode demorar até 60 segundos.',
    );
  }

  static Future<http.Response> _get(String rota) {
    return http
        .get(Uri.parse('$baseUrl$rota'))
        .timeout(_timeout, onTimeout: () {
      throw Exception(
        'Tempo esgotado ao acessar $baseUrl$rota. '
        'Aguarde o serviço no Render iniciar e tente novamente.',
      );
    });
  }

  static Future<http.Response> _post(String rota, Map<String, dynamic> body) {
    return http
        .post(
          Uri.parse('$baseUrl$rota'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout, onTimeout: () {
      throw Exception(
        'Tempo esgotado ao enviar dados para $baseUrl$rota. '
        'Aguarde o serviço no Render iniciar e tente novamente.',
      );
    });
  }

  static Future<String> testarConexaoBanco() async {
    try {
      final resposta = await _get('/teste-banco');

      if (resposta.statusCode != 200) {
        throw Exception(
          'erro ao testar conexão (${resposta.statusCode}): ${resposta.body}',
        );
      }

      final dados = jsonDecode(resposta.body);
      return dados['mensagem'];
    } on Exception {
      rethrow;
    } catch (erro) {
      throw _erroConexao('conectar', erro);
    }
  }

  static Future<List<Tarefa>> buscarTarefas() async {
    try {
      final resposta = await _get('/tarefas');

      if (resposta.statusCode != 200) {
        throw Exception(
          'erro ao buscar tarefas (${resposta.statusCode}): ${resposta.body}',
        );
      }

      final List<dynamic> dados = jsonDecode(resposta.body);

      return dados.map((item) => Tarefa.fromJson(item)).toList();
    } on Exception {
      rethrow;
    } catch (erro) {
      throw _erroConexao('carregar tarefas', erro);
    }
  }

  static Future<void> salvarTarefa(Tarefa tarefa) async {
    try {
      final resposta = await _post('/tarefas', tarefa.toJson());

      if (resposta.statusCode != 201) {
        throw Exception(
          'erro ao salvar tarefa (${resposta.statusCode}): ${resposta.body}',
        );
      }
    } on Exception {
      rethrow;
    } catch (erro) {
      throw _erroConexao('salvar a tarefa', erro);
    }
  }

  static Future<void> atualizarTarefa(Tarefa tarefa) async {
    try {
      final resposta = await http
          .put(
            Uri.parse('$baseUrl/tarefas/${tarefa.id}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(tarefa.toJson()),
          )
          .timeout(_timeout);

      if (resposta.statusCode != 200) {
        throw Exception(
          'erro ao atualizar tarefa (${resposta.statusCode}): ${resposta.body}',
        );
      }
    } on Exception {
      rethrow;
    } catch (erro) {
      throw _erroConexao('atualizar a tarefa', erro);
    }
  }

  static Future<void> deletarTarefa(int id) async {
    try {
      final resposta = await http
          .delete(Uri.parse('$baseUrl/tarefas/$id'))
          .timeout(_timeout);

      if (resposta.statusCode != 200) {
        throw Exception(
          'erro ao deletar tarefa (${resposta.statusCode}): ${resposta.body}',
        );
      }
    } on Exception {
      rethrow;
    } catch (erro) {
      throw _erroConexao('excluir a tarefa', erro);
    }
  }
}
