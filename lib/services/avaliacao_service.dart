import '../models/avaliacao_receita.dart';
import 'supabase_service.dart';

class AvaliacaoService {
  static const String _tabela = 'avaliacoes';

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
