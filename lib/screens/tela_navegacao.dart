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
  String? _categoriaExplorar;

  void _irParaExplorar({String? categoria}) {
    setState(() {
      _categoriaExplorar = categoria;
      _indiceSelecionado = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _indiceSelecionado == 0
          ? HomeScreen(onExplorar: _irParaExplorar)
          : _indiceSelecionado == 1
          ? ExplorarScreen(categoriaInicial: _categoriaExplorar)
          : const FavoritosScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSelecionado,
        onDestinationSelected: (i) {
          setState(() {
            _categoriaExplorar = null;
            _indiceSelecionado = i;
          });
        },
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
