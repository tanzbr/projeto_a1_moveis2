import 'package:flutter/material.dart';
import '../models/receita.dart';

class CardReceita extends StatelessWidget {
  final Receita receita;
  final VoidCallback onTap;

  const CardReceita({super.key, required this.receita, required this.onTap});

  Widget _buildImagem(String url) {
    if (url.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.restaurant, size: 40, color: Colors.grey),
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
            child: Icon(Icons.restaurant, size: 40, color: Colors.grey),
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
          child: Icon(Icons.restaurant, size: 40, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'receita-imagem-${receita.id}',
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: _buildImagem(receita.imagemUrl),
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
                      color: Color.fromARGB(255, 45, 45, 45),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer,
                          size: 13,
                          color: Color.fromARGB(255, 117, 117, 117)),
                      const SizedBox(width: 2),
                      Text(
                        '${receita.tempoMinutos} min',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color.fromARGB(255, 117, 117, 117)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.people,
                          size: 13,
                          color: Color.fromARGB(255, 117, 117, 117)),
                      const SizedBox(width: 2),
                      Text(
                        '${receita.porcoes}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color.fromARGB(255, 117, 117, 117)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 13,
                          color: Color.fromARGB(255, 155, 142, 193)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          receita.dificuldade,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color.fromARGB(255, 155, 142, 193)),
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
                      color: const Color.fromARGB(255, 213, 204, 230),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      receita.categoria,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color.fromARGB(255, 107, 91, 149),
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
