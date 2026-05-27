import '../models/receita.dart';
import 'supabase_service.dart';

// CRUD da tabela `favoritos` no Supabase.
// Linhas vivem so' enquanto o usuario dono existe (FK on delete cascade).
class FavoritoService {
  static const String _tabela = 'favoritos';

  // ids das receitas favoritadas pelo usuario (usado para flag rapida na UI)
  Future<List<int>> listarFavoritosDoUsuario(String usuarioId) async {
    final rows = await SupabaseService.client
        .from(_tabela)
        .select('receita_id')
        .eq('usuario_id', usuarioId);
    return rows.map((m) => (m['receita_id'] as num).toInt()).toList();
  }

  // junta favoritos com a receita relacionada, para a tela de Favoritos
  Future<List<Receita>> listarReceitasFavoritadas(String usuarioId) async {
    final rows = await SupabaseService.client
        .from(_tabela)
        .select('receita_id, receitas(*)')
        .eq('usuario_id', usuarioId)
        .order('created_at', ascending: false);
    return rows
        // o filtro extra evita explodir se uma receita for excluida
        // entre o select e o map (linha sem 'receitas' aninhada)
        .where((m) => m['receitas'] != null)
        .map((m) => Receita.fromMap(m['receitas'] as Map<String, dynamic>))
        .toList();
  }

  // upsert com ignoreDuplicates manda ON CONFLICT DO NOTHING:
  // - evita erro de chave duplicada se o usuario clicar duas vezes
  // - nao dispara o ramo UPDATE (a tabela so' tem policies INSERT/SELECT/DELETE,
  //   sem UPDATE, entao um conflito viraria erro 42501 de RLS)
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
