import 'dart:convert';
import 'dart:typed_data';

// par nome/quantidade usado dentro da receita
class Ingrediente {
  final String nome;
  final String quantidade;

  const Ingrediente({required this.nome, required this.quantidade});
}

// modelo principal — espelha as colunas da tabela `receitas` no Supabase
class Receita {
  final int id;
  final String nome;
  final String descricao;
  final String imagemUrl;
  final int tempoMinutos;
  final int porcoes;
  final String dificuldade; // "Fácil", "Médio", "Difícil"
  final String categoria;   // "Café da Manhã", "Almoço", "Jantar", "Lanches"
  final List<Ingrediente> ingredientes;
  final List<String> modoPreparo;
  final bool destaque;
  // usuario dono da receita (null = seed sem dono, sempre publica)
  final String? usuarioId;
  // se true aparece na lista geral; se false so' aparece para o dono
  bool publica;
  // mantidos pelo trigger em avaliacoes (ver 09_stats_avaliacoes.sql).
  // Sao read-only no app: o `toMap` nao os envia para nao sobrescrever
  // o valor calculado no banco.
  final double mediaAvaliacao;
  final int totalAvaliacoes;

  Receita({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.imagemUrl,
    required this.tempoMinutos,
    required this.porcoes,
    required this.dificuldade,
    required this.categoria,
    required this.ingredientes,
    required this.modoPreparo,
    this.destaque = false,
    this.usuarioId,
    this.publica = false,
    this.mediaAvaliacao = 0,
    this.totalAvaliacoes = 0,
  });

  // Map no formato aceito pelo Supabase (Postgres, snake_case).
  // No insert nao mandamos id (bigserial gera no banco), por isso `incluirId`.
  Map<String, dynamic> toMap({bool incluirId = false}) {
    final map = <String, dynamic>{
      'nome': nome,
      'descricao': descricao,
      'imagem_url': imagemUrl,
      'tempo_minutos': tempoMinutos,
      'porcoes': porcoes,
      'dificuldade': dificuldade,
      'categoria': categoria,
      'ingredientes': ingredientes
          .map((i) => {'nome': i.nome, 'quantidade': i.quantidade})
          .toList(),
      'modo_preparo': modoPreparo,
      'destaque': destaque,
      'publica': publica,
      'usuario_id': usuarioId,
    };
    if (incluirId) map['id'] = id;
    return map;
  }

  // Reconstrói a partir de uma linha vinda do Supabase
  factory Receita.fromMap(Map<String, dynamic> m) {
    final ingRaw = (m['ingredientes'] as List?) ?? const [];
    final passosRaw = (m['modo_preparo'] as List?) ?? const [];
    return Receita(
      id: (m['id'] as num).toInt(),
      nome: m['nome'] as String,
      descricao: (m['descricao'] ?? '') as String,
      imagemUrl: (m['imagem_url'] ?? '') as String,
      tempoMinutos: (m['tempo_minutos'] as num?)?.toInt() ?? 0,
      porcoes: (m['porcoes'] as num?)?.toInt() ?? 0,
      dificuldade: m['dificuldade'] as String,
      categoria: m['categoria'] as String,
      ingredientes: ingRaw
          .map((e) => Ingrediente(
                nome: (e as Map)['nome'] as String,
                quantidade: e['quantidade'] as String,
              ))
          .toList(),
      modoPreparo: passosRaw.map((e) => e as String).toList(),
      destaque: (m['destaque'] as bool?) ?? false,
      usuarioId: m['usuario_id'] as String?,
      publica: (m['publica'] as bool?) ?? false,
      mediaAvaliacao: (m['media_avaliacao'] as num?)?.toDouble() ?? 0,
      totalAvaliacoes: (m['total_avaliacoes'] as num?)?.toInt() ?? 0,
    );
  }
}

// helpers para tratar os 3 tipos de imagem que a app aceita:
// asset (seed), base64 (cadastrada pelo usuário) e URL (fallback)
bool isBase64Image(String s) => s.startsWith('data:image');
bool isAssetImage(String s) => s.startsWith('assets/');

// extrai os bytes da string `data:image/jpeg;base64,XXXX...`
Uint8List? base64ToBytes(String dataUri) {
  final idx = dataUri.indexOf('base64,');
  if (idx < 0) return null;
  try {
    return base64Decode(dataUri.substring(idx + 7));
  } catch (_) {
    return null;
  }
}

// monta o data URI a partir dos bytes (usado ao salvar a foto escolhida)
String bytesToDataUri(Uint8List bytes, {String mime = 'image/jpeg'}) {
  return 'data:$mime;base64,${base64Encode(bytes)}';
}
