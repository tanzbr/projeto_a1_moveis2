import 'package:flutter/material.dart';
import '../controllers/favorito_controller.dart';
import '../controllers/receita_controller.dart';
import '../models/receita.dart';
import '../theme/cores.dart';
import '../widgets/carrossel_receita.dart';
import '../widgets/card_receita_lista.dart';
import 'auth_gate.dart';
import 'detalhes_screen.dart';
import 'tela_cadastro_receita.dart';
import 'tela_lista_compras.dart';

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

  final ReceitaController _controller = ReceitaController();

  @override
  void initState() {
    super.initState();
    _controller.carregarReceitasPublicas(); // carga inicial vinda do banco
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // exposto à TelaNavegacao via GlobalKey p/ atualizar ao voltar p/ aba
  Future<void> recarregar() => _controller.carregarReceitasPublicas();

  Future<void> _abrirDetalhes(BuildContext context, Receita receita) async {
    // await garante que recarregamos só depois que o usuário fechar a tela
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(receita: receita)),
    );
    _controller.carregarReceitasPublicas(); // reflete favorito/edições ao voltar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReceitasRápidas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Lista de compras',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaListaCompras()),
            ),
          ),
        ],
      ),
      // FAB abre o cadastro; espera o id devolvido p/ confirmar a inserção
      // heroTag unico evita colisao com o FAB da tela Minhas Receitas
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_home_nova_receita',
        onPressed: () async {
          // capturados antes do await p/ não usar context após gap async
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          // criar receita exige login; o gate abre a tela de login se preciso
          final autenticado = await exigirLogin(context);
          if (!mounted || !autenticado) return;
          final novoId = await navigator.push<int>(
            MaterialPageRoute(builder: (_) => const TelaCadastroReceita()),
          );
          if (!mounted) return;
          if (novoId != null) {
            _controller.carregarReceitasPublicas();
            messenger.showSnackBar(
              const SnackBar(content: Text('Receita cadastrada!')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova receita'),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge(
          [_controller, FavoritoController.instance],
        ),
        builder: (context, child) {
          // filtros leves em memória — não precisa de query no banco p/ isso
          final receitas = _controller.receitas;
          final receitasDestaque = receitas.where((r) => r.destaque).toList();
          // favoritos vem da tabela por-usuario, nao mais da coluna na receita
          final favoritos = FavoritoController.instance.receitas;

          return SingleChildScrollView(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Cores.fundoSuave,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Cores.primaria),
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
                            categoria: cat['label'] as String,
                          ),
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
                        Icon(
                          Icons.favorite,
                          size: 20,
                          color: Cores.primariaEscura,
                        ),
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
                  ...favoritos.map(
                    (receita) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: CardReceitaLista(
                        receita: receita,
                        onTap: () => _abrirDetalhes(context, receita),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
