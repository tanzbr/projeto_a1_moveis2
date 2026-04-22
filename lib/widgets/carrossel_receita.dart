import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../theme/cores.dart';
import 'imagem_receita.dart';

class CarrosselReceita extends StatefulWidget {
  final List<Receita> receitas;
  final void Function(Receita) onReceitaTap;

  const CarrosselReceita({
    super.key,
    required this.receitas,
    required this.onReceitaTap,
  });

  @override
  State<CarrosselReceita> createState() => _CarrosselReceitaState();
}

class _CarrosselReceitaState extends State<CarrosselReceita> {
  // viewportFraction < 1 deixa o card vizinho aparecer "espiando" na lateral
  final PageController _controller = PageController(viewportFraction: 0.8);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      // PageView.builder constrói os cards sob demanda (lazy)
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: widget.receitas.length,
        itemBuilder: (context, index) {
          final receita = widget.receitas[index];
          return GestureDetector(
            onTap: () => widget.onReceitaTap(receita),
            child: Container(
              // primeiro card precisa de margem maior p/ alinhar com o resto da tela
              margin: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
              decoration: BoxDecoration(
                color: Cores.primaria,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3)),
                ],
              ),
              // Stack empilha imagem + degradê + texto p/ legibilidade
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ImagemReceita(
                      url: receita.imagemUrl,
                      raio: 16,
                      tamanhoIcone: 60,
                    ),
                  ),
                  // degradê escuro embaixo p/ o texto branco contrastar
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receita.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.timer,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${receita.tempoMinutos} min',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.people,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${receita.porcoes} porções',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
