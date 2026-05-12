// casca da navegação inferior — controla qual aba está visível
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'explorar_screen.dart';
import 'favoritos_screen.dart';

class TelaNavegacao extends StatefulWidget {
  const TelaNavegacao({super.key});

  @override
  State<TelaNavegacao> createState() => _TelaNavegacaoState();
}

class _TelaNavegacaoState extends State<TelaNavegacao> {
  int _indiceSelecionado = 0;

  // GlobalKeys p/ chamar métodos do State de cada aba (ex.: recarregar)
  final _homeKey = GlobalKey<HomeScreenState>();
  final _explorarKey = GlobalKey<ExplorarScreenState>();
  final _favoritosKey = GlobalKey<FavoritosScreenState>();

  // disparado pela Home ao tocar num chip de categoria → pula p/ Explorar
  void _irParaExplorar({String? categoria}) {
    _explorarKey.currentState?.selecionarCategoria(categoria);
    setState(() => _indiceSelecionado = 1);
    _explorarKey.currentState?.recarregar();
  }

  // ao trocar de aba, recarrega os dados da aba ativa p/ refletir mudanças
  // feitas em outra (ex.: favoritar um item na Explorar e voltar p/ Home)
  void _aoTrocarAba(int novo) {
    setState(() => _indiceSelecionado = novo);
    switch (novo) {
      case 0:
        _homeKey.currentState?.recarregar();
        break;
      case 1:
        _explorarKey.currentState?.recarregar();
        break;
      case 2:
        _favoritosKey.currentState?.recarregar();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantém as 3 telas vivas: preserva scroll/filtros
      // ao trocar de aba (ao contrário de só recriar o widget)
      body: IndexedStack(
        index: _indiceSelecionado,
        children: [
          HomeScreen(key: _homeKey, onExplorar: _irParaExplorar),
          ExplorarScreen(key: _explorarKey),
          FavoritosScreen(key: _favoritosKey),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSelecionado,
        onDestinationSelected: _aoTrocarAba,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}
