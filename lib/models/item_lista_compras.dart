class ItemListaCompras {
  final int id;
  final String nome;
  final List<String> quantidades;
  bool comprado;

  ItemListaCompras({
    required this.id,
    required this.nome,
    required this.quantidades,
    this.comprado = false,
  });

  String get quantidadeFormatada => quantidades.join(' + ');

  factory ItemListaCompras.fromMap(Map<String, dynamic> m) {
    final qRaw = (m['quantidades'] as List?) ?? const [];
    return ItemListaCompras(
      id: (m['id'] as num).toInt(),
      nome: m['nome'] as String,
      quantidades: qRaw.map((e) => e as String).toList(),
      comprado: (m['comprado'] as bool?) ?? false,
    );
  }
}
