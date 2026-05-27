import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/receita_controller.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import '../widgets/card_receita_lista.dart';
import 'auth_gate.dart';
import 'detalhes_screen.dart';
import 'tela_cadastro_receita.dart';

class TelaMinhasReceitas extends StatefulWidget {
  const TelaMinhasReceitas({super.key});

  @override
  State<TelaMinhasReceitas> createState() => TelaMinhasReceitasState();
}

class TelaMinhasReceitasState extends State<TelaMinhasReceitas> {
  final ReceitaController _controller = ReceitaController();
  final AuthController _auth = AuthController.instance;

  @override
  void initState() {
    super.initState();
    _carregar();
    // recarrega ao logar/sair (lista de receitas depende do usuario atual)
    _auth.addListener(_carregar);
  }

  @override
  void dispose() {
    _auth.removeListener(_carregar);
    _controller.dispose();
    super.dispose();
  }

  Future<void> recarregar() => _carregar();

  Future<void> _carregar() async {
    final usuario = _auth.usuario;
    if (usuario == null) return;
    await _controller.carregarMinhasReceitas(usuario.id);
  }

  Future<void> _abrirDetalhes(int id) async {
    final receita = await _controller.buscarReceita(id);
    if (receita == null || !mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(receita: receita)),
    );
    await _carregar();
  }

  Future<void> _novaReceita() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final autenticado = await exigirLogin(context);
    if (!mounted || !autenticado) return;
    final novoId = await navigator.push<int>(
      MaterialPageRoute(builder: (_) => const TelaCadastroReceita()),
    );
    if (!mounted) return;
    if (novoId != null) {
      await _carregar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Receita cadastrada!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Receitas')),
      // heroTag unico evita colisao com o FAB da Home
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_minhas_receitas_nova',
        onPressed: _novaReceita,
        icon: const Icon(Icons.add),
        label: const Text('Nova receita'),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_controller, _auth]),
        builder: (context, _) {
          if (!_auth.estaLogado) return _semLogin();
          if (_controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }
          final lista = _controller.receitas;
          if (lista.isEmpty) return _vazio();

          return ListView.separated(
            padding: const EdgeInsets.all(Espacos.padPadrao),
            itemCount: lista.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final receita = lista[index];
              return CardReceitaLista(
                receita: receita,
                onTap: () => _abrirDetalhes(receita.id),
                mostrarCategoria: true,
                // chip rapido para diferenciar publica de privada
                acaoDireita: Icon(
                  receita.publica ? Icons.public : Icons.lock_outline,
                  size: 20,
                  color: Cores.primariaEscura,
                ),
              );
            },
          );
        },
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
              'Entre para ver suas receitas.',
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
          Icon(Icons.menu_book_outlined, size: 64, color: Cores.primaria),
          SizedBox(height: 16),
          Text(
            'Você ainda não criou nenhuma receita.',
            style: TextStyle(fontSize: 16, color: Cores.textoCinza),
          ),
          SizedBox(height: 8),
          Text(
            'Use o botão "+" para cadastrar a primeira!',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
