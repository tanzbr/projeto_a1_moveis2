import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/receita.dart';
import '../widgets/card_receita_lista.dart';
import 'detalhes_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  bool _carregando = true;
  List<Receita> _favoritas = [];
  final _filtroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtroController.addListener(() => setState(() {}));
    _carregarFavoritos();
  }

  @override
  void dispose() {
    _filtroController.dispose();
    super.dispose();
  }

  Future<void> _carregarFavoritos() async {
    setState(() => _carregando = true);
    final todas = await DatabaseHelper.listarReceitas();
    if (!mounted) return;
    setState(() {
      _favoritas = todas.where((r) => r.favorito).toList();
      _carregando = false;
    });
  }

  Future<void> _abrirDetalhes(Receita receita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(receita: receita)),
    );
    _carregarFavoritos();
  }

  Future<void> _desfavoritar(Receita receita) async {
    await DatabaseHelper.removerFavorito(receita.id);
    receita.favorito = false;
    if (!mounted) return;
    setState(() {
      _favoritas.removeWhere((r) => r.id == receita.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${receita.nome} removido dos favoritos'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Receita> get _filtradas {
    final q = _filtroController.text.toLowerCase().trim();
    if (q.isEmpty) return _favoritas;
    return _favoritas
        .where((r) => r.nome.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtradas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Receitas Salvas'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    controller: _filtroController,
                    decoration: InputDecoration(
                      hintText: 'Filtrar favoritos por nome...',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: Color.fromARGB(255, 155, 142, 193)),
                      filled: true,
                      fillColor:
                          const Color.fromARGB(255, 240, 235, 248),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                Expanded(
                  child: _favoritas.isEmpty
                      ? _vazio()
                      : filtradas.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum favorito corresponde ao filtro.',
                                style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 117, 117, 117)),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtradas.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final receita = filtradas[index];
                                return _cardFavorito(receita);
                              },
                            ),
                ),
                // Contador
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 16),
                  color: const Color.fromARGB(255, 240, 235, 248),
                  child: Text(
                    '${_favoritas.length} ${_favoritas.length == 1 ? "receita salva" : "receitas salvas"}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 107, 91, 149),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _cardFavorito(Receita receita) {
    return Dismissible(
      key: ValueKey('fav-${receita.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _desfavoritar(receita),
      child: CardReceitaLista(
        receita: receita,
        onTap: () => _abrirDetalhes(receita),
        mostrarCategoria: true,
        acaoDireita: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.redAccent),
          onPressed: () => _desfavoritar(receita),
        ),
      ),
    );
  }

  Widget _vazio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border,
              size: 64, color: Color.fromARGB(255, 155, 142, 193)),
          SizedBox(height: 16),
          Text(
            'Nenhuma receita favorita ainda.',
            style: TextStyle(
                fontSize: 16, color: Color.fromARGB(255, 117, 117, 117)),
          ),
          SizedBox(height: 8),
          Text(
            'Toque no coração nas receitas para salvar aqui!',
            style: TextStyle(
                fontSize: 13, color: Color.fromARGB(255, 160, 160, 160)),
          ),
        ],
      ),
    );
  }
}
