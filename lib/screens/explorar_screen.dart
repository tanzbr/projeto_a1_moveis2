import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/receitas_data.dart';
import '../models/receita.dart';
import '../widgets/recipe_card.dart';
import 'detalhes_screen.dart';

class ExplorarScreen extends StatefulWidget {
  final String? categoriaInicial;
  final String? buscaInicial;

  const ExplorarScreen({
    super.key,
    this.categoriaInicial,
    this.buscaInicial,
  });

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _buscaController;

  // categorias que aparecem nas abas
  final List<String> _categorias = ['Todos', 'Café da Manhã', 'Almoço', 'Jantar', 'Lanches'];
  String _filtroTempo = 'Todos';
  String _filtroDificuldade = 'Todos';

  @override
  void initState() {
    super.initState();
    // se vier de outra tela com categoria selecionada, abre direto na aba certa
    int indiceInicial = _categorias.indexOf(widget.categoriaInicial ?? 'Todos');
    if (indiceInicial == -1) indiceInicial = 0;
    _tabController = TabController(
      length: _categorias.length,
      vsync: this,
      initialIndex: indiceInicial,
    );
    _buscaController = TextEditingController(text: widget.buscaInicial ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  // filtra a lista de acordo com os filtros ativos
  List<Receita> get _receitasFiltradas {
    final busca = _buscaController.text.toLowerCase().trim();
    final categoriaAtual = _categorias[_tabController.index];

    return listaReceitas.where((r) {
      if (categoriaAtual != 'Todos' && r.categoria != categoriaAtual) return false;

      // busca por nome ou ingrediente
      if (busca.isNotEmpty) {
        final nomeMatch = r.nome.toLowerCase().contains(busca);
        final ingredienteMatch = r.ingredientes.any(
          (i) => i.nome.toLowerCase().contains(busca),
        );
        if (!nomeMatch && !ingredienteMatch) return false;
      }

      if (_filtroTempo == 'Até 10 min' && r.tempoMinutos > 10) return false;
      if (_filtroTempo == 'Até 20 min' && r.tempoMinutos > 20) return false;
      if (_filtroTempo == 'Até 30 min' && r.tempoMinutos > 30) return false;

      if (_filtroDificuldade != 'Todos' && r.dificuldade != _filtroDificuldade) return false;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explorar Receitas', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          isScrollable: true,
          labelColor: const Color.fromARGB(255, 255, 255, 255),
          unselectedLabelColor: const Color.fromARGB(255, 236, 236, 236),
          indicatorColor: const Color.fromARGB(255, 255, 255, 255),
          tabs: _categorias.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _buscaController,
              onChanged: (valor) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou ingrediente...',
                hintStyle: GoogleFonts.poppins(fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 155, 142, 193)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filtroTempo,
                    decoration: InputDecoration(
                      labelText: 'Tempo',
                      labelStyle: GoogleFonts.poppins(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: ['Todos', 'Até 10 min', 'Até 20 min', 'Até 30 min']
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v, style: GoogleFonts.poppins(fontSize: 12)),
                            ))
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
                      labelStyle: GoogleFonts.poppins(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: ['Todos', 'Fácil', 'Médio', 'Difícil']
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v, style: GoogleFonts.poppins(fontSize: 12)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _filtroDificuldade = v!),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _receitasFiltradas.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma receita encontrada.',
                      style: GoogleFonts.poppins(color: const Color.fromARGB(255, 117, 117, 117)),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: _receitasFiltradas.length,
                    itemBuilder: (context, index) {
                      final receita = _receitasFiltradas[index];
                      return RecipeCard(
                        receita: receita,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetalhesScreen(receita: receita)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
