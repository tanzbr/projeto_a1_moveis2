// resumo agregado das avaliacoes de uma receita.
// O service calcula `media` e `total` a partir das linhas da tabela;
// `notaUsuario` vem null quando o usuario atual ainda nao avaliou.
class ResumoAvaliacao {
  final int receitaId;
  final double media;
  final int total;
  final int? notaUsuario;

  const ResumoAvaliacao({
    required this.receitaId,
    required this.media,
    required this.total,
    this.notaUsuario,
  });

  factory ResumoAvaliacao.vazio(int receitaId) =>
      ResumoAvaliacao(receitaId: receitaId, media: 0, total: 0);
}
