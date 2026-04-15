import 'package:flutter/material.dart';
import '../models/receita.dart';

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
  final PageController _controller = PageController(viewportFraction: 0.8);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _imagemFundo(Receita receita) {
    final url = receita.imagemUrl;
    ImageProvider? provider;
    if (isAssetImage(url)) {
      provider = AssetImage(url);
    } else if (isBase64Image(url)) {
      final bytes = base64ToBytes(url);
      if (bytes != null) provider = MemoryImage(bytes);
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        image: provider != null
            ? DecorationImage(image: provider, fit: BoxFit.cover)
            : null,
      ),
      child: provider == null
          ? const Center(
              child: Icon(Icons.restaurant, size: 60, color: Colors.grey))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: widget.receitas.length,
        itemBuilder: (context, index) {
          final receita = widget.receitas[index];
          return GestureDetector(
            onTap: () => widget.onReceitaTap(receita),
            child: Container(
              margin: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 155, 142, 193),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Stack(
                children: [
                  _imagemFundo(receita),
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
