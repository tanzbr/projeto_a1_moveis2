import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/receitas_data.dart';
import '../data/database_helper.dart';
import '../models/receita.dart';
import '../widgets/recipe_carousel.dart';
import '../widgets/card_receita_lista.dart';
import 'detalhes_screen.dart';
import 'explorar_screen.dart';
import 'tela_cadastro_receita.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const _categorias = [
    {'label': 'Café da Manhã', 'icon': Icons.coffee},
    {'label': 'Almoço', 'icon': Icons.restaurant},
    {'label': 'Jantar', 'icon': Icons.nightlight_round},
    {'label': 'Lanches', 'icon': Icons.lunch_dining},
  ];

  List<Receita> _ultimosFavoritos = [];

  @override
  void initState() {
    super.initState();
    carregarFavoritos();
  }

  Future<void> carregarFavoritos() async {
    final ids = await DatabaseHelper.instance.listarIdsFavoritos();
    if (!mounted) return;
    setState(() {
      for (final receita in listaReceitas) {
        receita.favorito = ids.contains(receita.id);
      }
      _ultimosFavoritos = listaReceitas.where((r) => r.favorito).toList();
    });
  }

  void _abrirExplorar(
    BuildContext context, {
    String? categoria,
    String? busca,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ExplorarScreen(categoriaInicial: categoria, buscaInicial: busca),
      ),
    );
  }

  Future<void> _abrirDetalhes(BuildContext context, Receita receita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(receita: receita)),
    );
    carregarFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    final receitasDestaque = listaReceitas.where((r) => r.destaque).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ReceitasRápidas',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu_book),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final novoId = await Navigator.push<int>(
            context,
            MaterialPageRoute(builder: (_) => const TelaCadastroReceita()),
          );
          if (!mounted) return;
          if (novoId != null) {
            listaReceitas = await DatabaseHelper.instance.listarReceitas();
            if (!mounted) return;
            setState(() {});
            messenger.showSnackBar(
              const SnackBar(content: Text('Receita cadastrada!')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova receita'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de busca
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: InkWell(
                onTap: () => _abrirExplorar(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 240, 235, 248),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color.fromARGB(255, 155, 142, 193)),
                      const SizedBox(width: 10),
                      Text(
                        'Buscar receitas...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 117, 117, 117),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Seção Categorias
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Categorias',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 45, 45, 45),
                ),
              ),
            ),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final cat = _categorias[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => _abrirExplorar(
                        context,
                        categoria: cat['label'] as String,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 213, 204, 230),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              color: const Color.fromARGB(255, 107, 91, 149),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (cat['label'] as String).split(' ').first,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: const Color.fromARGB(255, 107, 91, 149),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Seção Receitas em Destaque
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Receitas em Destaque',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 45, 45, 45),
                ),
              ),
            ),
            RecipeCarousel(
              receitas: receitasDestaque,
              onReceitaTap: (receita) => _abrirDetalhes(context, receita),
            ),

            // Seção Últimos Favoritos
            if (_ultimosFavoritos.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, size: 20, color: Color.fromARGB(255, 107, 91, 149)),
                    const SizedBox(width: 8),
                    Text(
                      'Seus Favoritos',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 45, 45, 45),
                      ),
                    ),
                  ],
                ),
              ),
              ..._ultimosFavoritos.map((receita) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: CardReceitaLista(
                  receita: receita,
                  onTap: () => _abrirDetalhes(context, receita),
                ),
              )),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
