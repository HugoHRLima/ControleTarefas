import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

enum OrigemPersistencia {
  local,
  remota,
}

class ConfiguracaoPersistencia {
  static const _chave = 'origem_persistencia';

  static OrigemPersistencia _origem = OrigemPersistencia.local;

  static OrigemPersistencia get origem => _origem;

  static bool get localDisponivel => true;

  static bool get remotaDisponivel => ApiConfig.configurada;

  static String get descricao {
    switch (_origem) {
      case OrigemPersistencia.local:
        return kIsWeb ? 'Local (navegador)' : 'SQLite (local)';
      case OrigemPersistencia.remota:
        return 'API Render (remota)';
    }
  }

  static Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();

    // Se a API ainda não foi publicada, força modo local.
    if (!ApiConfig.configurada) {
      await prefs.setString(_chave, OrigemPersistencia.local.name);
      _origem = OrigemPersistencia.local;
      return;
    }

    final valor = prefs.getString(_chave);

    if (valor == OrigemPersistencia.remota.name) {
      _origem = OrigemPersistencia.remota;
      return;
    }

    _origem = OrigemPersistencia.local;
  }

  static Future<void> definir(OrigemPersistencia novaOrigem) async {
    if (novaOrigem == OrigemPersistencia.remota && !ApiConfig.configurada) {
      throw Exception(
        'API ainda não configurada. Publique a tarefas-api no Render e '
        'atualize a URL em lib/config/api_config.dart.',
      );
    }

    _origem = novaOrigem;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, novaOrigem.name);
  }
}
