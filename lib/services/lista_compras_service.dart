import '../models/item_lista_compras.dart';
import '../models/receita.dart';
import 'supabase_service.dart';

// Persistencia da lista de compras do usuario logado.
// Como cada usuario tem uma unica lista (unique index), o id e' "lazy":
// criado na primeira escrita e reaproveitado nas demais.
class ListaComprasService {
  static const String _tabelaListas = 'listas_compras';
  static const String _tabelaItens = 'lista_compras_itens';

  // Cria a lista do usuario se ainda nao existe; devolve o id em qualquer caso.
  Future<int> _obterOuCriarListaId(String usuarioId) async {
    final existente = await SupabaseService.client
        .from(_tabelaListas)
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();
    if (existente != null) return (existente['id'] as num).toInt();

    final nova = await SupabaseService.client
        .from(_tabelaListas)
        .insert({'usuario_id': usuarioId})
        .select('id')
        .single();
    return (nova['id'] as num).toInt();
  }

  Future<int?> _buscarListaId(String usuarioId) async {
    final row = await SupabaseService.client
        .from(_tabelaListas)
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();
    if (row == null) return null;
    return (row['id'] as num).toInt();
  }

  Future<List<ItemListaCompras>> listarItens(String usuarioId) async {
    final listaId = await _buscarListaId(usuarioId);
    if (listaId == null) return [];
    final rows = await SupabaseService.client
        .from(_tabelaItens)
        .select()
        .eq('lista_id', listaId)
        .order('created_at', ascending: true);
    return rows.map((m) => ItemListaCompras.fromMap(m)).toList();
  }

  // Pega receitas e junta os ingredientes na lista do usuario.
  // Itens com mesmo nome (case-insensitive) sao agrupados; quantidades
  // novas viram entradas adicionais no array textual.
  Future<void> gerarListaPorReceitas(
    String usuarioId,
    List<Receita> receitas,
  ) async {
    if (receitas.isEmpty) return;
    final listaId = await _obterOuCriarListaId(usuarioId);

    // Carrega itens atuais pra decidir entre INSERT e UPDATE
    final existentes = await listarItens(usuarioId);
    final porChave = <String, ItemListaCompras>{
      for (final item in existentes) item.nome.toLowerCase().trim(): item,
    };

    for (final receita in receitas) {
      for (final ing in receita.ingredientes) {
        final chave = ing.nome.toLowerCase().trim();
        if (chave.isEmpty) continue;

        final atual = porChave[chave];
        if (atual == null) {
          // novo item: insere com a primeira quantidade
          final row = await SupabaseService.client
              .from(_tabelaItens)
              .insert({
                'lista_id': listaId,
                'nome': ing.nome,
                'quantidades': [ing.quantidade],
              })
              .select()
              .single();
          porChave[chave] = ItemListaCompras.fromMap(row);
        } else if (!atual.quantidades.contains(ing.quantidade)) {
          // ja existe: anexa quantidade se ainda nao estiver registrada
          final novas = [...atual.quantidades, ing.quantidade];
          await SupabaseService.client
              .from(_tabelaItens)
              .update({'quantidades': novas})
              .eq('id', atual.id);
          // atualiza o cache em memoria para os proximos loops
          porChave[chave] = ItemListaCompras(
            id: atual.id,
            nome: atual.nome,
            quantidades: novas,
            comprado: atual.comprado,
          );
        }
      }
    }
  }

  Future<void> marcarComprado(int itemId, bool comprado) async {
    await SupabaseService.client
        .from(_tabelaItens)
        .update({'comprado': comprado})
        .eq('id', itemId);
  }

  Future<void> removerItem(int itemId) async {
    await SupabaseService.client.from(_tabelaItens).delete().eq('id', itemId);
  }

  // Esvazia a lista do usuario sem apagar a propria lista (o id segue valido).
  Future<void> limparLista(String usuarioId) async {
    final listaId = await _buscarListaId(usuarioId);
    if (listaId == null) return;
    await SupabaseService.client
        .from(_tabelaItens)
        .delete()
        .eq('lista_id', listaId);
  }
}
