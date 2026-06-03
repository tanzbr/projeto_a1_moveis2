import '../models/receita.dart';
import 'supabase_service.dart';

class ReceitaRemoteService {
  static const String _tabela = 'receitas';

  Future<List<Receita>> listarReceitas() async {
    final rows = await SupabaseService.client
        .from(_tabela)
        .select()
        .order('id', ascending: true);
    return rows.map((m) => Receita.fromMap(m)).toList();
  }

  Future<List<Receita>> listarReceitasPublicas() async {
    final rows = await SupabaseService.client
        .from(_tabela)
        .select()
        .eq('publica', true)
        .order('id', ascending: true);
    return rows.map((m) => Receita.fromMap(m)).toList();
  }

  Future<List<Receita>> listarMinhasReceitas(String usuarioId) async {
    final rows = await SupabaseService.client
        .from(_tabela)
        .select()
        .eq('usuario_id', usuarioId)
        .order('id', ascending: true);
    return rows.map((m) => Receita.fromMap(m)).toList();
  }

  Future<Receita?> buscarReceita(int id) async {
    final row = await SupabaseService.client
        .from(_tabela)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return Receita.fromMap(row);
  }

  Future<int> inserirReceita(Receita r) async {
    final row = await SupabaseService.client
        .from(_tabela)
        .insert(r.toMap())
        .select('id')
        .single();
    return (row['id'] as num).toInt();
  }

  Future<void> atualizarReceita(Receita r) async {
    await SupabaseService.client
        .from(_tabela)
        .update(r.toMap())
        .eq('id', r.id);
  }

  Future<void> excluirReceita(int id) async {
    await SupabaseService.client.from(_tabela).delete().eq('id', id);
  }
}
