import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/receita.dart';
import '../widgets/carrossel_receita.dart';
import '../widgets/card_receita_lista.dart';
import 'detalhes_screen.dart';
import 'tela_cadastro_receita.dart';

class HomeScreen extends StatefulWidget {
  final void Function({String? categoria}) onExplorar;

  const HomeScreen({super.key, required this.onExplorar});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categorias = [
    {'label': 'Café da Manhã', 'icon': Icons.coffee},
    {'label': 'Almoço', 'icon': Icons.restaurant},
    {'label': 'Jantar', 'icon': Icons.nightlight_round},
    {'label': 'Lanches', 'icon': Icons.lunch_dining},
  ];

  List<Receita> _receitas = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final dados = await DatabaseHelper.listarReceitas();
    if (!mounted) return;
    setState(() => _receitas = dados);
  }

  Future<void> _abrirDetalhes(BuildContext context, Receita receita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(receita: receita)),
    );
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    final receitasDestaque = _receitas.where((r) => r.destaque).toList();
    final favoritos = _receitas.where((r) => r.favorito).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReceitasRápidas'),
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
            _carregarDados();
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
                onTap: () => widget.onExplorar(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 240, 235, 248),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search,
                          color: Color.fromARGB(255, 155, 142, 193)),
                      SizedBox(width: 10),
                      Text(
                        'Buscar receitas...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 117, 117, 117),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categorias
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Categorias',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 45, 45, 45),
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
                      onTap: () => widget.onExplorar(
                          categoria: cat['label'] as String),
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
                              color:
                                  const Color.fromARGB(255, 107, 91, 149),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (cat['label'] as String).split(' ').first,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color.fromARGB(255, 107, 91, 149),
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

            // Receitas em Destaque
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Receitas em Destaque',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 45, 45, 45),
                ),
              ),
            ),
            CarrosselReceita(
              receitas: receitasDestaque,
              onReceitaTap: (receita) => _abrirDetalhes(context, receita),
            ),

            // Últimos Favoritos
            if (favoritos.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.favorite,
                        size: 20,
                        color: Color.fromARGB(255, 107, 91, 149)),
                    SizedBox(width: 8),
                    Text(
                      'Seus Favoritos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 45, 45, 45),
                      ),
                    ),
                  ],
                ),
              ),
              ...favoritos.map((receita) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
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
