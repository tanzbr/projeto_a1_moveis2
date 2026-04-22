import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../theme/cores.dart';
import '../theme/espacos.dart';
import 'imagem_receita.dart';

// card vertical usado no GridView da Explorar
class CardReceita extends StatelessWidget {
  final Receita receita;
  final VoidCallback onTap;

  const CardReceita({super.key, required this.receita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // InkWell garante o efeito ripple ao tocar (em vez de Container puro)
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Espacos.raioCard),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Espacos.raioCard),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // mesmo tag da DetalhesScreen, animação Hero da imagem
            Hero(
              tag: 'receita-imagem-${receita.id}',
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: ImagemReceita(
                    url: receita.imagemUrl,
                    raio: 0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receita.nome,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Cores.textoEscuro,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer,
                          size: 13,
                          color: Cores.textoCinza),
                      const SizedBox(width: 2),
                      Text(
                        '${receita.tempoMinutos} min',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Cores.textoCinza),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.people,
                          size: 13,
                          color: Cores.textoCinza),
                      const SizedBox(width: 2),
                      Text(
                        '${receita.porcoes}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Cores.textoCinza),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 13,
                          color: Cores.primaria),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          receita.dificuldade,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Cores.primaria),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Cores.primariaClara,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      receita.categoria,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Cores.primariaEscura,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
