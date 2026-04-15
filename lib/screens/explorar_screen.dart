import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/receita.dart';
import '../widgets/card_receita.dart';
import 'detalhes_screen.dart';

class ExplorarScreen extends StatefulWidget {
  final String? categoriaInicial;

  const ExplorarScreen({super.key, this.categoriaInicial});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  final _buscaController = TextEditingController();
  List<Receita> _receitas = [];

  final List<String> _categorias = [
    'Todos',
    'Café da Manhã',
    'Almoço',
    'Jantar',
    'Lanches'
  ];
  String _categoriaAtual = 'Todos';
  String _filtroTempo = 'Todos';
  String _filtroDificuldade = 'Todos';

  @override
  void initState() {
    super.initState();
    if (widget.categoriaInicial != null &&
        _categorias.contains(widget.categoriaInicial)) {
      _categoriaAtual = widget.categoriaInicial!;
    }
    _carregarReceitas();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarReceitas() async {
    final dados = await DatabaseHelper.listarReceitas();
    if (!mounted) return;
    setState(() => _receitas = dados);
  }

  List<Receita> get _receitasFiltradas {
    final busca = _buscaController.text.toLowerCase().trim();

    return _receitas.where((r) {
      if (_categoriaAtual != 'Todos' && r.categoria != _categoriaAtual) {
        return false;
      }

      if (busca.isNotEmpty) {
        final nomeMatch = r.nome.toLowerCase().contains(busca);
        final ingredienteMatch =
            r.ingredientes.any((i) => i.nome.toLowerCase().contains(busca));
        if (!nomeMatch && !ingredienteMatch) return false;
      }

      if (_filtroTempo == 'Até 10 min' && r.tempoMinutos > 10) return false;
      if (_filtroTempo == 'Até 20 min' && r.tempoMinutos > 20) return false;
      if (_filtroTempo == 'Até 30 min' && r.tempoMinutos > 30) return false;

      if (_filtroDificuldade != 'Todos' &&
          r.dificuldade != _filtroDificuldade) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Receitas'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categorias.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categorias[i];
                return ChoiceChip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  selected: _categoriaAtual == cat,
                  onSelected: (_) => setState(() => _categoriaAtual = cat),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _buscaController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou ingrediente...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: Color.fromARGB(255, 155, 142, 193)),
                filled: true,
                fillColor: const Color.fromARGB(255, 240, 235, 248),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filtroTempo,
                    decoration: InputDecoration(
                      labelText: 'Tempo',
                      labelStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: [
                      'Todos',
                      'Até 10 min',
                      'Até 20 min',
                      'Até 30 min'
                    ]
                        .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v,
                                style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) => setState(() => _filtroTempo = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filtroDificuldade,
                    decoration: InputDecoration(
                      labelText: 'Dificuldade',
                      labelStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: ['Todos', 'Fácil', 'Médio', 'Difícil']
                        .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v,
                                style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _filtroDificuldade = v!),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _receitasFiltradas.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma receita encontrada.',
                      style: TextStyle(
                          color: Color.fromARGB(255, 117, 117, 117)),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 210,
                    ),
                    itemCount: _receitasFiltradas.length,
                    itemBuilder: (context, index) {
                      final receita = _receitasFiltradas[index];
                      return CardReceita(
                        receita: receita,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DetalhesScreen(receita: receita)),
                          );
                          _carregarReceitas();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
