import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../models/tarefa.dart';
import '../../repository/tarefa_repository.dart';

class TesteApi extends StatefulWidget {
  const TesteApi({super.key});

  @override
  State<TesteApi> createState() => _TesteApiState();
}

class _TesteApiState extends State<TesteApi>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String _resultadoLocal = 'Escolha um teste local abaixo.';
  String _resultadoRemoto = 'Escolha um teste remoto abaixo.';
  bool _carregandoLocal = false;
  bool _carregandoRemoto = false;

  final TarefaRepositoryLocal _repositorioLocal = RepositorioTarefa.local;
  final TarefaRepositoryRemoto _repositorioRemoto = RepositorioTarefa.remoto;

  String get _tipoLocal =>
      kIsWeb ? 'armazenamento do navegador' : 'SQLite';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _validarApiConfigurada() {
    if (!ApiConfig.configurada) {
      throw Exception(
        'Configure a URL da API em lib/config/api_config.dart',
      );
    }
  }

  Future<void> _executarLocal(Future<void> Function() acao) async {
    setState(() => _carregandoLocal = true);

    try {
      await acao();
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _resultadoLocal = erro.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _carregandoLocal = false);
      }
    }
  }

  Future<void> _executarRemoto(Future<void> Function() acao) async {
    setState(() => _carregandoRemoto = true);

    try {
      await acao();
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _resultadoRemoto = erro.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _carregandoRemoto = false);
      }
    }
  }

  Future<void> _testarLocal() async {
    await _executarLocal(() async {
      setState(() {
        _resultadoLocal = 'Testando persistência local ($_tipoLocal)...';
      });

      final tarefas = await _repositorioLocal.buscarTarefas();

      setState(() {
        _resultadoLocal = tarefas.isEmpty
            ? 'Persistência local OK. Nenhuma tarefa salva ainda.'
            : 'Persistência local OK.\n${tarefas.join('\n')}';
      });
    });
  }

  Future<void> _criarTarefaLocalTeste() async {
    await _executarLocal(() async {
      setState(() {
        _resultadoLocal = 'Criando tarefa de teste local...';
      });

      await _repositorioLocal.salvarTarefa(
        Tarefa(
          titulo: 'Tarefa local teste',
          descricao: 'Salva em $_tipoLocal',
        ),
      );

      setState(() {
        _resultadoLocal = 'Tarefa local criada com sucesso.';
      });
    });
  }

  Future<void> _testarConexaoRemota() async {
    try {
      _validarApiConfigurada();
    } catch (erro) {
      setState(() {
        _resultadoRemoto = erro.toString().replaceFirst('Exception: ', '');
      });
      return;
    }

    await _executarRemoto(() async {
      setState(() {
        _resultadoRemoto =
            'Testando API remota...\n'
            'URL: ${ApiConfig.baseUrl}\n'
            'Aguarde: o Render Free pode demorar na 1ª requisição.';
      });

      final mensagem = await RepositorioTarefa.testarConexaoRemota();

      setState(() {
        _resultadoRemoto = 'API remota OK.\n$mensagem';
      });
    });
  }

  Future<void> _listarTarefasRemotas() async {
    try {
      _validarApiConfigurada();
    } catch (erro) {
      setState(() {
        _resultadoRemoto = erro.toString().replaceFirst('Exception: ', '');
      });
      return;
    }

    await _executarRemoto(() async {
      setState(() {
        _resultadoRemoto = 'Buscando tarefas na API remota...';
      });

      final tarefas = await _repositorioRemoto.buscarTarefas();

      setState(() {
        _resultadoRemoto = tarefas.isEmpty
            ? 'API remota OK. Nenhuma tarefa encontrada.'
            : 'API remota OK.\n${tarefas.join('\n')}';
      });
    });
  }

  Future<void> _criarTarefaRemotaTeste() async {
    try {
      _validarApiConfigurada();
    } catch (erro) {
      setState(() {
        _resultadoRemoto = erro.toString().replaceFirst('Exception: ', '');
      });
      return;
    }

    await _executarRemoto(() async {
      setState(() {
        _resultadoRemoto = 'Criando tarefa de teste na API remota...';
      });

      await _repositorioRemoto.salvarTarefa(
        Tarefa(
          titulo: 'Tarefa Flutter',
          descricao: 'Criada pela tela de teste da API',
        ),
      );

      setState(() {
        _resultadoRemoto = 'Tarefa remota criada com sucesso.';
      });
    });
  }

  Widget _abaLocal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Testes de persistência local ($_tipoLocal).',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _carregandoLocal ? null : _testarLocal,
            child: const Text('Testar banco local'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _carregandoLocal ? null : _criarTarefaLocalTeste,
            child: const Text('Criar tarefa teste local'),
          ),
          const SizedBox(height: 24),
          if (_carregandoLocal) const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          SelectableText(
            _resultadoLocal,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _abaRemota() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Testes da API remota.\nURL: ${ApiConfig.baseUrl}',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _carregandoRemoto || !ApiConfig.configurada
                ? null
                : _testarConexaoRemota,
            child: const Text('Testar conexão com banco remoto'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _carregandoRemoto || !ApiConfig.configurada
                ? null
                : _listarTarefasRemotas,
            child: const Text('Listar tarefas da API'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _carregandoRemoto || !ApiConfig.configurada
                ? null
                : _criarTarefaRemotaTeste,
            child: const Text('Criar tarefa teste na API'),
          ),
          const SizedBox(height: 24),
          if (_carregandoRemoto) const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          SelectableText(
            _resultadoRemoto,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.storage), text: 'Local'),
            Tab(icon: Icon(Icons.cloud), text: 'Remota'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _abaLocal(),
          _abaRemota(),
        ],
      ),
    );
  }
}
