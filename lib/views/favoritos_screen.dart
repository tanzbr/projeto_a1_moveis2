import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/favorito_controller.dart';
import '../models/receita.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import '../widgets/campo_busca.dart';
import '../widgets/card_receita_lista.dart';
import 'auth_gate.dart';
import 'detalhes_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => FavoritosScreenState();
}

class FavoritosScreenState extends State<FavoritosScreen> {
  final FavoritoController _controller = FavoritoController.instance;
  final _filtroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtroController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _filtroController.dispose();
    super.dispose();
  }

  Future<void> recarregar() => _controller.recarregar();

  Future<void> _abrirDetalhes(Receita receita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(receita: receita)),
    );
    await _controller.recarregar();
  }

  Future<void> _desfavoritar(Receita receita) async {
    final autenticado = await exigirLogin(context);
    if (!mounted || !autenticado) {
      // recarrega para "reverter" o swipe quando o usuario cancelou o login
      await _controller.recarregar();
      return;
    }
    await _controller.desfavoritar(receita.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${receita.nome} removido dos favoritos'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Receita> _filtrar(List<Receita> favoritas) {
    final q = _filtroController.text.toLowerCase().trim();
    if (q.isEmpty) return favoritas;
    return favoritas.where((r) => r.nome.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Receitas Salvas')),
      body: ListenableBuilder(
        listenable: Listenable.merge([_controller, AuthController.instance]),
        builder: (context, child) {
          if (!AuthController.instance.estaLogado) return _semLogin();
          if (_controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoritas = _controller.receitas;
          final filtradas = _filtrar(favoritas);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: CampoBusca(
                  controller: _filtroController,
                  hint: 'Filtrar favoritos por nome...',
                ),
              ),
              Expanded(
                child: favoritas.isEmpty
                    ? _vazio()
                    : filtradas.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum favorito corresponde ao filtro.',
                          style: TextStyle(color: Cores.textoCinza),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtradas.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final receita = filtradas[index];
                          return _cardFavorito(receita);
                        },
                      ),
              ),
              // rodapé com contagem total (singular/plural)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                color: Cores.fundoSuave,
                child: Text(
                  '${favoritas.length} ${favoritas.length == 1 ? "receita salva" : "receitas salvas"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Cores.primariaEscura,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Dismissible permite remover o favorito arrastando o card p/ a esquerda
  Widget _cardFavorito(Receita receita) {
    return Dismissible(
      key: ValueKey('fav-${receita.id}'), // chave estável p/ o Flutter
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(Espacos.raioCard),
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

  Widget _semLogin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Espacos.padPadrao),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline,
                size: 64, color: Cores.primariaEscura),
            const SizedBox(height: 12),
            const Text(
              'Entre para ver seus favoritos.',
              style: TextStyle(fontSize: 16, color: Cores.textoEscuro),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Entrar'),
              onPressed: () => exigirLogin(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vazio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Cores.primaria),
          SizedBox(height: 16),
          Text(
            'Nenhuma receita favorita ainda.',
            style: TextStyle(fontSize: 16, color: Cores.textoCinza),
          ),
          SizedBox(height: 8),
          Text(
            'Toque no coração nas receitas para salvar aqui!',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
