import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/receita.dart';

class RecipeCard extends StatelessWidget {
  final Receita receita;
  final void Function() onTap;

  const RecipeCard({super.key, required this.receita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // card clicável que abre os detalhes da receita
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // imagem da receita (por enquanto só um placeholder)
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(Icons.restaurant, size: 40, color: Colors.grey),
              ),
            ),
            // informações da receita
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receita.nome,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 45, 45, 45),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 13, color: Color.fromARGB(255, 117, 117, 117)),
                      const SizedBox(width: 2),
                      Text(
                        '${receita.tempoMinutos} min',
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color.fromARGB(255, 117, 117, 117)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.people, size: 13, color: Color.fromARGB(255, 117, 117, 117)),
                      const SizedBox(width: 2),
                      Text(
                        '${receita.porcoes}',
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color.fromARGB(255, 117, 117, 117)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 13, color: Color.fromARGB(255, 155, 142, 193)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          receita.dificuldade,
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color.fromARGB(255, 155, 142, 193)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
