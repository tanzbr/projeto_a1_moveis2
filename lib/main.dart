import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'data/database_helper.dart';
import 'data/receitas_data.dart' as dados;
import 'screens/home_screen.dart';
import 'screens/explorar_screen.dart';
import 'screens/favoritos_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // sqflite no web precisa do factory FFI (sem web worker p/ evitar bug de result null)
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }
  // carrega receitas do SQLite (seed acontece no onCreate na primeira execução)
  dados.listaReceitas = await DatabaseHelper.instance.listarReceitas();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReceitasRápidas',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 155, 142, 193),
        scaffoldBackgroundColor: const Color.fromARGB(255, 250, 248, 252),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 155, 142, 193),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      scrollBehavior: const ScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
        },
      ),
      home: const TelaNavegacao(),
    );
  }
}

class TelaNavegacao extends StatefulWidget {
  const TelaNavegacao({super.key});

  @override
  State<TelaNavegacao> createState() => _TelaNavegacaoState();
}

class _TelaNavegacaoState extends State<TelaNavegacao> {
  int _indiceSelecionado = 0;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey();
  final GlobalKey<ExplorarScreenState> _explorarKey = GlobalKey();
  final GlobalKey<FavoritosScreenState> _favoritosKey = GlobalKey();

  late final List<Widget> _telas;

  @override
  void initState() {
    super.initState();
    _telas = [
      HomeScreen(key: _homeKey),
      ExplorarScreen(key: _explorarKey),
      FavoritosScreen(key: _favoritosKey),
    ];
  }

  Future<void> _trocarTela(int i) async {
    setState(() {
      _indiceSelecionado = i;
    });
    dados.listaReceitas = await DatabaseHelper.instance.listarReceitas();
    if (!mounted) return;
    if (i == 0) {
      _homeKey.currentState?.carregarFavoritos();
    } else if (i == 1) {
      _explorarKey.currentState?.recarregar();
    } else if (i == 2) {
      _favoritosKey.currentState?.carregarFavoritos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceSelecionado,
        children: [
          for (int i = 0; i < _telas.length; i++)
            HeroMode(enabled: i == _indiceSelecionado, child: _telas[i]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSelecionado,
        onDestinationSelected: _trocarTela,
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
