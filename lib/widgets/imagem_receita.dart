import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../theme/espacos.dart';

class ImagemReceita extends StatelessWidget {
  final String url;
  final double? largura;
  final double? altura;
  final double raio;
  final BoxFit fit;
  final IconData iconePlaceholder;
  final double tamanhoIcone;
  final String? heroTag;

  const ImagemReceita({
    super.key,
    required this.url,
    this.largura,
    this.altura,
    this.raio = Espacos.raioCard,
    this.fit = BoxFit.cover,
    this.iconePlaceholder = Icons.restaurant,
    this.tamanhoIcone = 30,
    this.heroTag,
  });

  Widget _placeholder() {
    return Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Icon(iconePlaceholder, size: tamanhoIcone, color: Colors.grey),
    );
  }

  Widget _conteudo() {
    if (url.isEmpty) return _placeholder();
    if (isAssetImage(url)) {
      return Image.asset(url, fit: fit);
    }
    if (isBase64Image(url)) {
      final bytes = base64ToBytes(url);
      if (bytes == null) return _placeholder();
      return Image.memory(bytes, fit: fit);
    }
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget filho = ClipRRect(
      borderRadius: BorderRadius.circular(raio),
      child: SizedBox(
        width: largura,
        height: altura,
        child: _conteudo(),
      ),
    );

    if (heroTag != null) {
      filho = Hero(tag: heroTag!, child: filho);
    }
    return filho;
  }
}
