import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/receitas_data.dart';
import '../data/local_storage.dart';
import '../models/receita.dart';
import '../widgets/recipe_card.dart';
import 'detalhes_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => FavoritosScreenState();
}

class FavoritosScreenState extends State<FavoritosScreen> {
  List<Receita> _receitasFavoritas = [];

  @override
  void initState() {
    super.initState();
    carregarFavoritos();
  }

  Future<void> carregarFavoritos() async {
    final ids = await FavoritosStorage.carregarFavoritos();
    setState(() {
      // sincroniza o campo favorito na lista global
      for (final receita in listaReceitas) {
        receita.favorito = ids.contains(receita.id);
      }
      _receitasFavoritas = listaReceitas.where((r) => r.favorito).toList();
    });
  }

  Future<void> _abrirDetalhes(Receita receita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(receita: receita)),
    );
    // recarrega ao voltar, pois o usuário pode ter desfavoritado
    carregarFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favoritos',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: _receitasFavoritas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Color.fromARGB(255, 155, 142, 193),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma receita favorita ainda.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 117, 117, 117),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no coração nas receitas para salvar aqui!',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color.fromARGB(255, 160, 160, 160),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: _receitasFavoritas.length,
              itemBuilder: (context, index) {
                final receita = _receitasFavoritas[index];
                return RecipeCard(
                  receita: receita,
                  onTap: () => _abrirDetalhes(receita),
                );
              },
            ),
    );
  }
}
