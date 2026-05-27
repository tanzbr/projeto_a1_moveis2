import 'package:flutter/material.dart';
import '../controllers/receita_controller.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import '../widgets/imagem_receita.dart';

// Tela com checkboxes para escolher quais receitas vao virar itens na lista
// de compras. Devolve a List<Receita> selecionada via Navigator.pop.
class TelaSelecionarReceitas extends StatefulWidget {
  const TelaSelecionarReceitas({super.key});

  @override
  State<TelaSelecionarReceitas> createState() => _TelaSelecionarReceitasState();
}

class _TelaSelecionarReceitasState extends State<TelaSelecionarReceitas> {
  final ReceitaController _controller = ReceitaController();
  // Set para alternar selecao em O(1) e nao depender da ordem
  final Set<int> _selecionados = {};

  @override
  void initState() {
    super.initState();
    _controller.carregarReceitas(); // tudo que o RLS deixa eu ver
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _alternar(int id) {
    setState(() {
      if (_selecionados.contains(id)) {
        _selecionados.remove(id);
      } else {
        _selecionados.add(id);
      }
    });
  }

  void _confirmar() {
    final escolhidas = _controller.receitas
        .where((r) => _selecionados.contains(r.id))
        .toList();
    Navigator.pop(context, escolhidas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar receitas'),
        actions: [
          TextButton(
            onPressed: _selecionados.isEmpty ? null : _confirmar,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(
              _selecionados.isEmpty
                  ? 'Adicionar'
                  : 'Adicionar (${_selecionados.length})',
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }
          final receitas = _controller.receitas;
          if (receitas.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma receita disponivel.',
                style: TextStyle(color: Cores.textoCinza),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(Espacos.padPadrao),
            itemCount: receitas.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final receita = receitas[index];
              final marcada = _selecionados.contains(receita.id);
              return InkWell(
                onTap: () => _alternar(receita.id),
                borderRadius: BorderRadius.circular(Espacos.raioCard),
                child: Container(
                  decoration: BoxDecoration(
                    color: marcada ? Cores.fundoSuave : Colors.white,
                    borderRadius: BorderRadius.circular(Espacos.raioCard),
                    border: Border.all(
                      color: marcada ? Cores.primaria : Colors.grey.shade300,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: ImagemReceita(
                            url: receita.imagemUrl,
                            raio: 0,
                            tamanhoIcone: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              receita.nome,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Cores.textoEscuro,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${receita.ingredientes.length} ingredientes',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Cores.textoCinza,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: marcada,
                        onChanged: (_) => _alternar(receita.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
