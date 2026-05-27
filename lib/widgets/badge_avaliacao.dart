import 'package:flutter/material.dart';
import '../theme/cores.dart';

// Selo compacto reutilizado nos cards e na DetalhesScreen.
// Sai do layout quando ainda nao ha nenhuma avaliacao.
class BadgeAvaliacao extends StatelessWidget {
  final double media;
  final int total;
  final double tamanhoIcone;
  final double tamanhoTexto;

  const BadgeAvaliacao({
    super.key,
    required this.media,
    required this.total,
    this.tamanhoIcone = 14,
    this.tamanhoTexto = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: tamanhoIcone, color: Colors.amber.shade700),
        const SizedBox(width: 3),
        Text(
          media.toStringAsFixed(1),
          style: TextStyle(
            fontSize: tamanhoTexto,
            fontWeight: FontWeight.w600,
            color: Cores.textoEscuro,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '($total)',
          style: TextStyle(
            fontSize: tamanhoTexto,
            color: Cores.textoCinza,
          ),
        ),
      ],
    );
  }
}
