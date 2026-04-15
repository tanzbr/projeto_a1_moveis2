import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/receita.dart';
import '../utils/image_utils.dart';

class RecipeCarousel extends StatefulWidget {
  final List<Receita> receitas;
  final void Function(Receita) onReceitaTap;

  const RecipeCarousel({
    super.key,
    required this.receitas,
    required this.onReceitaTap,
  });

  @override
  State<RecipeCarousel> createState() => _RecipeCarouselState();
}

class _RecipeCarouselState extends State<RecipeCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.8);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _imagemFundo(Receita receita) {
    final bytes = isBase64Image(receita.imagemUrl)
        ? base64ToBytes(receita.imagemUrl)
        : null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        image: bytes != null
            ? DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover)
            : null,
      ),
      child: bytes == null
          ? const Center(
              child: Icon(Icons.restaurant, size: 60, color: Colors.grey),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: widget.receitas.length,
        itemBuilder: (context, index) {
          final receita = widget.receitas[index];
          return GestureDetector(
            onTap: () => widget.onReceitaTap(receita),
            child: Container(
              margin: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 155, 142, 193),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  _imagemFundo(receita),
                  // Gradiente overlay com info
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receita.nome,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${receita.tempoMinutos} min',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.people,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${receita.porcoes} porções',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
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
        },
      ),
    );
  }
}
