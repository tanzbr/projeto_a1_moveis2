import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/receita.dart';
import '../data/local_storage.dart';

class DetalhesScreen extends StatefulWidget {
  final Receita receita;

  const DetalhesScreen({super.key, required this.receita});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  late bool _favorito;

  @override
  void initState() {
    super.initState();
    _favorito = widget.receita.favorito;
  }

  Future<void> _toggleFavorito() async {
    setState(() {
      _favorito = !_favorito;
      widget.receita.favorito = _favorito;
    });

    final ids = await FavoritosStorage.carregarFavoritos();
    if (_favorito) {
      ids.add(widget.receita.id);
    } else {
      ids.remove(widget.receita.id);
    }
    await FavoritosStorage.salvarFavoritos(ids);
  }

  @override
  Widget build(BuildContext context) {
    final receita = widget.receita;
    const corPrincipal = Color.fromARGB(255, 107, 91, 149);
    const corBadge = Color.fromARGB(255, 213, 204, 230);

    return Scaffold(
      appBar: AppBar(
        title: Text(receita.nome),
        actions: [
          IconButton(
            icon: Icon(
              _favorito ? Icons.favorite : Icons.favorite_border,
              color: _favorito ? Colors.redAccent : Colors.white,
            ),
            onPressed: _toggleFavorito,
          ),
        ],
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
                  // Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge(Icons.timer, '${receita.tempoMinutos} min', corPrincipal, corBadge),
                      _badge(Icons.people, '${receita.porcoes} porções', corPrincipal, corBadge),
                      _badge(Icons.local_fire_department, receita.dificuldade, corPrincipal, corBadge),
                      _badge(Icons.category, receita.categoria, corPrincipal, corBadge),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ingredientes
                  Text(
                    'Ingredientes',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 45, 45, 45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...receita.ingredientes.map((ingrediente) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: corPrincipal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ingrediente.nome,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                        Text(
                          ingrediente.quantidade,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 117, 117, 117),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),

                  // Modo de Preparo
                  Text(
                    'Modo de Preparo',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 45, 45, 45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...receita.modoPreparo.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: corPrincipal,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              entry.value,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text, Color corIcone, Color corFundo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: corIcone),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: corIcone,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
