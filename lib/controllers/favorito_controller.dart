import 'package:flutter/foundation.dart';
import '../models/receita.dart';
import '../services/favorito_service.dart';
import 'auth_controller.dart';

// Singleton: a lista de favoritas e' compartilhada entre Home, Favoritos
// e Detalhes. Recarrega sozinho quando o usuario entra ou sai.
class FavoritoController extends ChangeNotifier {
  static final FavoritoController instance = FavoritoController._();

  FavoritoController._() {
    AuthController.instance.addListener(_onAuthMudou);
    _carregar();
  }

  final FavoritoService _service = FavoritoService();

  List<Receita> _receitas = [];
  List<Receita> get receitas => _receitas;

  bool _carregando = false;
  bool get carregando => _carregando;

  bool ehFavorita(int receitaId) => _receitas.any((r) => r.id == receitaId);

  // alias do plano: ids das receitas favoritadas
  Set<int> get idsFavoritos => _receitas.map((r) => r.id).toSet();

  void _onAuthMudou() {
    _carregar();
  }

  Future<void> _carregar() async {
    final usuario = AuthController.instance.usuario;
    if (usuario == null) {
      _receitas = [];
      notifyListeners();
      return;
    }
    _carregando = true;
    notifyListeners();
    _receitas = await _service.listarReceitasFavoritadas(usuario.id);
    _carregando = false;
    notifyListeners();
  }

  Future<void> recarregar() => _carregar();

  Future<void> favoritar(Receita receita) async {
    final usuario = AuthController.instance.usuario;
    if (usuario == null) return;
    await _service.favoritar(usuario.id, receita.id);
    if (!_receitas.any((r) => r.id == receita.id)) {
      _receitas = [receita, ..._receitas];
      notifyListeners();
    }
  }

  Future<void> desfavoritar(int receitaId) async {
    final usuario = AuthController.instance.usuario;
    if (usuario == null) return;
    await _service.desfavoritar(usuario.id, receitaId);
    _receitas = _receitas.where((r) => r.id != receitaId).toList();
    notifyListeners();
  }
}
