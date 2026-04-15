import 'dart:convert';
import 'dart:typed_data';

class Ingrediente {
  final String nome;
  final String quantidade;

  const Ingrediente({required this.nome, required this.quantidade});
}

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
  bool favorito;

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
    this.favorito = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'imagemUrl': imagemUrl,
        'tempoMinutos': tempoMinutos,
        'porcoes': porcoes,
        'dificuldade': dificuldade,
        'categoria': categoria,
        'ingredientes': jsonEncode(
          ingredientes
              .map((i) => {'nome': i.nome, 'quantidade': i.quantidade})
              .toList(),
        ),
        'modoPreparo': jsonEncode(modoPreparo),
        'destaque': destaque ? 1 : 0,
        'favorito': favorito ? 1 : 0,
      };

  factory Receita.fromMap(Map<String, dynamic> m) {
    final ingRaw = jsonDecode(m['ingredientes'] as String) as List;
    final passosRaw = jsonDecode(m['modoPreparo'] as String) as List;
    return Receita(
      id: m['id'] as int,
      nome: m['nome'] as String,
      descricao: (m['descricao'] ?? '') as String,
      imagemUrl: (m['imagemUrl'] ?? '') as String,
      tempoMinutos: m['tempoMinutos'] as int,
      porcoes: m['porcoes'] as int,
      dificuldade: m['dificuldade'] as String,
      categoria: m['categoria'] as String,
      ingredientes: ingRaw
          .map((e) => Ingrediente(
                nome: e['nome'] as String,
                quantidade: e['quantidade'] as String,
              ))
          .toList(),
      modoPreparo: passosRaw.map((e) => e as String).toList(),
      destaque: (m['destaque'] as int) == 1,
      favorito: (m['favorito'] as int?) == 1,
    );
  }
}

// Helpers de imagem
bool isBase64Image(String s) => s.startsWith('data:image');
bool isAssetImage(String s) => s.startsWith('assets/');

Uint8List? base64ToBytes(String dataUri) {
  final idx = dataUri.indexOf('base64,');
  if (idx < 0) return null;
  try {
    return base64Decode(dataUri.substring(idx + 7));
  } catch (_) {
    return null;
  }
}

String bytesToDataUri(Uint8List bytes, {String mime = 'image/jpeg'}) {
  return 'data:$mime;base64,${base64Encode(bytes)}';
}
