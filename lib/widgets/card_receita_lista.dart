import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/receita.dart';
import '../utils/image_utils.dart';

// Card horizontal usado nas telas Home (lista de favoritos rápidos)
// e Favoritos (lista completa). Mesmo visual, pequenas variações.
class CardReceitaLista extends StatelessWidget {
  final Receita receita;
  final VoidCallback onTap;
  final String? rodape;
  final bool mostrarCategoria;
  final Widget? acaoDireita;

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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      receita.nome,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 45, 45, 45),
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
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color.fromARGB(255, 160, 160, 160),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: acaoDireita ??
                  const Icon(
                    Icons.chevron_right,
                    color: Color.fromARGB(255, 155, 142, 193),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail() {
    final bytes = isBase64Image(receita.imagemUrl)
        ? base64ToBytes(receita.imagemUrl)
        : null;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
        image: bytes != null
            ? DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover)
            : null,
      ),
      child: bytes == null
          ? const Center(
              child: Icon(Icons.restaurant, size: 30, color: Colors.grey),
            )
          : null,
    );
  }

  Widget _linhaInfo() {
    return Row(
      children: [
        const Icon(Icons.timer, size: 13, color: Color.fromARGB(255, 117, 117, 117)),
        const SizedBox(width: 3),
        Text(
          '${receita.tempoMinutos} min',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color.fromARGB(255, 117, 117, 117),
          ),
        ),
        const SizedBox(width: 10),
        if (mostrarCategoria)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 213, 204, 230),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              receita.categoria,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: const Color.fromARGB(255, 107, 91, 149),
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else ...[
          const Icon(Icons.local_fire_department,
              size: 13, color: Color.fromARGB(255, 155, 142, 193)),
          const SizedBox(width: 3),
          Text(
            receita.dificuldade,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color.fromARGB(255, 155, 142, 193),
            ),
          ),
        ],
      ],
    );
  }
}
