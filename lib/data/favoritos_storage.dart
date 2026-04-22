import 'package:shared_preferences/shared_preferences.dart';

import '../models/receita.dart';

class FavoritosStorage {
  static const String _idsKey = 'favoritos_ids';

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  static Future<Set<int>> carregarIds() async {
    final prefs = await _prefs;
    final ids = prefs.getStringList(_idsKey) ?? const [];
    return ids.map(int.parse).toSet();
  }

  static Future<bool> isFavorito(int receitaId) async {
    final ids = await carregarIds();
    return ids.contains(receitaId);
  }

  static Future<void> definirFavorito(int receitaId, bool favorito) async {
    final prefs = await _prefs;
    final ids = await carregarIds();

    if (favorito) {
      ids.add(receitaId);
    } else {
      ids.remove(receitaId);
    }

    await prefs.setStringList(
      _idsKey,
      ids.map((id) => id.toString()).toList(),
    );
  }

  static Future<void> marcarFavorito(int receitaId) async {
    await definirFavorito(receitaId, true);
  }

  static Future<void> removerFavorito(int receitaId) async {
    await definirFavorito(receitaId, false);
  }

  static Future<List<Receita>> aplicarFavoritos(List<Receita> receitas) async {
    final ids = await carregarIds();
    for (final receita in receitas) {
      receita.favorito = ids.contains(receita.id);
    }
    return receitas;
  }

  static Future<List<Receita>> listarFavoritas(
    List<Receita> receitas,
  ) async {
    final ids = await carregarIds();
    return receitas.where((receita) => ids.contains(receita.id)).toList();
  }
}