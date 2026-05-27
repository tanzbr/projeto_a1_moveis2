import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/avaliacao_controller.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import '../views/auth_gate.dart';

// 5 estrelas clicaveis + texto com a media e o total.
// Pinta filled ate a nota do usuario (ou nenhuma se ele ainda nao avaliou);
// se nao houver login, oferece atalho para entrar antes de avaliar.
class AvaliacaoReceitaWidget extends StatelessWidget {
  final int receitaId;
  final AvaliacaoController controller;

  const AvaliacaoReceitaWidget({
    super.key,
    required this.receitaId,
    required this.controller,
  });

  Future<void> _tocar(BuildContext context, int nota) async {
    if (!AuthController.instance.estaLogado) {
      final autenticado = await exigirLogin(context);
      if (!autenticado) return;
    }
    await controller.avaliar(receitaId, nota);
  }

  String _textoResumo() {
    if (controller.total == 0) return 'Sem avaliacoes';
    final media = controller.media.toStringAsFixed(1);
    final sufixo = controller.total == 1 ? 'avaliacao' : 'avaliacoes';
    return 'Media $media · ${controller.total} $sufixo';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, AuthController.instance]),
      builder: (context, _) {
        // referencia visual: nota do usuario se houver, senao a media arredondada
        final notaReferencia = controller.notaUsuario ?? controller.media.round();

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Cores.fundoSuave,
            borderRadius: BorderRadius.circular(Espacos.raioCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sua avaliacao',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Cores.textoEscuro,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  final estaPreenchida = i < notaReferencia;
                  return IconButton(
                    iconSize: 30,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    icon: Icon(
                      estaPreenchida ? Icons.star : Icons.star_border,
                      color: Cores.primariaEscura,
                    ),
                    onPressed: controller.carregando
                        ? null
                        : () => _tocar(context, i + 1),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _textoResumo(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Cores.textoCinza,
                      ),
                    ),
                  ),
                  // botao discreto para tirar a nota dada
                  if (controller.notaUsuario != null)
                    TextButton(
                      onPressed: () => controller.remover(receitaId),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('Limpar nota'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
