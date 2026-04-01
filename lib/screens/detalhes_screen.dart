import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/receita.dart';

class DetalhesScreen extends StatelessWidget {
  final Receita receita;

  const DetalhesScreen({super.key, required this.receita});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receita.nome),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem placeholder
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.restaurant, size: 80, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receita.nome,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 45, 45, 45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    receita.descricao,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 117, 117, 117),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [ // badges
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 213, 204, 230),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer, size: 14, color: Color.fromARGB(255, 107, 91, 149)),
                            const SizedBox(width: 4),
                            Text(
                              '${receita.tempoMinutos} min',
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color.fromARGB(255, 107, 91, 149), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 213, 204, 230),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people, size: 14, color: Color.fromARGB(255, 107, 91, 149)),
                            const SizedBox(width: 4),
                            Text(
                              '${receita.porcoes} porções',
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color.fromARGB(255, 107, 91, 149), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 213, 204, 230),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, size: 14, color: Color.fromARGB(255, 107, 91, 149)),
                            const SizedBox(width: 4),
                            Text(
                              receita.dificuldade,
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color.fromARGB(255, 107, 91, 149), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
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
