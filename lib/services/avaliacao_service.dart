import '../models/avaliacao_receita.dart';
import 'supabase_service.dart';

// Persistencia das notas (1 a 5) por usuario por receita.
// Media e total ficam derivados em buscarResumo — sem agregacao no banco.
class AvaliacaoService {
  static const String _tabela = 'avaliacoes';

  // Uma chamada pega todas as notas; a media e a nota do usuario saem
  // do mesmo conjunto pra evitar um segundo round-trip.
  Future<ResumoAvaliacao> buscarResumo(
    int receitaId,
    String? usuarioId,
  ) async {
    final rows = await SupabaseService.client
        .from(_tabela)
        .select('usuario_id, nota')
        .eq('receita_id', receitaId);

    if (rows.isEmpty) return ResumoAvaliacao.vazio(receitaId);

    final notas = rows.map((r) => (r['nota'] as num).toInt()).toList();
    final media = notas.reduce((a, b) => a + b) / notas.length;

    int? notaUsuario;
    if (usuarioId != null) {
      for (final r in rows) {
        if (r['usuario_id'] == usuarioId) {
          notaUsuario = (r['nota'] as num).toInt();
          break;
        }
      }
    }

    return ResumoAvaliacao(
      receitaId: receitaId,
      media: media,
      total: notas.length,
      notaUsuario: notaUsuario,
    );
  }

  // upsert pela PK composta (usuario_id, receita_id):
  // se a linha existe vira UPDATE (e a policy de update cobre),
  // se nao existe vira INSERT (coberto pela policy de insert).
  Future<void> salvarAvaliacao(
    String usuarioId,
    int receitaId,
    int nota,
  ) async {
    await SupabaseService.client.from(_tabela).upsert({
      'usuario_id': usuarioId,
      'receita_id': receitaId,
      'nota': nota,
    });
  }

  Future<void> removerAvaliacao(String usuarioId, int receitaId) async {
    await SupabaseService.client
        .from(_tabela)
        .delete()
        .eq('usuario_id', usuarioId)
        .eq('receita_id', receitaId);
  }
}
