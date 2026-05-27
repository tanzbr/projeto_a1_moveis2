import 'package:flutter/foundation.dart';
import '../models/item_lista_compras.dart';
import '../models/receita.dart';
import '../services/lista_compras_service.dart';
import 'auth_controller.dart';

// Singleton: a lista de compras e' compartilhada entre Home, Detalhes
// e a propria TelaListaCompras. Recarrega ao logar/sair.
class ListaComprasController extends ChangeNotifier {
  static final ListaComprasController instance = ListaComprasController._();

  ListaComprasController._() {
    AuthController.instance.addListener(_onAuthMudou);
    _carregar();
  }

  final ListaComprasService _service = ListaComprasService();

  List<ItemListaCompras> _itens = [];
  List<ItemListaCompras> get itens => _itens;

  bool _carregando = false;
  bool get carregando => _carregando;

  int get totalItens => _itens.length;
  int get totalPendentes => _itens.where((i) => !i.comprado).length;

  void _onAuthMudou() {
    _carregar();
  }

  Future<void> _carregar() async {
    final usuario = AuthController.instance.usuario;
    if (usuario == null) {
      _itens = [];
      notifyListeners();
      return;
    }
    _carregando = true;
    notifyListeners();
    _itens = await _service.listarItens(usuario.id);
    _carregando = false;
    notifyListeners();
  }

  Future<void> recarregar() => _carregar();

  // adiciona ingredientes das receitas e recarrega para refletir o estado real
  Future<void> adicionarReceitas(List<Receita> receitas) async {
    final usuario = AuthController.instance.usuario;
    if (usuario == null || receitas.isEmpty) return;
    await _service.gerarListaPorReceitas(usuario.id, receitas);
    await _carregar();
  }

  Future<void> alternarComprado(ItemListaCompras item) async {
    final novoEstado = !item.comprado;
    // atualiza local primeiro pra UI responder na hora
    item.comprado = novoEstado;
    notifyListeners();
    await _service.marcarComprado(item.id, novoEstado);
  }

  Future<void> removerItem(int itemId) async {
    _itens = _itens.where((i) => i.id != itemId).toList();
    notifyListeners();
    await _service.removerItem(itemId);
  }

  Future<void> limpar() async {
    final usuario = AuthController.instance.usuario;
    if (usuario == null) return;
    _itens = [];
    notifyListeners();
    await _service.limparLista(usuario.id);
  }
}
