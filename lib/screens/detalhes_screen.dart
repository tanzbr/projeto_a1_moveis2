import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../data/database_helper.dart';
import 'tela_cadastro_receita.dart';

class DetalhesScreen extends StatefulWidget {
  final Receita receita;

  const DetalhesScreen({super.key, required this.receita});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  late bool _favorito;
  late Receita _receita;

  @override
  void initState() {
    super.initState();
    _receita = widget.receita;
    _favorito = _receita.favorito;
  }

  Future<void> _toggleFavorito() async {
    setState(() {
      _favorito = !_favorito;
      _receita.favorito = _favorito;
    });

    if (_favorito) {
      await DatabaseHelper.salvarFavorito(_receita.id);
    } else {
      await DatabaseHelper.removerFavorito(_receita.id);
    }
  }

  Future<void> _editar() async {
    final resultado = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaCadastroReceita(receita: _receita),
      ),
    );
    if (resultado == null || !mounted) return;
    if (resultado == -1) {
      Navigator.pop(context);
      return;
    }
    final atualizada = await DatabaseHelper.buscarReceita(resultado);
    if (atualizada == null || !mounted) return;
    atualizada.favorito = _favorito;
    setState(() => _receita = atualizada);
  }

  @override
  Widget build(BuildContext context) {
    final receita = _receita;
    const corPrincipal = Color.fromARGB(255, 107, 91, 149);
    const corBadge = Color.fromARGB(255, 213, 204, 230);

    return Scaffold(
      appBar: AppBar(
        title: Text(receita.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editar,
          ),
          IconButton(
            icon: Icon(
              _favorito ? Icons.favorite : Icons.favorite_border,
              color: _favorito ? Colors.redAccent : Colors.white,
            ),
            onPressed: _toggleFavorito,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem da receita (Hero)
            Hero(
              tag: 'receita-imagem-${receita.id}',
              child: SizedBox(
                width: double.infinity,
                height: 250,
                child: _buildImagem(receita.imagemUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receita.nome,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 45, 45, 45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    receita.descricao,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 117, 117, 117)),
                  ),
                  const SizedBox(height: 16),
                  // Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge(Icons.timer, '${receita.tempoMinutos} min',
                          corPrincipal, corBadge),
                      _badge(Icons.people, '${receita.porcoes} porções',
                          corPrincipal, corBadge),
                      _badge(Icons.local_fire_department,
                          receita.dificuldade, corPrincipal, corBadge),
                      _badge(Icons.category, receita.categoria,
                          corPrincipal, corBadge),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ingredientes
                  const Text(
                    'Ingredientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 45, 45, 45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...receita.ingredientes.map((ingrediente) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.circle,
                                size: 6, color: corPrincipal),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(ingrediente.nome,
                                  style: const TextStyle(fontSize: 14)),
                            ),
                            Text(
                              ingrediente.quantidade,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color:
                                      Color.fromARGB(255, 117, 117, 117)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),

                  // Modo de Preparo
                  const Text(
                    'Modo de Preparo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 45, 45, 45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...receita.modoPreparo.asMap().entries.map(
                        (entry) => Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
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
                                  padding:
                                      const EdgeInsets.only(top: 3),
                                  child: Text(entry.value,
                                      style: const TextStyle(
                                          fontSize: 14)),
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

  Widget _buildImagem(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.restaurant, size: 60, color: Colors.grey),
        ),
      );
    }
    if (isAssetImage(url)) {
      return Image.asset(url, fit: BoxFit.cover);
    }
    if (isBase64Image(url)) {
      final bytes = base64ToBytes(url);
      if (bytes == null) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.restaurant, size: 60, color: Colors.grey),
          ),
        );
      }
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, st) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.restaurant, size: 60, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _badge(
      IconData icon, String text, Color corIcone, Color corFundo) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
