import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/favoritos_storage.dart';
import '../models/receita.dart';
import '../theme/cores.dart';
import '../widgets/carrossel_receita.dart';
import '../widgets/card_receita_lista.dart';
import 'detalhes_screen.dart';
import 'tela_cadastro_receita.dart';

class HomeScreen extends StatefulWidget {
  // callback usado p/ pedir à TelaNavegacao p/ abrir a aba Explorar
  // (opcionalmente já filtrando por uma categoria escolhida aqui)
  final void Function({String? categoria}) onExplorar;

  const HomeScreen({super.key, required this.onExplorar});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // categorias fixas exibidas no carrossel horizontal
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
    _carregarDados(); // carga inicial vinda do banco
  }

  // exposto à TelaNavegacao via GlobalKey p/ atualizar ao voltar p/ aba
  Future<void> recarregar() => _carregarDados();

  Future<void> _carregarDados() async {
    final dados = await DatabaseHelper.listarReceitas();
    if (!mounted) return; // evita setState se a tela já foi descartada
    final comFavoritos = await FavoritosStorage.aplicarFavoritos(dados);
    if (!mounted) return;
    setState(() => _receitas = comFavoritos);
  }

  Future<void> _abrirDetalhes(BuildContext context, Receita receita) async {
    // await garante que recarregamos só depois que o usuário fechar a tela
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(receita: receita)),
    );
    _carregarDados(); // reflete favorito/edições ao voltar
  }

  @override
  Widget build(BuildContext context) {
    // filtros leves em memória — não precisa de query no banco p/ isso
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
      // FAB abre o cadastro; espera o id devolvido p/ confirmar a inserção
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // capturado antes do await p/ não usar context após gap async
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
            // "Falso" campo de busca: só leva pra aba Explorar (busca real lá)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: InkWell(
                onTap: () => widget.onExplorar(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Cores.fundoSuave,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search,
                          color: Cores.primaria),
                      SizedBox(width: 10),
                      Text(
                        'Buscar receitas...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Cores.textoCinza,
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
                  color: Cores.textoEscuro,
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
                      // tocar no chip já abre Explorar com o filtro aplicado
                      onTap: () => widget.onExplorar(
                          categoria: cat['label'] as String),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: Cores.primariaClara,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              color: Cores.primariaEscura,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (cat['label'] as String).split(' ').first,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Cores.primariaEscura,
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
                  color: Cores.textoEscuro,
                ),
              ),
            ),
            CarrosselReceita(
              receitas: receitasDestaque,
              onReceitaTap: (receita) => _abrirDetalhes(context, receita),
            ),

            // Seção só aparece se o usuário já favoritou alguma receita
            if (favoritos.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.favorite,
                        size: 20,
                        color: Cores.primariaEscura),
                    SizedBox(width: 8),
                    Text(
                      'Seus Favoritos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Cores.textoEscuro,
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
