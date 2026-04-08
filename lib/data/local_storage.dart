import 'package:shared_preferences/shared_preferences.dart';

class FavoritosStorage {
  static const _chaveFavoritos = 'favoritos_ids';

  static Future<List<int>> carregarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_chaveFavoritos) ?? [];
    return lista.map((id) => int.parse(id)).toList();
  }

  static Future<void> salvarFavoritos(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _chaveFavoritos,
      ids.map((id) => id.toString()).toList(),
    );
  }
}
