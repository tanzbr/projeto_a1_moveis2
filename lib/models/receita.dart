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
}
