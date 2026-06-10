import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../repository/configuracao_persistencia.dart';
import 'tarefa/lista_tarefas.dart';
import 'testes/teste_api.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  OrigemPersistencia _origemAtual = ConfiguracaoPersistencia.origem;

  Future<void> _alterarOrigem(OrigemPersistencia novaOrigem) async {
    try {
      await ConfiguracaoPersistencia.definir(novaOrigem);

      if (!mounted) return;

      setState(() {
        _origemAtual = novaOrigem;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Persistência alterada para ${ConfiguracaoPersistencia.descricao}.',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controle de Tarefas')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.task_alt, size: 80, color: Colors.blue),
              const SizedBox(height: 8),
              const Text(
                'Organize suas tarefas do dia a dia',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Origem dos dados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Modo atual: ${ConfiguracaoPersistencia.descricao}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      if (!ApiConfig.configurada) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Modo Remota desativado: configure a URL da API em '
                          'lib/config/api_config.dart após publicar no Render.',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ] else if (kIsWeb) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Na web, o modo Local salva no navegador.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SegmentedButton<OrigemPersistencia>(
                        segments: [
                          ButtonSegment(
                            value: OrigemPersistencia.local,
                            label: const Text('Local'),
                            icon: const Icon(Icons.storage),
                            enabled: ConfiguracaoPersistencia.localDisponivel,
                          ),
                          ButtonSegment(
                            value: OrigemPersistencia.remota,
                            label: const Text('Remota'),
                            icon: const Icon(Icons.cloud),
                            enabled: ConfiguracaoPersistencia.remotaDisponivel,
                          ),
                        ],
                        selected: {_origemAtual},
                        onSelectionChanged: (selecao) {
                          _alterarOrigem(selecao.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _FeatureItem(
                    nome: 'Minhas Tarefas',
                    icone: Icons.list_alt,
                    onClick: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ListaTarefas(),
                        ),
                      );
                    },
                  ),
                  _FeatureItem(
                    nome: 'Testes',
                    icone: Icons.cloud,
                    onClick: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TesteApi(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String nome;
  final IconData icone;
  final void Function() onClick;

  const _FeatureItem({
    required this.nome,
    required this.icone,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          width: 120,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  nome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
