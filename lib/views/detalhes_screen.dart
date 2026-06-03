import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/avaliacao_controller.dart';
import '../controllers/favorito_controller.dart';
import '../controllers/lista_compras_controller.dart';
import '../controllers/receita_controller.dart';
import '../models/receita.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import '../widgets/avaliacao_receita.dart';
import '../widgets/badge_avaliacao.dart';
import '../widgets/imagem_receita.dart';
import 'auth_gate.dart';
import 'tela_cadastro_receita.dart';

class DetalhesScreen extends StatefulWidget {
  final Receita receita;

  const DetalhesScreen({super.key, required this.receita});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final ReceitaController _controller = ReceitaController();
  final FavoritoController _favoritoController = FavoritoController.instance;
  final AvaliacaoController _avaliacaoController = AvaliacaoController();
  late Receita _receita;

  @override
  void initState() {
    super.initState();
    _receita = widget.receita;
    _avaliacaoController.carregar(_receita.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    _avaliacaoController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorito() async {
    final autenticado = await exigirLogin(context);
    if (!mounted || !autenticado) return;

    if (_favoritoController.ehFavorita(_receita.id)) {
      await _favoritoController.desfavoritar(_receita.id);
    } else {
      await _favoritoController.favoritar(_receita);
    }
  }

  void _abrirAvaliacao() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: AvaliacaoReceitaWidget(
          receitaId: _receita.id,
          controller: _avaliacaoController,
        ),
      ),
    );
  }

  Future<void> _adicionarNaLista() async {
    final messenger = ScaffoldMessenger.of(context);
    final autenticado = await exigirLogin(context);
    if (!mounted || !autenticado) return;
    await ListaComprasController.instance.adicionarReceitas([_receita]);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Ingredientes adicionados a lista!')),
    );
  }

  Future<void> _editar() async {
    final autenticado = await exigirLogin(context);
    if (!mounted || !autenticado) return;
    final resultado = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => TelaCadastroReceita(receita: _receita)),
    );
    if (resultado == null || !mounted) return;
    if (resultado == -1) {
      Navigator.pop(context);
      return;
    }
    final atualizada = await _controller.buscarReceita(resultado);
    if (atualizada == null || !mounted) return;
    setState(() => _receita = atualizada);
  }

  @override
  Widget build(BuildContext context) {
    final receita = _receita;
    const corPrincipal = Cores.primariaEscura;
    const corBadge = Cores.primariaClara;

    final usuarioAtual = AuthController.instance.usuario;
    final eDono = usuarioAtual != null &&
        receita.usuarioId != null &&
        receita.usuarioId == usuarioAtual.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(receita.nome),
        actions: [
          ListenableBuilder(
            listenable: _avaliacaoController,
            builder: (context, _) {
              final jaAvaliei = _avaliacaoController.notaUsuario != null;
              return IconButton(
                tooltip: 'Avaliar receita',
                icon: Icon(
                  jaAvaliei ? Icons.star : Icons.star_border,
                  color: Colors.white,
                ),
                onPressed: _abrirAvaliacao,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            tooltip: 'Adicionar a lista de compras',
            onPressed: _adicionarNaLista,
          ),
          if (eDono)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _editar,
            ),
          ListenableBuilder(
            listenable: _favoritoController,
            builder: (context, _) {
              final ehFavorita = _favoritoController.ehFavorita(receita.id);
              return IconButton(
                icon: Icon(
                  ehFavorita ? Icons.favorite : Icons.favorite_border,
                  color: ehFavorita ? Colors.redAccent : Colors.white,
                ),
                onPressed: _toggleFavorito,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImagemReceita(
              url: receita.imagemUrl,
              largura: double.infinity,
              altura: 250,
              raio: 0,
              tamanhoIcone: 60,
              heroTag: 'receita-imagem-${receita.id}',
            ),
            Padding(
              padding: const EdgeInsets.all(Espacos.padPadrao),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receita.nome,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Cores.textoEscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    receita.descricao,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Cores.textoCinza,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge(
                        Icons.timer,
                        '${receita.tempoMinutos} min',
                        corPrincipal,
                        corBadge,
                      ),
                      _badge(
                        Icons.people,
                        '${receita.porcoes} porções',
                        corPrincipal,
                        corBadge,
                      ),
                      _badge(
                        Icons.local_fire_department,
                        receita.dificuldade,
                        corPrincipal,
                        corBadge,
                      ),
                      _badge(
                        Icons.category,
                        receita.categoria,
                        corPrincipal,
                        corBadge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ListenableBuilder(
                    listenable: _avaliacaoController,
                    builder: (context, _) {
                      if (_avaliacaoController.total == 0) {
                        return const Text(
                          'Sem avaliacoes ainda',
                          style: TextStyle(
                            fontSize: 12,
                            color: Cores.textoCinza,
                          ),
                        );
                      }
                      return BadgeAvaliacao(
                        media: _avaliacaoController.media,
                        total: _avaliacaoController.total,
                        tamanhoIcone: 16,
                        tamanhoTexto: 13,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Ingredientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Cores.textoEscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...receita.ingredientes.map(
                    (ingrediente) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 6,
                            color: corPrincipal,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ingrediente.nome,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            ingrediente.quantidade,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Cores.textoCinza,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Modo de Preparo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Cores.textoEscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...receita.modoPreparo.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: corPrincipal,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text, Color corIcone, Color corFundo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: corIcone),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: corIcone,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
