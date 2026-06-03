import '../models/receita.dart';
import 'supabase_service.dart';

class FavoritoService {
  static const String _tabela = 'favoritos';

  Future<List<int>> listarFavoritosDoUsuario(String usuarioId) async {
    final rows = await SupabaseService.client
        .from(_tabela)
        .select('receita_id')
        .eq('usuario_id', usuarioId);
    return rows.map((m) => (m['receita_id'] as num).toInt()).toList();
  }

  Future<List<Receita>> listarReceitasFavoritadas(String usuarioId) async {
    final rows = await SupabaseService.client
        .from(_tabela)
        .select('receita_id, receitas(*)')
        .eq('usuario_id', usuarioId)
        .order('created_at', ascending: false);
    return rows
        .where((m) => m['receitas'] != null)
        .map((m) => Receita.fromMap(m['receitas'] as Map<String, dynamic>))
        .toList();
  }

  Future<void> favoritar(String usuarioId, int receitaId) async {
    await SupabaseService.client.from(_tabela).upsert(
      {'usuario_id': usuarioId, 'receita_id': receitaId},
      ignoreDuplicates: true,
    );
  }

  Future<void> desfavoritar(String usuarioId, int receitaId) async {
    await SupabaseService.client
        .from(_tabela)
        .delete()
        .eq('usuario_id', usuarioId)
        .eq('receita_id', receitaId);
  }

  Future<bool> estaFavoritada(String usuarioId, int receitaId) async {
    final row = await SupabaseService.client
        .from(_tabela)
        .select('receita_id')
        .eq('usuario_id', usuarioId)
        .eq('receita_id', receitaId)
        .maybeSingle();
    return row != null;
  }
}
