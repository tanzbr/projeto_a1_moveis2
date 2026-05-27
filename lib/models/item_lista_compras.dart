// modelo de um item da lista de compras — espelha lista_compras_itens
class ItemListaCompras {
  final int id;
  final String nome;
  // varias quantidades acumuladas (ex.: ['200g', '1 xicara']) — sem conversao
  final List<String> quantidades;
  bool comprado;

  ItemListaCompras({
    required this.id,
    required this.nome,
    required this.quantidades,
    this.comprado = false,
  });

  // texto pronto pra exibir do lado do nome (juntando as varias quantidades)
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
