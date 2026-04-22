import 'dart:convert';
import 'dart:typed_data';

// par nome/quantidade usado dentro da receita
class Ingrediente {
  final String nome;
  final String quantidade;

  const Ingrediente({required this.nome, required this.quantidade});
}

// modelo principal da receita; favoritos ficam fora do SQLite
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
  bool favorito; // estado de UI/persistência via SharedPreferences

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

  // converte para Map no formato aceito pelo sqflite (insert/update)
  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'imagemUrl': imagemUrl,
        'tempoMinutos': tempoMinutos,
        'porcoes': porcoes,
        'dificuldade': dificuldade,
        'categoria': categoria,
        // listas viram JSON porque SQLite não tem coluna do tipo array
        'ingredientes': jsonEncode(
          ingredientes
              .map((i) => {'nome': i.nome, 'quantidade': i.quantidade})
              .toList(),
        ),
        'modoPreparo': jsonEncode(modoPreparo),
        // booleanos viram 0/1 (SQLite não tem tipo bool nativo)
        'destaque': destaque ? 1 : 0,
      };

  // reconstrói o objeto a partir da linha do banco
  factory Receita.fromMap(Map<String, dynamic> m) {
    // desfaz o jsonEncode do toMap
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
      favorito: false,
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
