import 'package:flutter/material.dart';
import '../controllers/lista_compras_controller.dart';
import 'home_screen.dart';
import 'explorar_screen.dart';
import 'tela_lista_compras.dart';
import 'tela_perfil.dart';

class TelaNavegacao extends StatefulWidget {
  const TelaNavegacao({super.key});

  @override
  State<TelaNavegacao> createState() => _TelaNavegacaoState();
}

class _TelaNavegacaoState extends State<TelaNavegacao> {
  int _indiceSelecionado = 0;

  final _homeKey = GlobalKey<HomeScreenState>();
  final _explorarKey = GlobalKey<ExplorarScreenState>();

  void _irParaExplorar({String? categoria}) {
    _explorarKey.currentState?.selecionarCategoria(categoria);
    setState(() => _indiceSelecionado = 1);
    _explorarKey.currentState?.recarregar();
  }

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
        ListaComprasController.instance.recarregar();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceSelecionado,
        children: [
          HomeScreen(key: _homeKey, onExplorar: _irParaExplorar),
          ExplorarScreen(key: _explorarKey),
          const TelaListaCompras(),
          const TelaPerfil(),
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
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Compras',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
