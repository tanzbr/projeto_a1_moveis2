import 'package:flutter/foundation.dart';
import '../models/avaliacao_receita.dart';
import '../services/avaliacao_service.dart';
import 'auth_controller.dart';

// Controller dedicado a uma receita aberta na DetalhesScreen.
// Mantem o resumo (media/total/notaUsuario) e dispara recarga apos avaliar.
class AvaliacaoController extends ChangeNotifier {
  final AvaliacaoService _service = AvaliacaoService();

  ResumoAvaliacao? _resumo;
  ResumoAvaliacao? get resumo => _resumo;

  double get media => _resumo?.media ?? 0;
  int get total => _resumo?.total ?? 0;
  int? get notaUsuario => _resumo?.notaUsuario;

  bool _carregando = false;
  bool get carregando => _carregando;

  bool _foiDescartado = false;

  @override
  void dispose() {
    _foiDescartado = true;
    super.dispose();
  }

  void _notificar() {
    if (!_foiDescartado) notifyListeners();
  }

  Future<void> carregar(int receitaId) async {
    _carregando = true;
    _notificar();
    final usuarioId = AuthController.instance.usuario?.id;
    _resumo = await _service.buscarResumo(receitaId, usuarioId);
    if (_foiDescartado) return;
    _carregando = false;
    _notificar();
  }

  // Retorna false se nao havia usuario logado, true se salvou.
  Future<bool> avaliar(int receitaId, int nota) async {
    final usuarioId = AuthController.instance.usuario?.id;
    if (usuarioId == null) return false;
    await _service.salvarAvaliacao(usuarioId, receitaId, nota);
    await carregar(receitaId);
    return true;
  }

  Future<void> remover(int receitaId) async {
    final usuarioId = AuthController.instance.usuario?.id;
    if (usuarioId == null) return;
    await _service.removerAvaliacao(usuarioId, receitaId);
    await carregar(receitaId);
  }
}
