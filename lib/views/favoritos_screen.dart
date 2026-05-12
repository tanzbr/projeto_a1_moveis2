import 'package:flutter/material.dart';
import '../controllers/receita_controller.dart';
import '../models/receita.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import '../widgets/campo_busca.dart';
import '../widgets/card_receita_lista.dart';
import 'detalhes_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => FavoritosScreenState();
}

class FavoritosScreenState extends State<FavoritosScreen> {
  final ReceitaController _controller = ReceitaController();
  final _filtroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // listener no controller refaz o filtro a cada digitação
    _filtroController.addListener(() => setState(() {}));
    _controller.carregarReceitas();
  }

  @override
  void dispose() {
    _filtroController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> recarregar() => _controller.carregarReceitas();

  Future<void> _abrirDetalhes(Receita receita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(receita: receita)),
    );
    // ao voltar, recarrega caso o usuário tenha desfavoritado lá dentro
    _controller.carregarReceitas();
  }

  Future<void> _desfavoritar(Receita receita) async {
    await _controller.removerFavorito(receita.id);
    receita.favorito = false;
    if (!mounted) return;
    // feedback visual rápido confirmando a ação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${receita.nome} removido dos favoritos'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Receita> get _favoritas =>
      _controller.receitas.where((r) => r.favorito).toList();

  // filtra os favoritos pelo texto digitado (apenas pelo nome)
  List<Receita> get _filtradas {
    final q = _filtroController.text.toLowerCase().trim();
    if (q.isEmpty) return _favoritas;
    return _favoritas.where((r) => r.nome.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Receitas Salvas')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          final favoritas = _favoritas;
          final filtradas = _filtradas;

          if (_controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

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
