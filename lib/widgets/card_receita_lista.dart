import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import 'imagem_receita.dart';

// versão horizontal do card — usada na Home (favoritos) e na Favoritos
// parâmetros opcionais permitem ajustar o conteúdo sem criar widgets novos
class CardReceitaLista extends StatelessWidget {
  final Receita receita;
  final VoidCallback onTap;
  final String? rodape; // texto extra opcional embaixo
  final bool mostrarCategoria; // se true, mostra chip da categoria
  final Widget? acaoDireita; // ícone customizado à direita (ex.: coração)

  const CardReceitaLista({
    super.key,
    required this.receita,
    required this.onTap,
    this.rodape,
    this.mostrarCategoria = false,
    this.acaoDireita,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Espacos.raioCard),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Espacos.raioCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _thumbnail(),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      receita.nome,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Cores.textoEscuro,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _linhaInfo(),
                    if (rodape != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        rodape!,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // se nenhum ícone for passado, mostra a setinha padrão
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: acaoDireita ??
                  const Icon(Icons.chevron_right,
                      color: Cores.primaria),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail() {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(
        left: Radius.circular(Espacos.raioCard),
      ),
      child: SizedBox(
        width: 80,
        height: 80,
        child: ImagemReceita(
          url: receita.imagemUrl,
          raio: 0,
          tamanhoIcone: 30,
        ),
      ),
    );
  }

  Widget _linhaInfo() {
    return Row(
      children: [
        const Icon(Icons.timer,
            size: 13, color: Cores.textoCinza),
        const SizedBox(width: 3),
        Text(
          '${receita.tempoMinutos} min',
          style: const TextStyle(
              fontSize: 12, color: Cores.textoCinza),
        ),
        const SizedBox(width: 10),
        if (mostrarCategoria)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Cores.primariaClara,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              receita.categoria,
              style: const TextStyle(
                fontSize: 10,
                color: Cores.primariaEscura,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else ...[
          const Icon(Icons.local_fire_department,
              size: 13, color: Cores.primaria),
          const SizedBox(width: 3),
          Text(
            receita.dificuldade,
            style: const TextStyle(
                fontSize: 12, color: Cores.primaria),
          ),
        ],
      ],
    );
  }
}
